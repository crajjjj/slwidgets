#pragma once

// The link to the mod's scripts: slw_bridge.psc, global functions the DLL calls
// through the Papyrus VM (DispatchStaticCall). Calls are queued on the SKSE task
// queue and dispatched on the game thread; an answer arrives on a VM thread. The
// editor reads the layout as one string (slw_widget_controller.editorLayout) and
// writes through the setters the MCM uses, so iWant's arrays are only ever touched
// from the scripts.

namespace Bridge
{
	// Ask for the layout. The answer, or the reason there is none, comes back
	// through Take; a call already out is not repeated unless a_force (the user
	// asked again after a call that never came back).
	void RequestLayout(bool a_force);

	// The newest unread answer. True once per answer; a_layout is the string
	// (empty when the mod said "not ready"), a_error why there is no string.
	bool Take(std::string& a_layout, std::string& a_error);

	// A request is out and unanswered, and for how long (seconds)
	bool  Pending();
	float PendingSeconds();

	// A game is being loaded or started: the VM is reset, so an answer on its way
	// is gone, and with it the callback.
	void OnVmReset();

	// The setters, fire and forget
	void SetBarPos(int a_bar, int a_x, int a_y);
	void SetBarSize(int a_bar, int a_size);
	void SetNpcGroup(int a_x, int a_y);
	void SetMeters(int a_x, int a_y, int a_scale);
	void ResetNpcLayout();
}
