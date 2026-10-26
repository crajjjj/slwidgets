Scriptname slw_module_sunhelm extends slw_base_module
{SunHelm: food, thirst, cold and fatigue of the player. Each need is the
percent SunHelm itself works its stages from (level over the last stage
threshold), mapped onto a nine-stage icon. Player only: SunHelm tracks no one
else. The quest scripts are cast through the stubs in Source/ApiHeaders.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

_SHHungerSystem _hunger
_SHThirstSystem _thirst
_SHColdSystem _cold
_SHFatigueSystem _fatigue

String FOOD_STATE = "SH_Food"
String THIRST_STATE = "SH_Thirst"
String COLD_STATE = "SH_Cold"
String FATIGUE_STATE = "SH_Fatigue"
string iconbasepath = "widgets/iwant/widgets/library/sunhelm/"
int EMPTY = -1
int _food_prv = -1
int _thirst_prv = -1
int _cold_prv = -1
int _fatigue_prv = -1

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

;override
Function resetInterface()
	Module_Ready = false
	_food_prv = EMPTY
	_thirst_prv = EMPTY
	_cold_prv = EMPTY
	_fatigue_prv = EMPTY
EndFunction

;override
Function initInterface()
	If Module_Ready || !isSunHelmReady()
		Return
	EndIf
	WriteLog("ModuleSunHelm: SunHelmSurvival.esp found")
	_hunger = (Game.GetFormFromFile(0x008EE8, "SunHelmSurvival.esp") as Quest) as _SHHungerSystem
	_thirst = (Game.GetFormFromFile(0x05C470, "SunHelmSurvival.esp") as Quest) as _SHThirstSystem
	_cold = (Game.GetFormFromFile(0x6A13C2, "SunHelmSurvival.esp") as Quest) as _SHColdSystem
	_fatigue = (Game.GetFormFromFile(0x01E844, "SunHelmSurvival.esp") as Quest) as _SHFatigueSystem
	If _hunger && _thirst && _cold && _fatigue
		Module_Ready = true
	Else
		WriteLog("ModuleSunHelm: a SunHelm need quest script was not found (hunger " + _hunger + ", thirst " + _thirst + ", cold " + _cold + ", fatigue " + _fatigue + ")", 2)
	EndIf
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_food_prv = EMPTY
	_thirst_prv = EMPTY
	_cold_prv = EMPTY
	_fatigue_prv = EMPTY
	iBars.releaseIcon(slwGetModName(), FOOD_STATE)
	iBars.releaseIcon(slwGetModName(), THIRST_STATE)
	iBars.releaseIcon(slwGetModName(), COLD_STATE)
	iBars.releaseIcon(slwGetModName(), FATIGUE_STATE)
	If !target || !isInterfaceActive()
		Return
	EndIf
	If config.isOn(config.module_sh_food)
		_loadFoodIcon(iBars)
	EndIf
	If config.isOn(config.module_sh_thirst)
		_loadThirstIcon(iBars)
	EndIf
	If config.isOn(config.module_sh_cold)
		_loadColdIcon(iBars)
	EndIf
	If config.isOn(config.module_sh_fatigue)
		_loadFatigueIcon(iBars)
	EndIf
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	Bool ready = target && isInterfaceActive()
	If ready && config.isOn(config.module_sh_food)
		_loadFoodIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), FOOD_STATE)
		_food_prv = EMPTY
	EndIf
	If ready && config.isOn(config.module_sh_thirst)
		_loadThirstIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), THIRST_STATE)
		_thirst_prv = EMPTY
	EndIf
	If ready && config.isOn(config.module_sh_cold)
		_loadColdIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), COLD_STATE)
		_cold_prv = EMPTY
	EndIf
	If ready && config.isOn(config.module_sh_fatigue)
		_loadFatigueIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), FATIGUE_STATE)
		_fatigue_prv = EMPTY
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	If !target || !isInterfaceActive()
		Return
	EndIf
	If config.isOn(config.module_sh_food)
		Int foodCurr = percentToState9NotStrict(getFoodPercent())
		If _food_prv == EMPTY || _food_prv != foodCurr
			iBars.setIconStatus(slwGetModName(), FOOD_STATE, foodCurr)
			_food_prv = foodCurr
		EndIf
	EndIf
	If config.isOn(config.module_sh_thirst)
		Int thirstCurr = percentToState9NotStrict(getThirstPercent())
		If _thirst_prv == EMPTY || _thirst_prv != thirstCurr
			iBars.setIconStatus(slwGetModName(), THIRST_STATE, thirstCurr)
			_thirst_prv = thirstCurr
		EndIf
	EndIf
	If config.isOn(config.module_sh_cold)
		Int coldCurr = percentToState9NotStrict(getColdPercent())
		If _cold_prv == EMPTY || _cold_prv != coldCurr
			iBars.setIconStatus(slwGetModName(), COLD_STATE, coldCurr)
			_cold_prv = coldCurr
		EndIf
	EndIf
	If config.isOn(config.module_sh_fatigue)
		Int fatigueCurr = percentToState9NotStrict(getFatiguePercent())
		If _fatigue_prv == EMPTY || _fatigue_prv != fatigueCurr
			iBars.setIconStatus(slwGetModName(), FATIGUE_STATE, fatigueCurr)
			_fatigue_prv = fatigueCurr
		EndIf
	EndIf
EndEvent

; The four reads, 0-100 and clamped. SunHelm's own percent functions divide
; the level by the last stage threshold, which the level can exceed briefly.
; Call only while isInterfaceActive().
Int Function getFoodPercent()
	Return clampInt(_hunger.GetHungerPercent(), 0, 100)
EndFunction

Int Function getThirstPercent()
	Return clampInt(_thirst.GetThirstPercent(), 0, 100)
EndFunction

Int Function getColdPercent()
	; no percent function on the cold system: same formula as the others
	Int top = _cold._SHColdStage5
	If top <= 0
		Return 0
	EndIf
	GlobalVariable level = _cold._SHCurrentColdLevel
	If !level
		Return 0
	EndIf
	Return clampInt(((level.GetValue() / top) * 100.0) as Int, 0, 100)
EndFunction

Int Function getFatiguePercent()
	Return clampInt(_fatigue.GetFatiguePercent(), 0, 100)
EndFunction

Function _loadFoodIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Full,Satisfied,Content,Peckish,Hungry,Very Hungry,Famished,Starving,Starved", ",")
	loadStageIcon(config, iBars, FOOD_STATE, iconbasepath + "food/food", d)
EndFunction

Function _loadThirstIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Quenched,Refreshed,Fine,Slightly Dry,Thirsty,Very Thirsty,Parched,Dehydrated,Dying of Thirst", ",")
	loadStageIcon(config, iBars, THIRST_STATE, iconbasepath + "thirst/thirst", d)
EndFunction

Function _loadColdIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Warm,Comfortable,Cool,Chilly,Cold,Very Cold,Freezing,Frostbitten,Hypothermic", ",")
	loadStageIcon(config, iBars, COLD_STATE, iconbasepath + "cold/cold", d)
EndFunction

Function _loadFatigueIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Rested,Fresh,Fine,Tired,Weary,Very Tired,Exhausted,Drained,Collapsing", ",")
	loadStageIcon(config, iBars, FATIGUE_STATE, iconbasepath + "fatigue/fatigue", d)
EndFunction
