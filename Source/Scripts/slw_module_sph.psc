Scriptname slw_module_sph extends slw_base_module
{SPH - Skyrim Pubic Hair: the player's pubic and armpit hair length, pubic
0-5 with the shaving style folded in, armpit 0-6. Read from SPH's main quest
script through slw_interface_sph. SPH also mirrors both into globals, but
only when its shave and growth-cream menus open, so up to 3.4.3 the icons
read those and never followed growth. The globals stay as the fallback when
the quest cannot be cast. Player only: SPH's NPC hair is a separate add-on.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

GlobalVariable _pubicLength
GlobalVariable _armpitStage
Quest _sphMain
Bool _sphFallbackLogged = false

String PUBIC_STATE = "SPH_Pubic"
String ARMPIT_STATE = "SPH_Armpit"
string iconbasepath = "widgets/iwant/widgets/library/sph/"
int EMPTY = -1
int _pubic_prv = -1
int _armpit_prv = -1

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

;override
Function resetInterface()
	Module_Ready = false
	_pubic_prv = EMPTY
	_armpit_prv = EMPTY
EndFunction

;override
Function initInterface()
	If !isSPHReady()
		If Module_Ready
			; the plugin left the load order: its forms read None from now on
			WriteLog("ModuleSPH: SPH no longer installed")
			Module_Ready = false
			_sphMain = None
		EndIf
		Return
	EndIf
	If !Module_Ready
		WriteLog("ModuleSPH: SPH - Skyrim Pubic Hair.esp found")
		_pubicLength = Game.GetFormFromFile(0x000880, "SPH - Skyrim Pubic Hair.esp") as GlobalVariable
		_armpitStage = Game.GetFormFromFile(0x000882, "SPH - Skyrim Pubic Hair.esp") as GlobalVariable
		If _pubicLength && _armpitStage
			Module_Ready = true
		Else
			WriteLog("ModuleSPH: SPH_GPubicLength / SPH_GArmpitStage not found (SPH 2.0 or newer is needed)", 2)
		EndIf
	EndIf
	; outside the first-detection block: a save from 3.4.3 or older is already
	; Module_Ready without it
	If Module_Ready && !_sphMain
		_sphMain = Game.GetFormFromFile(0x000800, "SPH - Skyrim Pubic Hair.esp") as Quest
	EndIf
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_pubic_prv = EMPTY
	_armpit_prv = EMPTY
	iBars.releaseIcon(slwGetModName(), PUBIC_STATE)
	iBars.releaseIcon(slwGetModName(), ARMPIT_STATE)
	If !target || !isInterfaceActive()
		Return
	EndIf
	If config.isOn(config.module_sph_pubic)
		_loadPubicIcon(iBars)
	EndIf
	If config.isOn(config.module_sph_armpit)
		_loadArmpitIcon(iBars)
	EndIf
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	Bool ready = target && isInterfaceActive()
	If ready && config.isOn(config.module_sph_pubic)
		_loadPubicIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), PUBIC_STATE)
		_pubic_prv = EMPTY
	EndIf
	If ready && config.isOn(config.module_sph_armpit)
		_loadArmpitIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), ARMPIT_STATE)
		_armpit_prv = EMPTY
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	If !target || !isInterfaceActive()
		Return
	EndIf
	If config.isOn(config.module_sph_pubic)
		Int pubicCurr = slw_interface_sph.getPubicLength(_sphMain)
		If pubicCurr < 0
			_logFallback()
			pubicCurr = _pubicLength.GetValue() as Int
		EndIf
		pubicCurr = clampInt(pubicCurr, 0, 5)
		If _pubic_prv == EMPTY || _pubic_prv != pubicCurr
			iBars.setIconStatus(slwGetModName(), PUBIC_STATE, pubicCurr)
			_pubic_prv = pubicCurr
		EndIf
	EndIf
	If config.isOn(config.module_sph_armpit)
		Int armpitCurr = slw_interface_sph.getArmpitStage(_sphMain)
		If armpitCurr < 0
			_logFallback()
			armpitCurr = _armpitStage.GetValue() as Int
		EndIf
		armpitCurr = clampInt(armpitCurr, 0, 6)
		If _armpit_prv == EMPTY || _armpit_prv != armpitCurr
			iBars.setIconStatus(slwGetModName(), ARMPIT_STATE, armpitCurr)
			_armpit_prv = armpitCurr
		EndIf
	EndIf
EndEvent

; The globals change only when SPH's menus open, so a fallback to them is a
; frozen icon: worth one line in the log
Function _logFallback()
	If !_sphFallbackLogged
		_sphFallbackLogged = true
		WriteLog("ModuleSPH: SPH_Main (quest 0x800) could not be read; the icons follow SPH's menu globals, which change only when its menus open", 1)
	EndIf
EndFunction

Function _loadPubicIcon(iWant_Status_Bars iBars)
	; SPH's own stage names
	String[] d = StringUtil.Split("Shaved,Shadow,Stubble,Short,Long,Untamed", ",")
	loadStageIcon(config, iBars, PUBIC_STATE, 0, iconbasepath + "pubic/pubic", d)
EndFunction

Function _loadArmpitIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Shaved,Shadow,Stubble,Short,Medium,Long,Very Long", ",")
	loadStageIcon(config, iBars, ARMPIT_STATE, 0, iconbasepath + "armpit/armpit", d)
EndFunction
