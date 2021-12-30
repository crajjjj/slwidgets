Scriptname slw_util Hidden

Import Debug

String Function slwGetModName() Global
	return "SLWidgets"
EndFunction

;SemVer support
Int Function GetVersion() Global
    Return 20004
    ; 1.0.0   -> 10000
    ; 1.1.0   -> 10100
    ; 1.1.1  -> 10101
    ; 1.61  -> 16100
    ; 10.61.20 -> 106120 
EndFunction

String Function GetVersionString() Global
    Return "2.0.4"
EndFunction

String Function StringIfElse(Bool isTrue, String returnTrue, String returnFalse = "") Global
    If isTrue
        Return returnTrue
    Else
        Return returnFalse
    EndIf
EndFunction

Bool Function isFHUReady() Global
	Return isDependencyReady("sr_FillHerUp.esp")
EndFunction

Bool Function isMMEReady() Global
	Return isDependencyReady("MilkModNEW.esp") 
EndFunction

Bool Function isSLAReady() Global
	Return  isDependencyReady("SexLabAroused.esm")
EndFunction

Bool Function isSLPReady() Global
	Return  isDependencyReady("SexLab-Parasites.esp") 
EndFunction

Bool Function isAprReady() Global
	Return isDependencyReady("Apropos2.esp") 
EndFunction

Bool Function isECReady() Global
	Return isDependencyReady("EstrusChaurus.esp")
EndFunction

Bool Function isESReady() Global
	Return isDependencyReady("EstrusSpider.esp") 
EndFunction

Bool Function isEDReady() Global
	Return isDependencyReady("EstrusDwemer.esp")
EndFunction

Bool Function isBFReady() Global
	Return isDependencyReady("BeeingFemale.esm") 
EndFunction

Bool Function isHPReady() Global
	Return isDependencyReady("HentaiPregnancy.esm")
EndFunction

Bool Function isFM3Ready() Global
	Return isDependencyReady("Fertility Mode.esm")
EndFunction

Bool Function isFM3TweaksReady() Global
	Return isDependencyReady("Fertility Mode 3 Fixes and Updates.esp")
EndFunction

Bool Function isEFReady() Global
	Return isDependencyReady("EggFactory.esp")
EndFunction

Bool Function isPAFReady() Global
	Return  isDependencyReady("PeeAndFart.esp")
EndFunction

Bool Function isMiniNeedsReady() Global
	Return  isDependencyReady("MiniNeeds.esp")
EndFunction

Bool Function isSLDefeatReady() Global
	Return  isDependencyReady("SexLabDefeat.esp")
EndFunction

Bool Function isDependencyReady(String modname) Global
	Return Game.GetModbyName(modname) != 255
EndFunction

Int Function percentToState9(int percent) Global
	if percent < 0
		percent = 0
	elseif percent > 100
		percent = 100
	endIf

	If percent == 0
		return 0
	ElseIf percent < 10
		return 1
	ElseIf percent < 25
		return 2
	ElseIf percent < 40
		return 3
	ElseIf percent < 55
		return 4
	ElseIf percent < 70
		return 5
	ElseIf percent < 85
		return 6
	ElseIf percent < 100
		return 7
	Else
		return 8
	EndIf
EndFunction			

Int Function percentToState5(int percent) Global
    If percent < 0
		percent = 0
	elseif percent > 100
		percent = 100
	endIf

	If percent == 0
		return 0
	ElseIf percent < 25
		return 1
	ElseIf percent < 50
		return 2
	ElseIf percent < 75
		return 3
	Else
		return 4
	EndIf
EndFunction		

;Appropos
;--------------------------------------

ReferenceAlias Function GetAproposAlias(Actor akTarget, Quest apropos2Quest ) Global
	; Search Apropos2 actor aliases as the player alias is not set in stone
	ReferenceAlias AproposTwoAlias = None
	Int i = 0
	ReferenceAlias AliasSelect
	While i < apropos2Quest.GetNumAliases() 
		AliasSelect = apropos2Quest.GetNthAlias(i) as ReferenceAlias
		If AliasSelect.GetReference() as Actor == akTarget
			AproposTwoAlias = AliasSelect
		EndIf
		Return AproposTwoAlias
		i += 1
	EndWhile
	Return AproposTwoAlias
EndFunction
	
Int Function GetWearStateAnal(Actor akTarget,  Quest apropos2Quest) Global
	ReferenceAlias AproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest) 
	if GetAproposAlias(akTarget, apropos2Quest) != None
		Int damage =  (AproposTwoAlias as Apropos2ActorAlias).AnalWearTearState
		If damage <= 8
			return damage
		Else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

Int Function GetWearStateVaginal(Actor akTarget,  Quest apropos2Quest) Global 
	ReferenceAlias AproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if GetAproposAlias(akTarget, apropos2Quest) != None
		Int damage = (AproposTwoAlias as Apropos2ActorAlias).VaginalWearTearState
		If damage <= 8
			return damage
		Else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

Int Function GetWearStateOral(Actor akTarget, Quest apropos2Quest) Global
	ReferenceAlias AproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if GetAproposAlias(akTarget, apropos2Quest) != None
		Int damage = (AproposTwoAlias as Apropos2ActorAlias).OralWearTearState
		If damage <= 8
			return damage
		Else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

;FHU
;--------------------------------------

Int Function GetCumAmount(Actor akTarget, Quest FhuInflateQuest) Global
	int percentage =(FhuInflateQuest as sr_inflateQuest).GetInflationPercentage(akTarget) as int
	return percentToState9(percentage)
EndFunction

Int Function GetCumAmountAnal(Actor akTarget, Quest FhuInflateQuest) Global
	float percentage =(FhuInflateQuest as sr_inflateQuest).GetAnalPercentage(akTarget) * 100.0 
	return percentToState9(percentage as int)
EndFunction

Int Function GetCumAmountVag(Actor akTarget, Quest FhuInflateQuest) Global
	float percentage =(FhuInflateQuest as sr_inflateQuest).GetVaginalPercentage(akTarget) * 100.0 
	return percentToState9(percentage as int)
EndFunction

;PAF/MiniNeeds
;--------------------------------------

Int Function _getPoopLevelPAF( Quest paf) Global
	int pafstate = (paf as PAF_MainQuestScript).PoopState
	if pafstate >= 4
		return  4
	Else
		return pafstate
	endif 
EndFunction

Int Function _getPoopLevelMND(Quest mnd) Global
	if !(mnd as mndController).enablePoop
		return 0
	endif
	int p = getMNDPercent("Poop", mnd)
	return percentToState5(p)
EndFunction

Int Function _getPeeLevelPAF(Quest paf) Global
	int pafstate = (paf as PAF_MainQuestScript).PeeState
	if pafstate >= 4
		return  4
	Else
		return pafstate
	endif 
EndFunction

Int Function _getPeeLevelMND(Quest mnd) Global
	if !(mnd as mndController).enablePiss
		return 0
	endif

	int p = getMNDPercent("Piss", mnd)
	return percentToState5(p)
EndFunction

;fixed function from mnd
int function getMNDPercent(string need, Quest mnd) Global
	mndController mndContr = mnd as mndController
	float now = Utility.GetCurrentGameTime()
	float tsv = 20.0/mndContr.TimeScale.getValue()
	float perc = -1.0
	
	If need=="Piss"
		perc = tsv * 24.0*(now - mndContr.lastTimePiss)/mndContr.timePiss
	elseIf need=="Poop"
		perc = tsv * 24.0*(now - mndContr.lastTimePoop)/mndContr.timePoop
	endIf
	return (perc * 100) as int
endFunction

;FM+
;--------------------------------------

int function getFMActorIndex( Quest fm, Actor akTarget) Global
	return (fm as _JSW_BB_Storage).TrackedActors.Find(akTarget as form) 
endFunction

bool function isFMPregnant( Quest fm, int actorIndex) Global
	return (fm as _JSW_BB_Storage).LastConception[actorIndex] != 0.0
endFunction

bool function isFMOvulating( Quest fm, int actorIndex) Global
	return (fm as _JSW_BB_Storage).LastOvulation[actorIndex] != 0.0
endFunction

bool function hasFMSperm( Quest fm, int actorIndex) Global
	return (fm as _JSW_BB_Storage).SpermCount[actorIndex] > 0
endFunction

;SLP
;--------------------------------------

bool function isInfectedBySLP( Quest slp, Actor akTarget, string parasite) Global
	return (slp as SLP_fcts_parasites).isInfectedByString(akTarget, parasite)
endFunction

;SLA
;--------------------------------------
Int Function getArousalLevel(Quest sla, Actor akTarget) Global
	Int arousal = (sla as slaFrameworkScr).GetActorArousal(akTarget)
	return percentToState9(arousal)
EndFunction

Int Function getExposureLevel(Quest sla, Actor akTarget) Global
	Int exposure = (sla as slaFrameworkScr).GetActorExposure(akTarget)
	return percentToState9(exposure)
EndFunction