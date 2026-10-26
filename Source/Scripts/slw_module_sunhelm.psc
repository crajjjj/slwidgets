Scriptname slw_module_sunhelm extends slw_base_module
{SunHelm: food, thirst, cold and fatigue of the player. Each need is the
percent SunHelm itself works its stages from (level over the last stage
threshold), mapped onto a nine-stage icon. Player only: SunHelm tracks no one
else. The quests are held as Quest; slw_interface_sunhelm does the casts.

SunHelm turns a need off by stopping its quest (StopSystem), which leaves the
level where it was, so an icon is shown only while its quest runs.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

Quest _hungerQ
Quest _thirstQ
Quest _coldQ
Quest _fatigueQ

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
	Return Module_Ready
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
	_prv = Utility.CreateIntArray(4, EMPTY)
	_loaded = Utility.CreateBoolArray(4, false)
EndFunction

;override
Function initInterface()
	_ensureArrays()
	If Module_Ready || !isSunHelmReady()
		Return
	EndIf
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

Int Function _percent(Int need)
	If need == 0
		Return slw_interface_sunhelm.getHungerPercent(_hungerQ)
	ElseIf need == 1
		Return slw_interface_sunhelm.getThirstPercent(_thirstQ)
	ElseIf need == 2
		Return slw_interface_sunhelm.getColdPercent(_coldQ)
	EndIf
	Return slw_interface_sunhelm.getFatiguePercent(_fatigueQ)
EndFunction

Function _release(iWant_Status_Bars iBars, Int need)
	_loaded[need] = false
	_prv[need] = EMPTY
	iBars.releaseIcon(slwGetModName(), _iconName(need))
EndFunction

; Load the icon when its switch is on and SunHelm runs that need, release it
; otherwise. The flag is claimed before the external load call, so a release
; that runs while the load is in flight leaves the flag false and the next
; tick loads again (a no-op when the icon is there).
Function _sync(iWant_Status_Bars iBars, Int need)
	Quest q = _quest(need)
	If _switchOn(need) && q && q.IsRunning()
		If !_loaded[need]
			_loaded[need] = true
			_loadIcon(iBars, need)
		EndIf
	ElseIf _loaded[need]
		_release(iBars, need)
	EndIf
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
		_sync(iBars, need)
		If _loaded[need]
			Int stage = percentToState9NotStrict(_percent(need))
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
