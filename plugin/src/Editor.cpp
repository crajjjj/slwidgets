#include "Editor.h"

#include "Bridge.h"
#include "Env.h"
#include "Layout.h"
#include "Ui.h"

// Render runs inside a callback SKSE Menu Framework invoked, on its render thread.
// It touches the model under g_lock, ImGui through Ui.h, and the game only for
// the screen size; every script call goes through Bridge, onto the SKSE task queue.

namespace Editor
{
	namespace
	{
		constexpr float  kAnswerTimeout = 6.0f;  // seconds without an answer before the toolbar says so
		constexpr double kNudgeSettle = 0.3;     // seconds after the last arrow key before the move is sent
		constexpr double kConfirmAfter = 1.5;    // seconds after a write before the layout is read back
		constexpr int    kSnapStep = 10;
		constexpr int    kMetersMaxY = 719;  // the MCM's slider, which must still be able to show the value

		enum class Kind
		{
			None,
			Bar,       // a player bar, 0-3
			NpcGroup,  // the NPC slots' bars, moved by their anchor
			Meters
		};

		struct Handle
		{
			Kind kind = Kind::None;
			int  index = 0;

			bool operator==(const Handle&) const = default;
		};

		// Stage units (iWant's 1280x720) to screen pixels: the Flash stage is scaled
		// by height and centered, which the Prisma renderer reproduces too
		struct Mapper
		{
			float scale = 1.0f;
			float ox = 0.0f;

			Ui::ImVec2 ToScreen(float a_x, float a_y) const { return { ox + a_x * scale, a_y * scale }; }
			Ui::ImVec2 ToScreen(const Ui::ImVec2& a_p) const { return ToScreen(a_p.x, a_p.y); }
		};

		SKSEMenuFramework::Model::WindowInterface* g_window = nullptr;

		std::mutex    g_lock;  // the model and the status are written on the render thread and reset from the game thread
		Layout::Model g_model;
		bool          g_haveModel = false;
		std::string   g_status;
		bool          g_statusIsError = false;

		// render thread only
		Handle     g_selected;
		Handle     g_hovered;
		bool       g_dragging = false;
		Ui::ImVec2 g_dragStart{};
		int        g_dx = 0;  // the move not yet sent: a drag in progress, or arrow keys settling
		int        g_dy = 0;
		double     g_nudgeAt = 0.0;
		bool       g_snap = false;
		bool       g_confirmReset = false;
		double     g_confirmAt = 0.0;  // read the layout back at this time; 0 = nothing owed
		bool       g_focusToolbar = false;
		bool       g_loggedFault = false;
		std::unordered_map<std::string, Ui::ImTextureID> g_textures;  // Interface\exported path -> texture; 0 = could not load

		const Ui::ImVec4 kWarn{ 1.0f, 0.5f, 0.4f, 1.0f };
		const Ui::ImVec4 kHint{ 0.7f, 0.7f, 0.7f, 1.0f };
		const Ui::ImVec4 kOk{ 0.6f, 0.9f, 0.6f, 1.0f };

		constexpr Ui::ImU32 Col(unsigned a_r, unsigned a_g, unsigned a_b, unsigned a_a)
		{
			return (a_a << 24) | (a_b << 16) | (a_g << 8) | a_r;
		}

		constexpr Ui::ImU32 kWhite = Col(255, 255, 255, 255);
		constexpr Ui::ImU32 kStageLine = Col(255, 255, 255, 60);
		constexpr Ui::ImU32 kLabel = Col(255, 255, 255, 220);
		constexpr Ui::ImU32 kLabelShadow = Col(0, 0, 0, 200);

		struct Look
		{
			Ui::ImU32 fill;
			Ui::ImU32 line;
		};

		Look LookOf(Kind a_kind, bool a_visible, bool a_selected, bool a_hovered)
		{
			unsigned r = 90, g = 160, b = 255;  // player bars
			if (a_kind == Kind::NpcGroup) {
				r = 110, g = 230, b = 130;
			} else if (a_kind == Kind::Meters) {
				r = 255, g = 190, b = 90;
			}
			const unsigned fillA = a_selected ? 90 : a_hovered ? 70 : 45;
			const unsigned lineA = a_selected ? 255 : a_hovered ? 220 : a_visible ? 160 : 90;
			return { Col(r, g, b, fillA), Col(r, g, b, lineA) };
		}

		void SetStatus(std::string a_text, bool a_error)
		{
			std::scoped_lock lock{ g_lock };
			g_status = std::move(a_text);
			g_statusIsError = a_error;
		}

		Mapper MakeMapper()
		{
			Mapper m;
			const auto size = RE::BSGraphics::Renderer::GetScreenSize();
			if (size.height == 0 || size.width == 0) {
				return m;
			}
			m.scale = static_cast<float>(size.height) / static_cast<float>(Layout::kStageH);
			m.ox = (static_cast<float>(size.width) - static_cast<float>(Layout::kStageW) * m.scale) * 0.5f;
			return m;
		}

		// An answer from the scripts, if one came
		void TakeAnswer()
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
			std::scoped_lock lock{ g_lock };
			Layout::Model    parsed = g_model;
			std::string      why;
			if (!Layout::Parse(layout, parsed, why)) {
				g_status = why;
				g_statusIsError = true;
				return;
			}
			g_model = parsed;
			g_haveModel = true;
			g_status = "Layout read.";
			g_statusIsError = false;
		}

		// The model with the move in progress applied
		Layout::Model Previewed(const Layout::Model& a_model)
		{
			Layout::Model m = a_model;
			if (!g_dx && !g_dy) {
				return m;
			}
			switch (g_selected.kind) {
			case Kind::Bar:
				m.bars[static_cast<std::size_t>(g_selected.index)].x += g_dx;
				m.bars[static_cast<std::size_t>(g_selected.index)].y += g_dy;
				break;
			case Kind::NpcGroup:
				m.npc.x += g_dx;
				m.npc.y += g_dy;
				Layout::ApplyNpcAnchor(m);
				break;
			case Kind::Meters:
				m.meters.x += g_dx;
				m.meters.y += g_dy;
				break;
			default:
				break;
			}
			return m;
		}

		Layout::Rect NpcFootprint(const Layout::Model& a_model)
		{
			Layout::Rect r = Layout::Footprint(a_model.bars[static_cast<std::size_t>(Layout::PrimaryBar(1))]);
			for (int slot = 1; slot <= Layout::kNpcSlots; ++slot) {
				r.Include(Layout::Footprint(a_model.bars[static_cast<std::size_t>(Layout::PrimaryBar(slot))]));
				r.Include(Layout::Footprint(a_model.bars[static_cast<std::size_t>(Layout::SecondaryBar(slot))]));
			}
			return r;
		}

		Handle HitTest(const Layout::Model& a_model, const Mapper& a_map, const Ui::ImVec2& a_mouse)
		{
			// stage coordinates of the mouse
			const float sx = (a_mouse.x - a_map.ox) / a_map.scale;
			const float sy = a_mouse.y / a_map.scale;
			for (int bar = 0; bar < Layout::kPlayerBars; ++bar) {
				if (Layout::Footprint(a_model.bars[static_cast<std::size_t>(bar)]).Contains(sx, sy)) {
					return { Kind::Bar, bar };
				}
			}
			if (Layout::MetersFootprint(a_model.meters).Contains(sx, sy)) {
				return { Kind::Meters, 0 };
			}
			if (NpcFootprint(a_model).Contains(sx, sy)) {
				return { Kind::NpcGroup, 0 };
			}
			return {};
		}

		Ui::ImTextureID TextureFor(const std::string& a_file)
		{
			const auto found = g_textures.find(a_file);
			if (found != g_textures.end()) {
				return found->second;
			}
			// iWant Widgets loads its art from Interface\exported; a pack in a BSA or
			// a path the loader does not read draws as a box
			const Ui::ImTextureID tex = SKSEMenuFramework::LoadTexture("Data/Interface/exported/" + a_file);
			g_textures.emplace(a_file, tex);
			return tex;
		}

		void DisposeTextures()
		{
			for (const auto& [file, tex] : g_textures) {
				if (tex) {
					SKSEMenuFramework::DisposeTexture("Data/Interface/exported/" + file);
				}
			}
			g_textures.clear();
		}

		void DrawLabel(Ui::ImDrawList* a_dl, const Ui::ImVec2& a_at, const std::string& a_text)
		{
			Ui::ImDrawListManager::AddText(a_dl, { a_at.x + 1.0f, a_at.y + 1.0f }, kLabelShadow, a_text.c_str());
			Ui::ImDrawListManager::AddText(a_dl, a_at, kLabel, a_text.c_str());
		}

		void DrawBar(Ui::ImDrawList* a_dl, const Mapper& a_map, const Layout::Bar& a_bar, const Look& a_look, const std::string& a_label)
		{
			const auto       fp = Layout::Footprint(a_bar);
			const Ui::ImVec2 p0 = a_map.ToScreen(fp.x0 - 2.0f, fp.y0 - 2.0f);
			const Ui::ImVec2 p1 = a_map.ToScreen(fp.x1 + 2.0f, fp.y1 + 2.0f);
			Ui::ImDrawListManager::AddRectFilled(a_dl, p0, p1, a_look.fill, 3.0f, 0);
			Ui::ImDrawListManager::AddRect(a_dl, p0, p1, a_look.line, 3.0f, 0, 1.5f);
			const auto slots = Layout::IconSlots(a_bar);
			for (std::size_t i = 0; i < slots.size(); ++i) {
				const auto&      s = slots[i];
				const Ui::ImVec2 i0 = a_map.ToScreen(s.cx - s.size * 0.5f, s.cy - s.size * 0.5f);
				const Ui::ImVec2 i1 = a_map.ToScreen(s.cx + s.size * 0.5f, s.cy + s.size * 0.5f);
				const Ui::ImTextureID tex = i < a_bar.files.size() ? TextureFor(a_bar.files[i]) : nullptr;
				if (tex) {
					Ui::ImDrawListManager::AddImage(a_dl, tex, i0, i1, { 0.0f, 0.0f }, { 1.0f, 1.0f }, a_bar.visible ? kWhite : Col(255, 255, 255, 120));
				} else {
					Ui::ImDrawListManager::AddRect(a_dl, i0, i1, a_look.line, 2.0f, 0, 1.0f);
				}
			}
			if (!a_label.empty()) {
				DrawLabel(a_dl, { p0.x, p0.y - Ui::GetFontSize() - 2.0f }, a_label);
			}
		}

		void DrawMeters(Ui::ImDrawList* a_dl, const Mapper& a_map, const Layout::Meters& a_m, const Look& a_look)
		{
			const auto       fp = Layout::MetersFootprint(a_m);
			const Ui::ImVec2 p0 = a_map.ToScreen(fp.x0 - 2.0f, fp.y0 - 2.0f);
			const Ui::ImVec2 p1 = a_map.ToScreen(fp.x1 + 2.0f, fp.y1 + 2.0f);
			Ui::ImDrawListManager::AddRectFilled(a_dl, p0, p1, a_look.fill, 3.0f, 0);
			Ui::ImDrawListManager::AddRect(a_dl, p0, p1, a_look.line, 3.0f, 0, 1.5f);
			for (const auto& row : Layout::MeterRows(a_m)) {
				Ui::ImDrawListManager::AddRectFilled(a_dl, a_map.ToScreen(row.cx - row.w * 0.5f, row.cy - row.h * 0.5f),
					a_map.ToScreen(row.cx + row.w * 0.5f, row.cy + row.h * 0.5f), Col(255, 255, 255, 110), 2.0f, 0);
				Ui::ImDrawListManager::AddRect(a_dl, a_map.ToScreen(row.iconCx - row.iconSize * 0.5f, row.cy - row.iconSize * 0.5f),
					a_map.ToScreen(row.iconCx + row.iconSize * 0.5f, row.cy + row.iconSize * 0.5f), Col(255, 255, 255, 160), 2.0f, 0, 1.0f);
			}
			const std::string label = a_m.rows > 0 ? std::format("Meters ({} switched on)", a_m.rows) : std::string{ "Meters (none switched on)" };
			DrawLabel(a_dl, { p0.x, p0.y - Ui::GetFontSize() - 2.0f }, label);
		}

		std::string HandleName(const Handle& a_h, const Layout::Model& a_m)
		{
			switch (a_h.kind) {
			case Kind::Bar:
				return std::format("Bar {} ({} icons)", a_h.index, a_m.bars[static_cast<std::size_t>(a_h.index)].files.size());
			case Kind::NpcGroup:
				return "NPC slots";
			case Kind::Meters:
				return "Meter stack";
			default:
				return "nothing";
			}
		}

		void Snap(int a_baseX, int a_baseY)
		{
			if (!g_snap) {
				return;
			}
			const auto snapTo = [](int a_v) { return static_cast<int>(std::lround(a_v / static_cast<double>(kSnapStep))) * kSnapStep; };
			g_dx = snapTo(a_baseX + g_dx) - a_baseX;
			g_dy = snapTo(a_baseY + g_dy) - a_baseY;
		}

		void SelectedBase(const Layout::Model& a_m, int& a_x, int& a_y)
		{
			switch (g_selected.kind) {
			case Kind::Bar:
				a_x = a_m.bars[static_cast<std::size_t>(g_selected.index)].x;
				a_y = a_m.bars[static_cast<std::size_t>(g_selected.index)].y;
				break;
			case Kind::NpcGroup:
				a_x = a_m.npc.x;
				a_y = a_m.npc.y;
				break;
			case Kind::Meters:
				a_x = a_m.meters.x;
				a_y = a_m.meters.y;
				break;
			default:
				a_x = a_y = 0;
			}
		}

		// Sends the pending move of the selected handle and applies it to the model
		void Commit()
		{
			if (g_selected.kind == Kind::None || (!g_dx && !g_dy)) {
				g_dx = g_dy = 0;
				return;
			}
			std::scoped_lock lock{ g_lock };
			switch (g_selected.kind) {
			case Kind::Bar: {
				auto& b = g_model.bars[static_cast<std::size_t>(g_selected.index)];
				b.x = Layout::Clamp(b.x + g_dx, Layout::kMinX, Layout::kMaxX);
				b.y = Layout::Clamp(b.y + g_dy, Layout::kMinY, Layout::kMaxY);
				Bridge::SetBarPos(g_selected.index, b.x, b.y);
				break;
			}
			case Kind::NpcGroup:
				g_model.npc.x = Layout::Clamp(g_model.npc.x + g_dx, Layout::kMinX, Layout::kMaxX);
				g_model.npc.y = Layout::Clamp(g_model.npc.y + g_dy, Layout::kMinY, Layout::kMaxY);
				Layout::ApplyNpcAnchor(g_model);
				Bridge::SetNpcGroup(g_model.npc.x, g_model.npc.y);
				break;
			case Kind::Meters:
				g_model.meters.x = Layout::Clamp(g_model.meters.x + g_dx, Layout::kMinX, Layout::kMaxX);
				g_model.meters.y = Layout::Clamp(g_model.meters.y + g_dy, Layout::kMinY, kMetersMaxY);
				Bridge::SetMeters(g_model.meters.x, g_model.meters.y, g_model.meters.scale);
				break;
			default:
				break;
			}
			g_dx = g_dy = 0;
			g_confirmAt = Ui::GetTime() + kConfirmAfter;
		}

		void Resize(int a_steps)
		{
			std::scoped_lock lock{ g_lock };
			switch (g_selected.kind) {
			case Kind::Bar: {
				auto& b = g_model.bars[static_cast<std::size_t>(g_selected.index)];
				b.size = Layout::Clamp(b.size + a_steps, Layout::kMinBarSize, Layout::kMaxBarSize);
				Bridge::SetBarSize(g_selected.index, b.size);
				break;
			}
			case Kind::Meters:
				g_model.meters.scale = Layout::Clamp(g_model.meters.scale + a_steps * 5, Layout::kMinMetersScale, Layout::kMaxMetersScale);
				Bridge::SetMeters(g_model.meters.x, g_model.meters.y, g_model.meters.scale);
				break;
			default:
				return;  // the NPC bars' icon size is fixed by the scripts
			}
			g_confirmAt = Ui::GetTime() + kConfirmAfter;
		}

		void HandleKeys()
		{
			if (g_dragging || g_selected.kind == Kind::None) {
				return;
			}
			const bool shift = Ui::IsKeyDown(Ui::ImGuiKey_LeftShift) || Ui::IsKeyDown(Ui::ImGuiKey_RightShift);
			const int  step = shift ? 10 : 1;
			int        nx = 0, ny = 0;
			if (Ui::IsKeyPressed(Ui::ImGuiKey_LeftArrow, true)) {
				nx -= step;
			}
			if (Ui::IsKeyPressed(Ui::ImGuiKey_RightArrow, true)) {
				nx += step;
			}
			if (Ui::IsKeyPressed(Ui::ImGuiKey_UpArrow, true)) {
				ny -= step;
			}
			if (Ui::IsKeyPressed(Ui::ImGuiKey_DownArrow, true)) {
				ny += step;
			}
			if (nx || ny) {
				g_dx += nx;
				g_dy += ny;
				g_nudgeAt = Ui::GetTime();
			} else if ((g_dx || g_dy) && Ui::GetTime() - g_nudgeAt > kNudgeSettle) {
				Commit();
			}
			if (Ui::IsKeyPressed(Ui::ImGuiKey_Equal, true) || Ui::IsKeyPressed(Ui::ImGuiKey_KeypadAdd, true)) {
				Resize(+1);
			}
			if (Ui::IsKeyPressed(Ui::ImGuiKey_Minus, true) || Ui::IsKeyPressed(Ui::ImGuiKey_KeypadSubtract, true)) {
				Resize(-1);
			}
		}

		void DrawOverlay(const Mapper& a_map)
		{
			Layout::Model model;
			bool          have = false;
			{
				std::scoped_lock lock{ g_lock };
				model = g_model;
				have = g_haveModel;
			}
			const auto size = RE::BSGraphics::Renderer::GetScreenSize();
			Ui::SetNextWindowPos({ 0.0f, 0.0f }, Ui::ImGuiCond_Always, { 0.0f, 0.0f });
			Ui::SetNextWindowSize({ static_cast<float>(size.width), static_cast<float>(size.height) }, Ui::ImGuiCond_Always);
			Ui::SetNextWindowBgAlpha(0.0f);
			// NoBringToFrontOnFocus keeps the overlay under the toolbar (and under the
			// framework's panel, where that stays open) however it is clicked
			constexpr int flags = Ui::ImGuiWindowFlags_NoDecoration | Ui::ImGuiWindowFlags_NoMove | Ui::ImGuiWindowFlags_NoSavedSettings |
			                      Ui::ImGuiWindowFlags_NoBackground | Ui::ImGuiWindowFlags_NoScrollWithMouse | Ui::ImGuiWindowFlags_NoBringToFrontOnFocus |
			                      Ui::ImGuiWindowFlags_NoFocusOnAppearing | Ui::ImGuiWindowFlags_NoNav;
			Ui::Begin("##SLWidgetsEditorOverlay", nullptr, flags);
			Ui::ImDrawList* dl = Ui::GetWindowDrawList();
			if (dl) {
				// the stage, so an ultrawide screen shows where 0..1279 ends
				Ui::ImDrawListManager::AddRect(dl, a_map.ToScreen(0.0f, 0.0f), a_map.ToScreen(static_cast<float>(Layout::kStageW), static_cast<float>(Layout::kStageH)), kStageLine, 0.0f, 0, 1.0f);
			}
			const bool       hovered = Ui::IsWindowHovered(0);
			const Ui::ImVec2 mouse = Ui::GetMousePos();
			if (have && dl) {
				const Layout::Model shown = Previewed(model);
				g_hovered = hovered && !g_dragging ? HitTest(shown, a_map, mouse) : Handle{};
				for (int bar = 0; bar < Layout::kBars; ++bar) {
					const auto&  b = shown.bars[static_cast<std::size_t>(bar)];
					const Handle h = bar < Layout::kPlayerBars ? Handle{ Kind::Bar, bar } : Handle{ Kind::NpcGroup, 0 };
					std::string  label;
					if (bar < Layout::kPlayerBars) {
						label = std::format("Bar {}{}", bar, b.visible ? "" : " (hidden)");
					} else if (bar % 2 == 0) {
						const int   slot = Layout::SlotOfBar(bar);
						const auto& name = shown.npc.names[static_cast<std::size_t>(slot - 1)];
						label = std::format("NPC {}: {}", slot, name.empty() ? "empty" : name);
					}
					DrawBar(dl, a_map, b, LookOf(h.kind, b.visible, h == g_selected, h == g_hovered), label);
				}
				DrawMeters(dl, a_map, shown.meters, LookOf(Kind::Meters, true, g_selected.kind == Kind::Meters, g_hovered.kind == Kind::Meters));

				if (!g_dragging && hovered && Ui::IsMouseClicked(Ui::ImGuiMouseButton_Left, false)) {
					Commit();  // a nudge of the previous handle still settling
					g_selected = g_hovered;
					if (g_selected.kind != Kind::None) {
						g_dragging = true;
						g_dragStart = mouse;
						g_dx = g_dy = 0;
					}
				}
				if (g_dragging) {
					if (Ui::IsMouseDown(Ui::ImGuiMouseButton_Left)) {
						g_dx = static_cast<int>(std::lround((mouse.x - g_dragStart.x) / a_map.scale));
						g_dy = static_cast<int>(std::lround((mouse.y - g_dragStart.y) / a_map.scale));
						int bx = 0, by = 0;
						SelectedBase(model, bx, by);
						Snap(bx, by);
					} else {
						g_dragging = false;
						Commit();
					}
				}
			}
			Ui::End();
		}

		void DrawToolbar()
		{
			const auto& env = Env::Get();
			if (g_focusToolbar) {
				Ui::SetNextWindowFocus();
				g_focusToolbar = false;
			}
			Ui::SetNextWindowPos({ 24.0f, 24.0f }, Ui::ImGuiCond_Appearing, { 0.0f, 0.0f });
			Ui::Begin("SL Widgets position editor", nullptr, Ui::ImGuiWindowFlags_NoSavedSettings | Ui::ImGuiWindowFlags_AlwaysAutoResize | Ui::ImGuiWindowFlags_NoCollapse);

			std::string   status;
			bool          statusIsError = false;
			Layout::Model model;
			bool          have = false;
			{
				std::scoped_lock lock{ g_lock };
				status = g_status;
				statusIsError = g_statusIsError;
				model = g_model;
				have = g_haveModel;
			}
			Ui::PushStyleColor(Ui::ImGuiCol_Text, statusIsError ? kWarn : kOk);
			Ui::TextUnformatted(status.c_str());
			Ui::PopStyleColor(1);
			Ui::Separator();

			if (have) {
				Ui::TextUnformatted(("Selected: " + HandleName(g_selected, model)).c_str());
				if (g_selected.kind != Kind::None) {
					int bx = 0, by = 0;
					SelectedBase(model, bx, by);
					std::string line = std::format("X {}  Y {}", bx + g_dx, by + g_dy);
					if (g_selected.kind == Kind::Bar) {
						line += std::format("  size {}", model.bars[static_cast<std::size_t>(g_selected.index)].size);
					} else if (g_selected.kind == Kind::Meters) {
						line += std::format("  scale {}%", model.meters.scale);
					}
					Ui::TextUnformatted(line.c_str());
					const bool shift = Ui::IsKeyDown(Ui::ImGuiKey_LeftShift) || Ui::IsKeyDown(Ui::ImGuiKey_RightShift);
					const int  step = shift ? 10 : 1;
					if (Ui::SmallButton("<")) {
						g_dx -= step;
						g_nudgeAt = Ui::GetTime();
					}
					Ui::SameLine();
					if (Ui::SmallButton(">")) {
						g_dx += step;
						g_nudgeAt = Ui::GetTime();
					}
					Ui::SameLine();
					if (Ui::SmallButton("^")) {
						g_dy -= step;
						g_nudgeAt = Ui::GetTime();
					}
					Ui::SameLine();
					if (Ui::SmallButton("v")) {
						g_dy += step;
						g_nudgeAt = Ui::GetTime();
					}
					if (g_selected.kind != Kind::NpcGroup) {
						Ui::SameLine();
						if (Ui::SmallButton("size -")) {
							Resize(-1);
						}
						Ui::SameLine();
						if (Ui::SmallButton("size +")) {
							Resize(+1);
						}
					}
				}
				Ui::Checkbox("Snap to 10", &g_snap);
				Ui::Separator();
			}

			if (Ui::Button("Refresh")) {
				Commit();
				SetStatus("Reading the layout...", false);
				Bridge::RequestLayout(true);
			}
			Ui::SameLine();
			if (!g_confirmReset) {
				if (Ui::Button("Reset NPC layout")) {
					g_confirmReset = true;
				}
			} else {
				Ui::TextUnformatted("Reset the NPC cluster to the default corner?");
				Ui::SameLine();
				if (Ui::SmallButton("Yes")) {
					g_confirmReset = false;
					Bridge::ResetNpcLayout();
					g_confirmAt = Ui::GetTime() + kConfirmAfter;
				}
				Ui::SameLine();
				if (Ui::SmallButton("No")) {
					g_confirmReset = false;
				}
			}
			Ui::SameLine();
			if (Ui::Button("Done")) {
				Commit();
				Close(true);
			}

			Ui::PushStyleColor(Ui::ImGuiCol_Text, kHint);
			Ui::TextUnformatted("Drag a box to move it. Arrow keys nudge by 1, with Shift by 10; + and - resize. Esc closes.");
			Ui::TextUnformatted("The NPC slots move as one cluster; the meter stack rebuilds a moment after a move.");
			if (!env.hasMainWindow) {
				Ui::TextUnformatted("This SKSE Menu Framework build keeps its own panel open behind the editor: drag the panel aside, or update the framework.");
			}
			Ui::PopStyleColor(1);
			Ui::End();
		}

		void __stdcall Render() noexcept
		{
			try {
				TakeAnswer();
				if (g_confirmAt > 0.0 && Ui::GetTime() >= g_confirmAt) {
					g_confirmAt = 0.0;
					Bridge::RequestLayout(false);
				}
				const Mapper map = MakeMapper();
				DrawOverlay(map);
				HandleKeys();
				DrawToolbar();
			} catch (const std::exception& e) {
				if (!g_loggedFault) {
					g_loggedFault = true;
					logger::error("editor frame failed: {}", e.what());
				}
			} catch (...) {
				if (!g_loggedFault) {
					g_loggedFault = true;
					logger::error("editor frame failed");
				}
			}
		}
	}

	void Register()
	{
		if (g_window) {
			return;
		}
		g_window = SKSEMenuFramework::AddWindow(&Render, true);
		if (!g_window) {
			logger::warn("the framework gave no window: the editor is disabled");
		}
	}

	void Open()
	{
		if (!g_window) {
			return;
		}
		SetStatus("Reading the layout...", false);
		{
			std::scoped_lock lock{ g_lock };
			g_haveModel = false;
		}
		g_selected = {};
		g_hovered = {};
		g_dragging = false;
		g_dx = g_dy = 0;
		g_confirmReset = false;
		g_confirmAt = 0.0;
		g_focusToolbar = true;
		DisposeTextures();  // a pack may have changed since the last session of the editor
		Bridge::RequestLayout(true);
		if (Env::Get().hasMainWindow) {
			if (auto* main = SKSEMenuFramework::GetMainWindow()) {
				main->IsOpen = false;
			}
		}
		g_window->IsOpen = true;
	}

	void Close(bool a_restoreMain)
	{
		if (!g_window) {
			return;
		}
		const bool wasOpen = g_window->IsOpen.exchange(false);
		if (wasOpen && a_restoreMain && Env::Get().hasMainWindow) {
			if (auto* main = SKSEMenuFramework::GetMainWindow()) {
				main->IsOpen = true;
			}
		}
	}

	bool IsOpen()
	{
		return g_window && g_window->IsOpen.load();
	}

	void OnVmReset()
	{
		Close(false);
		std::scoped_lock lock{ g_lock };
		g_haveModel = false;
		g_status.clear();
		g_statusIsError = false;
	}

	void DrawPageStatus()
	{
		const auto& env = Env::Get();
		Ui::PushStyleColor(Ui::ImGuiCol_Text, kHint);
		if (!env.hasMainWindow) {
			Ui::TextUnformatted("On this SKSE Menu Framework build the framework's panel stays open behind the editor; a newer framework lets the editor hide it.");
		}
		Ui::TextUnformatted("The editor needs a loaded game with iWant Status Bars running. Bars 0-3 are iWant's shared bars: moving one moves every mod's icons in it, as iWant's own MCM does.");
		Ui::PopStyleColor(1);
	}
}
