#include "Menu.h"

#include "Env.h"
#include "PositionsPage.h"
#include "PresetsPage.h"
#include "TogglesPage.h"
#include "Ui.h"

namespace Menu
{
	namespace
	{
		void __stdcall TogglesPage() noexcept
		{
			Toggles::Render();  // catches its own
		}

		void __stdcall PositionsPage() noexcept
		{
			Positions::Render();  // catches its own
		}

		void __stdcall PresetsPage() noexcept
		{
			Presets::Render();  // catches its own
		}

		// The framework closed its menu (Escape, its hotkey): a slider still held
		// gets no further frame, so what it owes is written here
		void __stdcall OnEvent(SKSEMenuFramework::Model::EventType a_event) noexcept
		{
			try {
				if (a_event == SKSEMenuFramework::Model::EventType::kCloseMenu) {
					Positions::OnMenuClosed();
				}
			} catch (...) {
			}
		}
	}

	void Register()
	{
		const auto& env = Env::Get();
		if (!env.frameworkOk) {
			logger::info("SKSE menu pages disabled: {}. SL Widgets runs as before; icon switches and positions then change only through settings presets.", env.frameworkWhy);
			return;
		}
		try {
			SKSEMenuFramework::SetSection("SL Widgets");
			SKSEMenuFramework::AddSectionItem("Toggles", &TogglesPage);
			SKSEMenuFramework::AddSectionItem("Positions", &PositionsPage);
			SKSEMenuFramework::AddSectionItem("Presets", &PresetsPage);
			SKSEMenuFramework::AddEvent(&OnEvent, 0.0f);  // lives as long as the game
			logger::info("Menu registered: section \"SL Widgets\", pages \"Toggles\", \"Positions\" and \"Presets\".");
		} catch (const std::exception& e) {
			logger::error("menu registration failed: {}", e.what());
		} catch (...) {
			logger::error("menu registration failed");
		}
	}
}
