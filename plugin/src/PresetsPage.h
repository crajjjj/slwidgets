#pragma once

// The Presets page in SKSE Menu Framework's menu: the settings presets in
// Data\SKSE\Plugins\SlWidgets\SettingsPresets, loaded and saved as the MCM's
// General page does. A preset holds the switches, the meters, the NPC slot
// switches and the layout (bars 0-3, the NPC cluster, the meter stack).

namespace Presets
{
	// The page's render function, inside a framework callback
	void Render();

	// A game is being loaded or started: the list belongs to the old VM
	void OnVmReset();
}
