#include "Env.h"

namespace Env
{
	namespace
	{
		State g_state;

		// Every SKSEMenuFramework.dll export the plugin reaches, by the name the
		// vendored header binds it to. The header's ImGui wrappers call through
		// GetProcAddress with NO null check, so a missing export is a crash at the
		// call site; probing them all here turns that into "page disabled" at load.
		// Keep in step with the pages, PageCommon.h and Menu.cpp.
		constexpr std::array kFrameworkExports{
			"AddSectionItem",
			"RegisterEventPriority",
			"UnregisterEvent",
			"igBeginCombo",
			"igBeginDisabled",
			"igBeginTooltip",
			"igCheckbox",
			"igEndCombo",
			"igEndDisabled",
			"igEndTooltip",
			"igGetFontSize",
			"igGetTime",
			"igIndent",
			"igInputText",
			"igIsItemActive",
			"igIsItemHovered",
			"igPopID",
			"igPopStyleColor",
			"igPopTextWrapPos",
			"igPushID_Int",
			"igPushStyleColor_Vec4",
			"igPushTextWrapPos",
			"igSameLine",
			"igSelectable_Bool",
			"igSeparator",
			"igSetNextItemWidth",
			"igSliderInt",
			"igSmallButton",
			"igSpacing",
			"igTextUnformatted",
			"igUnindent",
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
		}
	}

	void Detect()
	{
		g_state = {};
		ProbeFramework();
		logger::info("SKSE Menu Framework: {}", g_state.frameworkOk ? "ready" : g_state.frameworkWhy);
	}

	const State& Get()
	{
		return g_state;
	}
}
