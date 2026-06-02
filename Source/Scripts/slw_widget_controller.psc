Scriptname slw_widget_controller Extends Quest
import slw_util
import slw_log
iWant_Status_Bars property iBars auto hidden
slw_config Property config Auto

Bool property controller_initialised = False auto hidden


String EMPTY_STATE = "PLACEHOLDER"
String STATUS_BARS_EVENT_NAME = "iWantStatusBarsReady"

int _emptyIconIndex = 0
int _checkPlugins = 0

bool Function isLoaded()
	return controller_initialised && iBars && iBars.isReady()
EndFunction

; Assumed lifecycle: menu OnInit() -> OniWantStatusBarsReady......mcm enable -> setup() (Modules initialisation) -> UpdateIcons() -> ||controller_initialised|| -> UpdateIconStateStatus(in a loop)
Event OnInit()
	slw_log.InitLog()
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	controller_initialised = true
	config.loadPreset(config.activePreset)
EndEvent

;init ibars
Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == STATUS_BARS_EVENT_NAME
		iBars = sender As iWant_Status_Bars
		if iBars
			WriteLog("WidgetController: iBars ready")
			config.loadPreset(config.activePreset)
		else
			WriteLog("WidgetController: iBars cast failed from sender", 2)
		endif
	EndIf
EndEvent

;on game reload
;on enable mod button click
;on load settings
Function startUpdates()
	;Notification("WidgetController: moduleSetup")
	;just in case
	UnregisterForUpdate()
	UnregisterForModEvent(STATUS_BARS_EVENT_NAME)
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	;
	RegisterForSingleUpdate(3)
EndFunction

Function stopUpdates()
	UnregisterForUpdate()
	UnregisterForModEvent(STATUS_BARS_EVENT_NAME)
EndFunction

;Main update function
Event OnUpdate()
	if config.slw_stopped
		return
	endif
	if !iBars || !iBars.isReady()
		return
	endif
	config.moduleWidgetStateUpdate(iBars)
	RegisterForSingleUpdate(config.updateInterval)
EndEvent

;ON mcm updates
function reloadWidgets()
	If (!iBars || !iBars.isReady())
		WriteLog("iBars not ready. Reloading widgets failed", 2)
		Return
	endIf
	WriteLogAndPrintConsole("WidgetController: reloading widgets")
	config.moduleWidgetReload(iBars)
endFunction

function toggleUpdateWidgets()
	If (!iBars || !iBars.isReady())
		Return
	endIf
	config.moduleWidgetToggleUpdate(iBars)
endFunction

;Debug function to arrange iwant status bars icons better - fill empty spaces in the main bar to load/release toggles in a secondary bar
Function loadEmptyIcon()
	If !controller_initialised || !iBars || !iBars.isReady()
		WriteLogAndPrintConsole("iBars not loaded yet. Loading empty icon failed", 2)
		Return
	endIf

	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = "placeholder.dds"
	d[0] = EMPTY_STATE + _emptyIconIndex
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 0
	
	; This will fail silently if the icon is already loaded
	int res = iBars.loadIcon(slwGetModName(), EMPTY_STATE + _emptyIconIndex, d, s, r, g, b, a)
	if res >= 0
		_emptyIconIndex += 1
	endif
	
endFunction


