#include "Menu.h"

#include "Env.h"
#include "Page.h"
#include "Ui.h"

namespace Menu
{
	namespace
	{
		void __stdcall PositionsPage() noexcept
		{
			Page::Render();  // catches its own
		}

		// The framework closed its menu (Escape, its hotkey): a slider still held
		// gets no further frame, so what it owes is written here
		void __stdcall OnEvent(SKSEMenuFramework::Model::EventType a_event) noexcept
		{
			try {
				if (a_event == SKSEMenuFramework::Model::EventType::kCloseMenu) {
					Page::OnMenuClosed();
				}
			} catch (...) {
			}
		}
	}

	void Register()
	{
		const auto& env = Env::Get();
		if (!env.frameworkOk) {
			logger::info("Positions page disabled: {}. SL Widgets itself is unaffected - its MCM has the same sliders.", env.frameworkWhy);
			return;
		}
		try {
			SKSEMenuFramework::SetSection("SL Widgets");
			SKSEMenuFramework::AddSectionItem("Positions", &PositionsPage);
			SKSEMenuFramework::AddEvent(&OnEvent, 0.0f);  // lives as long as the game
			logger::info("Menu registered: section \"SL Widgets\", page \"Positions\".");
		} catch (const std::exception& e) {
			logger::error("menu registration failed: {}", e.what());
		} catch (...) {
			logger::error("menu registration failed");
		}
	}
}
