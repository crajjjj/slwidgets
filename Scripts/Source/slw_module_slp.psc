Scriptname slw_module_slp extends Quest  
import slw_log
import slw_util

Actor Property playerRef Auto

Bool Property Plugin_SLP = false auto hidden
;SLP
String Parasites_SpiderEggs = "Parasites_SpiderEggs"
String Parasites_ChaurusWorm = "Parasites_ChaurusWorm"
String Parasites_ChaurusWormVag = "Parasites_ChaurusWormVag"

SLP_fcts_parasites slp
String akActorName

string iconbasepath = "widgets/iwant/widgets/library/slp/parasite"
String[] s
String[] d
Int[] r
Int[] g
Int[] b
Int[] a


Function initInterface()
	slw_log.WriteLog("SLP dlc recheck")
	
	If (!Plugin_SLP && isSLPReady())
		WriteLog("SexLab-Parasites.esp found")
		Plugin_SLP = true
		slp = Game.GetFormFromFile(0x000D62, "SexLab-Parasites.esp") As SLP_fcts_parasites
		akActorName = playerRef.GetLeveledActorBase().GetName()
		if !slp
			WriteLog("SLP: SLP_fcts_parasites not found", 2)
		endif
	endif

EndFunction

Bool Function isInterfaceActive()
	Return  Plugin_SLP
EndFunction

Function releaseParasiteIcons(iWant_Status_Bars iBars)
	if !Plugin_SLP
		return
	endif

	iBars.releaseIcon(slwGetModName(),Parasites_SpiderEggs)
	iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWorm)
	iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWormVag)
EndFunction

;Parasites
 Function reloadParasiteIcons(iWant_Status_Bars iBars)
	if !Plugin_SLP
		return
	endif
	
	if slp.isInfectedByString(playerRef,"SpiderEgg")
		_loadSpiderIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Parasites_SpiderEggs)
	endif

	if slp.isInfectedByString(playerRef,"ChaurusWorm")
		_loadChaurusWormIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWorm)
	endif

	if slp.isInfectedByString(playerRef,"ChaurusWormVag")
		_loadChaurusWormVagIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Parasites_ChaurusWormVag)
	endif
EndFunction

Function _loadSpiderIcon(iWant_Status_Bars iBars)
	s = new String[1]
	d = new String[1]
	r = new Int[1]
	g = new Int[1]
	b = new Int[1]
	a = new Int[1]
	
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
	s = new String[1]
	d = new String[1]
	r = new Int[1]
	g = new Int[1]
	b = new Int[1]
	a = new Int[1]
	
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
	s = new String[1]
	d = new String[1]
	r = new Int[1]
	g = new Int[1]
	b = new Int[1]
	a = new Int[1]
	
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

