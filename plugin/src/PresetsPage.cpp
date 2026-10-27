#include "PresetsPage.h"

#include "Bridge.h"
#include "PageCommon.h"
#include "Text.h"

// Render runs inside the framework's callback for the page, on its render
// thread; OnVmReset comes from the game thread. g_lock keeps them apart.

namespace Presets
{
	namespace
	{
		using PageCommon::Colored;

		constexpr int         kVersion = 1;        // slw_config.editorPresets's "v="
		constexpr double      kReopenGap = 1.0;    // no frame drawn for this long: the page was left and came back
		constexpr double      kAfterSave = 1.5;    // seconds after a save before the list is read back
		constexpr double      kAfterLoad = 3.0;    // a load waits for the scripts' next update pass
		constexpr float       kAnswerTimeout = 6.0f;
		constexpr std::size_t kNameCapacity = 48;  // bytes a new name can hold, terminator included

		std::mutex               g_lock;
		std::vector<std::string> g_names;
		std::string              g_active;
		bool                     g_have = false;
		std::string              g_status;
		bool                     g_statusIsError = false;
		double                   g_lastFrame = 0.0;
		double                   g_confirmAt = 0.0;  // read the list back at this time; 0 = nothing owed
		std::string              g_selected;         // the preset picked in the list
		std::string              g_saving;           // a save awaiting the list that shows it
		std::string              g_loading;          // a load awaiting the list that shows it active
		bool                     g_confirmOverwrite = false;
		std::array<char, kNameCapacity> g_newName{};
		bool                     g_loggedFault = false;

		void SetStatus(std::string a_text, bool a_error)
		{
			g_status = std::move(a_text);
			g_statusIsError = a_error;
		}

		// A name the scripts take as a file in SettingsPresets: letters, digits,
		// spaces and - _ ( ), not blank
		bool ValidName(std::string_view a_name)
		{
			if (a_name.empty() || a_name.front() == ' ' || a_name.back() == ' ') {
				return false;
			}
			return std::ranges::all_of(a_name, [](unsigned char c) {
				return std::isalnum(c) || c == ' ' || c == '-' || c == '_' || c == '(' || c == ')';
			});
		}

		bool Has(std::string_view a_name)
		{
			return std::ranges::any_of(g_names, [&](const std::string& n) { return Text::Lower(n) == Text::Lower(a_name); });
		}

		// "v=1|a=<active>|p=<name>|p=<name>|..."
		bool Parse(std::string_view a_text, std::vector<std::string>& a_names, std::string& a_active, std::string& a_error)
		{
			a_names.clear();
			a_active.clear();
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
						a_error = std::format("the scripts report presets version {} but the DLL reads {}: install both from the same release", std::string{ value }, kVersion);
						return false;
					}
					sawVersion = true;
				} else if (tag == "a"sv) {
					a_active = std::string{ value };
				} else if (tag == "p"sv && !value.empty()) {
					a_names.emplace_back(value);
				}
			}
			if (!sawVersion) {
				a_error = "no presets version in the answer";
				return false;
			}
			return true;
		}

		void TakeAnswer()
		{
			std::string text, error;
			if (!Bridge::Take(Bridge::Query::Presets, text, error)) {
				if (Bridge::Pending(Bridge::Query::Presets) && Bridge::PendingSeconds(Bridge::Query::Presets) > kAnswerTimeout) {
					SetStatus(std::format("SL Widgets has not answered for {:.0f} s. Is the mod enabled, with a game loaded? Refresh asks again.",
								  Bridge::PendingSeconds(Bridge::Query::Presets)),
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
			std::vector<std::string> names;
			std::string              active, why;
			if (!Parse(text, names, active, why)) {
				SetStatus(why, true);
				return;
			}
			g_names = std::move(names);
			g_active = std::move(active);
			g_have = true;
			if (g_selected.empty() || !Has(g_selected)) {
				g_selected = g_active;
			}
			if (!g_saving.empty()) {
				const bool saved = Has(g_saving) && Text::Lower(g_active) == Text::Lower(g_saving);
				SetStatus(saved ? std::format("Saved \"{}\".", g_saving) : std::format("\"{}\" was not saved: see the Papyrus log.", g_saving), !saved);
				g_selected = g_saving;
				g_saving.clear();
			} else if (!g_loading.empty()) {
				const bool loaded = Text::Lower(g_active) == Text::Lower(g_loading);
				SetStatus(loaded ? std::format("Loaded \"{}\".", g_loading) :
				                   std::format("\"{}\" is still loading, or did not load: Refresh in a moment.", g_loading),
					!loaded);
				g_loading.clear();
			} else {
				SetStatus("Presets read.", false);
			}
		}

		void Save(const std::string& a_name, double a_now)
		{
			g_saving = a_name;
			g_loading.clear();
			SetStatus(std::format("Saving \"{}\"...", a_name), false);
			Bridge::SavePreset(a_name);
			g_confirmAt = a_now + kAfterSave;
		}

		void DrawList(double a_now)
		{
			Ui::TextUnformatted(std::format("Active preset: {}", g_active.empty() ? "none" : g_active).c_str());
			Ui::Spacing();
			for (std::size_t i = 0; i < g_names.size(); ++i) {
				const auto& name = g_names[i];
				Ui::PushID(static_cast<int>(i));
				const std::string label = Text::Lower(name) == Text::Lower(g_active) ? name + "   (active)" : name;
				if (Ui::Selectable(label.c_str(), Text::Lower(name) == Text::Lower(g_selected), 0, { 0.0f, 0.0f })) {
					g_selected = name;
					g_confirmOverwrite = false;
				}
				Ui::PopID();
			}
			Ui::Spacing();
			if (g_selected.empty()) {
				return;
			}
			if (Ui::SmallButton(std::format("Load \"{}\"", g_selected).c_str())) {
				g_loading = g_selected;
				g_saving.clear();
				g_confirmOverwrite = false;
				SetStatus(std::format("Loading \"{}\": the icons reload in a second or two...", g_selected), false);
				Bridge::LoadPreset(g_selected);
				g_confirmAt = a_now + kAfterLoad;
			}
			Ui::SameLine(0.0f, -1.0f);
			if (!g_confirmOverwrite) {
				if (Ui::SmallButton(std::format("Save over \"{}\"", g_selected).c_str())) {
					g_confirmOverwrite = true;
				}
			} else {
				Ui::TextUnformatted("Overwrite it?");
				Ui::SameLine(0.0f, -1.0f);
				if (Ui::SmallButton("Yes")) {
					g_confirmOverwrite = false;
					Save(g_selected, a_now);
				}
				Ui::SameLine(0.0f, -1.0f);
				if (Ui::SmallButton("No")) {
					g_confirmOverwrite = false;
				}
			}
		}

		void DrawSaveAs(double a_now)
		{
			Ui::TextUnformatted("Save the current settings as a new preset:");
			Ui::SetNextItemWidth(Ui::GetFontSize() * 14.0f);
			Ui::InputText("##newname", g_newName.data(), g_newName.size(), 0, nullptr, nullptr);
			Ui::SameLine(0.0f, -1.0f);
			if (Ui::SmallButton("Save as new")) {
				const std::string name{ g_newName.data() };
				if (!ValidName(name)) {
					SetStatus("A preset name takes letters, digits, spaces and - _ ( ), and no space at either end.", true);
				} else if (Has(name)) {
					SetStatus(std::format("\"{}\" exists: pick it in the list and use Save over.", name), true);
				} else {
					Save(name, a_now);
					g_newName.fill('\0');
				}
			}
		}
	}

	void Render()
	{
		try {
			std::scoped_lock lock{ g_lock };
			const double     now = Ui::GetTime();
			if (now - g_lastFrame > kReopenGap) {
				// the page just came up (or came back): the MCM may have changed the presets meanwhile
				g_have = false;
				g_confirmOverwrite = false;
				SetStatus("Reading the presets...", false);
				Bridge::Request(Bridge::Query::Presets, true);
			}
			g_lastFrame = now;
			TakeAnswer();

			Colored(g_statusIsError ? PageCommon::kWarn : PageCommon::kOk, g_status.c_str());
			Ui::SameLine(0.0f, -1.0f);
			if (Ui::SmallButton("Refresh")) {
				SetStatus("Reading the presets...", false);
				Bridge::Request(Bridge::Query::Presets, true);
			}
			Ui::Separator();

			if (g_have) {
				DrawList(now);
				Ui::Separator();
				DrawSaveAs(now);
				Ui::Separator();
			}
			Colored(PageCommon::kHint, "A settings preset holds the icon switches, the meters, the NPC slot switches and the layout: the player bars, the NPC cluster and the meter stack.");
			Colored(PageCommon::kHint, "The files are in Data\\SKSE\\Plugins\\SlWidgets\\SettingsPresets (Mod Organizer puts new ones in overwrite). The MCM's General page loads and saves them too.");

			if (g_confirmAt > 0.0 && now >= g_confirmAt) {
				g_confirmAt = 0.0;
				Bridge::Request(Bridge::Query::Presets, false);
			}
		} catch (const std::exception& e) {
			if (!g_loggedFault) {
				g_loggedFault = true;
				logger::error("presets page failed: {}", e.what());
			}
		} catch (...) {
			if (!g_loggedFault) {
				g_loggedFault = true;
				logger::error("presets page failed");
			}
		}
	}

	void OnVmReset()
	{
		std::scoped_lock lock{ g_lock };
		g_have = false;
		g_names.clear();
		g_active.clear();
		g_selected.clear();
		g_saving.clear();
		g_loading.clear();
		g_confirmOverwrite = false;
		g_status.clear();
		g_statusIsError = false;
		g_confirmAt = 0.0;
		g_lastFrame = 0.0;
	}
}
