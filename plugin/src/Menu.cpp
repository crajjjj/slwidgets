#include "Menu.h"

#include "Env.h"
#include "PositionsPage.h"
#include "PresetsPage.h"
#include "SettingsPage.h"
#include "TogglesPage.h"
#include "Ui.h"

namespace Menu
{
	namespace
	{
		void __stdcall GeneralPage() noexcept
		{
			Settings::Render(Settings::PageId::General);  // catches its own
		}

		void __stdcall TogglesPage() noexcept
		{
			Toggles::Render();
		}

		void __stdcall MetersPage() noexcept
		{
			Settings::Render(Settings::PageId::Meters);
		}

		void __stdcall NpcPage() noexcept
		{
			Settings::Render(Settings::PageId::Npc);
		}

		void __stdcall PositionsPage() noexcept
		{
			Positions::Render();
		}

		void __stdcall PresetsPage() noexcept
		{
			Presets::Render();
		}

		// The framework closed its menu (Escape, its hotkey): a slider still held
		// gets no further frame, so what it owes is written here
		void __stdcall OnEvent(SKSEMenuFramework::Model::EventType a_event) noexcept
		{
			try {
				if (a_event == SKSEMenuFramework::Model::EventType::kCloseMenu) {
					Positions::OnMenuClosed();
					Settings::OnMenuClosed();
				}
			} catch (...) {
			}
		}
	}

	void Register()
	{
		const auto& env = Env::Get();
		if (!env.frameworkOk) {
			logger::info("SKSE menu pages disabled: {}. SL Widgets has no settings in game without them: its MCM only shows the state.", env.frameworkWhy);
			return;
		}
		try {
			SKSEMenuFramework::SetSection("SL Widgets");
			SKSEMenuFramework::AddSectionItem("General", &GeneralPage);
			SKSEMenuFramework::AddSectionItem("Toggles", &TogglesPage);
			SKSEMenuFramework::AddSectionItem("Meters", &MetersPage);
			SKSEMenuFramework::AddSectionItem("NPC Tracking", &NpcPage);
			SKSEMenuFramework::AddSectionItem("Positions", &PositionsPage);
			SKSEMenuFramework::AddSectionItem("Presets", &PresetsPage);
			SKSEMenuFramework::AddEvent(&OnEvent, 0.0f);  // lives as long as the game
			Settings::RegisterInput();
			logger::info("Menu registered: section \"SL Widgets\", six pages.");
		} catch (const std::exception& e) {
			logger::error("menu registration failed: {}", e.what());
		} catch (...) {
			logger::error("menu registration failed");
		}
	}
}
