Scriptname slw_module_defeat extends slw_base_module  
import slw_log
import slw_util

slw_config Property config Auto
Actor Property PlayerRef Auto

Bool Property Module_Ready = false auto hidden
;SL Defeat
String DEFEAT_RAPED_STATE = "Defeat_Raped"
Spell _defeatRapedSpell 
Spell _defeatBeingRapedSpell

string iconbasepath = "widgets/iwant/widgets/library/defeatmod/"

Bool Function isInterfaceActive()
	Return  Module_Ready
EndFunction

Function initInterface()
	If (!Module_Ready && isSLDefeatReady())
		WriteLog("ModuleCombat: SexLabDefeat.esp found")
		Module_Ready = true 
		_defeatBeingRapedSpell = Game.GetFormFromFile(0x01D90, "SexLabDefeat.esp") as Spell
		_defeatRapedSpell = Game.GetFormFromFile(0x012C7, "SexLabDefeat.esp") as Spell
		if !_defeatBeingRapedSpell || _defeatRapedSpell
			WriteLog("ModuleCombat:: defeat spells not found", 2)
		endif
	endif
EndFunction

Event onWidgetReload(iWant_Status_Bars iBars)
	if(!config.module_defeat_enabled || !isInterfaceActive())
		_releaseDefeatIcons(iBars)
	endif
EndEvent

Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.module_defeat_enabled && isInterfaceActive())
		_reloadDefeatIcons(iBars)
	endIf
EndEvent

Function _reloadDefeatIcons(iWant_Status_Bars iBars)
	if !isInterfaceActive()
		return
	endif
	
	if PlayerRef.HasSpell(_defeatRapedSpell) || PlayerRef.HasSpell(_defeatBeingRapedSpell)
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

