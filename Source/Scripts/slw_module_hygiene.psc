Scriptname slw_module_hygiene extends slw_base_module
{The state of an actor's body, for the player and the tracked NPCs:
dirtiness from Bathing in Skyrim Renewed or Dirt and Blood, wetness from Wet
Function (Redux or NG), blood from Just Blood or Dirt and Blood and wounds
from Combat Wound. Where two mods show one icon, the worse of the two counts.
The wound switch sits
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
summons and while swimming. With the Papyrus Extender loaded the stage is the
highest of them that is active (see Dirt and Blood below for why); without
it, health against those thresholds, confirmed by the first stage's effect
being on the actor, so an actor Just Blood does not cover reads clean.

Dirt and Blood keeps the player in one state spell at a time: recently
washed, dirt 1-4, or blood 1-4, which is that dirt level with blood on it.
Its dirt goes on the dirtiness icon at every other stage (player only: NPCs
get dirt as random decoration by trade, not as a state), its blood on the
blood icon. NPC blood is five ability effects by health (85, 65, 45, 25, 10
percent), and a follower's the same effects from a potion it has them drink
below 60 percent. An ability keeps its condition-failed effects on the actor
flagged inactive, so those are read from the active ones only, through po3's
GetActiveEffects (Dirt and Blood needs the Papyrus Extender anyway); the
fifth level shares the icon's last stage.

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
Bool Property Plugin_DirtAndBlood = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

GlobalVariable _playerDirt
Quest _wfrConfig
; Just Blood's four stage effects
MagicEffect[] _jbBlood
Bool _po3 = false
; Dirt and Blood: the player's dirt and blood spells by level (index 0 = 1),
; the NPC blood effects by level
Spell[] _dnbDirt
Spell[] _dnbBlood
MagicEffect[] _dnbNpcBlood

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
	Return Plugin_Bathing || Plugin_WetFunction || Plugin_JustBlood || Plugin_CombatWound || Plugin_DirtAndBlood
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
	Plugin_DirtAndBlood = false
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
		_jbBlood = new MagicEffect[4]
		_jbBlood[0] = Game.GetFormFromFile(0x000885, "JustBlood.esp") as MagicEffect   ; Dirty_Effect_Blood1
		_jbBlood[1] = Game.GetFormFromFile(0x000886, "JustBlood.esp") as MagicEffect
		_jbBlood[2] = Game.GetFormFromFile(0x000887, "JustBlood.esp") as MagicEffect
		_jbBlood[3] = Game.GetFormFromFile(0x000888, "JustBlood.esp") as MagicEffect   ; Dirty_Effect_Blood4
		Plugin_JustBlood = _allEffects(_jbBlood)
		If !Plugin_JustBlood
			WriteLog("ModuleHygiene: a Just Blood effect was not found", 2)
		EndIf
	EndIf
	If !Plugin_CombatWound && isCombatWoundReady()
		WriteLog("ModuleHygiene: Combat Wound.esp and SlaveTats found")
		Plugin_CombatWound = true
	EndIf
	If !Plugin_DirtAndBlood && isDirtAndBloodReady()
		_initDirtAndBlood()
	EndIf
	_po3 = isPapyrusExtenderReady()
EndFunction

Bool Function _allSpells(Spell[] list)
	Int i = list.Length
	While i > 0
		i -= 1
		If !list[i]
			Return false
		EndIf
	EndWhile
	Return true
EndFunction

Bool Function _allEffects(MagicEffect[] list)
	Int i = list.Length
	While i > 0
		i -= 1
		If !list[i]
			Return false
		EndIf
	EndWhile
	Return true
EndFunction

Function _initDirtAndBlood()
	String p = "Dirt and Blood - Dynamic Visuals.esp"
	_dnbDirt = new Spell[4]
	_dnbDirt[0] = Game.GetFormFromFile(0x000806, p) as Spell   ; Dirty_Spell_Dirt1
	_dnbDirt[1] = Game.GetFormFromFile(0x000807, p) as Spell
	_dnbDirt[2] = Game.GetFormFromFile(0x000808, p) as Spell
	_dnbDirt[3] = Game.GetFormFromFile(0x000838, p) as Spell   ; Dirty_Spell_Dirt4
	_dnbBlood = new Spell[4]
	_dnbBlood[0] = Game.GetFormFromFile(0x000809, p) as Spell  ; Dirty_Spell_Blood1
	_dnbBlood[1] = Game.GetFormFromFile(0x00080A, p) as Spell
	_dnbBlood[2] = Game.GetFormFromFile(0x00080B, p) as Spell
	_dnbBlood[3] = Game.GetFormFromFile(0x000839, p) as Spell  ; Dirty_Spell_Blood4
	_dnbNpcBlood = new MagicEffect[5]
	_dnbNpcBlood[0] = Game.GetFormFromFile(0x000840, p) as MagicEffect   ; Dirty_NPCEffect_Blood1
	_dnbNpcBlood[1] = Game.GetFormFromFile(0x00083F, p) as MagicEffect
	_dnbNpcBlood[2] = Game.GetFormFromFile(0x00081D, p) as MagicEffect
	_dnbNpcBlood[3] = Game.GetFormFromFile(0x00081E, p) as MagicEffect
	_dnbNpcBlood[4] = Game.GetFormFromFile(0x00081F, p) as MagicEffect   ; Dirty_NPCEffect_Blood5
	Plugin_DirtAndBlood = _allSpells(_dnbDirt) && _allSpells(_dnbBlood) && _allEffects(_dnbNpcBlood)
	If Plugin_DirtAndBlood
		WriteLog("ModuleHygiene: Dirt and Blood found")
	Else
		WriteLog("ModuleHygiene: a Dirt and Blood spell or effect was not found", 2)
	EndIf
EndFunction

Bool Function _dirtOn(Int slot)
	Return (Plugin_Bathing || (Plugin_DirtAndBlood && slot == 0)) && config.isOnForSlot(config.module_dirtiness, slot, config.MOD_DIRT)
EndFunction

Bool Function _wetOn(Int slot)
	Return Plugin_WetFunction && config.isOnForSlot(config.module_wetness, slot, config.MOD_WET)
EndFunction

Bool Function _bloodOn(Int slot)
	Return (Plugin_JustBlood || Plugin_DirtAndBlood) && config.isOnForSlot(config.module_blood, slot, config.MOD_BLOOD)
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
	Bool dirtOn = _dirtOn(slot)
	Bool bloodOn = _bloodOn(slot)
	; the player's Dirt and Blood state, read once for both icons
	Int dnb = 0
	If slot == 0 && Plugin_DirtAndBlood && (dirtOn || bloodOn)
		dnb = _dnbPlayerState()
	EndIf
	If dirtOn
		Int dirtCurr = percentToState9NotStrict(getDirtPercentFor(target))
		If (dnb % 10) * 2 > dirtCurr
			dirtCurr = (dnb % 10) * 2
		EndIf
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
	If bloodOn
		Int bloodCurr = getBloodStage(target)
		Int dnbBlood = 0
		If slot == 0
			If dnb > 10
				dnbBlood = dnb - 10
			EndIf
		ElseIf Plugin_DirtAndBlood
			dnbBlood = _dnbNpcBloodStage(target)
		EndIf
		If dnbBlood > bloodCurr
			bloodCurr = dnbBlood
		EndIf
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

; The player's Dirt and Blood state: 0 clean (or recently washed), 1-4 the
; dirt level, plus 10 when that level carries blood
Int Function _dnbPlayerState()
	Int i = 3
	While i >= 0
		If PlayerRef.HasSpell(_dnbBlood[i])
			Return i + 11
		ElseIf PlayerRef.HasSpell(_dnbDirt[i])
			Return i + 1
		EndIf
		i -= 1
	EndWhile
	Return 0
EndFunction

; An NPC's Dirt and Blood blood, 0-4: the highest of its blood effects that
; is active
Int Function _dnbNpcBloodStage(Actor target)
	Return clampInt(_highestActive(target, _dnbNpcBlood), 0, 4)
EndFunction

; 1 + the index of the last effect in the list that is active on the actor,
; 0 for none
Int Function _highestActive(Actor target, MagicEffect[] effects)
	MagicEffect[] active = PO3_SKSEFunctions.GetActiveEffects(target, false)
	If !active
		Return 0
	EndIf
	Int i = effects.Length - 1
	While i >= 0
		If active.Find(effects[i]) >= 0
			Return i + 1
		EndIf
		i -= 1
	EndWhile
	Return 0
EndFunction

; 0 clean to 4 covered in blood, by Just Blood's own effects or thresholds
Int Function getBloodStage(Actor target)
	If !Plugin_JustBlood
		Return 0
	EndIf
	Float hp = target.GetActorValuePercentage("Health")
	If hp >= 0.75 && !target.IsDead()
		Return 0
	ElseIf _po3
		Return _highestActive(target, _jbBlood)
	EndIf
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
	If stage > 0 && !target.HasMagicEffect(_jbBlood[0])
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
