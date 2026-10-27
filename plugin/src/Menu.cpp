#include "Menu.h"

#include "Editor.h"
#include "Env.h"
#include "Ui.h"

namespace Menu
{
	namespace
	{
		bool g_loggedFault = false;

		void __stdcall Page() noexcept
		{
			try {
				Ui::TextUnformatted("Drag the status bars, the NPC slot cluster and the meter stack where you want them. A move is saved into the game at once, as the MCM's sliders are.");
				Ui::Spacing();
				if (Ui::Button("Open the position editor")) {
					Editor::Open();
				}
				Ui::Spacing();
				Editor::DrawPageStatus();
			} catch (...) {
				if (!g_loggedFault) {
					g_loggedFault = true;
					logger::error("menu page failed");
				}
			}
		}

		// The framework closed its menu (Escape, its hotkey): the editor goes with it,
		// and the framework's panel is not brought back
		void __stdcall OnEvent(SKSEMenuFramework::Model::EventType a_event) noexcept
		{
			try {
				if (a_event == SKSEMenuFramework::Model::EventType::kCloseMenu) {
					Editor::Close(false);
				}
			} catch (...) {
			}
		}
	}

	void Register()
	{
		const auto& env = Env::Get();
		if (!env.frameworkOk) {
			logger::info("Editor disabled: {}. SL Widgets itself is unaffected - its MCM has the position sliders.", env.frameworkWhy);
			return;
		}
		try {
			SKSEMenuFramework::SetSection("SL Widgets");
			SKSEMenuFramework::AddSectionItem("Position editor", &Page);
			Editor::Register();
			SKSEMenuFramework::AddEvent(&OnEvent, 0.0f);  // lives as long as the game
			logger::info("Menu registered: section \"SL Widgets\", the position editor.");
		} catch (const std::exception& e) {
			logger::error("menu registration failed: {}", e.what());
		} catch (...) {
			logger::error("menu registration failed");
		}
	}
}
