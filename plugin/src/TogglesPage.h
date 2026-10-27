#pragma once

// The Toggles page in SKSE Menu Framework's menu: the player icon switches of
// the MCM's Toggles page, grouped by mod, a switch greyed out while its mod is
// not installed. The list (keys, label and help keys, values, installed) comes
// from the scripts (slw_config.editorToggles); a click writes one switch through
// Bridge and the icons follow on the scripts' next update pass.

namespace Toggles
{
	// The page's render function, inside a framework callback
	void Render();

	// A game is being loaded or started: the list belongs to the old VM
	void OnVmReset();
}
