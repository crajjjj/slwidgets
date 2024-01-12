Scriptname slw_module_slp extends slw_base_module  
import slw_log
import slw_util
import slw_interface_slp

slw_config Property config Auto
Actor Property PlayerRef Auto

Bool Property Module_Ready = false auto hidden
;SLP
String Parasites_SpiderEggs = "Parasites_SpiderEggs"
String Parasites_ChaurusWorm = "Parasites_ChaurusWorm"
String Parasites_ChaurusWormVag = "Parasites_ChaurusWormVag"

Quest slp
String akActorName

string iconbasepath = "widgets/iwant/widgets/library/slp/parasite"

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
	If (!Module_Ready && isSLPReady())
		WriteLog("ModuleSLP: SexLab-Parasites.esp found")
		Module_Ready = true
		slp = Game.GetFormFromFile(0x000D62, "SexLab-Parasites.esp") As Quest
		akActorName = playerRef.GetLeveledActorBase().GetName()
		if !slp
			WriteLog("ModuleSLP:: SLP_fcts_parasites not found", 2)
			Module_Ready = false
		endif
	endif
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	if(!config.module_parasites_enabled || !isInterfaceActive())
		_releaseParasiteIcons(iBars)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.module_parasites_enabled && isInterfaceActive())
		_reloadParasiteIcons(iBars)
	endIf
EndEvent

Function _releaseParasiteIcons(iWant_Status_Bars iBars)
	iBars.releaseIcon(slwGetModName(),Parasites_SpiderEggs)
	iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWorm)
	iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWormVag)
EndFunction

;Parasites
 Function _reloadParasiteIcons(iWant_Status_Bars iBars)
	if isInfectedBySLP(slp, PlayerRef,"SpiderEgg")
		_loadSpiderIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), Parasites_SpiderEggs)
	endif

	if isInfectedBySLP(slp, PlayerRef,"ChaurusWorm")
		_loadChaurusWormIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), Parasites_ChaurusWorm)
	endif

	if isInfectedBySLP(slp, PlayerRef,"ChaurusWormVag")
		_loadChaurusWormVagIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), Parasites_ChaurusWormVag)
	endif
EndFunction

Function _loadSpiderIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "0.dds"
	d[0] = "SpiderEggs"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Parasites_SpiderEggs, d, s, r, g, b, a)
EndFunction	

Function _loadChaurusWormVagIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "1.dds"
	d[0] = "ChaurusWormVag"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Parasites_ChaurusWormVag, d, s, r, g, b, a)
EndFunction	

Function _loadChaurusWormIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "2.dds"
	d[0] = "ChaurusWorm"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Parasites_ChaurusWorm, d, s, r, g, b, a)
EndFunction	

