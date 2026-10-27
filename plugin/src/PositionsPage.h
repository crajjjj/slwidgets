#pragma once

// The Positions page in SKSE Menu Framework's menu: X, Y, size and orientation of
// iWant's player bars, X, Y and spacing of the NPC cluster, X, Y and scale of the
// meter stack, as sliders. A change is written through Bridge while the menu is
// open, and the real widgets move: the framework freezes time, Papyrus does not
// stop. The page holds a copy of the layout the scripts reported and reads it
// back after each write.

namespace Positions
{
	// The page's render function, inside a framework callback
	void Render();

	// The framework closed its menu: a value still being dragged is written
	void OnMenuClosed();

	// A game is being loaded or started: the layout belongs to the old VM
	void OnVmReset();
}
