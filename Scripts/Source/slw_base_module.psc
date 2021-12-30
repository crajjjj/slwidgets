Scriptname slw_base_module extends Quest Hidden
import slw_log
import slw_util


Function moduleSetup()
	initInterface()
EndFunction

Function moduleReset()
	resetInterface()
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

; @interface
Function resetInterface()
	WriteLog("slw_base_module resetInterface() not overriden", 2)
EndFunction	

	