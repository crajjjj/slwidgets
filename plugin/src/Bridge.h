#pragma once

// The link to the mod's scripts: slw_bridge.psc, global functions the DLL calls
// through the Papyrus VM (DispatchStaticCall). Calls are queued on the SKSE task
// queue and dispatched on the game thread; an answer arrives on a VM thread. The
// pages read what they show as one string per query and write through the
// setters the MCM uses, so the mod's state is only ever touched from the scripts.

namespace Bridge
{
	enum class Query : std::size_t
	{
		Layout,   // slw_bridge.GetLayout: positions (slw_widget_controller.editorLayout)
		Toggles,  // slw_bridge.GetToggles: the player icon switches (slw_config.editorToggles)
		Presets,  // slw_bridge.GetPresets: the settings presets and the active one (slw_config.editorPresets)
		kCount
	};

	// Ask a query. The answer, or the reason there is none, comes back through
	// Take; a call already out is not repeated unless a_force (the user asked
	// again after a call that never came back).
	void Request(Query a_query, bool a_force);

	// The newest unread answer of a query. True once per answer; a_text is the
	// string (empty when the mod said "not ready"), a_error why there is none.
	bool Take(Query a_query, std::string& a_text, std::string& a_error);

	// A request is out and unanswered, and for how long (seconds)
	bool  Pending(Query a_query);
	float PendingSeconds(Query a_query);

	// A game is being loaded or started: the VM is reset, so an answer on its way
	// is gone, and with it the callback.
	void OnVmReset();

	// The setters, fire and forget
	void SetBarPos(int a_bar, int a_x, int a_y);
	void SetBarSize(int a_bar, int a_size);
	void SetBarType(int a_bar, int a_type);
	void SetNpcGroup(int a_x, int a_y);
	void SetNpcSpacing(int a_spacing);
	void SetMeters(int a_x, int a_y, int a_scale);
	void ResetNpcLayout();
	void SetToggle(const std::string& a_key, bool a_value);
	void LoadPreset(const std::string& a_name);
	void SavePreset(const std::string& a_name);
}
