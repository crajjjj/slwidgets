Scriptname slw_module_baby extends slw_base_module
{BeeingFemale: the health of an unborn child, for the player and the tracked
NPCs. BeeingFemale keeps it as a StorageUtil float on the mother (0-100,
100 = healthy; its own widget reads the same key). The icon is shown while
the actor carries a child, BeeingFemale's states 4-7 (three trimesters and
labor) in FW.CurrentState, the same test slw_module_pregnancy uses. Not the
pregnancy spell: BeeingFemale keeps that through the Replenish state after
birth, when the health key is already gone. The scale runs the other way
round from the rest: full health is the calm end.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

String BABY_STATE = "BF_BabyHealth"
string iconbasepath = "widgets/iwant/widgets/library/bf/"
int EMPTY = -1
int[] baby_state_prv
; whether the icon is registered with iWant for the slot (it comes and goes
; with the pregnancy)
Bool[] baby_loaded

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

Function _ensurePrvArrays()
	If !baby_state_prv
		baby_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !baby_loaded
		baby_loaded = Utility.CreateBoolArray(getSlotCount(), false)
	EndIf
EndFunction

;override
Function resetInterface()
	baby_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	baby_loaded = Utility.CreateBoolArray(getSlotCount(), false)
	Module_Ready = false
EndFunction

;override
Function initInterface()
	_ensurePrvArrays()
	If Module_Ready || !isBFReady()
		Return
	EndIf
	WriteLog("ModuleBaby: BeeingFemale.esm found")
	Module_Ready = true
EndFunction

Bool Function _on(Int slot)
	Return isInterfaceActive() && config.isOnForSlot(config.module_baby_health, slot, config.MOD_BABY)
EndFunction

Function _release(iWant_Status_Bars iBars, Int slot)
	baby_loaded[slot] = false
	baby_state_prv[slot] = EMPTY
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(BABY_STATE, slot))
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	_release(iBars, slot)
	; loaded on the first status update that finds a pregnancy
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	If !target || !_on(slot)
		_release(iBars, slot)
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	If !target || !_on(slot)
		Return
	EndIf
	If !isPregnant(target)
		If baby_loaded[slot]
			_release(iBars, slot)
		EndIf
		Return
	EndIf
	If !baby_loaded[slot]
		; claimed before the external load call: a release that runs while the
		; load is in flight leaves the flag false, and the next tick loads again
		; (a no-op when the icon is there)
		baby_loaded[slot] = true
		_loadBabyIcon(iBars, slot)
	EndIf
	Int babyCurr = percentToState9NotStrict(100 - getBabyHealthFor(target))
	If baby_state_prv[slot] == EMPTY || baby_state_prv[slot] != babyCurr
		iBars.setIconStatus(slwGetModName(), getIconNameForSlot(BABY_STATE, slot), babyCurr)
		baby_state_prv[slot] = babyCurr
	EndIf
EndEvent

Bool Function isPregnant(Actor target)
	If !Module_Ready
		Return false
	EndIf
	Int st = StorageUtil.GetIntValue(target, "FW.CurrentState", 0)
	Return st >= 4 && st <= 7
EndFunction

; 0-100, 100 = healthy. BeeingFemale writes the key when the pregnancy
; starts; an actor without it counts as healthy.
Int Function getBabyHealthFor(Actor target)
	Return clampInt(StorageUtil.GetFloatValue(target, "FW.UnbornHealth", 100.0) as Int, 0, 100)
EndFunction

Function _loadBabyIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("Healthy,Strong,Stable,Fine,Weak,At Risk,Critical,Failing,Miscarrying", ",")
	loadStageIcon(config, iBars, BABY_STATE, slot, iconbasepath + "babyhealth/baby", d)
EndFunction
