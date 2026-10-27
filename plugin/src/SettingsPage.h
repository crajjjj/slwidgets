#pragma once

// The General, Meters and NPC Tracking pages: rows the scripts describe
// (slw_config.editorGeneral / editorMeters / editorNpc), drawn as they say:
// headers, text, switches, sliders, buttons, choices, a colour, a hotkey and
// text fields. A change goes back as the row's key and its new value as text
// through slw_bridge.SetSetting, which does what the MCM's handler for that
// option did.

namespace Settings
{
	enum class PageId : std::size_t
	{
		General,
		Meters,
		Npc,
		kCount
	};

	// The page's render function, inside a framework callback
	void Render(PageId a_page);

	// The framework closed its menu: a slider still held is written
	void OnMenuClosed();

	// A game is being loaded or started: the rows belong to the old VM
	void OnVmReset();

	// The hotkey capture listens to the game's input through the framework;
	// registered once with the pages
	void RegisterInput();
}
