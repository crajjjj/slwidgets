Scriptname slw_module_sldefeat extends slw_base_module  
import slw_log
import slw_util

slw_config Property config Auto
Actor Property PlayerRef Auto

Bool Property Module_Ready = false auto hidden
;SL Defeat
String DEFEAT_RAPED_STATE = "Defeat_Raped"

MagicEffect _defeatWeakened

string iconbasepath = "widgets/iwant/widgets/library/defeatmod/"
;override
Bool Function isInterfaceActive()
	Return  Module_Ready
EndFunction
;override
Function resetInterface()
	Module_Ready = false
EndFunction

;override
Function initInterface()
	If (!Module_Ready && isSLDefeatReady())
		WriteLog("ModuleDefeat: SexLabDefeat.esp found")
		Module_Ready = true 
		_defeatWeakened = Game.GetFormFromFile(0x0012C9, "SexLabDefeat.esp") as MagicEffect
		if !_defeatWeakened
			WriteLog("ModuleDefeat:: _defeatWeakened magicEffect not found", 2)
		else
			WriteLog("ModuleDefeat:: _defeatWeakened found")
		endif
	endif
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	if(!config.module_defeat_enabled || !isInterfaceActive())
		_releaseDefeatIcons(iBars)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.module_defeat_enabled && isInterfaceActive())
		_reloadDefeatIcons(iBars)
	endIf
EndEvent

Function _reloadDefeatIcons(iWant_Status_Bars iBars)
	if !isInterfaceActive()
		return
	endif
	if PlayerRef.HasMagicEffect(_defeatWeakened)
		_loadDefeatRapedIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),DEFEAT_RAPED_STATE)
	endif
EndFunction

Function _releaseDefeatIcons(iWant_Status_Bars iBars)
	if !isInterfaceActive()
		return
	endif
	iBars.releaseIcon(slwGetModName(), DEFEAT_RAPED_STATE)
EndFunction

Function _loadDefeatRapedIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; SLDefeatRaped
	s[0] = iconbasepath + "raped.dds"
	d[0] = "Defeat Raped"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), DEFEAT_RAPED_STATE, d, s, r, g, b, a)
EndFunction	

