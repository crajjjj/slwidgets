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
		constexpr double      kCheckAfter = 1.5;   // seconds between the reads that wait for a save or a load
		constexpr double      kSaveTimeout = 8.0;  // a save or a load waits for the scripts' next update pass
		constexpr double      kLoadTimeout = 15.0;
		constexpr std::size_t kNameCapacity = 48;  // bytes a new name can hold, terminator included

		// A save or a load the list has not shown yet
		struct Pending
		{
			std::string name;
			bool        save = false;
			double      since = 0.0;     // the click
			double      deadline = 0.0;  // no success by then: a failure
		};

		std::mutex                      g_lock;
		PageCommon::PageState           g_page{ Bridge::Query::Presets, "presets", "SL Widgets is not running: load a game, then Refresh." };
		std::vector<std::string>        g_names;
		std::string                     g_active;
		bool                            g_have = false;
		std::string                     g_selected;  // the preset picked in the list
		std::optional<Pending>          g_pending;
		bool                            g_confirmOverwrite = false;
		std::array<char, kNameCapacity> g_newName{};
		bool                            g_loggedFault = false;

		bool Same(std::string_view a_left, std::string_view a_right)
		{
			return Text::Lower(a_left) == Text::Lower(a_right);
		}

		bool Has(std::string_view a_name)
		{
			return std::ranges::any_of(g_names, [&](const std::string& n) { return Same(n, a_name); });
		}

		// A name the scripts take as a file in SettingsPresets: letters, digits,
		// spaces and - _ ( ), not blank at either end
		bool ValidName(std::string_view a_name)
		{
			if (a_name.empty() || a_name.front() == ' ' || a_name.back() == ' ') {
				return false;
			}
			return std::ranges::all_of(a_name, [](unsigned char c) {
				return std::isalnum(c) || c == ' ' || c == '-' || c == '_' || c == '(' || c == ')';
			});
		}

		std::string InProgress(const Pending& a_pending)
		{
			return a_pending.save ? std::format("Saving \"{}\"...", a_pending.name) :
			                        std::format("Loading \"{}\": the icons reload in a second or two...", a_pending.name);
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

		// A save or a load succeeded once a read asked for after the click shows
		// its name active (and, for a save, listed). A read asked for before the
		// click cannot know; a later one that does not show it yet asks again
		// until the deadline.
		void Judge(double a_now)
		{
			auto& p = *g_pending;
			if (g_page.LastRequestAt() < p.since) {
				g_page.SetStatus(InProgress(p), false);
				return;
			}
			if (Same(g_active, p.name) && (!p.save || Has(p.name))) {
				g_page.SetStatus(std::format("{} \"{}\".", p.save ? "Saved" : "Loaded", p.name), false);
				g_selected = p.name;
				g_pending.reset();
				return;
			}
			if (a_now < p.deadline) {
				g_page.SetStatus(InProgress(p), false);
				g_page.ConfirmAt(a_now + kCheckAfter);
				return;
			}
			g_page.SetStatus(p.save ? std::format("\"{}\" was not saved: see the Papyrus log.", p.name) :
			                          std::format("\"{}\" did not load in time: Refresh to check, or see the Papyrus log.", p.name),
				true);
			g_pending.reset();
		}

		void TakeAnswer(double a_now)
		{
			std::string text;
			if (!g_page.Take(text)) {
				return;
			}
			std::vector<std::string> names;
			std::string              active, why;
			if (!Parse(text, names, active, why)) {
				g_page.SetStatus(why, true);
				return;
			}
			g_names = std::move(names);
			g_active = std::move(active);
			g_have = true;
			if (g_selected.empty() || !Has(g_selected)) {
				g_selected = g_active;
			}
			if (g_pending) {
				Judge(a_now);
			} else {
				g_page.SetStatus("Presets read.", false);
			}
		}

		void Start(const std::string& a_name, bool a_save, double a_now)
		{
			g_pending = Pending{ a_name, a_save, a_now, a_now + (a_save ? kSaveTimeout : kLoadTimeout) };
			g_confirmOverwrite = false;
			g_page.SetStatus(InProgress(*g_pending), false);
			if (a_save) {
				Bridge::SavePreset(a_name);
			} else {
				Bridge::LoadPreset(a_name);
			}
			g_page.ConfirmAt(a_now + kCheckAfter);
		}

		void DrawList(double a_now)
		{
			Ui::TextUnformatted(std::format("Active preset: {}", g_active.empty() ? "none" : g_active).c_str());
			Ui::Spacing();
			for (std::size_t i = 0; i < g_names.size(); ++i) {
				const auto&           name = g_names[i];
				PageCommon::IdScope   id{ static_cast<int>(i) };
				const std::string     label = Same(name, g_active) ? name + "   (active)" : name;
				if (Ui::Selectable(label.c_str(), Same(name, g_selected), 0, { 0.0f, 0.0f })) {
					g_selected = name;
					g_confirmOverwrite = false;
				}
			}
			Ui::Spacing();
			if (g_selected.empty()) {
				return;
			}
			if (Ui::SmallButton(std::format("Load \"{}\"", g_selected).c_str())) {
				Start(g_selected, false, a_now);
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
					Start(g_selected, true, a_now);
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
					g_page.SetStatus("A preset name takes letters, digits, spaces and - _ ( ), and no space at either end.", true);
				} else if (Has(name)) {
					g_page.SetStatus(std::format("\"{}\" exists: pick it in the list and use Save over.", name), true);
				} else {
					Start(name, true, a_now);
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
			if (g_page.BeginFrame(now)) {
				// the page just came up (or came back): the MCM may have changed the presets meanwhile
				g_have = false;
				g_confirmOverwrite = false;
			}
			TakeAnswer(now);
			g_page.DrawStatusLine(now);
			Ui::Separator();

			if (g_have) {
				DrawList(now);
				Ui::Separator();
				DrawSaveAs(now);
				Ui::Separator();
			}
			Colored(PageCommon::kHint, "A settings preset holds the icon switches, the meters, the NPC slot switches and the layout: the player bars, the NPC cluster and the meter stack.");
			Colored(PageCommon::kHint, "The files are in Data\\SKSE\\Plugins\\SlWidgets\\SettingsPresets (Mod Organizer puts new ones in overwrite).");
			g_page.ServeConfirm(now, false);
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
		g_pending.reset();
		g_confirmOverwrite = false;
		g_page.Reset();
	}
}
