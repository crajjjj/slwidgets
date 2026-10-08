Scriptname slw_interface_slove Hidden

;SLO VE
;--------------------------------------
; Read from the StorageUtil keys SLO VE documents for other mods, so nothing
; here compiles against SLO VE.

; Willpower (0-100) as the actor's next scene will find it. SLO VE applies
; recovery only when that scene starts, so between scenes it is worked out
; here: the value the last scene left behind plus the recovery for the whole
; game hours since its time stamp. A break is all or nothing: 0 until its hours
; have passed, then 100. During a scene SLO VE keeps the stamp current, so the
; same lines give the live value. Mirrors, read-only, what SLO VE's
; SLOVE_Resistance.CalculateStartupResistance does.
Int Function getSloveWillpower(Actor target) Global
	if !target
		return 100
	endif
	Int hours = 0
	Float last = StorageUtil.GetFloatValue(target, "SLOVE_LastSexTime", -1.0)
	if last >= 0.0
		hours = Math.Floor((Utility.GetCurrentGameTime() - last) * 24.0)
	endif
	if hours < 0
		hours = 0
	endif
	Int broken = StorageUtil.GetIntValue(target, "SLOVE_BrokenPoints", 0)
	if broken > 0
		if broken > hours
			return 0
		endif
		return 100
	endif
	; SLO VE writes the rate since 0.7.2. A save that has not had a scene since
	; then has none: 10 is what SLO VE ships for the player, and the next scene
	; puts the real number there.
	Int rate = StorageUtil.GetIntValue(target, "SLOVE_RecoverPerHour", 10)
	Int value = StorageUtil.GetIntValue(target, "SLOVE_Resistance", 100) + hours * rate
	if value > 100
		return 100
	elseif value < 0
		return 0
	endif
	return value
EndFunction
