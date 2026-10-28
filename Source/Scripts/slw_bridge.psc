Scriptname slw_bridge Hidden
{The link between SLWidgetsMenu.dll (the Positions page in SKSE Menu
Framework's menu, plugin\) and the mod. The DLL calls these global functions through the Papyrus VM, so their
names and argument lists are an interface: never change a signature, add a new
function instead. A call whose argument count differs from what the DLL sends
is rejected by the VM without a trace, and the editor then shows nothing.
Everything here forwards to slw_widget_controller, where iWant is in scope.}

Int Function GetVersion() Global
	Return 6
EndFunction

slw_config Function _config() Global
	Return Game.GetFormFromFile(0x000800, "SLWidgets.esp") As slw_config
EndFunction

slw_widget_controller Function _controller() Global
	slw_config c = _config()
	If !c
		Return None
	EndIf
	Return c.widget_controller
EndFunction

; The player icon switches, "" while no game is loaded.
; Format: slw_config.editorToggles
String Function GetToggles() Global
	slw_config c = _config()
	If !c
		Return ""
	EndIf
	Return c.editorToggles()
EndFunction

; One switch by its key (the property's name); the icons follow on the next
; update pass, as they do when the MCM closes
Function SetToggle(String toggleKey, Bool value) Global
	slw_config c = _config()
	If c && c.setToggleByKey(toggleKey, value) && c.widget_controller
		c.widget_controller.requestTogglePass()
	EndIf
EndFunction

; The General, Meters and NPC Tracking pages, "" while no game is loaded.
; Format: the rows described above slw_config.editorGeneral
String Function GetGeneral() Global
	slw_config c = _config()
	If !c
		Return ""
	EndIf
	Return c.editorGeneral()
EndFunction

String Function GetMeters() Global
	slw_config c = _config()
	If !c || !c.widget_controller
		Return ""
	EndIf
	Return c.editorMeters()
EndFunction

String Function GetNpc() Global
	slw_config c = _config()
	If !c || !c.widget_controller
		Return ""
	EndIf
	Return c.editorNpc()
EndFunction

; The icons of the player bars, "" while iWant is not running.
; Format: slw_widget_controller.editorBarIcons
String Function GetBarIcons() Global
	slw_widget_controller w = _controller()
	If !w
		Return ""
	EndIf
	Return w.editorBarIcons()
EndFunction

; The DLL's report at each game load: 1 its pages are up, 2 the installed
; SKSE Menu Framework lacks what they need; shown on the MCM's General page
Function SetMenuReport(Int report) Global
	slw_config c = _config()
	If c
		c.skseMenuReport = report
	EndIf
EndFunction

; One row of those pages changed: its key and the new value as text
Function SetSetting(String settingKey, String value) Global
	slw_config c = _config()
	If c && c.widget_controller
		c.editorSet(settingKey, value)
	EndIf
EndFunction

; The settings presets and the active one, "" while no game is loaded.
; Format: slw_config.editorPresets
String Function GetPresets() Global
	slw_config c = _config()
	If !c
		Return ""
	EndIf
	Return c.editorPresets()
EndFunction

; Load a settings preset as the MCM's preset menu does, from the widget
; controller's next update pass
Function LoadPreset(String presetName) Global
	slw_config c = _config()
	If c && c.widget_controller && _isPresetName(presetName)
		c.widget_controller.requestPresetLoad(presetName)
	EndIf
EndFunction

; Save the current settings as a preset (a new name makes a new file) and make
; it the active one, in the widget controller's next update pass
Function SavePreset(String presetName) Global
	slw_config c = _config()
	If c && c.widget_controller && _isPresetName(presetName)
		c.widget_controller.requestPresetSave(presetName)
	EndIf
EndFunction

; A preset is a file name in SettingsPresets: no folder, no way out of it
Bool Function _isPresetName(String presetName) Global
	If presetName == ""
		Return False
	EndIf
	Return StringUtil.Find(presetName, "\\") < 0 && StringUtil.Find(presetName, "/") < 0 && StringUtil.Find(presetName, ":") < 0 && StringUtil.Find(presetName, "..") < 0
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

; A player icon one place along its bar (dir -1 or 1), or to the first free
; seat of another player bar, while it still sits where the page saw it
Function MoveIconInBar(Int bar, Int seat, Int icon, Int dir) Global
	slw_widget_controller w = _controller()
	If w
		w.editorMoveIconInBar(bar, seat, icon, dir)
	EndIf
EndFunction

Function MoveIconToBar(Int bar, Int seat, Int icon, Int target) Global
	slw_widget_controller w = _controller()
	If w
		w.editorMoveIconToBar(bar, seat, icon, target)
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

; iWant's icon step in percent of the icon size (150 is iWant's own), for every
; line bar at once
Function SetIconSpacing(Int percent) Global
	slw_widget_controller w = _controller()
	If w
		w.editorSetIconSpacing(percent)
	EndIf
EndFunction

; ---------------------------------------------------------------------------
; Natives of SLWidgetsMenu.dll (3.4.1): the scripts calling into the DLL. They
; are bound only while the DLL is loaded; without it a call logs an unbound
; native and returns 0.0 / False, so callers ask hasNatives() first.
; ---------------------------------------------------------------------------

; The natives came with the 3.4.1 DLL, so an older one (scripts updated, the
; DLL not) leaves them unbound. SKSE reports a plugin's version packed as
; major << 24 | minor << 16 | patch << 4.
Bool Function hasNatives() Global
	Return SKSE.GetPluginVersion("SLWidgetsMenu") >= 0x03040010
EndFunction

; iWant's icon step: how far a line bar puts each icon from the one before, in
; icon sizes. It is BAR_SPACING_PERCENTAGE, a private Float of the
; iWant_Status_Bars script (1.5, one value for every bar of every mod), which no
; other script can reach. 0.0 when the DLL cannot find it on the quest.
Float Function GetIWantIconStep(Quest bars) Global Native

; Writes it, held to 0.8 - 3.0 (False outside, or when it cannot be found).
; iWant uses it from its next draw, and saves it with its own script.
Bool Function SetIWantIconStep(Quest bars, Float step) Global Native
