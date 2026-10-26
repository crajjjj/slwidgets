Scriptname slw_interface_sunhelm Hidden
{SunHelm reads. slw_module_sunhelm keeps the four need quests as plain Quest
references, and only these global functions cast them to SunHelm's script
types (stubbed in Source/ApiHeaders). A module that held variables of those
types would need them resolved when the module loads, which fails on every
install without SunHelm; a global function body is linked only when called,
and these are called only once SunHelm was found. Same pattern as
slw_interface_sgo4. All return 0-100, clamped: SunHelm divides the level by
the last stage threshold, which the level can pass for a moment.}
import slw_util

Int Function getHungerPercent(Quest q) Global
	_SHHungerSystem sys = q as _SHHungerSystem
	If !sys
		Return 0
	EndIf
	Return clampInt(sys.GetHungerPercent(), 0, 100)
EndFunction

Int Function getThirstPercent(Quest q) Global
	_SHThirstSystem sys = q as _SHThirstSystem
	If !sys
		Return 0
	EndIf
	Return clampInt(sys.GetThirstPercent(), 0, 100)
EndFunction

Int Function getFatiguePercent(Quest q) Global
	_SHFatigueSystem sys = q as _SHFatigueSystem
	If !sys
		Return 0
	EndIf
	Return clampInt(sys.GetFatiguePercent(), 0, 100)
EndFunction

; The cold system has no percent function: the same formula as the others,
; the level global over the last stage threshold.
Int Function getColdPercent(Quest q) Global
	_SHColdSystem sys = q as _SHColdSystem
	If !sys
		Return 0
	EndIf
	Int top = sys._SHColdStage5
	GlobalVariable level = sys._SHCurrentColdLevel
	If top <= 0 || !level
		Return 0
	EndIf
	Return clampInt(((level.GetValue() / top) * 100.0) as Int, 0, 100)
EndFunction
