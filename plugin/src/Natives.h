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

	bool Register(RE::BSScript::IVirtualMachine* a_vm);
}
