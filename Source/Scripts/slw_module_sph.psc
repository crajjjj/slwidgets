Scriptname slw_module_sph extends slw_base_module
{SPH - Skyrim Pubic Hair: the player's pubic and armpit hair length. SPH
mirrors both stages into globals for its own menu conditions (pubic length
0-5 with the shaving style folded in, armpit stage 0-6), so nothing is
called into. Player only: SPH grows hair on no one else.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

GlobalVariable _pubicLength
GlobalVariable _armpitStage

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
	If Module_Ready || !isSPHReady()
		Return
	EndIf
	WriteLog("ModuleSPH: SPH - Skyrim Pubic Hair.esp found")
	_pubicLength = Game.GetFormFromFile(0x000880, "SPH - Skyrim Pubic Hair.esp") as GlobalVariable
	_armpitStage = Game.GetFormFromFile(0x000882, "SPH - Skyrim Pubic Hair.esp") as GlobalVariable
	If _pubicLength && _armpitStage
		Module_Ready = true
	Else
		WriteLog("ModuleSPH: SPH_GPubicLength / SPH_GArmpitStage not found (SPH 2.0 or newer is needed)", 2)
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
		Int pubicCurr = clampInt(_pubicLength.GetValue() as Int, 0, 5)
		If _pubic_prv == EMPTY || _pubic_prv != pubicCurr
			iBars.setIconStatus(slwGetModName(), PUBIC_STATE, pubicCurr)
			_pubic_prv = pubicCurr
		EndIf
	EndIf
	If config.isOn(config.module_sph_armpit)
		Int armpitCurr = clampInt(_armpitStage.GetValue() as Int, 0, 6)
		If _armpit_prv == EMPTY || _armpit_prv != armpitCurr
			iBars.setIconStatus(slwGetModName(), ARMPIT_STATE, armpitCurr)
			_armpit_prv = armpitCurr
		EndIf
	EndIf
EndEvent

Function _loadPubicIcon(iWant_Status_Bars iBars)
	; SPH's own stage names
	String[] d = StringUtil.Split("Shaved,Shadow,Stubble,Short,Long,Untamed", ",")
	loadStageIcon(config, iBars, PUBIC_STATE, iconbasepath + "pubic/pubic", d)
EndFunction

Function _loadArmpitIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Shaved,Shadow,Stubble,Short,Medium,Long,Very Long", ",")
	loadStageIcon(config, iBars, ARMPIT_STATE, iconbasepath + "armpit/armpit", d)
EndFunction
