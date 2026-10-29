#pragma once

// Papyrus natives on slw_bridge: the other direction of the bridge, the scripts
// calling into the DLL. Registered at load whether or not the framework is there.

namespace Natives
{
	// iWant Status Bars' icon step: how far a line bar puts each icon from the one
	// before, in icon sizes. It is BAR_SPACING_PERCENTAGE, a private Float of the
	// iWant_Status_Bars script (1.5, one value for every bar of every mod), which
	// no other script can reach, so the natives read and write it in the VM.
	constexpr float kMinIconStep = 0.8f;  // keep in step with Layout::kMinIconSpacing
	constexpr float kMaxIconStep = 3.0f;

	// 3.4.2: the stage iWant shows for an icon (iconActiveStatus, private as well),
	// which the scripts need to park an icon's other stages after a layout change
	// (slw_widget_controller._parkIdleStages).

	bool Register(RE::BSScript::IVirtualMachine* a_vm);
}
