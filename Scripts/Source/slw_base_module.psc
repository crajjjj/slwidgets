Scriptname slw_base_module extends Quest Hidden
import slw_log
import slw_util


Function moduleSetup()
	initInterface()
EndFunction

; @interface
Event onWidgetReload(iWant_Status_Bars iBars)
	WriteLog("slw_base_module UIUpdate() not overriden", 2)
EndEvent

; @interface
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	WriteLog("slw_base_module UpdateStatus() not overriden", 2)
EndEvent

; @interface
Function initInterface()
	WriteLog("slw_base_module initInterface() not overriden", 2)
EndFunction	

Int Function _percentToState9(int percent)
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

Int Function _percentToState5(int percent)
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