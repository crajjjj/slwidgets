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
		constexpr double kReopenGap = 1.0;     // no frame drawn for this long: the page was left and came back
		constexpr double kConfirmAfter = 1.5;  // seconds after a click before the list is read back
		constexpr double kKeepClicked = 4.0;   // a read this soon after a click may predate it: keep the clicked value
		constexpr float  kAnswerTimeout = 6.0f;

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
		std::vector<Row>                        g_rows;
		bool                                    g_have = false;
		std::string                             g_status;
		bool                                    g_statusIsError = false;
		double                                  g_lastFrame = 0.0;
		double                                  g_confirmAt = 0.0;  // read the list back at this time; 0 = nothing owed
		std::unordered_map<std::string, double> g_clickedAt;  // key -> time of its last click
		bool                                    g_loggedFault = false;

		void SetStatus(std::string a_text, bool a_error)
		{
			g_status = std::move(a_text);
			g_statusIsError = a_error;
		}

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

		void TakeAnswer(double a_now)
		{
			std::string text, error;
			if (!Bridge::Take(Bridge::Query::Toggles, text, error)) {
				if (Bridge::Pending(Bridge::Query::Toggles) && Bridge::PendingSeconds(Bridge::Query::Toggles) > kAnswerTimeout) {
					SetStatus(std::format("SL Widgets has not answered for {:.0f} s. Is the mod enabled, with a game loaded? Refresh asks again.",
								  Bridge::PendingSeconds(Bridge::Query::Toggles)),
						true);
				}
				return;
			}
			if (!error.empty()) {
				SetStatus(error, true);
				return;
			}
			if (text.empty()) {
				SetStatus("SL Widgets is not running: load a game, then Refresh.", true);
				return;
			}
			std::vector<Row> parsed;
			std::string      why;
			if (!Parse(text, parsed, why)) {
				SetStatus(why, true);
				return;
			}
			// a read that may have left before a recent click shows the old value:
			// keep what was clicked until the read that follows it
			for (auto& row : parsed) {
				const auto clicked = g_clickedAt.find(row.key);
				if (clicked == g_clickedAt.end()) {
					continue;
				}
				if (a_now - clicked->second < kKeepClicked) {
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
			SetStatus("Switches read.", false);
		}

		void DrawRows(double a_now)
		{
			bool indented = false;
			for (std::size_t i = 0; i < g_rows.size(); ++i) {
				auto& row = g_rows[i];
				if (row.kind != Kind::Toggle && indented) {
					Ui::Unindent(0.0f);
					indented = false;
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
					Ui::Indent(0.0f);
					indented = true;
					break;
				case Kind::Toggle:
					{
						Ui::PushID(static_cast<int>(i));
						if (!row.installed) {
							Ui::BeginDisabled(true);
						}
						bool value = row.on;
						if (Ui::Checkbox(row.label.c_str(), &value) && row.installed) {
							row.on = value;
							g_clickedAt[row.key] = a_now;
							g_confirmAt = a_now + kConfirmAfter;
							Bridge::SetToggle(row.key, value);
						}
						if (!row.installed) {
							Ui::EndDisabled();
						}
						PageCommon::Tooltip(row.installed ? row.help : row.help + "\n\nNot installed.");
						if (!row.installed) {
							Ui::SameLine(0.0f, -1.0f);
							Colored(PageCommon::kHint, "(not installed)");
						}
						Ui::PopID();
						break;
					}
				}
			}
			if (indented) {
				Ui::Unindent(0.0f);
			}
		}
	}

	void Render()
	{
		try {
			std::scoped_lock lock{ g_lock };
			const double     now = Ui::GetTime();
			if (now - g_lastFrame > kReopenGap) {
				// the page just came up (or came back): the MCM may have changed a switch meanwhile
				g_have = false;
				SetStatus("Reading the switches...", false);
				Bridge::Request(Bridge::Query::Toggles, true);
			}
			g_lastFrame = now;
			TakeAnswer(now);

			Colored(g_statusIsError ? PageCommon::kWarn : PageCommon::kOk, g_status.c_str());
			Ui::SameLine(0.0f, -1.0f);
			if (Ui::SmallButton("Refresh")) {
				SetStatus("Reading the switches...", false);
				Bridge::Request(Bridge::Query::Toggles, true);
			}

			if (g_have) {
				DrawRows(now);
				Ui::Spacing();
				Ui::Separator();
			}
			Colored(PageCommon::kHint, "The player's icons, as on the MCM's Toggles page. A switch applies within a second or two, while this menu stays open.");

			if (g_confirmAt > 0.0 && now >= g_confirmAt) {
				g_confirmAt = 0.0;
				Bridge::Request(Bridge::Query::Toggles, false);
			}
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
		g_status.clear();
		g_statusIsError = false;
		g_confirmAt = 0.0;
		g_lastFrame = 0.0;
	}
}
