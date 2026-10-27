#include "Page.h"

#include "Bridge.h"
#include "Layout.h"
#include "Ui.h"

// Render runs inside the framework's callback for the page, on its render
// thread; OnMenuClosed and OnVmReset come from the game thread. g_lock keeps
// them apart. ImGui only through Ui.h; every script call through Bridge.

namespace Page
{
	namespace
	{
		constexpr double kLivePush = 0.15;     // seconds between writes while a live slider is dragged
		constexpr double kConfirmAfter = 1.5;  // seconds after a write before the layout is read back
		constexpr double kReopenGap = 1.0;     // no frame drawn for this long: the page was left and came back
		constexpr float  kAnswerTimeout = 6.0f;

		// iwant_status_bars' bar types, in statusBarTypeIndex order
		constexpr std::array<const char*, Layout::kOrientations> kOrientations{
			"Left", "Right", "Up", "Down", "Circle", "Orbit", "Lower half circle", "Upper half circle", "Left half circle", "Right half circle"
		};

		// One slider's write state
		struct Row
		{
			bool   wasActive = false;
			int    pushed = 0;  // the value last written, or read
			double pushedAt = 0.0;
		};

		std::mutex    g_lock;
		Layout::Model g_model;
		bool          g_haveModel = false;
		std::string   g_status;
		bool          g_statusIsError = false;
		double        g_lastFrame = 0.0;
		double        g_confirmAt = 0.0;  // read the layout back at this time; 0 = nothing owed
		bool          g_anyActive = false;  // a slider was held in the last frame drawn
		bool          g_confirmReset = false;
		bool          g_loggedFault = false;

		std::array<std::array<Row, 3>, Layout::kBars> g_barRows;  // x, y, size
		std::array<Row, 3>                            g_npcRows;  // x, y, spacing
		std::array<Row, 3>                            g_metersRows;  // x, y, scale

		const Ui::ImVec4 kWarn{ 1.0f, 0.5f, 0.4f, 1.0f };
		const Ui::ImVec4 kHint{ 0.7f, 0.7f, 0.7f, 1.0f };
		const Ui::ImVec4 kOk{ 0.6f, 0.9f, 0.6f, 1.0f };

		void SetStatus(std::string a_text, bool a_error)
		{
			g_status = std::move(a_text);
			g_statusIsError = a_error;
		}

		void Colored(const Ui::ImVec4& a_color, const char* a_text)
		{
			Ui::PushStyleColor(Ui::ImGuiCol_Text, a_color);
			Ui::TextUnformatted(a_text);
			Ui::PopStyleColor(1);
		}

		// After a read nothing is owed: every slider's last written value is the one shown
		void SyncRows()
		{
			for (int bar = 0; bar < Layout::kBars; ++bar) {
				const auto& b = g_model.bars[static_cast<std::size_t>(bar)];
				auto&       rows = g_barRows[static_cast<std::size_t>(bar)];
				rows[0].pushed = b.x;
				rows[1].pushed = b.y;
				rows[2].pushed = b.size;
			}
			g_npcRows[0].pushed = g_model.npc.x;
			g_npcRows[1].pushed = g_model.npc.y;
			g_npcRows[2].pushed = g_model.npc.stride;
			g_metersRows[0].pushed = g_model.meters.x;
			g_metersRows[1].pushed = g_model.meters.y;
			g_metersRows[2].pushed = g_model.meters.scale;
		}

		void TakeAnswer(double a_now)
		{
			std::string layout, error;
			if (!Bridge::Take(layout, error)) {
				if (Bridge::Pending() && Bridge::PendingSeconds() > kAnswerTimeout) {
					SetStatus(std::format("SL Widgets has not answered for {:.0f} s. Is the mod enabled, with a game loaded? Refresh asks again.", Bridge::PendingSeconds()), true);
				}
				return;
			}
			if (!error.empty()) {
				SetStatus(error, true);
				return;
			}
			if (layout.empty()) {
				SetStatus("SL Widgets is not running: load a game, let iWant Status Bars come up, then Refresh.", true);
				return;
			}
			if (g_anyActive) {
				// a slider is held: the answer would put the game's value under the
				// hand that is moving it; read again once it is released
				g_confirmAt = a_now + kConfirmAfter;
				return;
			}
			Layout::Model parsed = g_model;
			std::string   why;
			if (!Layout::Parse(layout, parsed, why)) {
				SetStatus(why, true);
				return;
			}
			g_model = parsed;
			g_haveModel = true;
			SyncRows();
			SetStatus("Layout read.", false);
		}

		// A slider. True when its value is to be written now: while held and
		// a_live, every kLivePush; otherwise once, on release with a new value.
		bool Slider(const char* a_label, int& a_value, int a_min, int a_max, Row& a_row, bool a_live, double a_now)
		{
			Ui::SetNextItemWidth(Ui::GetFontSize() * 9.0f);
			Ui::SliderInt(a_label, &a_value, a_min, a_max, "%d", Ui::ImGuiSliderFlags_AlwaysClamp);
			const bool active = Ui::IsItemActive();
			g_anyActive = g_anyActive || active;
			bool send = false;
			if (active) {
				send = a_live && a_value != a_row.pushed && a_now - a_row.pushedAt >= kLivePush;
			} else if (a_row.wasActive) {
				send = a_value != a_row.pushed;
			}
			a_row.wasActive = active;
			if (send) {
				a_row.pushed = a_value;
				a_row.pushedAt = a_now;
				g_confirmAt = a_now + kConfirmAfter;
			}
			return send;
		}

		// What a row owes when no frame will follow (the menu closed mid-drag)
		bool Owed(const Row& a_row, int a_value)
		{
			return a_row.wasActive && a_value != a_row.pushed;
		}

		bool Orientation(int& a_type, double a_now)
		{
			bool      changed = false;
			const int shown = Layout::Clamp(a_type, 0, Layout::kOrientations - 1);
			Ui::SetNextItemWidth(Ui::GetFontSize() * 9.0f);
			if (Ui::BeginCombo("Orientation", kOrientations[static_cast<std::size_t>(shown)], 0)) {
				for (int i = 0; i < Layout::kOrientations; ++i) {
					if (Ui::Selectable(kOrientations[static_cast<std::size_t>(i)], i == shown, 0, { 0.0f, 0.0f }) && i != a_type) {
						a_type = i;
						changed = true;
					}
				}
				Ui::EndCombo();
			}
			if (changed) {
				g_confirmAt = a_now + kConfirmAfter;
			}
			return changed;
		}

		void DrawBars(double a_now)
		{
			Colored(kHint, "Player bars: iWant's shared bars, so every mod's icons in a bar move with it");
			for (int bar = 0; bar < Layout::kPlayerBars; ++bar) {
				auto& b = g_model.bars[static_cast<std::size_t>(bar)];
				auto& rows = g_barRows[static_cast<std::size_t>(bar)];
				Ui::PushID(bar);
				std::string title = std::format("Bar {}", bar);
				if (!b.visible) {
					title += "   (hidden by iWant right now)";
				}
				Ui::TextUnformatted(title.c_str());
				bool pos = Slider("X", b.x, Layout::kMinX, Layout::kMaxX, rows[0], true, a_now);
				Ui::SameLine();
				pos = Slider("Y", b.y, Layout::kMinY, Layout::kMaxY, rows[1], true, a_now) || pos;
				if (pos) {
					Bridge::SetBarPos(bar, b.x, b.y);
				}
				if (Slider("Size", b.size, Layout::kMinBarSize, Layout::kMaxBarSize, rows[2], false, a_now)) {
					Bridge::SetBarSize(bar, b.size);
				}
				Ui::SameLine();
				if (Orientation(b.type, a_now)) {
					Bridge::SetBarType(bar, b.type);
				}
				Ui::PopID();
				Ui::Spacing();
			}
		}

		void DrawNpc(double a_now)
		{
			auto& npc = g_model.npc;
			Ui::PushID(100);
			Ui::TextUnformatted("NPC slots");
			std::string who;
			for (int slot = 1; slot <= Layout::kNpcSlots; ++slot) {
				const auto& name = npc.names[static_cast<std::size_t>(slot - 1)];
				who += std::format("{}NPC {}: {}", slot > 1 ? "   " : "", slot, name.empty() ? "empty" : name);
			}
			Colored(kHint, who.c_str());
			bool pos = Slider("X", npc.x, Layout::kMinX, Layout::kMaxX, g_npcRows[0], false, a_now);
			Ui::SameLine();
			pos = Slider("Y", npc.y, Layout::kMinY, Layout::kMaxY, g_npcRows[1], false, a_now) || pos;
			if (pos) {
				Bridge::SetNpcGroup(npc.x, npc.y);
			}
			if (Slider("Spacing", npc.stride, Layout::kMinNpcSpacing, Layout::kMaxNpcSpacing, g_npcRows[2], false, a_now)) {
				Bridge::SetNpcSpacing(npc.stride);
			}
			Ui::SameLine();
			if (!g_confirmReset) {
				if (Ui::SmallButton("Reset NPC layout")) {
					g_confirmReset = true;
				}
			} else {
				Ui::TextUnformatted("Back to the default corner?");
				Ui::SameLine();
				if (Ui::SmallButton("Yes")) {
					g_confirmReset = false;
					Bridge::ResetNpcLayout();
					g_confirmAt = a_now + kConfirmAfter;
				}
				Ui::SameLine();
				if (Ui::SmallButton("No")) {
					g_confirmReset = false;
				}
			}
			Ui::PopID();
		}

		void DrawMeters(double a_now)
		{
			auto& m = g_model.meters;
			Ui::PushID(200);
			Ui::TextUnformatted("Meter stack");
			Colored(kHint, m.rows > 0 ? std::format("{} switched on; the stack rebuilds a moment after a change and shows itself for 30 s", m.rows).c_str() :
			                            "none switched on: switch a meter on in the MCM to see the stack");
			bool any = Slider("X", m.x, Layout::kMinX, Layout::kMaxX, g_metersRows[0], false, a_now);
			Ui::SameLine();
			any = Slider("Y", m.y, Layout::kMinY, Layout::kMaxMetersY, g_metersRows[1], false, a_now) || any;
			any = Slider("Scale %", m.scale, Layout::kMinMetersScale, Layout::kMaxMetersScale, g_metersRows[2], false, a_now) || any;
			if (any) {
				Bridge::SetMeters(m.x, m.y, m.scale);
			}
			Ui::PopID();
		}

		void Flush()
		{
			for (int bar = 0; bar < Layout::kPlayerBars; ++bar) {
				const auto& b = g_model.bars[static_cast<std::size_t>(bar)];
				auto&       rows = g_barRows[static_cast<std::size_t>(bar)];
				if (Owed(rows[0], b.x) || Owed(rows[1], b.y)) {
					Bridge::SetBarPos(bar, b.x, b.y);
					rows[0].pushed = b.x;
					rows[1].pushed = b.y;
				}
				if (Owed(rows[2], b.size)) {
					Bridge::SetBarSize(bar, b.size);
					rows[2].pushed = b.size;
				}
			}
			const auto& npc = g_model.npc;
			if (Owed(g_npcRows[0], npc.x) || Owed(g_npcRows[1], npc.y)) {
				Bridge::SetNpcGroup(npc.x, npc.y);
				g_npcRows[0].pushed = npc.x;
				g_npcRows[1].pushed = npc.y;
			}
			if (Owed(g_npcRows[2], npc.stride)) {
				Bridge::SetNpcSpacing(npc.stride);
				g_npcRows[2].pushed = npc.stride;
			}
			const auto& m = g_model.meters;
			if (Owed(g_metersRows[0], m.x) || Owed(g_metersRows[1], m.y) || Owed(g_metersRows[2], m.scale)) {
				Bridge::SetMeters(m.x, m.y, m.scale);
				g_metersRows[0].pushed = m.x;
				g_metersRows[1].pushed = m.y;
				g_metersRows[2].pushed = m.scale;
			}
			for (auto& rows : g_barRows) {
				for (auto& row : rows) {
					row.wasActive = false;
				}
			}
			for (auto& row : g_npcRows) {
				row.wasActive = false;
			}
			for (auto& row : g_metersRows) {
				row.wasActive = false;
			}
			g_anyActive = false;
		}
	}

	void Render()
	{
		try {
			std::scoped_lock lock{ g_lock };
			const double     now = Ui::GetTime();
			if (now - g_lastFrame > kReopenGap) {
				// the page just came up (or came back): what the game holds may have
				// changed in the MCMs meanwhile
				g_haveModel = false;
				g_confirmReset = false;
				SetStatus("Reading the layout...", false);
				Bridge::RequestLayout(true);
			}
			g_lastFrame = now;
			TakeAnswer(now);
			g_anyActive = false;

			Colored(g_statusIsError ? kWarn : kOk, g_status.c_str());
			Ui::SameLine();
			if (Ui::SmallButton("Refresh")) {
				SetStatus("Reading the layout...", false);
				Bridge::RequestLayout(true);
			}
			Ui::Separator();

			if (g_haveModel) {
				DrawBars(now);
				Ui::Separator();
				DrawNpc(now);
				Ui::Separator();
				DrawMeters(now);
				Ui::Separator();
			}

			Colored(kHint, "Values are iWant's 1280 x 720 stage units, written into the game at once: the icons move while this menu is open.");
			Colored(kHint, "X and Y of a bar follow the slider. Size, orientation, the NPC cluster and the meters apply when the slider is released.");

			if (g_confirmAt > 0.0 && now >= g_confirmAt && !g_anyActive) {
				g_confirmAt = 0.0;
				Bridge::RequestLayout(false);
			}
		} catch (const std::exception& e) {
			if (!g_loggedFault) {
				g_loggedFault = true;
				logger::error("positions page failed: {}", e.what());
			}
		} catch (...) {
			if (!g_loggedFault) {
				g_loggedFault = true;
				logger::error("positions page failed");
			}
		}
	}

	void OnMenuClosed()
	{
		std::scoped_lock lock{ g_lock };
		if (g_haveModel) {
			Flush();
		}
		g_lastFrame = 0.0;  // the next frame is a fresh page
	}

	void OnVmReset()
	{
		std::scoped_lock lock{ g_lock };
		g_haveModel = false;
		g_status.clear();
		g_statusIsError = false;
		g_confirmAt = 0.0;
		g_lastFrame = 0.0;
	}
}
