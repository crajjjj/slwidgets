Scriptname slw_util Hidden

Import Debug

String Function slwGetModName() Global
	return "SLWidgets"
EndFunction

;SemVer support
Int Function GetVersion() Global
    Return 20200
    ; 1.0.0   -> 10000
    ; 1.1.0   -> 10100
    ; 1.1.1  -> 10101
    ; 1.61  -> 16100
    ; 10.61.20 -> 106120
EndFunction

String Function GetVersionString() Global
    Return "2.2.0"
EndFunction

String Function StringIfElse(Bool isTrue, String returnTrue, String returnFalse = "") Global
    If isTrue
        Return returnTrue
    Else
        Return returnFalse
    EndIf
EndFunction

; Slot model: index 0 is the player, indices 1..N_NPC_SLOTS are tracked NPCs.
Int Function getSlotCount() Global
    Return 4
EndFunction

Int Function getNpcSlotCount() Global
    Return 3
EndFunction

; Returns the icon name to use for a given slot. Slot 0 (player) keeps the
; original unsuffixed name for save-compat with existing widgets; NPC slots
; get a "_NPCn" suffix so iWant Status Bars treats them as distinct icons.
String Function getIconNameForSlot(String baseName, Int slot) Global
    If slot <= 0
        Return baseName
    EndIf
    Return baseName + "_NPC" + slot
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
	Return  isPAFLegacyReady() || isPAFAIOReady()
EndFunction

Bool Function isPAFLegacyReady() Global
	Return  isDependencyReady("PeeAndFart.esp")
EndFunction

Bool Function isPAFAIOReady() Global
	Return  isDependencyReady("Paf Fixes and Addons.esp")
EndFunction


Bool Function isMiniNeedsReady() Global
	Return  isDependencyReady("MiniNeeds.esp")
EndFunction

Bool Function isAlivePeeingReady() Global
	Return  isDependencyReady("AlivePeeingSE.esp")
EndFunction

Bool Function isPNOReady() Global
	Return  isDependencyReady("Private Needs - Orgasm.esp")
EndFunction

Bool Function isSLDefeatReady() Global
	Return  isDependencyReady("SexLabDefeat.esp")
EndFunction

Bool Function isSGO4Ready() Global
	Return  isDependencyReady("dse-soulgem-oven.esp")
EndFunction

Bool Function isMALReady() Global
	Return  isDependencyReady("Mammaries And Lactation.esp")
EndFunction

Bool Function isCurseOfLifeReady() Global
	Return isDependencyReady("CurseOfLife.esp")
EndFunction

Bool Function isDependencyReady(String modname) Global
	int index = Game.GetModByName(modname)
	if index == 255 || index == -1
		return false
	else
		return true
	endif
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

Int Function percentToState9NotStrict(int percent) Global
	if percent < 0
		percent = 0
	elseif percent > 100
		percent = 100
	endIf

	If percent < 5
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

	If percent < 10
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