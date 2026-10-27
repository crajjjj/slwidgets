#pragma once

// The plugin's page in SKSE Menu Framework's menu (section "SL Widgets") and the
// framework events it listens to.

namespace Menu
{
	// Registers the page, the editor window and the event hook. Logs and does
	// nothing when Env found no usable framework.
	void Register();
}
