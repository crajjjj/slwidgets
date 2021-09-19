Scriptname slw_util Hidden

Import Debug

String Function slwGetModName() Global
	return "SL Widgets"
EndFunction

;SemVer support
Int Function GetVersion() Global
    Return 10000
    ; 1.0.0   -> 10000
    ; 1.1.0   -> 10100
    ; 1.1.1  -> 10101
    ; 1.61  -> 16100
    ; 10.61.20 -> 106120 
EndFunction

String Function GetVersionString() Global
    Return "1.0.0"
EndFunction

String Function StringIfElse(Bool isTrue, String returnTrue, String returnFalse = "") Global
    If isTrue
        Return returnTrue
    Else
        Return returnFalse
    EndIf
EndFunction