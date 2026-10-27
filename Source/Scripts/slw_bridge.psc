Scriptname slw_bridge Hidden
{The link between SLWidgetsMenu.dll (the Positions page in SKSE Menu
Framework's menu, plugin\) and the mod. The DLL calls these global functions through the Papyrus VM, so their
names and argument lists are an interface: never change a signature, add a new
function instead. A call whose argument count differs from what the DLL sends
is rejected by the VM without a trace, and the editor then shows nothing.
Everything here forwards to slw_widget_controller, where iWant is in scope.}

Int Function GetVersion() Global
	Return 1
EndFunction

slw_widget_controller Function _controller() Global
	slw_config c = Game.GetFormFromFile(0x000800, "SLWidgets.esp") As slw_config
	If !c
		Return None
	EndIf
	Return c.widget_controller
EndFunction

; The whole layout as one string, "" while the mod or iWant is not running.
; Format: slw_widget_controller.editorLayout
String Function GetLayout() Global
	slw_widget_controller w = _controller()
	If !w
		Return ""
	EndIf
	Return w.editorLayout()
EndFunction

; Player bars 0-3, straight to iWant as its own MCM does
Function SetBarPos(Int bar, Int x, Int y) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetBarPos(bar, x, y)
	EndIf
EndFunction

Function SetBarSize(Int bar, Int size) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetBarSize(bar, size)
	EndIf
EndFunction

Function SetBarType(Int bar, Int type) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetBarType(bar, type)
	EndIf
EndFunction

; The NPC cluster's anchor: the bars follow (_layoutNpcBars)
Function SetNpcGroup(Int x, Int y) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetNpcGroup(x, y)
	EndIf
EndFunction

Function SetNpcSpacing(Int v) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetNpcSpacing(v)
	EndIf
EndFunction

; The meter stack's center and size; rebuilt on the next pass
Function SetMeters(Int x, Int y, Int scale) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetMeters(x, y, scale)
	EndIf
EndFunction

Function ResetNpcLayout() Global
	slw_widget_controller w = _controller()
	If w
		w.applyDefaultNpcBarLayout()
	EndIf
EndFunction
