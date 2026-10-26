Scriptname slw_module_baby extends slw_base_module
{BeeingFemale: the health of an unborn child, for the player and the tracked
NPCs. BeeingFemale keeps it as a StorageUtil float on the mother (0-100,
100 = healthy; its own widget reads the same key) and marks a pregnancy with
a spell. The icon is shown only while the actor is pregnant, and it runs the
other way round from the rest: full health is the calm end of the scale.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

Spell _bfPregnant

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
	; the same pregnancy marker slw_module_pregnancy uses
	_bfPregnant = Game.GetFormFromFile(0x28a0, "BeeingFemale.esm") as Spell
	If _bfPregnant
		Module_Ready = true
	Else
		WriteLog("ModuleBaby: BeeingFemale pregnancy spell not found", 2)
	EndIf
EndFunction

Bool Function _on(Int slot)
	Return isInterfaceActive() && config.isOnForSlot(config.module_baby_health, slot, config.MOD_BABY)
EndFunction

Function _release(iWant_Status_Bars iBars, Int slot)
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(BABY_STATE, slot))
	baby_loaded[slot] = false
	baby_state_prv[slot] = EMPTY
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
		_loadBabyIcon(iBars, slot)
		baby_loaded[slot] = true
	EndIf
	Int babyCurr = percentToState9NotStrict(100 - getBabyHealthFor(target))
	If baby_state_prv[slot] == EMPTY || baby_state_prv[slot] != babyCurr
		iBars.setIconStatus(slwGetModName(), getIconNameForSlot(BABY_STATE, slot), babyCurr)
		baby_state_prv[slot] = babyCurr
	EndIf
EndEvent

Bool Function isPregnant(Actor target)
	Return Module_Ready && target.HasSpell(_bfPregnant)
EndFunction

; 0-100, 100 = healthy. BeeingFemale writes the key when the pregnancy
; starts; an actor without it counts as healthy.
Int Function getBabyHealthFor(Actor target)
	Return clampInt(StorageUtil.GetFloatValue(target, "FW.UnbornHealth", 100.0) as Int, 0, 100)
EndFunction

Function _loadBabyIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("Healthy,Strong,Stable,Fine,Weak,At Risk,Critical,Failing,Miscarrying", ",")
	loadStageIcon(config, iBars, getIconNameForSlot(BABY_STATE, slot), iconbasepath + "babyhealth/baby", d)
EndFunction
