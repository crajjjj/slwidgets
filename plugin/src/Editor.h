#pragma once

// The position editor: a full-screen SKSE Menu Framework window over the HUD where
// the status bars, the NPC slot cluster and the meter stack are boxes to drag. It
// draws its own preview from the layout the scripts report (the icons' art, the
// bars' footprints) and writes a move once, on release, through Bridge; the real
// widgets follow when the scripts have applied it, and the layout is read back.

namespace Editor
{
	// Creates the window with the framework. Only after Env found the framework.
	void Register();

	// From a framework callback (the menu page's button)
	void Open();

	// From any thread. a_restoreMain: show the framework's own panel again when the
	// editor had hidden it (not when the framework itself is closing everything).
	void Close(bool a_restoreMain);

	bool IsOpen();

	// A game is being loaded or started: the layout belongs to the old VM
	void OnVmReset();

	// The status lines of the menu page, inside a framework callback
	void DrawPageStatus();
}
