#include "PositionsPage.h"

#include "Bridge.h"
#include "Layout.h"
#include "PageCommon.h"

// Render runs inside the framework's callback for the page, on its render
// thread; OnMenuClosed and OnVmReset come from the game thread. g_lock keeps
// them apart. ImGui only through Ui.h; every script call through Bridge.

namespace Positions
{
	namespace
	{
		using PageCommon::Colored;
		using PageCommon::kHint;

		constexpr double kLivePush = 0.15;     // seconds between writes while a live slider is dragged
		constexpr double kConfirmAfter = 1.5;  // seconds after a write before the layout is read back

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

		std::mutex            g_lock;
		PageCommon::PageState g_page{ Bridge::Query::Layout, "layout", "SL Widgets is not running: load a game, let iWant Status Bars come up, then Refresh." };
		Layout::Model         g_model;
		bool                  g_haveModel = false;
		bool                  g_anyActive = false;  // a slider was held in the last frame drawn
		// The bars' icons come on their own read, asked for only while an Icons
		// list is open: listing them costs a call into iWant per seat
		bool                  g_iconsOpen = false;    // an Icons list was open in the frame being drawn
		bool                  g_iconsWanted = false;  // a list was open in the last frame, and its read asked for
		bool                  g_iconsHave = false;
		double                g_iconsConfirmAt = 0.0;
		bool          g_confirmReset = false;
		bool          g_loggedFault = false;

		std::array<std::array<Row, 3>, Layout::kBars> g_barRows;  // x, y, size
		std::array<Row, 3>                            g_npcRows;  // x, y, spacing
		std::array<Row, 3>                            g_metersRows;  // x, y, scale
		Row                                           g_spacingRow;  // iWant's icon step

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
			g_spacingRow.pushed = g_model.iconSpacing;
		}

		void TakeAnswer(double a_now)
		{
			std::string layout;
			if (!g_page.Take(layout)) {
				return;
			}
			if (g_anyActive) {
				// a slider is held: the answer would put the game's value under the
				// hand that is moving it; read again once it is released
				g_page.ConfirmAt(a_now + kConfirmAfter);
				return;
			}
			Layout::Model parsed = g_model;
			std::string   why;
			if (!Layout::Parse(layout, parsed, why)) {
				g_page.SetStatus(why, true);
				return;
			}
			g_model = parsed;
			g_haveModel = true;
			SyncRows();
			g_page.SetStatus("Layout read.", false);
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
				g_page.ConfirmAt(a_now + kConfirmAfter);
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
				g_page.ConfirmAt(a_now + kConfirmAfter);
			}
			return changed;
		}

		// A move picked in an icon list, made once the lists are drawn
		struct Move
		{
			int  bar = -1;
			int  index = -1;  // in that bar's icons
			int  dir = 0;     // -1 / 1 within the bar, or 0 with a target bar
			int  target = -1;
		};

		// The bar's icons in draw order, each with its moves. iWant puts an icon back
		// in the first free seat when it is loaded again, so the list says so.
		void DrawIcons(int a_bar, std::optional<Move>& a_move)
		{
			const auto& icons = g_model.bars[static_cast<std::size_t>(a_bar)].icons;
			const std::string header = std::format("Icons ({})###icons", icons.size());
			if (!Ui::CollapsingHeader(header.c_str(), 0)) {
				return;
			}
			g_iconsOpen = true;
			if (!g_iconsHave) {
				Colored(kHint, "Reading the icons...");
				return;
			}
			if (icons.empty()) {
				Colored(kHint, "No icon in this bar.");
				return;
			}
			for (std::size_t i = 0; i < icons.size(); ++i) {
				PageCommon::IdScope id{ 1000 + static_cast<int>(i) };
				const int           index = static_cast<int>(i);
				{
					PageCommon::DisabledScope first{ i == 0 };
					if (Ui::SmallButton("^")) {
						a_move = Move{ a_bar, index, -1, -1 };
					}
				}
				Ui::SameLine(0.0f, -1.0f);
				{
					PageCommon::DisabledScope last{ i + 1 == icons.size() };
					if (Ui::SmallButton("v")) {
						a_move = Move{ a_bar, index, 1, -1 };
					}
				}
				for (int target = 0; target < Layout::kPlayerBars; ++target) {
					if (target == a_bar) {
						continue;
					}
					Ui::SameLine(0.0f, -1.0f);
					PageCommon::DisabledScope full{ g_model.bars[static_cast<std::size_t>(target)].icons.size() >= static_cast<std::size_t>(Layout::kIconsPerBar) };
					if (Ui::SmallButton(std::format("to {}", target).c_str())) {
						a_move = Move{ a_bar, index, 0, target };
					}
				}
				Ui::SameLine(0.0f, -1.0f);
				Ui::TextUnformatted(icons[i].label.c_str());
			}
			Colored(kHint, "A moved icon goes back to the first free seat when it is loaded again: switched off and on, a preset loaded, the mod enabled, or an icon that comes and goes with its state.");
		}

		// Sends the move and shows it at once; the read that follows corrects the guess
		void MakeMove(const Move& a_move, double a_now)
		{
			auto&       icons = g_model.bars[static_cast<std::size_t>(a_move.bar)].icons;
			const auto  i = static_cast<std::size_t>(a_move.index);
			if (i >= icons.size()) {
				return;
			}
			const auto icon = icons[i];
			if (a_move.dir != 0) {
				const auto j = a_move.dir < 0 ? i - 1 : i + 1;
				if (a_move.dir < 0 ? i == 0 : j >= icons.size()) {
					return;
				}
				Bridge::MoveIconInBar(a_move.bar, icon.seat, icon.id, a_move.dir);
				std::swap(icons[i].id, icons[j].id);
				std::swap(icons[i].label, icons[j].label);
			} else {
				auto& to = g_model.bars[static_cast<std::size_t>(a_move.target)].icons;
				Bridge::MoveIconToBar(a_move.bar, icon.seat, icon.id, a_move.target);
				icons.erase(icons.begin() + static_cast<std::ptrdiff_t>(i));
				to.push_back(icon);  // the seat is a guess until the read
			}
			g_iconsConfirmAt = a_now + kConfirmAfter;
		}

		// The icon lists' own read: when a list opens, after a move, and its answer
		void ServeIcons(double a_now)
		{
			std::string text, error;
			if (Bridge::Take(Bridge::Query::BarIcons, text, error)) {
				std::string why;
				if (error.empty() && !text.empty() && Layout::ParseIcons(text, g_model, why)) {
					g_iconsHave = true;
				} else if (!why.empty() || !error.empty()) {
					g_page.SetStatus(why.empty() ? error : why, true);
				}
			}
			if (!g_iconsOpen) {
				g_iconsWanted = false;
				return;
			}
			if (!g_iconsWanted) {
				g_iconsWanted = true;
				Bridge::Request(Bridge::Query::BarIcons, true);
			} else if (g_iconsConfirmAt > 0.0 && a_now >= g_iconsConfirmAt) {
				g_iconsConfirmAt = 0.0;
				if (!Bridge::Request(Bridge::Query::BarIcons, false)) {
					g_iconsConfirmAt = a_now + 1.0;  // one still out: ask again after it
				}
			}
		}

		// iWant's icon step: one value for every line bar, every mod's. It is iWant's
		// own state, saved with its script, like the bars' positions.
		void DrawSpacing(double a_now)
		{
			auto&               spacing = g_model.iconSpacing;
			PageCommon::IdScope id{ 300 };
			Ui::TextUnformatted("Icon spacing");
			if (spacing == 0) {
				Colored(kHint, "This iWant Status Bars build keeps its icon step where SL Widgets cannot reach it.");
				return;
			}
			if (Slider("Spacing %", spacing, Layout::kMinIconSpacing, Layout::kMaxIconSpacing, g_spacingRow, false, a_now)) {
				Bridge::SetIconSpacing(spacing);
			}
			Ui::SameLine();
			{
				PageCommon::DisabledScope same{ spacing == Layout::kDefaultIconSpacing };
				if (Ui::SmallButton("iWant default")) {
					spacing = Layout::kDefaultIconSpacing;
					g_spacingRow.pushed = spacing;
					Bridge::SetIconSpacing(spacing);
					g_page.ConfirmAt(a_now + kConfirmAfter);
				}
			}
			Colored(kHint, "From one icon to the next, in % of the icon size: 150 is iWant's own, 100 puts the icons edge to edge.");
			Colored(kHint, "It is iWant's one value for every line bar, every mod's and the NPC bars too. Circles and half circles keep their shape.");
		}

		void DrawBars(double a_now)
		{
			Colored(kHint, "Player bars: iWant's shared bars, so every mod's icons in a bar move with it");
			std::optional<Move> move;
			for (int bar = 0; bar < Layout::kPlayerBars; ++bar) {
				auto& b = g_model.bars[static_cast<std::size_t>(bar)];
				auto& rows = g_barRows[static_cast<std::size_t>(bar)];
				PageCommon::IdScope id{ bar };
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
				DrawIcons(bar, move);
				Ui::Spacing();
			}
			if (move) {
				MakeMove(*move, a_now);
			}
		}

		void DrawNpc(double a_now)
		{
			auto& npc = g_model.npc;
			PageCommon::IdScope id{ 100 };
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
					g_page.ConfirmAt(a_now + kConfirmAfter);
				}
				Ui::SameLine();
				if (Ui::SmallButton("No")) {
					g_confirmReset = false;
				}
			}
		}

		void DrawMeters(double a_now)
		{
			auto& m = g_model.meters;
			PageCommon::IdScope id{ 200 };
			Ui::TextUnformatted("Meter stack");
			Colored(kHint, m.rows > 0 ? std::format("{} switched on; the stack rebuilds a moment after a change and shows itself for 30 s", m.rows).c_str() :
			                            "none switched on: switch a meter on on the Meters page to see the stack");
			bool any = Slider("X", m.x, Layout::kMinX, Layout::kMaxX, g_metersRows[0], false, a_now);
			Ui::SameLine();
			any = Slider("Y", m.y, Layout::kMinY, Layout::kMaxMetersY, g_metersRows[1], false, a_now) || any;
			any = Slider("Scale %", m.scale, Layout::kMinMetersScale, Layout::kMaxMetersScale, g_metersRows[2], false, a_now) || any;
			if (any) {
				Bridge::SetMeters(m.x, m.y, m.scale);
			}
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
			if (g_model.iconSpacing > 0 && Owed(g_spacingRow, g_model.iconSpacing)) {
				Bridge::SetIconSpacing(g_model.iconSpacing);
				g_spacingRow.pushed = g_model.iconSpacing;
			}
			g_spacingRow.wasActive = false;
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
			if (g_page.BeginFrame(now)) {
				g_iconsWanted = false;  // a list left open is read again
				g_iconsHave = false;
				// the page just came up (or came back): what the game holds may have
				// changed in iWant's menu or through a preset meanwhile
				g_haveModel = false;
				g_confirmReset = false;
			}
			TakeAnswer(now);
			g_anyActive = false;

			g_page.DrawStatusLine(now);
			Ui::Separator();

			if (g_haveModel) {
				if (g_model.iconSpacing >= 0) {  // -1: scripts from before 3.4.1
					DrawSpacing(now);
					Ui::Separator();
				}
				DrawBars(now);
				Ui::Separator();
				DrawNpc(now);
				Ui::Separator();
				DrawMeters(now);
				Ui::Separator();
			}

			Colored(kHint, "Values are iWant's 1280 x 720 stage units, written into the game at once: the icons move while this menu is open.");
			Colored(kHint, "X and Y of a bar follow the slider. Size, orientation, icon spacing, the NPC cluster and the meters apply when the slider is released.");

			ServeIcons(now);
			g_iconsOpen = false;
			g_page.ServeConfirm(now, g_anyActive);
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
		g_page.ForgetFrame();
	}

	void OnVmReset()
	{
		std::scoped_lock lock{ g_lock };
		g_haveModel = false;
		g_iconsHave = false;
		g_iconsWanted = false;
		g_iconsConfirmAt = 0.0;
		g_page.Reset();
	}
}
