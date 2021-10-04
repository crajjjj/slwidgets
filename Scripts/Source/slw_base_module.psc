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

Int Function _percentToState(int percent)
	if percent < 0
		percent = 0
	elseif percent > 101
		percent = 101
	endIf

	If percent < 10
		return 0
	ElseIf percent < 20
		return 1
	ElseIf percent < 30
		return 2
	ElseIf percent < 40
		return 3
	ElseIf percent < 60
		return 4
	ElseIf percent < 80
		return 5
	ElseIf percent < 90
		return 6
	ElseIf percent < 100
		return 7
	Else
		return 8
	EndIf
EndFunction			