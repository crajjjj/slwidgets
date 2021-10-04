Scriptname slw_module_pregnancy extends slw_base_module  
import slw_log
import slw_util

slw_config Property config Auto
Actor Property PlayerRef Auto

Bool Property Plugin_EstrusChaurus = false auto hidden
Bool Property Plugin_EstrusSpider = false auto hidden
Bool Property Plugin_EstrusDwemer = false auto hidden
Bool Property Plugin_EggFactory = false auto hidden
Bool Property Plugin_BeeingFemale = false auto hidden
Bool Property Plugin_FertilityMode3 = false auto hidden
Bool Property Plugin_HentaiPregnancy = false auto hidden

Spell _BFStatePregnant 
Faction _HentaiPregnantFaction
Faction _EggFactoryPregnantFaction

Spell _ChaurusBreederSpell
Keyword _zzEstrusParasiteKeyword

Spell _SpiderBreederSpell
Keyword _zzEstrusSpiderParasiteKWD

Spell _DwemerBreederSpell
Keyword _zzEstrusDwemerParasiteKWD

_JSW_BB_Storage _FMStorage

;Pregnancy
String Pregnancy_Basic = "Pregnancy_Basic"
String Pregnancy_CumInflation = "Pregnancy_CumInflation"
String Pregnancy_Ovulation = "Pregnancy_Ovulation"
String Pregnancy_Fetus = "Pregnancy_Fetus"
String Pregnancy_Eggs = "Pregnancy_Eggs"
String Pregnancy_Spider_Eggs = "Pregnancy_Spider_Eggs"
String Pregnancy_Chaurus_Eggs = "Pregnancy_Chaurus_Eggs"
String Pregnancy_Dwemer_Spheres = "Pregnancy_Dwemer_Spheres"

String akActorName

string iconbasepath = "widgets/iwant/widgets/library/pregnancymod/"


Function initInterface()
	akActorName = playerRef.GetLeveledActorBase().GetName()
	
	If (!Plugin_EstrusChaurus && isECReady())
		WriteLog("ModulePregnancy: EstrusChaurus.esp found")
		Plugin_EstrusChaurus = true
		_ChaurusBreederSpell = Game.GetFormFromFile(0x19121, "EstrusChaurus.esp") as Spell
		if !_ChaurusBreederSpell
			WriteLog("ModulePregnancy: _ChaurusBreederSpell not found", 2)
		endif
		_zzEstrusParasiteKeyword = Game.GetFormFromFile(0x160A8, "EstrusChaurus.esp") as Keyword
		if !_zzEstrusParasiteKeyword
			WriteLog("ModulePregnancy: _zzEstrusParasiteKeyword not found", 2)
		endif
	endif
	
	If (!Plugin_EstrusSpider && isESReady())
		WriteLog("ModulePregnancy: EstrusSpider.esp found")
		Plugin_EstrusSpider = true
		_SpiderBreederSpell = Game.GetFormFromFile(0x4e255, "EstrusSpider.esp") as Spell
		if !_SpiderBreederSpell
			WriteLog("ModulePregnancy: _SpiderBreederSpell not found", 2)
		endif
		_zzEstrusSpiderParasiteKWD = Game.GetFormFromFile(0x4F2A3, "EstrusSpider.esp") as Keyword
		if !_SpiderBreederSpell
			WriteLog("ModulePregnancy: _zzEstrusSpiderParasiteKWD not found", 2)
		endif
	endif
	
	If (!Plugin_EstrusDwemer && isEDReady())
		WriteLog("ModulePregnancy: EstrusDwemer.esp found")
		Plugin_EstrusDwemer = true
		_DwemerBreederSpell = Game.GetFormFromFile(0x4e255, "EstrusDwemer.esp") as Spell 
		if !_DwemerBreederSpell
			WriteLog("ModulePregnancy: _DwemerBreederSpell not found", 2)
		endif
		_zzEstrusDwemerParasiteKWD = Game.GetFormFromFile(0x4F2A3, "EstrusDwemer.esp") as Keyword
		if !_zzEstrusDwemerParasiteKWD
			WriteLog("ModulePregnancy: _zzEstrusDwemerParasiteKWD not found", 2)
		endif
	endif
	
	If (!Plugin_BeeingFemale && isBFReady())
		WriteLog("ModulePregnancy: BeeingFemale.esm found")
		Plugin_BeeingFemale = true
		_BFStatePregnant = Game.GetFormFromFile(0x28a0, "BeeingFemale.esm") as Spell
		if !_BFStatePregnant
			WriteLog("ModulePregnancy: _BFStatePregnant not found", 2)
		endif
	endif
	
	If (!Plugin_HentaiPregnancy && isHPReady())
		WriteLog("ModulePregnancy: HentaiPregnancy.esm found")
		Plugin_HentaiPregnancy = true
		_HentaiPregnantFaction = ( Game.GetFormFromFile(0x12085, "HentaiPregnancy.esm") as Faction )
		if !_HentaiPregnantFaction
			WriteLog("ModulePregnancy: _HentaiPregnantFaction not found", 2)
		endif
	endif

	If (!Plugin_EggFactory && isEFReady())
		WriteLog("ModulePregnancy: EggFactory found")
		Plugin_EggFactory = true
		_EggFactoryPregnantFaction = Game.GetFormFromFile(0x2943C, "EggFactory.esp") as Faction 
		if !_EggFactoryPregnantFaction
			WriteLog("ModulePregnancy: _EggFactoryPregnantFaction not found", 2)
		endif
	endif

	If (!Plugin_FertilityMode3 && isFM3Ready())
		WriteLog("ModulePregnancy: Fertility Mode found")
		Plugin_FertilityMode3 = true
		_FMStorage = Game.GetFormFromFile(0x000D62,"Fertility Mode.esm") as _JSW_BB_Storage
		if !_FMStorage
			WriteLog("ModulePregnancy: _JSW_BB_Storage not found", 2)
		endif
	endif
EndFunction

Bool Function isInterfaceActive()
	Return (Plugin_EstrusSpider || 	Plugin_EstrusChaurus || Plugin_EstrusDwemer || Plugin_BeeingFemale || Plugin_HentaiPregnancy || Plugin_EggFactory || Plugin_FertilityMode3)
EndFunction

Event onWidgetReload(iWant_Status_Bars iBars)
	if(!config.module_pregnancy_enabled || !isInterfaceActive())
		_releasePregnancyIcons(iBars)
	endif
EndEvent

Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.module_pregnancy_enabled && isInterfaceActive())
		_reloadPregnancyIcons(iBars)
	endIf
EndEvent

Function _releasePregnancyIcons(iWant_Status_Bars iBars)
	if !isInterfaceActive()
		return
	endif
	iBars.releaseIcon(slwGetModName(),Pregnancy_Basic)
	iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Eggs)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Spider_Eggs)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Chaurus_Eggs)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Dwemer_Spheres)
EndFunction


 Function _reloadPregnancyIcons(iWant_Status_Bars iBars)
	if !isInterfaceActive()
		return
	endif
	
	if Plugin_HentaiPregnancy
		handleHentaiPregnancy(iBars)
	endif

	if Plugin_FertilityMode3
		handleFertilityMode3(iBars)
	endif

	;BeeingFemale
	if Plugin_BeeingFemale
		if PlayerRef.HasSpell(_BFStatePregnant) ;_BFStatePregnant spell
			_loadBasicIcon(iBars)
		Else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Basic)
		endif
	endif
	
	;EggFactory
	If Plugin_EggFactory
		if PlayerRef.isInFaction(_EggFactoryPregnantFaction ) ;EggFactoryPregCheck Faction
			_loadEggsIcon(iBars)
		else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Eggs)
		endif
	endif

	;Estrus Chaurus+
	if Plugin_EstrusChaurus
		if PlayerRef.HasSpell(_ChaurusBreederSpell) || PlayerRef.WornHasKeyword(_zzEstrusParasiteKeyword)  
			_loadChaurusEggsIcon(iBars)
		Else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Chaurus_Eggs)
		endif
	endif
	
	;Estrus Spider+
	if Plugin_EstrusSpider
		if PlayerRef.HasSpell( _SpiderBreederSpell) || PlayerRef.WornHasKeyword(_zzEstrusSpiderParasiteKWD) ;SpiderBreeder spell
			_loadSpiderEggsIcon(iBars)
		else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Spider_Eggs)
		endif
	endif
	
	;Estrus Dwemer+
	if Plugin_EstrusDwemer
		if PlayerRef.HasSpell(_DwemerBreederSpell) || PlayerRef.WornHasKeyword(_zzEstrusDwemerParasiteKWD)  ;DwemerBreeder spell
			_loadSphereIcon(iBars)
		else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Dwemer_Spheres)
		endif
	endif
EndFunction

Function handleFertilityMode3(iWant_Status_Bars iBars)
	int actorIndex = _FMStorage.TrackedActors.Find(PlayerRef)
	if (_FMStorage.LastConception[actorIndex] != 0.0)
		; Fired for pregnant actors
		_loadFetusIcon(iBars)
		iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
  	elseIf _FMStorage.LastOvulation[actorIndex] != 0.0
		 ; Fired for ovulating actors
		 _loadOvulationIcon(iBars)
		 iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
	else
		iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
		iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
   endIf

   If (_FMStorage.SpermCount[actorIndex] > 0.0)
	; Fired for inflated actors
		_loadCumInflationIcon(iBars)
   else
		iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
   endIf
EndFunction

;Hentai pregnancy LE/SE
	;You can check pregnancy through "HentaiPregnantFaction" its ranks are: 1- actor is cuminflated 2- actor is cuminflated and will be pregnant 3- actor is pregnant
Function handleHentaiPregnancy(iWant_Status_Bars iBars)
	int _HentaiPregnantFactionRank = PlayerRef.GetFactionRank(_HentaiPregnantFaction)
	if _HentaiPregnantFactionRank == 1 
			_loadCumInflationIcon(iBars)
			iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
			iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
	Elseif _HentaiPregnantFactionRank == 2
			_loadCumInflationIcon(iBars)
			_loadOvulationIcon(iBars)
			iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
	ElseIf _HentaiPregnantFactionRank == 3
			_loadFetusIcon(iBars)
			iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
			iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
	Else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
			iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
			iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
	endif
EndFunction

Function _loadBasicIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "basic.dds"
	d[0] = "PregnantBasic"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Basic, d, s, r, g, b, a)
EndFunction	

Function _loadEggsIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "eggs.dds"
	d[0] = "PregnantEggs"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Eggs, d, s, r, g, b, a)
EndFunction	

Function _loadFetusIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "fetus.dds"
	d[0] = "PregnantFetus"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Fetus, d, s, r, g, b, a)
EndFunction	

Function _loadChaurusEggsIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "chaurusEggs.dds"
	d[0] = "PregnantChaurus"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Chaurus_Eggs, d, s, r, g, b, a)
EndFunction	

Function _loadSpiderEggsIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "spiderEggs.dds"
	d[0] = "PregnantSpider"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Spider_Eggs, d, s, r, g, b, a)
EndFunction	

Function _loadSphereIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "spheres.dds"
	d[0] = "PregnantSpheres"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Dwemer_Spheres, d, s, r, g, b, a)
EndFunction	

Function _loadCumInflationIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "cum.dds"
	d[0] = "PregnantCum"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_CumInflation, d, s, r, g, b, a)
EndFunction	

Function _loadOvulationIcon(iWant_Status_Bars iBars)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	; HentaiPregnant
	s[0] = iconbasepath + "ovulation.dds"
	d[0] = "PregnantOvulation"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Ovulation, d, s, r, g, b, a)
EndFunction	