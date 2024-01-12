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
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	controller_initialised = true
EndEvent

;init ibars
Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == STATUS_BARS_EVENT_NAME
		iBars = sender As iWant_Status_Bars
	EndIf
EndEvent

;on game reload
;on enable mod button click
Function setup()
	;Notification("WidgetController: moduleSetup")
	;just in case
	UnregisterForModEvent(STATUS_BARS_EVENT_NAME)
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	;
	config.moduleSetup()
	RegisterForSingleUpdate(3)
EndFunction

;Main update function
Event OnUpdate()
	if config.slw_stopped
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
	
	string iconbasepath = "widgets/iwant/widgets/library/misc/"
	s[0] = "placeholder.dds"
	d[0] = EMPTY_STATE + _emptyIconIndex
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 0
	
	; This will fail silently if the icon is already loaded
	int res = iBars.loadIcon(slwGetModName(), EMPTY_STATE + _emptyIconIndex, d, s, r, g, b, a)
	; returns -1 on no spots available
	if res != -1
		_emptyIconIndex += 1
	endif
	
endFunction


