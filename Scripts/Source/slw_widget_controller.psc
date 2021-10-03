Scriptname slw_widget_controller Extends Quest
import slw_util
import slw_log
iWant_Status_Bars property iBars auto hidden
slw_config Property config Auto

Bool property controller_initialised = False auto hidden

String EMPTY_STATE = "PLACEHOLDER"

int _emptyIconIndex = 0


; Assumed lifecycle: OnInit() -> setup() (Modules initialisation) -> OniWantStatusBarsReady -> UpdateIcons() -> ||controller_initialised|| -> UpdateIconStateStatus(in a loop)

Event OnInit()
	WriteLog("Initialising plugin")
	setup()
EndEvent

;on game reload
Function setup()
	WriteLog(" widget_controller setup")
	RegisterForModEvent("iWantStatusBarsReady", "OniWantStatusBarsReady")
	config.setupModules()
	RegisterForSingleUpdate(1)
EndFunction

bool Function isLoaded()
	return controller_initialised
EndFunction

Event OnUpdate()
    if(controller_initialised)
		UpdateIconStateStatus()
		RegisterForSingleUpdate(config.updateInterval)
	else
		RegisterForSingleUpdate(1)
	endIf
EndEvent

Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == "iWantStatusBarsReady"
		iBars = sender As iWant_Status_Bars
		if (!controller_initialised)
			WriteLog("iWantStatusBars loaded")
			_updateIcons()
			;give some time to load all icons
			Utility.Wait(5)
			controller_initialised = true
		endif
	EndIf
EndEvent

;Main update function
Function UpdateIconStateStatus()
	If !controller_initialised
		WriteLog("UpdateIconStateStatus: iBars not loaded yet", 2)
		Return
	endIf
	config.stateStatusUpdate(iBars)
EndFunction


;ON mcm update and init
Function UpdateIcons()
	If !controller_initialised
		WriteLog("iBars not loaded yet. UpdateIcons failed", 2)
		Return
	endIf
	_updateIcons()
endFunction

Function _updateIcons()
	WriteLog("UpdateIcons: updating widgets")
	config.widgetReload(iBars)
endFunction

;Debug function to arrange iwant status bars icons better - fill empty spaces in the main bar to load/release toggles in a secondary bar
Function LoadEmptyIcon()
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


