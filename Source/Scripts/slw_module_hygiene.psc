Scriptname slw_module_hygiene extends slw_base_module
{The state of an actor's body, for the player and the tracked NPCs:
dirtiness from Bathing in Skyrim Renewed, wetness from Wet Function (Redux or
NG), blood from Just Blood and wounds from Combat Wound. The wound switch sits
with the health icons on the Toggles page; it lives here because this module
already tracks NPCs.

Dirt: Renewed stores the player's dirt percent in a global and an NPC's in a
StorageUtil float on the actor.

Wetness is on the mods' own scale, 0 up to a cap (10 by default), with 1
the level below which an actor counts as dry. The icon shows the part above
dry as a percentage of the rest, which is the strength both mods drive their
wet look with. Redux keeps the value in a StorageUtil float on the actor and
its settings (cap, dry) on its MCM quest; NG keeps the value in its DLL and
exposes it, and the cap, through WetFunctionNG.* natives. NG wins when both
are loaded.

Blood: Just Blood's four stages are the effects of one ability, conditioned
on health below 75, 50, 40 and 25 percent (or dead), and off for ghosts,
summons and while swimming. The stage is health against those thresholds,
confirmed by the first stage's effect being on the actor, so an actor Just
Blood does not cover reads clean.

Wounds: Combat Wound puts each wound on as a SlaveTats tattoo of its own
section and has Fade Tattoos take it off once faded (6 game hours by
default). The stage is how many the actor wears, 4 or more the last.}
import slw_log
import slw_util

Bool Property Plugin_Bathing = false auto hidden
; any wetness source (Redux or NG)
Bool Property Plugin_WetFunction = false auto hidden
Bool Property Plugin_WetFunctionNG = false auto hidden
Bool Property Plugin_JustBlood = false auto hidden
Bool Property Plugin_CombatWound = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

GlobalVariable _playerDirt
Quest _wfrConfig
MagicEffect _bloodEffect

String DIRT_STATE = "Dirtiness"
String WET_STATE = "Wetness"
String BLOOD_STATE = "Blood"
String WOUND_STATE = "Wounds"
String WOUND_SECTION = "Collygon - Wounds"
string iconbasepath = "widgets/iwant/widgets/library/hygiene/"
string woundbasepath = "widgets/iwant/widgets/library/health/wound/wound"
int EMPTY = -1
int[] dirt_state_prv
int[] wet_state_prv
int[] blood_state_prv
int[] wound_state_prv

;override
Bool Function isInterfaceActive()
	Return Plugin_Bathing || Plugin_WetFunction || Plugin_JustBlood || Plugin_CombatWound
EndFunction

Function _ensurePrvArrays()
	If !dirt_state_prv
		dirt_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !wet_state_prv
		wet_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !blood_state_prv
		blood_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !wound_state_prv
		wound_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
EndFunction

;override
Function resetInterface()
	dirt_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	wet_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	blood_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	wound_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	Plugin_Bathing = false
	Plugin_WetFunction = false
	Plugin_WetFunctionNG = false
	Plugin_JustBlood = false
	Plugin_CombatWound = false
EndFunction

;override
Function initInterface()
	_ensurePrvArrays()
	If !Plugin_Bathing && isBathingReady()
		WriteLog("ModuleHygiene: Bathing in Skyrim Renewed found")
		_playerDirt = Game.GetFormFromFile(0x000DA8, "Bathing in Skyrim.esp") as GlobalVariable
		Plugin_Bathing = _playerDirt != None
	EndIf
	If !Plugin_WetFunction
		If isWetFunctionNGReady()
			WriteLog("ModuleHygiene: WetFunctionNG.esp found")
			Plugin_WetFunctionNG = true
			Plugin_WetFunction = true
		ElseIf isWetFunctionReady()
			WriteLog("ModuleHygiene: WetFunction.esp (Redux) found")
			; WetFunctionMCM, the form Redux stores its settings on
			_wfrConfig = Game.GetFormFromFile(0x000800, "WetFunction.esp") as Quest
			Plugin_WetFunction = true
		EndIf
	EndIf
	If !Plugin_JustBlood && isJustBloodReady()
		WriteLog("ModuleHygiene: JustBlood.esp found")
		; Dirty_Effect_Blood1, the first stage of the ability
		_bloodEffect = Game.GetFormFromFile(0x000885, "JustBlood.esp") as MagicEffect
		Plugin_JustBlood = _bloodEffect != None
	EndIf
	If !Plugin_CombatWound && isCombatWoundReady()
		WriteLog("ModuleHygiene: Combat Wound.esp and SlaveTats found")
		Plugin_CombatWound = true
	EndIf
EndFunction

Bool Function _dirtOn(Int slot)
	Return Plugin_Bathing && config.isOnForSlot(config.module_dirtiness, slot, config.MOD_DIRT)
EndFunction

Bool Function _wetOn(Int slot)
	Return Plugin_WetFunction && config.isOnForSlot(config.module_wetness, slot, config.MOD_WET)
EndFunction

Bool Function _bloodOn(Int slot)
	Return Plugin_JustBlood && config.isOnForSlot(config.module_blood, slot, config.MOD_BLOOD)
EndFunction

Bool Function _woundsOn(Int slot)
	Return Plugin_CombatWound && config.isOnForSlot(config.module_wounds, slot, config.MOD_WOUNDS)
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	dirt_state_prv[slot] = EMPTY
	wet_state_prv[slot] = EMPTY
	blood_state_prv[slot] = EMPTY
	wound_state_prv[slot] = EMPTY
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(DIRT_STATE, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(WET_STATE, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(BLOOD_STATE, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(WOUND_STATE, slot))
	If !target
		Return
	EndIf
	If _dirtOn(slot)
		_loadDirtIcon(iBars, slot)
	EndIf
	If _wetOn(slot)
		_loadWetIcon(iBars, slot)
	EndIf
	If _bloodOn(slot)
		_loadBloodIcon(iBars, slot)
	EndIf
	If _woundsOn(slot)
		_loadWoundIcon(iBars, slot)
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
	If target && _bloodOn(slot)
		_loadBloodIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(BLOOD_STATE, slot))
		blood_state_prv[slot] = EMPTY
	EndIf
	If target && _woundsOn(slot)
		_loadWoundIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(WOUND_STATE, slot))
		wound_state_prv[slot] = EMPTY
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
	If _bloodOn(slot)
		Int bloodCurr = getBloodStage(target)
		If blood_state_prv[slot] == EMPTY || blood_state_prv[slot] != bloodCurr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(BLOOD_STATE, slot), bloodCurr)
			blood_state_prv[slot] = bloodCurr
		EndIf
	EndIf
	If _woundsOn(slot)
		Int woundCurr = clampInt(getWoundCount(target), 0, 4)
		If wound_state_prv[slot] == EMPTY || wound_state_prv[slot] != woundCurr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(WOUND_STATE, slot), woundCurr)
			wound_state_prv[slot] = woundCurr
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

; Wetness 0-100: (wetness - dry) / (cap - dry). NG exposes the cap but not the
; dry level, so NG uses its ini default (1). Redux's settings are absent when
; its settings loader never ran; then the defaults (cap 10, dry 1) apply.
Int Function getWetPercentFor(Actor target)
	If !Plugin_WetFunction
		Return 0
	EndIf
	Float wet
	Float cap
	Float dry = 1.0
	If Plugin_WetFunctionNG
		wet = WetFunctionNG.GetWetness(target)
		cap = WetFunctionNG.GetWetnessCap()
	Else
		wet = StorageUtil.GetFloatValue(target, "WetFunction_Actor_wetness", 0.0)
		cap = 0.0
		If _wfrConfig
			cap = StorageUtil.GetFloatValue(_wfrConfig, "wetnessCap", 0.0)
			If cap > 0.0
				dry = StorageUtil.GetFloatValue(_wfrConfig, "wetnessDry", 1.0)
			EndIf
		EndIf
	EndIf
	If cap <= 0.0
		cap = 10.0
		dry = 1.0
	EndIf
	If cap <= dry
		Return 0
	EndIf
	Return clampInt((((wet - dry) / (cap - dry)) * 100.0) as Int, 0, 100)
EndFunction

; 0 clean to 4 covered in blood, by Just Blood's own thresholds
Int Function getBloodStage(Actor target)
	If !Plugin_JustBlood
		Return 0
	EndIf
	Float hp = target.GetActorValuePercentage("Health")
	Int stage = 0
	If hp < 0.25
		stage = 4
	ElseIf hp < 0.4
		stage = 3
	ElseIf hp < 0.5
		stage = 2
	ElseIf hp < 0.75
		stage = 1
	EndIf
	If stage > 0 && !target.HasMagicEffect(_bloodEffect)
		Return 0
	EndIf
	Return stage
EndFunction

; The wounds the actor wears, through SlaveTats' own query (it returns true
; on an error, and then nothing counts)
Int Function getWoundCount(Actor target)
	If !Plugin_CombatWound
		Return 0
	EndIf
	Int template = JValue.retain(JMap.object())
	Int matches = JValue.retain(JArray.object())
	JMap.setStr(template, "section", WOUND_SECTION)
	Int n = 0
	If !SlaveTats.query_applied_tattoos(target, template, matches)
		n = JArray.count(matches)
	EndIf
	JValue.release(matches)
	JValue.release(template)
	Return n
EndFunction

Function _loadDirtIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("Clean,Fresh,Dusty,Slightly Dirty,Dirty,Grimy,Very Dirty,Filthy,Reeking", ",")
	loadStageIcon(config, iBars, DIRT_STATE, slot, iconbasepath + "dirt/dirt", d)
EndFunction

Function _loadWetIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("Dry,Damp,Sweaty,Moist,Wet,Very Wet,Soaked,Drenched,Dripping", ",")
	loadStageIcon(config, iBars, WET_STATE, slot, iconbasepath + "wet/wet", d)
EndFunction

Function _loadBloodIcon(iWant_Status_Bars iBars, Int slot)
	; Just Blood's own effect names
	String[] d = StringUtil.Split("Clean,Bloodstains,Large Bloodstains,Quite Bloody,Covered in Blood", ",")
	loadStageIcon(config, iBars, BLOOD_STATE, slot, iconbasepath + "blood/blood", d)
EndFunction

Function _loadWoundIcon(iWant_Status_Bars iBars, Int slot)
	String[] d = StringUtil.Split("No Wounds,One Wound,Two Wounds,Three Wounds,Four or More Wounds", ",")
	loadStageIcon(config, iBars, WOUND_STATE, slot, woundbasepath, d)
EndFunction
