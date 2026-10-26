Scriptname slw_module_hygiene extends slw_base_module
{Dirtiness from Bathing in Skyrim Renewed and wetness from Wet Function
Redux, for the player and the tracked NPCs. Both mods keep per-actor values
SL Widgets can read without calling into them: Renewed stores the player's
dirt percent in a global and an NPC's in a StorageUtil float on the actor,
Wet Function stores every actor's wetness (0-1) in a StorageUtil float.}
import slw_log
import slw_util

Bool Property Plugin_Bathing = false auto hidden
Bool Property Plugin_WetFunction = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

GlobalVariable _playerDirt

String DIRT_STATE = "Dirtiness"
String WET_STATE = "Wetness"
string iconbasepath = "widgets/iwant/widgets/library/hygiene/"
int EMPTY = -1
int[] dirt_state_prv
int[] wet_state_prv

;override
Bool Function isInterfaceActive()
	Return Plugin_Bathing || Plugin_WetFunction
EndFunction

Function _ensurePrvArrays()
	If !dirt_state_prv
		dirt_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !wet_state_prv
		wet_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
EndFunction

;override
Function resetInterface()
	dirt_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	wet_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	Plugin_Bathing = false
	Plugin_WetFunction = false
EndFunction

;override
Function initInterface()
	_ensurePrvArrays()
	If !Plugin_Bathing && isBathingReady()
		WriteLog("ModuleHygiene: Bathing in Skyrim Renewed found")
		_playerDirt = Game.GetFormFromFile(0x000DA8, "Bathing in Skyrim.esp") as GlobalVariable
		Plugin_Bathing = _playerDirt != None
	EndIf
	If !Plugin_WetFunction && isWetFunctionReady()
		WriteLog("ModuleHygiene: WetFunction.esp found")
		Plugin_WetFunction = true
	EndIf
EndFunction

Bool Function _dirtOn(Int slot)
	Return Plugin_Bathing && config.isOnForSlot(config.module_dirtiness, slot, config.MOD_DIRT)
EndFunction

Bool Function _wetOn(Int slot)
	Return Plugin_WetFunction && config.isOnForSlot(config.module_wetness, slot, config.MOD_WET)
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	dirt_state_prv[slot] = EMPTY
	wet_state_prv[slot] = EMPTY
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(DIRT_STATE, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(WET_STATE, slot))
	If !target
		Return
	EndIf
	If _dirtOn(slot)
		_loadDirtIcon(iBars, slot)
	EndIf
	If _wetOn(slot)
		_loadWetIcon(iBars, slot)
	EndIf
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	If target && _dirtOn(slot)
		_loadDirtIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(DIRT_STATE, slot))
		dirt_state_prv[slot] = EMPTY
	EndIf
	If target && _wetOn(slot)
		_loadWetIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(WET_STATE, slot))
		wet_state_prv[slot] = EMPTY
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	If !target
		Return
	EndIf
	If _dirtOn(slot)
		Int dirtCurr = percentToState9NotStrict(getDirtPercentFor(target))
		If dirt_state_prv[slot] == EMPTY || dirt_state_prv[slot] != dirtCurr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(DIRT_STATE, slot), dirtCurr)
			dirt_state_prv[slot] = dirtCurr
		EndIf
	EndIf
	If _wetOn(slot)
		Int wetCurr = percentToState9NotStrict(getWetPercentFor(target))
		If wet_state_prv[slot] == EMPTY || wet_state_prv[slot] != wetCurr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(WET_STATE, slot), wetCurr)
			wet_state_prv[slot] = wetCurr
		EndIf
	EndIf
EndEvent

; Dirt 0-100. Renewed's own GetActorDirtPercent has no return on its NPC
; branch (2.7.10), so the two stores are read directly: the player's global,
; and the float Renewed writes on every actor it tracks (0 for the rest).
Int Function getDirtPercentFor(Actor target)
	If !Plugin_Bathing
		Return 0
	EndIf
	Float pct
	If target == PlayerRef
		pct = _playerDirt.GetValue()
	Else
		pct = StorageUtil.GetFloatValue(target, "BiS_Dirtiness", 0.0)
	EndIf
	Return clampInt(pct as Int, 0, 100)
EndFunction

; Wetness 0-100 from Wet Function's 0-1 float on the actor.
Int Function getWetPercentFor(Actor target)
	If !Plugin_WetFunction
		Return 0
	EndIf
	Float wet = StorageUtil.GetFloatValue(target, "WetFunction_Actor_wetness", 0.0)
	Return clampInt((wet * 100.0) as Int, 0, 100)
EndFunction

Function _loadDirtIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("Clean,Fresh,Dusty,Slightly Dirty,Dirty,Grimy,Very Dirty,Filthy,Reeking", ",")
	loadStageIcon(config, iBars, getIconNameForSlot(DIRT_STATE, slot), iconbasepath + "dirt/dirt", d)
EndFunction

Function _loadWetIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("Dry,Damp,Sweaty,Moist,Wet,Very Wet,Soaked,Drenched,Dripping", ",")
	loadStageIcon(config, iBars, getIconNameForSlot(WET_STATE, slot), iconbasepath + "wet/wet", d)
EndFunction
