#include "TogglesPage.h"

#include "Bridge.h"
#include "PageCommon.h"
#include "Text.h"
#include "Translations.h"

// Render runs inside the framework's callback for the page, on its render
// thread; OnVmReset comes from the game thread. g_lock keeps them apart.

namespace Toggles
{
	namespace
	{
		using PageCommon::Colored;

		constexpr int    kVersion = 1;         // slw_config.editorToggles's "v="
		constexpr double kConfirmAfter = 1.5;  // seconds after a click before the list is read back

		enum class Kind
		{
			Section,
			Group,
			Toggle
		};

		struct Row
		{
			Kind        kind = Kind::Toggle;
			std::string key;    // the switch's property name; empty for headers
			std::string label;  // translated
			std::string help;   // translated
			bool        on = false;
			bool        installed = false;
		};

		std::mutex                              g_lock;
		PageCommon::PageState                   g_page{ Bridge::Query::Toggles, "switches", "SL Widgets is not running: load a game, then Refresh." };
		std::vector<Row>                        g_rows;
		bool                                    g_have = false;
		std::unordered_map<std::string, double> g_clickedAt;  // key -> time of its last click, until a read that saw it
		bool                                    g_loggedFault = false;

		// "v=1|s=<key>|h=<key>|t=<property>,<label key>,<help key>,<on>,<installed>|..."
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
				if (tag == "v"sv) {
					int version = 0;
					if (!Text::ToInt(value, version) || version != kVersion) {
						a_error = std::format("the scripts report toggles version {} but the DLL reads {}: install both from the same release", std::string{ value }, kVersion);
						return false;
					}
					sawVersion = true;
				} else if (tag == "s"sv || tag == "h"sv) {
					a_out.push_back({ tag == "s"sv ? Kind::Section : Kind::Group, {}, Translations::Get(value), {}, false, true });
				} else if (tag == "t"sv) {
					const auto f = Text::Split(value, ',');
					int        on = 0, installed = 0;
					if (f.size() < 5 || f[0].empty() || !Text::ToInt(f[3], on) || !Text::ToInt(f[4], installed)) {
						a_error = "a switch entry does not read";
						return false;
					}
					a_out.push_back({ Kind::Toggle, std::string{ f[0] }, Translations::Get(f[1]), Translations::Get(f[2]), on != 0, installed != 0 });
				}
			}
			if (!sawVersion) {
				a_error = "no toggles version in the answer";
				return false;
			}
			return true;
		}

		void TakeAnswer()
		{
			std::string text;
			if (!g_page.Take(text)) {
				return;
			}
			std::vector<Row> parsed;
			std::string      why;
			if (!Parse(text, parsed, why)) {
				g_page.SetStatus(why, true);
				return;
			}
			// A switch clicked after the newest read was asked for may be missing
			// from this answer: it keeps its clicked value until a read asked for
			// after the click (the one a click schedules) shows what the game holds.
			for (auto& row : parsed) {
				const auto clicked = g_clickedAt.find(row.key);
				if (clicked == g_clickedAt.end()) {
					continue;
				}
				if (clicked->second >= g_page.LastRequestAt()) {
					for (const auto& old : g_rows) {
						if (old.key == row.key) {
							row.on = old.on;
						}
					}
				} else {
					g_clickedAt.erase(clicked);
				}
			}
			g_rows = std::move(parsed);
			g_have = true;
			g_page.SetStatus("Switches read.", false);
		}

		void DrawToggle(std::size_t a_index, Row& a_row, double a_now)
		{
			PageCommon::IdScope id{ static_cast<int>(a_index) };
			const std::string   tip = a_row.installed ? a_row.help : a_row.help + "\n\nNot installed.";
			bool                value = a_row.on;
			bool                clicked = false;
			{
				PageCommon::DisabledScope disabled{ !a_row.installed };
				clicked = Ui::Checkbox(a_row.label.c_str(), &value);
			}
			PageCommon::Tooltip(tip);
			if (!a_row.installed) {
				Ui::SameLine(0.0f, -1.0f);
				Colored(PageCommon::kHint, "(not installed)");
			} else if (clicked) {
				a_row.on = value;
				g_clickedAt[a_row.key] = a_now;
				g_page.ConfirmAt(a_now + kConfirmAfter);
				Bridge::SetToggle(a_row.key, value);
			}
		}

		void DrawRows(double a_now)
		{
			std::optional<PageCommon::IndentScope> indent;  // the switches of a group
			for (std::size_t i = 0; i < g_rows.size(); ++i) {
				auto& row = g_rows[i];
				if (row.kind != Kind::Toggle) {
					indent.reset();
				}
				switch (row.kind) {
				case Kind::Section:
					Ui::Spacing();
					Ui::Separator();
					Colored(PageCommon::kHint, row.label.c_str());
					break;
				case Kind::Group:
					Ui::Spacing();
					Ui::TextUnformatted(row.label.c_str());
					indent.emplace();
					break;
				case Kind::Toggle:
					DrawToggle(i, row, a_now);
					break;
				}
			}
		}
	}

	void Render()
	{
		try {
			std::scoped_lock lock{ g_lock };
			const double     now = Ui::GetTime();
			if (g_page.BeginFrame(now)) {
				// the page just came up (or came back): the MCM or a preset may have changed a switch meanwhile
				g_have = false;
			}
			TakeAnswer();
			g_page.DrawStatusLine(now);

			if (g_have) {
				DrawRows(now);
				Ui::Spacing();
				Ui::Separator();
			}
			Colored(PageCommon::kHint, "The player's icons. A switch applies within a second or two, while this menu stays open. The per-NPC switches are on the MCM's NPC Tracking page, the meter switches on its Meters page.");
			g_page.ServeConfirm(now, false);
		} catch (const std::exception& e) {
			if (!g_loggedFault) {
				g_loggedFault = true;
				logger::error("toggles page failed: {}", e.what());
			}
		} catch (...) {
			if (!g_loggedFault) {
				g_loggedFault = true;
				logger::error("toggles page failed");
			}
		}
	}

	void OnVmReset()
	{
		std::scoped_lock lock{ g_lock };
		g_have = false;
		g_rows.clear();
		g_clickedAt.clear();
		g_page.Reset();
	}
}
