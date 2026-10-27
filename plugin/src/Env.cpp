#include "Env.h"

namespace Env
{
	namespace
	{
		State g_state;

		// Every SKSEMenuFramework.dll export the plugin reaches, by the name the
		// vendored header binds it to. The header's ImGui wrappers call through
		// GetProcAddress with NO null check, so a missing export is a crash at the
		// call site; probing them all here turns that into "editor disabled" at load.
		// Keep in step with Editor.cpp and Menu.cpp.
		constexpr std::array kFrameworkExports{
			"AddSectionItem",
			"AddWindow",
			"DisposeTexture",
			"LoadTexture",
			"RegisterEventPriority",
			"UnregisterEvent",
			"ImDrawList_AddImage",
			"ImDrawList_AddLine",
			"ImDrawList_AddRect",
			"ImDrawList_AddRectFilled",
			"ImDrawList_AddText_Vec2",
			"igBegin",
			"igBeginTooltip",
			"igButton",
			"igCalcTextSize",
			"igCheckbox",
			"igEnd",
			"igEndTooltip",
			"igGetFontSize",
			"igGetMousePos",
			"igGetTime",
			"igGetWindowDrawList",
			"igIsItemHovered",
			"igIsKeyDown_Nil",
			"igIsKeyPressed_Bool",
			"igIsMouseClicked_Bool",
			"igIsMouseDown_Nil",
			"igIsMouseReleased_Nil",
			"igIsWindowHovered",
			"igPopID",
			"igPopStyleColor",
			"igPushID_Int",
			"igPushStyleColor_Vec4",
			"igSameLine",
			"igSeparator",
			"igSetNextWindowBgAlpha",
			"igSetNextWindowFocus",
			"igSetNextWindowPos",
			"igSetNextWindowSize",
			"igSmallButton",
			"igSpacing",
			"igTextUnformatted",
		};

		void ProbeFramework()
		{
			const HMODULE module = ::GetModuleHandleW(L"SKSEMenuFramework");
			if (!module) {
				g_state.frameworkWhy = "SKSE Menu Framework is not installed";
				return;
			}
			std::string missing;
			for (const char* name : kFrameworkExports) {
				if (!::GetProcAddress(module, name)) {
					missing += missing.empty() ? "" : ", ";
					missing += name;
				}
			}
			if (!missing.empty()) {
				g_state.frameworkWhy = "this SKSE Menu Framework lacks: " + missing;
				return;
			}
			g_state.frameworkOk = true;
			g_state.hasMainWindow = ::GetProcAddress(module, "GetMainWindow") != nullptr;
		}
	}

	void Detect()
	{
		g_state = {};
		ProbeFramework();
		logger::info("SKSE Menu Framework: {}{}", g_state.frameworkOk ? "ready" : g_state.frameworkWhy,
			g_state.frameworkOk && !g_state.hasMainWindow ? " (no GetMainWindow: the framework panel stays visible while the editor is open)" : "");
	}

	const State& Get()
	{
		return g_state;
	}
}
