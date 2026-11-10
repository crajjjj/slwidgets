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
Bool Function isInterfaceActive()
	Return False
EndFunction

; @interface
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	WriteLog("slw_base_module UIUpdate() not overriden", 2)
EndEvent

; @interface
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
EndEvent

; @interface
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
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

	

; Every stage of an iWant icon is a widget of its own. iWant draws the bar
; before it fades the new stage in, and with Skip Hidden Icons on (its
; default) the draw passes over a widget at alpha 0 without leaving it a
; seat, so the icons after it close up by one. A stage the icon showed
; before was faded to exactly 0 when it left: on its next turn the draw
; skips it, its neighbours move in, and it then fades in on top of the one
; that took its seat, until a later change in any bar draws again. That is
; the "icons on top of each other" of every setup, whatever the script
; load. iWant loads a fresh widget at alpha 1 for the same reason (2.10),
; which covers a stage's first turn only. So a stage about to show is
; raised to 1 first: the draw then seats it, and iWant fades it from 1 to
; its alpha. Not for a stage whose alpha is 0 (the draw is to pass over
; it), nor for the stage shown already (iWant would not fade it back in an
; auto-hide bar), which the DLL reads; without the DLL the raise stands,
; since the modules call only on a change. Modules call this, never
; iWant's setIconStatus directly.
Function setIconStatus(iWant_Status_Bars iBars, String name, Int status)
	String modName = slwGetModName()
	Int icon = iBars._getIconID(modName, name)
	If icon >= 0 && iBars._getIconAlpha(icon, status) > 0 && iBars.iWidgets
		If !slw_bridge.hasLayoutNatives() || slw_bridge.GetIWantIconState(iBars, icon) != status
			Int w = iBars._getIconWidget(icon, status)
			If w >= 0
				iBars.iWidgets.setTransparency(w, 1)
			EndIf
		EndIf
	EndIf
	iBars.setIconStatus(modName, name, status)
EndFunction
