#include "SettingsPage.h"

#include "Bridge.h"
#include "PageCommon.h"
#include "Text.h"
#include "Translations.h"

// Render runs inside the framework's callback for a page, on its render
// thread; OnMenuClosed and OnVmReset come from the game thread, the input
// callback from the input thread. g_lock keeps the pages apart from the first
// two; the capture hands its key over through atomics.

namespace Settings
{
	namespace
	{
		using PageCommon::Colored;

		constexpr int    kVersion = 1;         // the rows' "v=" (see slw_config.editorGeneral)
		constexpr double kConfirmAfter = 1.5;  // seconds after a write before the page is read back
		constexpr double kAfterAction = 2.5;   // a button usually starts more work than a value does
		constexpr double kColorPush = 0.25;    // seconds between writes while a colour is being picked
		constexpr std::size_t kTextCapacity = 96;

		enum class Kind
		{
			Header,
			Text,
			Bool,
			Int,
			Action,
			Choice,
			Color,
			Key,
			String
		};

		struct Row
		{
			Kind                     kind = Kind::Text;
			std::string              key;
			bool                     enabled = true;
			int                      value = 0;
			int                      min = 0;
			int                      max = 0;
			std::string              label;  // translated
			std::string              help;   // translated
			std::string              text;   // a text row's value, a text field's content
			std::vector<std::string> options;
		};

		// What a row's control holds between frames, by key
		struct RowUi
		{
			bool                              wasActive = false;
			int                               pushed = 0;  // the value last written or read
			double                            pushedAt = 0.0;
			std::array<char, kTextCapacity>   buf{};
			std::string                       bufFor;  // the text the buffer was last filled from
		};

		struct Page
		{
			PageCommon::PageState                   state;
			const char*                             intro;
			std::vector<Row>                        rows;
			std::unordered_map<std::string, RowUi>  ui;
			std::unordered_map<std::string, double> writtenAt;  // key -> time of its last write, until a read that saw it
			bool                                    have = false;
			bool                                    anyActive = false;
			bool                                    loggedFault = false;
		};

		std::mutex g_lock;
		std::array<Page, static_cast<std::size_t>(PageId::kCount)> g_pages{ {
			{ { Bridge::Query::General, "settings", "SL Widgets is not running: load a game, then Refresh." },
				"The MCM only shows the state and the dependency check; every setting is here." },
			{ { Bridge::Query::Meters, "meters", "SL Widgets is not running: load a game, then Refresh." },
				"The stack's place and size are on the Positions page. A switch is greyed out while its mod is not installed." },
			{ { Bridge::Query::Npc, "NPC settings", "SL Widgets is not running: load a game, then Refresh." },
				"A slot fills when you aim at an NPC and press the hotkey. The cluster's place is on the Positions page." },
		} };

		// The hotkey capture: armed on the page, filled by the input callback
		std::atomic<bool> g_capturing{ false };
		std::atomic<int>  g_captured{ -2 };  // -2: nothing captured
		std::string       g_captureKey;       // the row armed, under g_lock

		// A line split into a_count fields, the last one taking the rest (free text)
		std::vector<std::string_view> Fields(std::string_view a_text, std::size_t a_count)
		{
			std::vector<std::string_view> out;
			std::size_t                   start = 0;
			while (out.size() + 1 < a_count) {
				const auto comma = a_text.find(',', start);
				if (comma == std::string_view::npos) {
					break;
				}
				out.push_back(a_text.substr(start, comma - start));
				start = comma + 1;
			}
			out.push_back(a_text.substr(std::min(start, a_text.size())));
			return out;
		}

		bool Int(std::string_view a_text, int& a_out)
		{
			return Text::ToInt(a_text, a_out);
		}

		bool Parse(std::string_view a_text, std::vector<Row>& a_out, std::string& a_error)
		{
			a_out.clear();
			bool sawVersion = false;
			for (const auto item : Text::Split(a_text, '|')) {
				const auto eq = item.find('=');
				if (eq == std::string_view::npos) {
					continue;
				}
				const auto tag = item.substr(0, eq);
				const auto value = item.substr(eq + 1);
				Row        row;
				int        enabled = 1;
				bool       ok = true;
				if (tag == "v"sv) {
					int version = 0;
					if (!Int(value, version) || version != kVersion) {
						a_error = std::format("the scripts report settings version {} but the DLL reads {}: install both from the same release", std::string{ value }, kVersion);
						return false;
					}
					sawVersion = true;
					continue;
				} else if (tag == "h"sv) {
					row.kind = Kind::Header;
					row.label = Translations::Get(value);
				} else if (tag == "t"sv) {
					const auto f = Fields(value, 2);
					row.kind = Kind::Text;
					row.label = Translations::Get(f[0]);
					row.text = f.size() > 1 ? Translations::Get(f[1]) : std::string{};
				} else if (tag == "b"sv || tag == "rgb"sv || tag == "k"sv) {
					const auto f = Fields(value, 5);
					row.kind = tag == "b"sv ? Kind::Bool : tag == "rgb"sv ? Kind::Color : Kind::Key;
					ok = f.size() == 5 && Int(f[1], enabled) && Int(f[2], row.value);
					if (ok) {
						row.key = std::string{ f[0] };
						row.label = Translations::Get(f[3]);
						row.help = Translations::Get(f[4]);
					}
				} else if (tag == "i"sv) {
					const auto f = Fields(value, 7);
					row.kind = Kind::Int;
					ok = f.size() == 7 && Int(f[1], enabled) && Int(f[2], row.value) && Int(f[3], row.min) && Int(f[4], row.max);
					if (ok) {
						row.key = std::string{ f[0] };
						row.label = Translations::Get(f[5]);
						row.help = Translations::Get(f[6]);
					}
				} else if (tag == "a"sv) {
					const auto f = Fields(value, 4);
					row.kind = Kind::Action;
					ok = f.size() == 4 && Int(f[1], enabled);
					if (ok) {
						row.key = std::string{ f[0] };
						row.label = Translations::Get(f[2]);
						row.help = Translations::Get(f[3]);
					}
				} else if (tag == "c"sv) {
					const auto f = Fields(value, 6);
					row.kind = Kind::Choice;
					ok = f.size() == 6 && Int(f[1], enabled) && Int(f[2], row.value);
					if (ok) {
						row.key = std::string{ f[0] };
						row.label = Translations::Get(f[3]);
						row.help = Translations::Get(f[4]);
						for (const auto option : Text::Split(f[5], ';')) {
							row.options.emplace_back(option);
						}
					}
				} else if (tag == "s"sv) {
					const auto f = Fields(value, 5);
					row.kind = Kind::String;
					ok = f.size() == 5 && Int(f[1], enabled);
					if (ok) {
						row.key = std::string{ f[0] };
						row.label = Translations::Get(f[2]);
						row.help = Translations::Get(f[3]);
						row.text = std::string{ f[4] };
					}
				} else {
					continue;  // a row kind from a newer build of the scripts
				}
				if (!ok) {
					a_error = std::format("a \"{}\" row does not read", std::string{ tag });
					return false;
				}
				row.enabled = enabled != 0;
				a_out.push_back(std::move(row));
			}
			if (!sawVersion) {
				a_error = "no settings version in the answer";
				return false;
			}
			return true;
		}

		void Write(Page& a_page, Row& a_row, const std::string& a_value, double a_now, double a_confirmAfter)
		{
			a_page.writtenAt[a_row.key] = a_now;
			a_page.state.ConfirmAt(a_now + a_confirmAfter);
			auto& ui = a_page.ui[a_row.key];
			ui.pushed = a_row.value;
			ui.pushedAt = a_now;
			Bridge::SetSetting(a_row.key, a_value);
		}

		void TakeAnswer(Page& a_page)
		{
			std::string text;
			if (!a_page.state.Take(text)) {
				return;
			}
			if (a_page.anyActive) {
				// a slider is held: the answer would put the game's value under the
				// hand that is moving it; read again once it is released
				a_page.state.ConfirmAt(Ui::GetTime() + kConfirmAfter);
				return;
			}
			std::vector<Row> parsed;
			std::string      why;
			if (!Parse(text, parsed, why)) {
				a_page.state.SetStatus(why, true);
				return;
			}
			// A row written after the newest read was asked for may be missing
			// from this answer: it keeps its value until a read asked for after
			// the write (the one each write schedules) shows what the game holds.
			for (auto& row : parsed) {
				const auto written = a_page.writtenAt.find(row.key);
				if (row.key.empty() || written == a_page.writtenAt.end()) {
					continue;
				}
				if (written->second >= a_page.state.LastRequestAt()) {
					for (const auto& old : a_page.rows) {
						if (old.key == row.key) {
							row.value = old.value;
							row.text = old.text;
						}
					}
				} else {
					a_page.writtenAt.erase(written);
				}
			}
			a_page.rows = std::move(parsed);
			for (const auto& row : a_page.rows) {
				if (!row.key.empty()) {
					a_page.ui[row.key].pushed = row.value;
				}
			}
			a_page.have = true;
			a_page.state.SetStatus("Settings read.", false);
		}

		std::string KeyName(int a_code)
		{
			static const std::unordered_map<int, const char*> kNames{
				{ 0x02, "1" }, { 0x03, "2" }, { 0x04, "3" }, { 0x05, "4" }, { 0x06, "5" }, { 0x07, "6" }, { 0x08, "7" }, { 0x09, "8" }, { 0x0A, "9" }, { 0x0B, "0" },
				{ 0x0C, "-" }, { 0x0D, "=" }, { 0x0E, "Backspace" }, { 0x0F, "Tab" },
				{ 0x10, "Q" }, { 0x11, "W" }, { 0x12, "E" }, { 0x13, "R" }, { 0x14, "T" }, { 0x15, "Y" }, { 0x16, "U" }, { 0x17, "I" }, { 0x18, "O" }, { 0x19, "P" },
				{ 0x1A, "[" }, { 0x1B, "]" }, { 0x1C, "Enter" }, { 0x1D, "Left Ctrl" },
				{ 0x1E, "A" }, { 0x1F, "S" }, { 0x20, "D" }, { 0x21, "F" }, { 0x22, "G" }, { 0x23, "H" }, { 0x24, "J" }, { 0x25, "K" }, { 0x26, "L" },
				{ 0x27, ";" }, { 0x28, "'" }, { 0x29, "`" }, { 0x2A, "Left Shift" }, { 0x2B, "\\" },
				{ 0x2C, "Z" }, { 0x2D, "X" }, { 0x2E, "C" }, { 0x2F, "V" }, { 0x30, "B" }, { 0x31, "N" }, { 0x32, "M" },
				{ 0x33, "," }, { 0x34, "." }, { 0x35, "/" }, { 0x36, "Right Shift" }, { 0x37, "Num *" }, { 0x38, "Left Alt" }, { 0x39, "Space" }, { 0x3A, "Caps Lock" },
				{ 0x3B, "F1" }, { 0x3C, "F2" }, { 0x3D, "F3" }, { 0x3E, "F4" }, { 0x3F, "F5" }, { 0x40, "F6" }, { 0x41, "F7" }, { 0x42, "F8" }, { 0x43, "F9" }, { 0x44, "F10" },
				{ 0x45, "Num Lock" }, { 0x46, "Scroll Lock" },
				{ 0x47, "Num 7" }, { 0x48, "Num 8" }, { 0x49, "Num 9" }, { 0x4A, "Num -" }, { 0x4B, "Num 4" }, { 0x4C, "Num 5" }, { 0x4D, "Num 6" }, { 0x4E, "Num +" },
				{ 0x4F, "Num 1" }, { 0x50, "Num 2" }, { 0x51, "Num 3" }, { 0x52, "Num 0" }, { 0x53, "Num ." }, { 0x57, "F11" }, { 0x58, "F12" },
				{ 0x9C, "Num Enter" }, { 0x9D, "Right Ctrl" }, { 0xB5, "Num /" }, { 0xB8, "Right Alt" }, { 0xC5, "Pause" },
				{ 0xC7, "Home" }, { 0xC8, "Up" }, { 0xC9, "Page Up" }, { 0xCB, "Left" }, { 0xCD, "Right" }, { 0xCF, "End" }, { 0xD0, "Down" }, { 0xD1, "Page Down" },
				{ 0xD2, "Insert" }, { 0xD3, "Delete" },
			};
			if (a_code < 0) {
				return "none";
			}
			const auto found = kNames.find(a_code);
			return found != kNames.end() ? std::string{ found->second } : std::format("key 0x{:02X}", a_code);
		}

		void DrawKey(Page& a_page, Row& a_row, double a_now)
		{
			Ui::TextUnformatted(std::format("{}: {}", a_row.label, KeyName(a_row.value)).c_str());
			PageCommon::Tooltip(a_row.help);
			Ui::SameLine(0.0f, -1.0f);
			if (g_capturing.load() && g_captureKey == a_row.key) {
				Colored(PageCommon::kOk, "press a key...");
				Ui::SameLine(0.0f, -1.0f);
				if (Ui::SmallButton("Cancel")) {
					g_capturing.store(false);
				}
				return;
			}
			if (Ui::SmallButton("Set")) {
				g_captureKey = a_row.key;
				g_captured.store(-2);
				g_capturing.store(true);
			}
			Ui::SameLine(0.0f, -1.0f);
			if (Ui::SmallButton("Clear")) {
				a_row.value = -1;
				Write(a_page, a_row, "-1", a_now, kConfirmAfter);
			}
		}

		void DrawColor(Page& a_page, Row& a_row, double a_now)
		{
			const int v = a_row.value;
			float     col[3]{ ((v >> 16) & 0xFF) / 255.0f, ((v >> 8) & 0xFF) / 255.0f, (v & 0xFF) / 255.0f };
			if (Ui::ColorEdit3(a_row.label.c_str(), col, Ui::ImGuiColorEditFlags_NoAlpha)) {
				const auto channel = [](float a_c) { return std::clamp(static_cast<int>(std::lround(a_c * 255.0f)), 0, 255); };
				a_row.value = (channel(col[0]) << 16) | (channel(col[1]) << 8) | channel(col[2]);
			}
			// the picker is a popup whose end the edit field cannot report:
			// write while it changes, at most every kColorPush, and the last value
			auto& ui = a_page.ui[a_row.key];
			if (a_row.value != ui.pushed && a_now - ui.pushedAt >= kColorPush) {
				Write(a_page, a_row, std::to_string(a_row.value), a_now, kConfirmAfter);
			}
		}

		void DrawRow(Page& a_page, std::size_t a_index, double a_now)
		{
			Row& row = a_page.rows[a_index];
			if (row.kind == Kind::Header) {
				Ui::Spacing();
				Ui::Separator();
				Ui::TextUnformatted(row.label.c_str());
				return;
			}
			if (row.kind == Kind::Text) {
				Ui::TextUnformatted(std::format("{}: {}", row.label, row.text).c_str());
				return;
			}
			PageCommon::IdScope id{ static_cast<int>(a_index) };
			{
				PageCommon::DisabledScope disabled{ !row.enabled };
				switch (row.kind) {
				case Kind::Bool:
					{
						bool on = row.value != 0;
						if (Ui::Checkbox(row.label.c_str(), &on)) {
							row.value = on ? 1 : 0;
							Write(a_page, row, on ? "1" : "0", a_now, kConfirmAfter);
						}
						break;
					}
				case Kind::Int:
					{
						Ui::SetNextItemWidth(Ui::GetFontSize() * 10.0f);
						Ui::SliderInt(row.label.c_str(), &row.value, row.min, row.max, "%d", Ui::ImGuiSliderFlags_AlwaysClamp);
						const bool active = Ui::IsItemActive();
						a_page.anyActive = a_page.anyActive || active;
						auto& ui = a_page.ui[row.key];
						if (!active && ui.wasActive && row.value != ui.pushed) {
							Write(a_page, row, std::to_string(row.value), a_now, kConfirmAfter);
						}
						ui.wasActive = active;
						break;
					}
				case Kind::Action:
					if (Ui::SmallButton(row.label.c_str())) {
						Write(a_page, row, "1", a_now, kAfterAction);
					}
					break;
				case Kind::Choice:
					{
						const int   shown = row.options.empty() ? -1 : std::clamp(row.value, 0, static_cast<int>(row.options.size()) - 1);
						const char* preview = shown < 0 ? "" : row.options[static_cast<std::size_t>(shown)].c_str();
						Ui::SetNextItemWidth(Ui::GetFontSize() * 12.0f);
						if (Ui::BeginCombo(row.label.c_str(), preview, 0)) {
							for (int i = 0; i < static_cast<int>(row.options.size()); ++i) {
								if (Ui::Selectable(row.options[static_cast<std::size_t>(i)].c_str(), i == shown, 0, { 0.0f, 0.0f }) && i != row.value) {
									row.value = i;
									Write(a_page, row, std::to_string(i), a_now, kConfirmAfter);
								}
							}
							Ui::EndCombo();
						}
						break;
					}
				case Kind::Color:
					DrawColor(a_page, row, a_now);
					break;
				case Kind::Key:
					DrawKey(a_page, row, a_now);
					break;
				case Kind::String:
					{
						auto& ui = a_page.ui[row.key];
						if (ui.bufFor != row.text && !ui.wasActive) {
							ui.buf.fill('\0');
							std::copy_n(row.text.begin(), std::min(row.text.size(), ui.buf.size() - 1), ui.buf.begin());
							ui.bufFor = row.text;
						}
						Ui::SetNextItemWidth(Ui::GetFontSize() * 14.0f);
						const bool enter = Ui::InputText(row.label.c_str(), ui.buf.data(), ui.buf.size(), Ui::ImGuiInputTextFlags_EnterReturnsTrue, nullptr, nullptr);
						const bool left = Ui::IsItemDeactivatedAfterEdit();
						ui.wasActive = Ui::IsItemActive();
						// '|' separates the rows the scripts send back: a label holding one
						// would break the page that reads it
						std::string typed{ ui.buf.data() };
						std::erase(typed, '|');
						if ((enter || left) && typed != row.text) {
							row.text = typed;
							ui.bufFor = typed;
							Write(a_page, row, typed, a_now, kConfirmAfter);
						}
						break;
					}
				default:
					break;
				}
			}
			if (row.kind != Kind::Key) {
				PageCommon::Tooltip(row.help);
			}
		}

		// A key the capture took for the row armed on this page
		void ApplyCapture(Page& a_page, double a_now)
		{
			const int code = g_captured.load();
			if (code == -2) {
				return;
			}
			for (auto& row : a_page.rows) {
				if (row.kind == Kind::Key && row.key == g_captureKey) {
					g_captured.store(-2);
					row.value = code;
					Write(a_page, row, std::to_string(code), a_now, kConfirmAfter);
					return;
				}
			}
		}

		// Called by the framework for each input event; consumes the key it takes.
		// Escape is left alone: the framework closes its menu on it.
		bool __stdcall OnInput(RE::InputEvent* a_event)
		{
			if (!g_capturing.load() || !a_event || a_event->GetEventType() != RE::INPUT_EVENT_TYPE::kButton ||
				a_event->GetDevice() != RE::INPUT_DEVICE::kKeyboard) {
				return false;
			}
			const auto* button = a_event->AsButtonEvent();
			if (!button || !button->IsDown()) {
				return false;
			}
			const auto code = static_cast<int>(button->GetIDCode());
			if (code == 0x01) {
				return false;
			}
			g_captured.store(code);
			g_capturing.store(false);
			return true;
		}
	}

	void Render(PageId a_page)
	{
		auto& page = g_pages[static_cast<std::size_t>(a_page)];
		try {
			std::scoped_lock lock{ g_lock };
			const double     now = Ui::GetTime();
			if (page.state.BeginFrame(now)) {
				// the page just came up (or came back): a preset or another page may have changed things meanwhile
				page.have = false;
			}
			TakeAnswer(page);
			ApplyCapture(page, now);
			page.anyActive = false;
			page.state.DrawStatusLine(now);
			if (page.have) {
				for (std::size_t i = 0; i < page.rows.size(); ++i) {
					DrawRow(page, i, now);
				}
				Ui::Spacing();
				Ui::Separator();
			}
			Colored(PageCommon::kHint, page.intro);
			page.state.ServeConfirm(now, page.anyActive);
		} catch (const std::exception& e) {
			if (!page.loggedFault) {
				page.loggedFault = true;
				logger::error("settings page failed: {}", e.what());
			}
		} catch (...) {
			if (!page.loggedFault) {
				page.loggedFault = true;
				logger::error("settings page failed");
			}
		}
	}

	void OnMenuClosed()
	{
		std::scoped_lock lock{ g_lock };
		g_capturing.store(false);
		for (auto& page : g_pages) {
			for (auto& row : page.rows) {
				if (row.key.empty() || (row.kind != Kind::Int && row.kind != Kind::Color)) {
					continue;
				}
				auto& ui = page.ui[row.key];
				if (row.value != ui.pushed) {
					// no frame follows to finish the drag or the colour pick
					ui.pushed = row.value;
					Bridge::SetSetting(row.key, std::to_string(row.value));
				}
				ui.wasActive = false;
			}
			page.anyActive = false;
			page.state.ForgetFrame();
		}
	}

	void OnVmReset()
	{
		std::scoped_lock lock{ g_lock };
		g_capturing.store(false);
		g_captured.store(-2);
		for (auto& page : g_pages) {
			page.have = false;
			page.rows.clear();
			page.ui.clear();
			page.writtenAt.clear();
			page.anyActive = false;
			page.state.Reset();
		}
	}

	void RegisterInput()
	{
		SKSEMenuFramework::AddInputEvent(&OnInput);  // lives as long as the game
	}
}
