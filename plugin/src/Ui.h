#pragma once

// The ONLY include site of the vendored SKSE Menu Framework header (see
// extern\SKSEMenuFramework\README.txt). Rules for everything that includes this:
//  - call ImGuiMCP:: functions only inside a callback the framework invoked. The
//    wrappers resolve the framework's exports with GetProcAddress and do not check
//    for null, so a call without the framework DLL crashes.
//  - call only wrappers whose export is on the probe list in Env.cpp.
//  - never read ImGui structs (GetStyle, GetIO, GetMainViewport): their layout
//    belongs to whatever ImGui build the installed framework carries. The screen
//    size comes from the game's renderer instead, as the framework itself does.
//  - text that comes from the game (actor names, file names) goes through
//    TextUnformatted or AddText, never through a printf-style wrapper.

#pragma warning(push, 0)
#include "SKSEMenuFramework.h"
#pragma warning(pop)

namespace Ui = ImGuiMCP;
