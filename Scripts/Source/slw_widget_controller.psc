Scriptname slw_widget_controller Extends Quest
import slw_util
import slw_log
iWant_Status_Bars property iBars auto hidden
slw_config Property config Auto

Bool property controller_initialised = False auto hidden


String EMPTY_STATE = "PLACEHOLDER"
String STATUS_BARS_EVENT_NAME = "iWantStatusBarsReady"

int _emptyIconIndex = 0
int _checkModules = 0

bool Function isLoaded()
	return controller_initialised
EndFunction

Event OnInit()
	setup()
EndEvent

; Assumed lifecycle: menu OnInit() -> setup() (Modules initialisation) -> OniWantStatusBarsReady -> UpdateIcons() -> ||controller_initialised|| -> UpdateIconStateStatus(in a loop)

;on game reload
;on enable mod button click
Function setup()
	WriteLog("WidgetController module setup")
	config.moduleReset()
	_checkModules = 1 
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	RegisterForSingleUpdate(5)
EndFunction

Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == STATUS_BARS_EVENT_NAME
		iBars = sender As iWant_Status_Bars
		if (!controller_initialised)
			WriteLog("WidgetController: iWantStatusBars loaded")
			_reloadWidgets()
			;give some time to load all icons
			Utility.Wait(5)
			controller_initialised = true
		endif
	EndIf
EndEvent

;Main update function
Event OnUpdate()
	if config.slw_stopped
		return
	endif
	;postponed module init
	If _checkModules > 0
		_checkModules += 1
		If _checkModules > 2
			config.moduleSetup()
			_checkModules = 0
		EndIf
	EndIf
    if(controller_initialised && iBars.isReady())
		config.moduleWidgetStateUpdate(iBars)
		RegisterForSingleUpdate(config.updateInterval)
	else
		RegisterForSingleUpdate(5)
	endIf

	
EndEvent

;ON mcm update and init
Function reloadWidgets()
	If !controller_initialised || !iBars || !iBars.isReady()
		WriteLogAndPrintConsole("iBars not loaded yet. Reloading widgets failed", 2)
		Return
	endIf
	_reloadWidgets()
endFunction

Function _reloadWidgets()
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


