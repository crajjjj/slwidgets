Scriptname slw_util Hidden

Import Debug

String Function slwGetModName() Global
	return "SL Widgets"
EndFunction

;SemVer support
Int Function GetVersion() Global
    Return 20000
    ; 1.0.0   -> 10000
    ; 1.1.0   -> 10100
    ; 1.1.1  -> 10101
    ; 1.61  -> 16100
    ; 10.61.20 -> 106120 
EndFunction

String Function GetVersionString() Global
    Return "2.0.0"
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