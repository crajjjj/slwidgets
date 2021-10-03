Scriptname slw_module_slp extends slw_base_module  
import slw_log
import slw_util

slw_config Property config Auto
Actor Property PlayerRef Auto

Bool Property Module_Ready = false auto hidden
;SLP
String Parasites_SpiderEggs = "Parasites_SpiderEggs"
String Parasites_ChaurusWorm = "Parasites_ChaurusWorm"
String Parasites_ChaurusWormVag = "Parasites_ChaurusWormVag"

SLP_fcts_parasites slp
String akActorName

string iconbasepath = "widgets/iwant/widgets/library/slp/parasite"

Bool Function isInterfaceActive()
	Return  Module_Ready
EndFunction

Function initInterface()
	slw_log.WriteLog("SLP dlc recheck")
	If (!Module_Ready && isSLPReady())
		WriteLog("SexLab-Parasites.esp found")
		Module_Ready = true
		slp = Game.GetFormFromFile(0x000D62, "SexLab-Parasites.esp") As SLP_fcts_parasites
		akActorName = playerRef.GetLeveledActorBase().GetName()
		if !slp
			WriteLog("SLP: SLP_fcts_parasites not found", 2)
		endif
	endif
EndFunction

Event onWidgetReload(iWant_Status_Bars iBars)
	if(!config.module_parasites_enabled || !isInterfaceActive())
		_releaseParasiteIcons(iBars)
	endif
EndEvent

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
	if slp.isInfectedByString(PlayerRef,"SpiderEgg")
		_loadSpiderIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Parasites_SpiderEggs)
	endif

	if slp.isInfectedByString(PlayerRef,"ChaurusWorm")
		_loadChaurusWormIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWorm)
	endif

	if slp.isInfectedByString(PlayerRef,"ChaurusWormVag")
		_loadChaurusWormVagIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWormVag)
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

