Scriptname slw_module_sunhelm extends slw_base_module
{Survival needs of the player: SunHelm's food, thirst, cold and fatigue, or
the Creation Club Survival Mode's hunger, cold and exhaustion on the food,
cold and fatigue icons (Survival Mode has no thirst). Each need is the percent
of the level its worst stage starts at, the share SunHelm itself works its
stages from, mapped onto a nine-stage icon. Player only: neither mod tracks
anyone else. The SunHelm quests are held as Quest; slw_interface_sunhelm does
the casts.

SunHelm turns a need off by stopping its quest (StopSystem), which leaves the
level where it was, so a SunHelm need shows only while its quest runs, and it
wins a need that both mods run.

Survival Mode keeps each need's level in a global. Its own scripts stop a
need's quest to turn the need off and hard-code the stage thresholds (the
worst stage at hunger 770, cold 800, exhaustion 800). Survival Mode Improved
strips those scripts and runs the needs in its DLL: there a need is on while
the mode is and its SMI_<need>ShouldBeEnabled global is set, and its worst
stage is its Survival_<need>Stage5Value global.}
import slw_log
import slw_util

; SunHelm found (the name predates Survival Mode support)
Bool Property Module_Ready = false auto hidden
Bool Property Plugin_Survival = false auto hidden
Bool Property Plugin_SurvivalImproved = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

Quest _hungerQ
Quest _thirstQ
Quest _coldQ
Quest _fatigueQ

; Survival Mode, indexed like the needs below (1, thirst, stays empty)
GlobalVariable _svEnabled
GlobalVariable _svEnabledShared
GlobalVariable[] _svLevel
GlobalVariable[] _svWorst
GlobalVariable[] _svSwitch
Quest[] _svQuest
Float SV_WORST_DEFAULT = 800.0

String FOOD_STATE = "SH_Food"
String THIRST_STATE = "SH_Thirst"
String COLD_STATE = "SH_Cold"
String FATIGUE_STATE = "SH_Fatigue"
string iconbasepath = "widgets/iwant/widgets/library/sunhelm/"
int EMPTY = -1
; per need, index 0 food, 1 thirst, 2 cold, 3 fatigue
int[] _prv
Bool[] _loaded

;override
Bool Function isInterfaceActive()
	Return Module_Ready || Plugin_Survival
EndFunction

; A need this install can show now: thirst only with SunHelm, Survival Mode's
; three only while the mode is on (its plugin comes with every Anniversary
; install, used or not)
Bool Function canShowNeed(Int need)
	Return Module_Ready || (Plugin_Survival && need != 1 && _survivalModeOn())
EndFunction

Bool Function _survivalModeOn()
	Return _svEnabled.GetValue() >= 1.0 || (_svEnabledShared && _svEnabledShared.GetValue() >= 1.0)
EndFunction

Function _ensureArrays()
	If !_prv
		_prv = Utility.CreateIntArray(4, EMPTY)
	EndIf
	If !_loaded
		_loaded = Utility.CreateBoolArray(4, false)
	EndIf
EndFunction

;override
Function resetInterface()
	Module_Ready = false
	Plugin_Survival = false
	Plugin_SurvivalImproved = false
	_svLevel = None
	_prv = Utility.CreateIntArray(4, EMPTY)
	_loaded = Utility.CreateBoolArray(4, false)
EndFunction

;override
Function initInterface()
	_ensureArrays()
	If !Module_Ready && isSunHelmReady()
		WriteLog("ModuleSunHelm: SunHelmSurvival.esp found")
		_hungerQ = Game.GetFormFromFile(0x008EE8, "SunHelmSurvival.esp") as Quest
		_thirstQ = Game.GetFormFromFile(0x05C470, "SunHelmSurvival.esp") as Quest
		_coldQ = Game.GetFormFromFile(0x6A13C2, "SunHelmSurvival.esp") as Quest
		_fatigueQ = Game.GetFormFromFile(0x01E844, "SunHelmSurvival.esp") as Quest
		If _hungerQ && _thirstQ && _coldQ && _fatigueQ
			Module_Ready = true
		Else
			WriteLog("ModuleSunHelm: a SunHelm need quest was not found (hunger " + _hungerQ + ", thirst " + _thirstQ + ", cold " + _coldQ + ", fatigue " + _fatigueQ + ")", 2)
		EndIf
	EndIf
	If !Plugin_Survival && isSurvivalModeReady()
		_initSurvival()
	EndIf
EndFunction

Function _initSurvival()
	String cc = "ccQDRSSE001-SurvivalMode.esl"
	_svEnabled = Game.GetFormFromFile(0x000826, cc) as GlobalVariable                 ; Survival_ModeEnabled
	_svEnabledShared = Game.GetFormFromFile(0x00314A, "Update.esm") as GlobalVariable ; Survival_ModeEnabledShared
	_svLevel = new GlobalVariable[4]
	_svLevel[0] = Game.GetFormFromFile(0x00081A, cc) as GlobalVariable   ; Survival_HungerNeedValue
	_svLevel[2] = Game.GetFormFromFile(0x00081B, cc) as GlobalVariable   ; Survival_ColdNeedValue
	_svLevel[3] = Game.GetFormFromFile(0x000816, cc) as GlobalVariable   ; Survival_ExhaustionNeedValue
	_svQuest = new Quest[4]
	_svQuest[0] = Game.GetFormFromFile(0x000894, cc) as Quest            ; Survival_NeedHungerQuest
	_svQuest[2] = Game.GetFormFromFile(0x000896, cc) as Quest            ; Survival_NeedColdQuest
	_svQuest[3] = Game.GetFormFromFile(0x000899, cc) as Quest            ; Survival_NeedExhaustionQuest
	_svWorst = new GlobalVariable[4]
	_svSwitch = new GlobalVariable[4]
	; the stock scripts set hunger's stages from this global's value too
	_svWorst[0] = Game.GetFormFromFile(0x000805, cc) as GlobalVariable   ; Survival_HungerStage5Value
	Plugin_SurvivalImproved = isSurvivalModeImprovedReady()
	If Plugin_SurvivalImproved
		String smi = "SurvivalModeImproved.esp"
		_svWorst[2] = Game.GetFormFromFile(0x000D24, smi) as GlobalVariable   ; Survival_ColdStage5Value
		_svWorst[3] = Game.GetFormFromFile(0x000A1B, smi) as GlobalVariable   ; Survival_ExhaustionStage5Value
		_svSwitch[0] = Game.GetFormFromFile(0x000F27, smi) as GlobalVariable  ; SMI_HungerShouldBeEnabled
		_svSwitch[2] = Game.GetFormFromFile(0x000F28, smi) as GlobalVariable  ; SMI_ColdShouldBeEnabled
		_svSwitch[3] = Game.GetFormFromFile(0x000F29, smi) as GlobalVariable  ; SMI_ExhaustionShouldBeEnabled
	EndIf
	Plugin_Survival = _svEnabled && _svLevel[0] && _svLevel[2] && _svLevel[3]
	If Plugin_Survival
		WriteLog("ModuleSunHelm: Survival Mode found (Survival Mode Improved: " + Plugin_SurvivalImproved + ")")
	Else
		WriteLog("ModuleSunHelm: a Survival Mode need global was not found", 2)
	EndIf
EndFunction

Quest Function _quest(Int need)
	If need == 0
		Return _hungerQ
	ElseIf need == 1
		Return _thirstQ
	ElseIf need == 2
		Return _coldQ
	EndIf
	Return _fatigueQ
EndFunction

String Function _iconName(Int need)
	If need == 0
		Return FOOD_STATE
	ElseIf need == 1
		Return THIRST_STATE
	ElseIf need == 2
		Return COLD_STATE
	EndIf
	Return FATIGUE_STATE
EndFunction

Bool Function _switchOn(Int need)
	If need == 0
		Return config.isOn(config.module_sh_food)
	ElseIf need == 1
		Return config.isOn(config.module_sh_thirst)
	ElseIf need == 2
		Return config.isOn(config.module_sh_cold)
	EndIf
	Return config.isOn(config.module_sh_fatigue)
EndFunction

Bool Function _sunHelmRuns(Int need)
	If !Module_Ready
		Return false
	EndIf
	Quest q = _quest(need)
	Return q && q.IsRunning()
EndFunction

Bool Function _survivalRuns(Int need)
	If !Plugin_Survival || need == 1 || !_svLevel
		Return false
	EndIf
	If !_survivalModeOn()
		Return false
	EndIf
	If Plugin_SurvivalImproved
		; its DLL runs the needs, the quests have no scripts left to stop
		Return !_svSwitch[need] || _svSwitch[need].GetValue() >= 1.0
	EndIf
	Quest q = _svQuest[need]
	Return q && q.IsRunning()
EndFunction

; Which mod shows this need now: 0 none (icon off), 1 SunHelm, 2 Survival Mode
Int Function _source(Int need)
	If !_switchOn(need)
		Return 0
	ElseIf _sunHelmRuns(need)
		Return 1
	ElseIf _survivalRuns(need)
		Return 2
	EndIf
	Return 0
EndFunction

Int Function _percent(Int need, Int src)
	If src == 2
		Return _survivalPercent(need)
	ElseIf need == 0
		Return slw_interface_sunhelm.getHungerPercent(_hungerQ)
	ElseIf need == 1
		Return slw_interface_sunhelm.getThirstPercent(_thirstQ)
	ElseIf need == 2
		Return slw_interface_sunhelm.getColdPercent(_coldQ)
	EndIf
	Return slw_interface_sunhelm.getFatiguePercent(_fatigueQ)
EndFunction

Int Function _survivalPercent(Int need)
	Float worst = SV_WORST_DEFAULT
	If _svWorst[need]
		worst = _svWorst[need].GetValue()
	EndIf
	If worst <= 0.0
		Return 0
	EndIf
	Return clampInt(((_svLevel[need].GetValue() / worst) * 100.0) as Int, 0, 100)
EndFunction

Function _release(iWant_Status_Bars iBars, Int need)
	_loaded[need] = false
	_prv[need] = EMPTY
	iBars.releaseIcon(slwGetModName(), _iconName(need))
EndFunction

; Load the icon when its switch is on and a mod runs that need, release it
; otherwise; returns the source (_source). The flag is claimed before the
; external load call, so a release that runs while the load is in flight
; leaves the flag false and the next tick loads again (a no-op when the icon
; is there).
Int Function _sync(iWant_Status_Bars iBars, Int need)
	Int src = _source(need)
	If src > 0
		If !_loaded[need]
			_loaded[need] = true
			_loadIcon(iBars, need)
		EndIf
	ElseIf _loaded[need]
		_release(iBars, need)
	EndIf
	Return src
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensureArrays()
	Int need = 0
	While need < 4
		_release(iBars, need)
		need += 1
	EndWhile
	If !target || !isInterfaceActive()
		Return
	EndIf
	need = 0
	While need < 4
		_sync(iBars, need)
		need += 1
	EndWhile
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensureArrays()
	Int need = 0
	While need < 4
		If target && isInterfaceActive()
			_sync(iBars, need)
		ElseIf _loaded[need]
			_release(iBars, need)
		EndIf
		need += 1
	EndWhile
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensureArrays()
	If !target || !isInterfaceActive()
		Return
	EndIf
	Int need = 0
	While need < 4
		Int src = _sync(iBars, need)
		If src > 0 && _loaded[need]
			Int stage = percentToState9NotStrict(_percent(need, src))
			If _prv[need] == EMPTY || _prv[need] != stage
				iBars.setIconStatus(slwGetModName(), _iconName(need), stage)
				_prv[need] = stage
			EndIf
		EndIf
		need += 1
	EndWhile
EndEvent

Function _loadIcon(iWant_Status_Bars iBars, Int need)
	String[] d
	String path
	If need == 0
		d = StringUtil.Split("Full,Satisfied,Content,Peckish,Hungry,Very Hungry,Famished,Starving,Starved", ",")
		path = iconbasepath + "food/food"
	ElseIf need == 1
		d = StringUtil.Split("Quenched,Refreshed,Fine,Slightly Dry,Thirsty,Very Thirsty,Parched,Dehydrated,Dying of Thirst", ",")
		path = iconbasepath + "thirst/thirst"
	ElseIf need == 2
		d = StringUtil.Split("Warm,Comfortable,Cool,Chilly,Cold,Very Cold,Freezing,Frostbitten,Hypothermic", ",")
		path = iconbasepath + "cold/cold"
	Else
		d = StringUtil.Split("Rested,Fresh,Fine,Tired,Weary,Very Tired,Exhausted,Drained,Collapsing", ",")
		path = iconbasepath + "fatigue/fatigue"
	EndIf
	loadStageIcon(config, iBars, _iconName(need), 0, path, d)
EndFunction
