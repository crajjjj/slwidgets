#pragma once

// What this install has, found once at kPostPostLoad: every SKSE plugin is loaded
// by then, and the framework's window list has not met its render thread yet.

namespace Env
{
	struct State
	{
		bool        frameworkOk = false;    // SKSE Menu Framework is loaded with every export the plugin calls
		std::string frameworkWhy;           // why not, for the log and the menu page
		bool        hasMainWindow = false;  // GetMainWindow export (newer than framework 3.8): the editor can hide the framework's panel while it is open
	};

	void         Detect();
	const State& Get();
}
