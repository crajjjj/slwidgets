#pragma once

// What this install has, found once at kPostPostLoad: every SKSE plugin is loaded
// by then, and the framework has not started rendering.

namespace Env
{
	struct State
	{
		bool        frameworkOk = false;  // SKSE Menu Framework is loaded with every export the plugin calls
		std::string frameworkWhy;         // why not, for the log
	};

	void         Detect();
	const State& Get();
}
