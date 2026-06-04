Scriptname slw_module_pregnancy extends slw_base_module  
import slw_log
import slw_util
import slw_interface_fm
import slw_interface_eggfact36
import slw_interface_sgo4

slw_config Property config Auto
Actor Property PlayerRef Auto

int EMPTY = -1
int FM3_EMPTY = -2
int[] gems_state_prv
Float[] GemPrePercent

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
;BeeingFemale
Quest fwControllerQuest

Spell _ChaurusBreederSpell
Keyword _zzEstrusParasiteKeyword

Spell _SpiderBreederSpell
Keyword _zzEstrusSpiderParasiteKWD

Spell _DwemerBreederSpell
Keyword _zzEstrusDwemerParasiteKWD
;FM
Quest _FMStorage
Spell _JSW_BB_Trimester1
Spell _JSW_BB_Trimester2
Spell _JSW_BB_Trimester3
Spell _JSW_BB_Ovulation

;BF
Quest _dse_sgo_QuestDatabase_Main

;Pregnancy
String Pregnancy_Basic = "Pregnancy_Basic"
String Pregnancy_Trimester1 = "Pregnancy_Trimester1"
String Pregnancy_Trimester2 = "Pregnancy_Trimester2"
String Pregnancy_Trimester3 = "Pregnancy_Trimester3"
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
	_ensurePrvArrays()
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
		fwControllerQuest = Game.GetFormFromFile(0x182A, "BeeingFemale.esm") as Quest
		Plugin_BeeingFemale = true
		if !_BFStatePregnant
			WriteLog("ModulePregnancy: _BFStatePregnant not found", 2)
			Plugin_BeeingFemale = false
		endif
		if !fwControllerQuest
			WriteLog("ModulePregnancy: fwControllerQuest not found", 2)
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
		_JSW_BB_Trimester1 = Game.GetFormFromFile(0x01B816,"Fertility Mode.esm") as Spell
 		_JSW_BB_Trimester2 = Game.GetFormFromFile(0x01B818,"Fertility Mode.esm") as Spell
 		_JSW_BB_Trimester3 = Game.GetFormFromFile(0x01B81A,"Fertility Mode.esm") as Spell
		_JSW_BB_Ovulation = Game.GetFormFromFile(0x0181E2,"Fertility Mode.esm") as Spell
		Plugin_FertilityMode3 = true
		if !_FMStorage
			WriteLog("ModulePregnancy: _FMStorage not found", 2)
			Plugin_FertilityMode3 = false
		endif
		if !_JSW_BB_Trimester1
			WriteLog("ModulePregnancy: _JSW_BB_Trimester1 not found", 2)
			Plugin_FertilityMode3 = false
		endif
		if !_JSW_BB_Trimester2
			WriteLog("ModulePregnancy: _JSW_BB_Trimester2 not found", 2)
			Plugin_FertilityMode3 = false
		endif
		if !_JSW_BB_Trimester3
			WriteLog("ModulePregnancy: _JSW_BB_Trimester3 not found", 2)
			Plugin_FertilityMode3 = false
		endif
		if !_JSW_BB_Ovulation
			WriteLog("ModulePregnancy: _JSW_BB_Ovulation not found", 2)
			Plugin_FertilityMode3 = false
		endif
		if Plugin_FertilityMode3
			WriteLog("ModulePregnancy: FM3 fully initialized, all forms resolved")
		else
			WriteLog("ModulePregnancy: FM3 init failed, one or more forms missing", 2)
		endif
	endif

	If (!Plugin_SGO4 && isSGO4Ready())
		WriteLog("ModulePregnancy: SGO4 found")
		_dse_sgo_QuestDatabase_Main = Game.GetFormFromFile(0x00182A,"dse-soulgem-oven.esp") as Quest 
		Plugin_SGO4 = true
		if !_dse_sgo_QuestDatabase_Main
			WriteLog("ModulePregnancy: _dse_sgo_QuestDatabase_Main not found", 2)
			Plugin_SGO4 = false
		endif
	endif

	If (!Plugin_CurseOfLife && isCurseOfLifeReady())
		WriteLog("ModulePregnancy: Curse of life found")
		Plugin_CurseOfLife = true
	endif

	if isInterfaceActive()
		WriteLog("ModulePregnancy: active plugins - EC:" + Plugin_EstrusChaurus + " ES:" + Plugin_EstrusSpider + " ED:" + Plugin_EstrusDwemer + " BF:" + Plugin_BeeingFemale + " HP:" + Plugin_HentaiPregnancy + " EF:" + Plugin_EggFactory + " FM3:" + Plugin_FertilityMode3 + " SGO4:" + Plugin_SGO4 + " COL:" + Plugin_CurseOfLife)
	else
		WriteLog("ModulePregnancy: no pregnancy mods detected")
	endif

EndFunction

;override
Bool Function isInterfaceActive()
	Return (Plugin_EstrusSpider || 	Plugin_EstrusChaurus || Plugin_EstrusDwemer || Plugin_BeeingFemale || Plugin_HentaiPregnancy || Plugin_EggFactory || Plugin_FertilityMode3 || Plugin_SGO4 || Plugin_CurseOfLife)
EndFunction

Function _ensurePrvArrays()
	If !gems_state_prv
		gems_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !GemPrePercent
		GemPrePercent = Utility.CreateFloatArray(getSlotCount(), 0.0)
	EndIf
	If !_fm3_actorIndex_prv
		_fm3_actorIndex_prv = Utility.CreateIntArray(getSlotCount(), FM3_EMPTY)
	EndIf
	If !_bf_state_prv
		_bf_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !_hp_rank_prv
		_hp_rank_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
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
	gems_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	GemPrePercent = Utility.CreateFloatArray(getSlotCount(), 0.0)
	_fm3_actorIndex_prv = Utility.CreateIntArray(getSlotCount(), FM3_EMPTY)
	_bf_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	_hp_rank_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	_releasePregnancyIcons(iBars, slot)
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	If !target || !config.isOnForSlot(config.module_pregnancy_enabled, slot, config.MOD_PREG) || !isInterfaceActive()
		_releasePregnancyIcons(iBars, slot)
		gems_state_prv[slot] = EMPTY
		GemPrePercent[slot] = 0.0
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	if !target
		return
	endif
	if (config.isOnForSlot(config.module_pregnancy_enabled, slot, config.MOD_PREG) && isInterfaceActive())
		_reloadPregnancyIcons(iBars, target, slot)
	endIf
EndEvent

Function _releasePregnancyIcons(iWant_Status_Bars iBars, Int slot)
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Basic, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_CumInflation, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Fetus, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Eggs, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Spider_Eggs, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Chaurus_Eggs, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Dwemer_Spheres, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Gems, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester1, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester2, slot))
	iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester3, slot))
EndFunction


 Function _reloadPregnancyIcons(iWant_Status_Bars iBars, Actor target, Int slot)
	if Plugin_FertilityMode3
		handleFertilityMode3(iBars, target, slot)
	elseif Plugin_HentaiPregnancy
		handleHentaiPregnancy(iBars, target, slot)
	elseif Plugin_BeeingFemale
		handleBeeingFemale(iBars, target, slot)
	endif

	;Soul Gem Oven 4
	if Plugin_SGO4
		handleSGO4(iBars, target, slot)
	endif


	;EggFactory
	If Plugin_EggFactory
		if isEggFactPregnant(EggFactoryMasterTimerQuest, target) ;EggFactoryPregCheck Faction
			_loadEggsIcon(iBars, slot)
		else
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Eggs, slot))
		endif
	endif

	;Estrus Chaurus+
	if Plugin_EstrusChaurus
		if target.HasSpell(_ChaurusBreederSpell) || target.WornHasKeyword(_zzEstrusParasiteKeyword)
			_loadChaurusEggsIcon(iBars, slot)
		Else
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Chaurus_Eggs, slot))
		endif
	endif

	;Estrus Spider+
	if Plugin_EstrusSpider
		if target.HasSpell( _SpiderBreederSpell) || target.WornHasKeyword(_zzEstrusSpiderParasiteKWD) ;SpiderBreeder spell
			_loadSpiderEggsIcon(iBars, slot)
		else
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Spider_Eggs, slot))
		endif
	endif

	;Estrus Dwemer+
	if Plugin_EstrusDwemer
		if target.HasSpell(_DwemerBreederSpell) || target.WornHasKeyword(_zzEstrusDwemerParasiteKWD)  ;DwemerBreeder spell
			_loadSphereIcon(iBars, slot)
		else
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Dwemer_Spheres, slot))
		endif
	endif

	;Curse Of Life — global state, only meaningful for player
	if Plugin_CurseOfLife && slot == 0
		handleCOF(iBars, slot)
	endif

EndFunction

;BeeingFemale
; $FW_MENU_INFO_StateName0	Follicular phase
; $FW_MENU_INFO_StateName1	Ovulating
; $FW_MENU_INFO_StateName2	Luteal phase
; $FW_MENU_INFO_StateName3	Menstruation
; $FW_MENU_INFO_StateName4	1st Trimester
; $FW_MENU_INFO_StateName5	2nd Trimester
; $FW_MENU_INFO_StateName6	3rd Trimester
; $FW_MENU_INFO_StateName7	Labor pains
; $FW_MENU_INFO_StateName8	Replanish
; $FW_MENU_INFO_StateName20	Pregnant
; $FW_MENU_INFO_StateName21	Pregnant by chaurus
int[] _bf_state_prv

Function handleBeeingFemale(iWant_Status_Bars iBars, Actor target, Int slot)
	int st = StorageUtil.GetIntValue(target, "FW.CurrentState", 0)
	bool isCumInside = slw_interface_bf.HasRelevantSperm(fwControllerQuest, target)
	if st != _bf_state_prv[slot]
		WriteLog("ModulePregnancy: BF state changed " + _bf_state_prv[slot] + " -> " + st + ", cum:" + isCumInside)
		_bf_state_prv[slot] = st
	endif

	bool showOvulation = (st == 1 || st == 2)
	bool showCumInflation = (st < 4 && isCumInside)
	bool showBasic = (st == 20)
	bool showTrimester1 = (st == 4)
	bool showTrimester2 = (st == 5)
	bool showTrimester3 = (st == 6 || st == 7)
	bool showChaurusEggs = (st == 21)

	if showOvulation
		_loadOvulationIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
	endif

	if showCumInflation
		_loadCumInflationIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_CumInflation, slot))
	endif

	if showBasic
		_loadBasicIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Basic, slot))
	endif

	if showTrimester1
		_loadTrimester1Icon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester1, slot))
	endif

	if showTrimester2
		_loadTrimester2Icon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester2, slot))
	endif

	if showTrimester3
		_loadTrimester3Icon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester3, slot))
	endif

	if showChaurusEggs
		_loadChaurusEggsIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Chaurus_Eggs, slot))
	endif

EndFunction
int[] _fm3_actorIndex_prv

Function handleFertilityMode3(iWant_Status_Bars iBars, Actor target, Int slot)
	int actorIndex = getFMActorIndex(_FMStorage, target)
	if actorIndex != _fm3_actorIndex_prv[slot]
		if actorIndex == -1
			WriteLog("ModulePregnancy: FM3 player not in TrackedActors, releasing icons", 1)
		else
			WriteLog("ModulePregnancy: FM3 player tracked at index " + actorIndex)
		endif
		_fm3_actorIndex_prv[slot] = actorIndex
	endif
	if (actorIndex == -1)
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester1, slot))
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester2, slot))
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester3, slot))
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Fetus, slot))
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_CumInflation, slot))
		return
	endIf

	if target.HasSpell(_JSW_BB_Ovulation)
		_loadOvulationIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
	endif

	if target.HasSpell(_JSW_BB_Trimester1)
		_loadTrimester1Icon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester1, slot))
	endif

	if target.HasSpell(_JSW_BB_Trimester2)
		_loadTrimester2Icon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester2, slot))
	endif

	if target.HasSpell(_JSW_BB_Trimester3)
		_loadTrimester3Icon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Trimester3, slot))
	endif

	; Mismatch error can be shown cause tweaks mod changed SpermCount array to int
  	If hasFMSperm(_FMStorage, actorIndex)
	; Fired for inflated actors
		_loadCumInflationIcon(iBars, slot)
    else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_CumInflation, slot))
    endIf

EndFunction

Function handleSGO4(iWant_Status_Bars iBars, Actor target, Int slot)
	int gems_state_curr = gotGems(_dse_sgo_QuestDatabase_Main, target)
	Float GemTotalPercent = gotGemTotalPercent(_dse_sgo_QuestDatabase_Main, target)
	GemTotalPercent = ((GemTotalPercent*100.0) as Int) /100.0
	if gems_state_curr > 0
		if gems_state_prv[slot] == EMPTY || gems_state_prv[slot] != gems_state_curr || GemPrePercent[slot] != GemTotalPercent
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Gems, slot))
			_loadGemsIcon(iBars, slot, GemTotalPercent)
			if gems_state_curr >= 6
				iBars.setIconStatus(slwGetModName(), getIconNameForSlot(Pregnancy_Gems, slot), 5)
			else
				iBars.setIconStatus(slwGetModName(), getIconNameForSlot(Pregnancy_Gems, slot), gems_state_curr - 1)
			endif
			gems_state_prv[slot] = gems_state_curr
			GemPrePercent[slot] = GemTotalPercent
		endif
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Gems, slot))
		gems_state_prv[slot] = EMPTY
		GemPrePercent[slot] = 0.0
	endif
EndFunction

Function handleCOF(iWant_Status_Bars iBars, Int slot)
	; Overall Status
	float CharusCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_CharusCurrentSize", 0.0)
	float SpiderCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_SpiderCurrentSize", 0.0)
	float DragonCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_DragonCurrentSize", 0.0)
	float BlessingCurrentSize = StorageUtil.GetFloatValue(none, "CurseOfLife_BlessingCurrentSize", 0.0)

	if (CharusCurrentSize > 0)
		_loadChaurusEggsIcon(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Chaurus_Eggs, slot))
	endif

	if (SpiderCurrentSize > 0)
		_loadSpiderEggsIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Spider_Eggs, slot))
	endif

	if (DragonCurrentSize > 0 || BlessingCurrentSize > 0)
		_loadEggsIcon(iBars, slot)
	else
		iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Eggs, slot))
	endif

EndFunction

int[] _hp_rank_prv

;Hentai pregnancy LE/SE
	;You can check pregnancy through "HentaiPregnantFaction" its ranks are: 1- actor is cuminflated 2- actor is cuminflated and will be pregnant 3- actor is pregnant
Function handleHentaiPregnancy(iWant_Status_Bars iBars, Actor target, Int slot)
	int _HentaiPregnantFactionRank = target.GetFactionRank(_HentaiPregnantFaction)
	if _HentaiPregnantFactionRank != _hp_rank_prv[slot]
		WriteLog("ModulePregnancy: HP faction rank changed " + _hp_rank_prv[slot] + " -> " + _HentaiPregnantFactionRank)
		_hp_rank_prv[slot] = _HentaiPregnantFactionRank
	endif
	if _HentaiPregnantFactionRank == 1
			_loadCumInflationIcon(iBars, slot)
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Fetus, slot))
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
	Elseif _HentaiPregnantFactionRank == 2
			_loadCumInflationIcon(iBars, slot)
			_loadOvulationIcon(iBars, slot)
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Fetus, slot))
	ElseIf _HentaiPregnantFactionRank == 3
			_loadFetusIcon(iBars, slot)
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_CumInflation, slot))
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
	Else
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Ovulation, slot))
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_CumInflation, slot))
			iBars.releaseIcon(slwGetModName(), getIconNameForSlot(Pregnancy_Fetus, slot))
	endif
EndFunction

Function _loadBasicIcon(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(Pregnancy_Basic, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Basic, slot), d, s, r, g, b, a, slot)
EndFunction

Function _loadTrimester1Icon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "preg1.dds"
	d[0] = "Pregnancy_Trimester1"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Trimester1, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Trimester1, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadTrimester2Icon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "preg2.dds"
	d[0] = "Pregnancy_Trimester2"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Trimester2, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Trimester2, slot), d, s, r, g, b, a, slot)
EndFunction

Function _loadTrimester3Icon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "preg3.dds"
	d[0] = "Pregnancy_Trimester3"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Trimester3, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Trimester3, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadEggsIcon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "eggs.dds"
	d[0] = "PregnantEggs"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Eggs, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Eggs, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadFetusIcon(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(Pregnancy_Fetus, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Fetus, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadChaurusEggsIcon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "chaurusEggs.dds"
	d[0] = "PregnantChaurus"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Chaurus_Eggs, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Chaurus_Eggs, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadSpiderEggsIcon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "spiderEggs.dds"
	d[0] = "PregnantSpider"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Spider_Eggs, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Spider_Eggs, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadSphereIcon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "spheres.dds"
	d[0] = "PregnantSpheres"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Dwemer_Spheres, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Dwemer_Spheres, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadCumInflationIcon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	int random = Utility.RandomInt(1,100)
	If (random>=50)
		s[0] = iconbasepath + "cum.dds"
	Else
		s[0] = iconbasepath + "cum1.dds"
	EndIf
	
	d[0] = "PregnantCum"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_CumInflation, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_CumInflation, slot), d, s, r, g, b, a, slot)
EndFunction	

Function _loadOvulationIcon(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = iconbasepath + "ovulation.dds"
	d[0] = "PregnantOvulation"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 100

	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Ovulation, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Ovulation, slot), d, s, r, g, b, a, slot)
EndFunction

Function _loadGemsIcon(iWant_Status_Bars iBars, Int slot, Float GemPercent)
	String[] s = new String[6]
	String[] d = new String[6]
	Int[] r = new Int[6]
	Int[] g = new Int[6]
	Int[] b = new Int[6]
	Int[] a = new Int[6]

	s[0] = iconbasepath + "gems.dds"
	d[0] = "PregnantGems"

	s[1] = iconbasepath + "gems2.dds"
	d[1] = "PregnantGems_2"

	s[2] = iconbasepath + "gems3.dds"
	d[2] = "PregnantGems_3"

	s[3] = iconbasepath + "gems4.dds"
	d[3] = "PregnantGems_4"

	s[4] = iconbasepath + "gems5.dds"
	d[4] = "PregnantGems_5"

	s[5] = iconbasepath + "gems6.dds"
	d[5] = "PregnantGems_6"

	int i = 0
	While (i < 6)
		a[i] = 100
		if GemPercent < 0.1
			r[i] = 255
			g[i] = 255
			b[i] = 255
		Elseif GemPercent < 0.2
			r[i] = 255
			g[i] = 192
			b[i] = 224
		Elseif GemPercent < 0.3
			r[i] = 255
			g[i] = 171
			b[i] = 212
		Elseif GemPercent < 0.4
			r[i] = 255
			g[i] = 140
			b[i] = 202
		Elseif GemPercent < 0.5
			r[i] = 255
			g[i] = 112
			b[i] = 192
		Elseif GemPercent < 0.6
			r[i] = 255
			g[i] = 84
			b[i] = 167
		Elseif GemPercent < 1.0
			r[i] = 255
			g[i] = 8
			b[i] = 127
		Else
			r[i] = 255
			g[i] = 0
			b[i] = 0
		endif
		i += 1
	EndWhile
	; This will fail silently if the icon is already loaded
	config.ApplyIconColors(Pregnancy_Gems, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(Pregnancy_Gems, slot), d, s, r, g, b, a, slot)
EndFunction
