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
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_releaseParasiteIcons(iBars, slot)
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	If !target || !config.isOnForSlot(config.module_parasites_enabled, slot, config.MOD_SLP) || !isInterfaceActive()
		_releaseParasiteIcons(iBars, slot)
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	if !target
		return
	endif
	if (config.isOnForSlot(config.module_parasites_enabled, slot, config.MOD_SLP) && isInterfaceActive())
		_reloadParasiteIcons(iBars, target, slot)
	endIf
EndEvent

Function _releaseParasiteIcons(iWant_Status_Bars iBars, Int slot)
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Parasites_SpiderEggs, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Parasites_ChaurusWorm, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Parasites_ChaurusWormVag, slot))
EndFunction

;Parasites
 Function _reloadParasiteIcons(iWant_Status_Bars iBars, Actor target, Int slot)
	if isInfectedBySLP(slp, target,"SpiderEgg")
		_loadSpiderIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Parasites_SpiderEggs, slot))
	endif

	if isInfectedBySLP(slp, target,"ChaurusWorm")
		_loadChaurusWormIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Parasites_ChaurusWorm, slot))
	endif

	if isInfectedBySLP(slp, target,"ChaurusWormVag")
		_loadChaurusWormVagIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Parasites_ChaurusWormVag, slot))
	endif
EndFunction

Function _loadSpiderIcon(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(Parasites_SpiderEggs, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Parasites_SpiderEggs, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadChaurusWormVagIcon(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(Parasites_ChaurusWormVag, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Parasites_ChaurusWormVag, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadChaurusWormIcon(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(Parasites_ChaurusWorm, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Parasites_ChaurusWorm, slot), d, s, r, g, b, a, slot)
EndFunction	

