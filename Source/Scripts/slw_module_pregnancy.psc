Scriptname slw_module_pregnancy extends slw_base_module  
import slw_log
import slw_util
import slw_interface_fm
import slw_interface_eggfact36
import slw_interface_sgo4

slw_config Property config Auto
Actor Property PlayerRef Auto

int EMPTY = -1
int gems_state_prv = -1

Bool Property Plugin_EstrusChaurus = false auto hidden
Bool Property Plugin_EstrusSpider = false auto hidden
Bool Property Plugin_EstrusDwemer = false auto hidden
Bool Property Plugin_EggFactory = false auto hidden
Bool Property Plugin_BeeingFemale = false auto hidden
Bool Property Plugin_FertilityMode3 = false auto hidden
Bool Property Plugin_HentaiPregnancy = false auto hidden
Bool Property Plugin_SGO4 = false auto hidden
Bool Property Plugin_CurseOfLife = false auto hidden

Spell _BFStatePregnant 
Faction _HentaiPregnantFaction
;deprecated
Faction _EggFactoryPregnantFaction
;EggFactory
Quest EggFactoryMasterTimerQuest

Spell _ChaurusBreederSpell
Keyword _zzEstrusParasiteKeyword

Spell _SpiderBreederSpell
Keyword _zzEstrusSpiderParasiteKWD

Spell _DwemerBreederSpell
Keyword _zzEstrusDwemerParasiteKWD

Quest _FMStorage

Quest _dse_sgo_QuestDatabase_Main

;Pregnancy
String Pregnancy_Basic = "Pregnancy_Basic"
String Pregnancy_CumInflation = "Pregnancy_CumInflation"
String Pregnancy_Ovulation = "Pregnancy_Ovulation"
String Pregnancy_Fetus = "Pregnancy_Fetus"
String Pregnancy_Eggs = "Pregnancy_Eggs"
String Pregnancy_Spider_Eggs = "Pregnancy_Spider_Eggs"
String Pregnancy_Chaurus_Eggs = "Pregnancy_Chaurus_Eggs"
String Pregnancy_Dwemer_Spheres = "Pregnancy_Dwemer_Spheres"
String Pregnancy_Gems = "Pregnancy_Gems"

String akActorName

string iconbasepath = "widgets/iwant/widgets/library/pregnancymod/"

;override
Function initInterface()
	akActorName = playerRef.GetLeveledActorBase().GetName()
	
	If (!Plugin_EstrusChaurus && isECReady())
		WriteLog("ModulePregnancy: EstrusChaurus.esp found")
		_ChaurusBreederSpell = Game.GetFormFromFile(0x19121, "EstrusChaurus.esp") as Spell
		_zzEstrusParasiteKeyword = Game.GetFormFromFile(0x160A8, "EstrusChaurus.esp") as Keyword
		Plugin_EstrusChaurus = true
		if !_ChaurusBreederSpell || !_zzEstrusParasiteKeyword
			WriteLog("ModulePregnancy: _ChaurusBreederSpell or _zzEstrusParasiteKeyword  not found", 2)
			Plugin_EstrusChaurus = false
		endif
	endif
	
	If (!Plugin_EstrusSpider && isESReady())
		WriteLog("ModulePregnancy: EstrusSpider.esp found")
		_SpiderBreederSpell = Game.GetFormFromFile(0x4e255, "EstrusSpider.esp") as Spell
		_zzEstrusSpiderParasiteKWD = Game.GetFormFromFile(0x4F2A3, "EstrusSpider.esp") as Keyword
		Plugin_EstrusSpider = true
		if (!_SpiderBreederSpell || !_zzEstrusSpiderParasiteKWD)
			WriteLog("ModulePregnancy: _SpiderBreederSpell or _zzEstrusSpiderParasiteKWD not found", 2)
			Plugin_EstrusSpider = false
		endif
		
	endif
	
	If (!Plugin_EstrusDwemer && isEDReady())
		WriteLog("ModulePregnancy: EstrusDwemer.esp found")
		_DwemerBreederSpell = Game.GetFormFromFile(0x4e255, "EstrusDwemer.esp") as Spell 
		_zzEstrusDwemerParasiteKWD = Game.GetFormFromFile(0x4F2A3, "EstrusDwemer.esp") as Keyword
		Plugin_EstrusDwemer = true
		if (!_DwemerBreederSpell || !_zzEstrusDwemerParasiteKWD)
			WriteLog("ModulePregnancy: _DwemerBreederSpell or _zzEstrusDwemerParasiteKWD not found", 2)
			Plugin_EstrusDwemer = false
		endif
	endif
	
	If (!Plugin_BeeingFemale && isBFReady())
		WriteLog("ModulePregnancy: BeeingFemale.esm found")
		_BFStatePregnant = Game.GetFormFromFile(0x28a0, "BeeingFemale.esm") as Spell
		Plugin_BeeingFemale = true
		if !_BFStatePregnant
			WriteLog("ModulePregnancy: _BFStatePregnant not found", 2)
			Plugin_BeeingFemale = false
		endif
	endif
	
	If (!Plugin_HentaiPregnancy && isHPReady())
		WriteLog("ModulePregnancy: HentaiPregnancy.esm found")
		_HentaiPregnantFaction = ( Game.GetFormFromFile(0x12085, "HentaiPregnancy.esm") as Faction )
		Plugin_HentaiPregnancy = true
		if !_HentaiPregnantFaction
			WriteLog("ModulePregnancy: _HentaiPregnantFaction not found", 2)
			Plugin_HentaiPregnancy = false
		endif
	endif

	If (!Plugin_EggFactory && isEFReady())
		WriteLog("ModulePregnancy: EggFactory found")
		EggFactoryMasterTimerQuest = Game.GetFormFromFile(0x03D261, "EggFactory.esp") as Quest
		Plugin_EggFactory = true
		if !EggFactoryMasterTimerQuest
			WriteLog("ModulePregnancy: EggFactoryMasterTimerQuest not found", 2)
			Plugin_EggFactory = false
		endif

	endif

	If (!Plugin_FertilityMode3 && isFM3Ready())
		WriteLog("ModulePregnancy: Fertility Mode found")
		_FMStorage = Game.GetFormFromFile(0x000D62,"Fertility Mode.esm") as Quest 
		Plugin_FertilityMode3 = true
		if !_FMStorage
			WriteLog("ModulePregnancy: _JSW_BB_Storage not found", 2)
		endif
	endif

	If (!Plugin_SGO4 && isSGO4Ready())
		WriteLog("ModulePregnancy: SGO4 found")
		_dse_sgo_QuestDatabase_Main = Game.GetFormFromFile(0x00182A,"dse-soulgem-oven.esp") as Quest 
		Plugin_SGO4 = true
		if !_dse_sgo_QuestDatabase_Main
			WriteLog("ModulePregnancy: _dse_sgo_QuestDatabase_Main not found", 2)
		endif
	endif

	If (!Plugin_CurseOfLife && isCurseOfLifeReady())
		WriteLog("ModulePregnancy: Curse of life found")
		Plugin_CurseOfLife = true
	endif

EndFunction

;override
Bool Function isInterfaceActive()
	Return (Plugin_EstrusSpider || 	Plugin_EstrusChaurus || Plugin_EstrusDwemer || Plugin_BeeingFemale || Plugin_HentaiPregnancy || Plugin_EggFactory || Plugin_FertilityMode3 || Plugin_SGO4 || Plugin_CurseOfLife)
EndFunction

;override
Function resetInterface()
	Plugin_EstrusSpider = false
	Plugin_EstrusChaurus = false
	Plugin_EstrusDwemer = false
	Plugin_BeeingFemale = false
	Plugin_HentaiPregnancy = false
	Plugin_EggFactory = false
	Plugin_FertilityMode3 = false
	Plugin_SGO4 = false
	Plugin_CurseOfLife = false
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	if(!config.isOn(config.module_pregnancy_enabled) || !isInterfaceActive())
		_releasePregnancyIcons(iBars)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	gems_state_prv = EMPTY
	if (config.isOn(config.module_pregnancy_enabled) && isInterfaceActive())
		_reloadPregnancyIcons(iBars)
	endIf
EndEvent

Function _releasePregnancyIcons(iWant_Status_Bars iBars)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Basic)
	iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Eggs)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Spider_Eggs)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Chaurus_Eggs)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Dwemer_Spheres)
	iBars.releaseIcon(slwGetModName(),Pregnancy_Gems)
EndFunction


 Function _reloadPregnancyIcons(iWant_Status_Bars iBars)
	if Plugin_FertilityMode3
		handleFertilityMode3(iBars)
	elseif Plugin_HentaiPregnancy
		handleHentaiPregnancy(iBars)
	endif

	;BeeingFemale
	if Plugin_BeeingFemale
		if PlayerRef.HasSpell(_BFStatePregnant) ;_BFStatePregnant spell
			_loadBasicIcon(iBars)
		Else
			iBars.releaseIcon(slwGetModName(),Pregnancy_Basic)
		endif
	endif
	
	;Soul Gem Oven 4
	if Plugin_SGO4
		handleSGO4(iBars)
	endif

	
	;EggFactory
	If Plugin_EggFactory
		if isEggFactPregnant(EggFactoryMasterTimerQuest,PlayerRef) ;EggFactoryPregCheck Faction
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

	;Curse Of Life
	if Plugin_CurseOfLife
		handleCOF(iBars)
	endif

EndFunction

Function handleFertilityMode3(iWant_Status_Bars iBars)
	int actorIndex = getFMActorIndex(_FMStorage,PlayerRef)
	if (actorIndex == -1)
		iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
		iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
		iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
		return
	endIf
	if isFMPregnant(_FMStorage,actorIndex)
		; Fired for pregnant actors
		iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
		_loadFetusIcon(iBars)
  	elseIf isFMOvulating(_FMStorage, actorIndex)
		 ; Fired for ovulating actors
		 iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
		 _loadOvulationIcon(iBars)
	else
		iBars.releaseIcon(slwGetModName(),Pregnancy_Fetus)
		iBars.releaseIcon(slwGetModName(),Pregnancy_Ovulation)
   endIf
	; Mismatch error can be shown cause tweaks mod changed SpermCount array to int
   If hasFMSperm(_FMStorage, actorIndex)
	; Fired for inflated actors
		_loadCumInflationIcon(iBars)
   else
		iBars.releaseIcon(slwGetModName(),Pregnancy_CumInflation)
   endIf
EndFunction

Function handleSGO4(iWant_Status_Bars iBars)
	int gems_state_curr = gotGems(_dse_sgo_QuestDatabase_Main,PlayerRef)
	if gems_state_curr > 0
		_loadGemsIcon(iBars)
		if gems_state_prv == EMPTY || gems_state_prv != gems_state_curr
			if gems_state_curr >= 6
				iBars.setIconStatus(slwGetModName(), Pregnancy_Gems, 5)  ;
			else
				iBars.setIconStatus(slwGetModName(), Pregnancy_Gems, gems_state_curr - 1)  ;
			endif
			gems_state_prv = gems_state_curr
		endif
	else
		iBars.releaseIcon(slwGetModName(), Pregnancy_Gems)
		gems_state_prv = EMPTY
	endif
EndFunction

Function handleCOF(iWant_Status_Bars iBars)
	; Overall Status
	float CharusCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_CharusCurrentSize", 0.0)
	float SpiderCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_SpiderCurrentSize", 0.0)
	float DragonCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_DragonCurrentSize", 0.0)
	float BlessingCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_BlessingCurrentSize", 0.0)

	if (CharusCurrentSize > 0)
		_loadChaurusEggsIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(),Pregnancy_Chaurus_Eggs)
	endif

	if (SpiderCurrentSize > 0)
		_loadSpiderEggsIcon(iBars)
	else
		iBars.releaseIcon(slwGetModName(),Pregnancy_Spider_Eggs)
	endif

	if (DragonCurrentSize > 0 || BlessingCurrentSize > 0)
		_loadEggsIcon(iBars)
	else
		iBars.releaseIcon(slwGetModName(),Pregnancy_Eggs)
	endif

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

Function _loadGemsIcon(iWant_Status_Bars iBars)
	String[] s = new String[6]
	String[] d = new String[6]
	Int[] r = new Int[6]
	Int[] g = new Int[6]
	Int[] b = new Int[6]
	Int[] a = new Int[6]

	; HentaiPregnant
	s[0] = iconbasepath + "gems.dds"
	d[0] = "PregnantGems"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	s[1] = iconbasepath + "gems2.dds"
	d[1] = "PregnantGems_2"
	r[1] = 255
	g[1] = 255
	b[1] = 255
	a[1] = 100

	s[2] = iconbasepath + "gems3.dds"
	d[2] = "PregnantGems_3"
	r[2] = 255
	g[2] = 255
	b[2] = 255
	a[2] = 100

	s[3] = iconbasepath + "gems4.dds"
	d[3] = "PregnantGems_4"
	r[3] = 255
	g[3] = 255
	b[3] = 255
	a[3] = 100

	s[4] = iconbasepath + "gems5.dds"
	d[4] = "PregnantGems_5"
	r[4] = 255
	g[4] = 255
	b[4] = 255
	a[4] = 100

	s[5] = iconbasepath + "gems6.dds"
	d[5] = "PregnantGems_6"
	r[5] = 255
	g[5] = 255
	b[5] = 255
	a[5] = 100


	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), Pregnancy_Gems, d, s, r, g, b, a)
EndFunction	