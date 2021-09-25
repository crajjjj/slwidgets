Scriptname slw_widget Extends Quest
import slw_util
slw_mcm Property mcm Auto
slw_interface_slax Property slax Auto
slw_interface_apropos_two  property apropos2 auto
slw_interface_fhu  property fhu auto
slw_interface_mme property mme auto
slw_interface_pregnancy Property pregnancy Auto

;Toggle icons
slw_module_slp Property slp Auto
slw_module_pregnancy Property pregnancy_module Auto

iWant_Status_Bars Property iBars Auto


String MODNAME = "SL Widgets"
;SLA
String AROUSAL_STATE = "Arousal"
String EXPOSURE_STATE = "Exposure"
;Apropos2
String VAG_STATE = "AP2Vaginal"
String ANAL_STATE = "AP2Anal"
String ORAL_STATE = "AP2Oral"
;FHU
String CUM_STATE = "FHUCum"
String CUM_ANAL_STATE = "FHUCumAnal"
String CUM_VAGINAL_STATE = "FHUCumVaginal"
;MME
String MILK_STATE = "MMEMilk"
String LACTACID_STATE = "MMELactacid"
;Pregnancy Deprecated
String PREGNANCY_STATE = "Pregnancy"

String EMPTY_STATE = "PLACEHOLDER"

Bool _loaded=false

int _emptyIconIndex = 0
String[] s
String[] d
Int[] r
Int[] g
Int[] b
Int[] a

; Assumed lifecycle: OnInit() -> OniWantStatusBarsReady -> ||_loaded|| -> updateInterfaces() -> UIUpdate () -> updatestatus -> UpdateToggleIcons
Event OnInit()
	slw_log.WriteLog("Registering event handlers")
	RegisterForModEvent("iWantStatusBarsReady", "OniWantStatusBarsReady")
	loadSetup()
EndEvent

;on game reload
Function loadSetup()
	RegisterForSingleUpdate(1)
	slw_log.WriteLog("loading setup")
	if _loaded
		updateInterfaces()
	endif
EndFunction

bool Function isLoaded()
	return _loaded
EndFunction

Function updateInterfaces()
	slw_log.WriteLog("updating interfaces")
	slax.initInterface()
	apropos2.initInterface()
	fhu.initInterface()
	mme.initInterface()
	slp.initInterface()
	pregnancy_module.initInterface()
EndFunction


Event OnUpdate()
    if(_loaded)
		UpdateStatus()
		UpdateToggleIcons()
		RegisterForSingleUpdate(mcm.updateInterval)
	else
		RegisterForSingleUpdate(1)
	endIf
EndEvent

Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == "iWantStatusBarsReady"
		iBars = sender As iWant_Status_Bars
		if (!_loaded)
			slw_log.WriteLog("iWantStatusBars loaded")
			;give some time to init
			Utility.Wait(3)
			_loaded = true
			updateInterfaces()
			UIUpdate()
		endif
	EndIf
EndEvent

;Main update function
Function UpdateStatus()
	If !_loaded
		slw_log.WriteLog("UpdateStatus: iBars not loaded yet", 2)
		Return
	endIf
	if(mcm.arousal && slax.isInterfaceActive())
		iBars.setIconStatus(MODNAME, AROUSAL_STATE, slax.getArousalLevel())
	endif
	if(mcm.exposure && slax.isInterfaceActive())
		iBars.setIconStatus(MODNAME, EXPOSURE_STATE, slax.getExposureLevel())
	endif	
	if (mcm.damage && apropos2.isInterfaceActive())
		iBars.setIconStatus(MODNAME, ORAL_STATE, apropos2.GetWearStateOral())
		iBars.setIconStatus(MODNAME, ANAL_STATE, apropos2.GetWearStateAnal())
		iBars.setIconStatus(MODNAME, VAG_STATE, apropos2.GetWearStateVaginal())
	endIf
	if (mcm.cum && fhu.isInterfaceActive())
		iBars.setIconStatus(MODNAME, CUM_STATE, fhu.GetCumAmount())
	endIf
	if (mcm.cuma && fhu.isInterfaceActive())
		iBars.setIconStatus(MODNAME, CUM_ANAL_STATE, fhu.GetCumAmountAnal())
	endIf
	if (mcm.cumv && fhu.isInterfaceActive())
		iBars.setIconStatus(MODNAME, CUM_VAGINAL_STATE, fhu.GetCumAmountVag())
	endIf
	if (mcm.milk && mme.isInterfaceActive())
		iBars.setIconStatus(MODNAME, MILK_STATE, mme.getMilkLevel())
	endIf

	if (mcm.lactacid && mme.isInterfaceActive())
		iBars.setIconStatus(MODNAME, LACTACID_STATE, mme.getLactacidLevel())
	endIf
	
EndFunction

Function UpdateToggleIcons()
	If !_loaded
		slw_log.WriteLog("UpdateToggleIcons: iBars not loaded yet", 2)
		Return
	endIf
	if (mcm.isSLP && slp.isInterfaceActive())
		slp.reloadParasiteIcons(iBars)
	endIf
	if (mcm.pregnancy_module_enabled && pregnancy_module.isInterfaceActive())
		pregnancy_module.reloadPregnancyIcons(iBars)
	endIf
EndFunction	

;ON mcm update and init
Function UIUpdate()
	If !_loaded
		slw_log.WriteLog("iBars not loaded yet. UIUpdate failed", 2)
		Return
	endIf
	slw_log.WriteLog("UIUpdate: updating widgets")
	;----------------------------------	
	if(mcm.arousal && slax.isInterfaceActive())
		_loadArousedIcons()
	else
		iBars.releaseIcon(MODNAME,AROUSAL_STATE)
	endif
		
	if(mcm.exposure && slax.isInterfaceActive())
		_loadExposureIcons()
	else
		iBars.releaseIcon(MODNAME,EXPOSURE_STATE)
	endif
	;----------------------------------	
	if(mcm.damage && apropos2.isInterfaceActive())
		_loadApropos2Oral()
		_loadApropos2Anal()
		_loadApropos2Vag()
	else
		iBars.releaseIcon(MODNAME,ORAL_STATE)
		iBars.releaseIcon(MODNAME,ANAL_STATE)
		iBars.releaseIcon(MODNAME,VAG_STATE)
	endif
	;----------------------------------	
	if(mcm.cum && fhu.isInterfaceActive())
		_loadCumIcons()
	else
		iBars.releaseIcon(MODNAME,CUM_STATE)
	endif
	if(mcm.cuma && fhu.isInterfaceActive())
		_loadCumAnalIcons()
	else
		iBars.releaseIcon(MODNAME,CUM_ANAL_STATE)
	endif
	if(mcm.cumv && fhu.isInterfaceActive())
		_loadCumVaginalIcons()
	else
		iBars.releaseIcon(MODNAME,CUM_VAGINAL_STATE)
	endif
	;----------------------------------	
	if(mcm.milk && mme.isInterfaceActive())
		_loadMilkIcons()
	else
		iBars.releaseIcon(MODNAME,MILK_STATE)
	endif

	if(mcm.lactacid && mme.isInterfaceActive())
		_loadLactacidIcons()
	else
		iBars.releaseIcon(MODNAME,LACTACID_STATE)
	endif
	;----------------------------------	

 	;Toggle icons ----------------------------------
	if(!mcm.isSLP || !slp.isInterfaceActive())
		slp.releaseParasiteIcons(iBars)
	endif

	if(!mcm.pregnancy_module_enabled || !pregnancy_module.isInterfaceActive())
		pregnancy_module.releasePregnancyIcons(iBars)
	endif

	UpdateStatus()
	UpdateToggleIcons()
endFunction

;Debug function to arrange iwant status bars icons better - fill empty spaces in the main bar to load/release toggles in a secondary bar
Function LoadEmptyIcon()
	s = new String[1]
	d = new String[1]
	r = new Int[1]
	g = new Int[1]
	b = new Int[1]
	a = new Int[1]
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

Function _loadArousedIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/sla/arousal/aroused"
	; Not Aroused
	s[0] = iconbasepath + "0.dds"
	d[0] = "Not Aroused"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 33
	; Slightly Aroused
	s[1] =  iconbasepath + "1.dds"
	d[1] = "Slightly Aroused"
	r[1] = 255
	g[1] = 192
	b[1] = 224
	a[1] = 75
	; Moderately Aroused
	s[2] =  iconbasepath + "2.dds"
	d[2] = "Moderately Aroused"
	r[2] = 255
	g[2] = 171
	b[2] = 212
	a[2] = 100
	; Highly Aroused
	s[3] =  iconbasepath + "3.dds"
	d[3] = "Highly Aroused"
	r[3] = 255
	g[3] = 140
	b[3] = 202
	a[3] = 100
	; Extremely Aroused
	s[4] =  iconbasepath + "4.dds"
	d[4] = "Extremely Aroused"
	r[4] = 255
	g[4] = 112
	b[4] = 192
	a[4] = 100
	; Completely Aroused
	s[5] =  iconbasepath + "5.dds"
	d[5] = "Completely Aroused" 
	r[5] = 255 
	g[5] = 84
	b[5] = 167
	a[5] = 100
	; Shaking
	s[6] =  iconbasepath + "6.dds"
	d[6] = "Shaking"
	r[6] = 255
	g[6] = 8
	b[6] = 127
	a[6] = 100
	; Maximum Arousal 1
	s[7] =  iconbasepath + "7.dds"
	d[7] = "Losing Control"
	r[7] = 255
	g[7] = 0
	b[7] = 0
	a[7] = 100
	; Maximum Arousal 2
	s[8] =  iconbasepath + "8.dds"
	d[8] = "No Control"
	r[8] = 255
	g[8] = 0
	b[8] = 0
	a[8] = 100
	
	; This will fail silently if the icon is already loaded 
	iBars.loadIcon(MODNAME, AROUSAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadExposureIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/sla/exposure/exp"
	; Not Exposed
	s[0] = iconbasepath + "0.dds"
	d[0] = "Not Exposed"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 33
	; Slightly Exposed
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Exposed"
	r[1] = 206
	g[1] = 193
	b[1] = 255
	a[1] = 75
	; Moderately Exposed
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Exposed"
	r[2] = 183
	g[2] = 165
	b[2] = 255
	a[2] = 100
	; Highly Exposed
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Exposed"
	r[3] = 160
	g[3] = 137
	b[3] = 255
	a[3] = 100
	; Extremely Exposed
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Exposed"
	r[4] = 138
	g[4] = 108
	b[4] = 255
	a[4] = 100
	; Completely Exposed
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Exposed" ; 
	r[5] = 115 
	g[5] = 80
	b[5] = 255
	a[5] = 100
	; Totally Exposed
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Exposed"
	r[6] = 115
	g[6] = 80
	b[6] = 255
	a[6] = 100
	; Super Exposed
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Exposed"
	r[7] = 92
	g[7] = 51
	b[7] = 255
	a[7] = 100
	; Mega Exposed 
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Exposed"
	r[8] = 51
	g[8] = 0
	b[8] = 255
	a[8] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, EXPOSURE_STATE, d, s, r, g, b, a)

EndFunction

Function _loadApropos2Oral()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/apropos2/oral/oral"
	; Oral
	; Not Damaged
	s[0] = iconbasepath + "0.dds"
	d[0] = "Normal"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 33
	; Slightly Damaged
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Damaged"
	r[1] = 255
	g[1] = 171
	b[1] = 171
	a[1] = 75
	; Moderately Damaged
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Damaged"
	r[2] = 255
	g[2] = 142
	b[2] = 142
	a[2] = 100
	; Highly Damaged
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Damaged"
	r[3] = 255
	g[3] = 114
	b[3] = 114
	a[3] = 100
	; Extremely Damaged
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Damaged"
	r[4] = 255
	g[4] = 114
	b[4] = 114
	a[4] = 100
	; Completely Damaged
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Damaged" ; 
	r[5] = 255 
	g[5] = 85
	b[5] = 85
	a[5] = 100
	; Totally Damaged
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Damaged"
	r[6] = 255
	g[6] = 57
	b[6] = 57
	a[6] = 100
	; Super Damaged
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Damaged"
	r[7] = 255
	g[7] = 28
	b[7] = 28
	a[7] = 100
	; Mega Damaged 
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Damaged"
	r[8] = 255
	g[8] = 0
	b[8] = 0
	a[8] = 100
	

	 ; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, ORAL_STATE, d, s, r, g, b, a)
EndFunction

Function _loadApropos2Anal()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/apropos2/anal/ass"
	; Anal
	; Not Damaged
	s[0] = iconbasepath + "0.dds"
	d[0] = "Normal"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 33
	; Slightly Exposed
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Damaged"
	r[1] = 255
	g[1] = 171
	b[1] = 171
	a[1] = 75
	; Moderately Damaged
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Damaged"
	r[2] = 255
	g[2] = 142
	b[2] = 142
	a[2] = 100
	; Highly Damaged
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Damaged"
	r[3] = 255
	g[3] = 114
	b[3] = 114
	a[3] = 100
	; Extremely Damaged
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Damaged"
	r[4] = 255
	g[4] = 114
	b[4] = 114
	a[4] = 100
	; Completely Damaged
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Damaged" ; 
	r[5] = 255 
	g[5] = 85
	b[5] = 85
	a[5] = 100
	; Totally Damaged
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Damaged"
	r[6] = 255
	g[6] = 57
	b[6] = 57
	a[6] = 100
	; Super Damaged
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Damaged"
	r[7] = 255
	g[7] = 28
	b[7] = 28
	a[7] = 100
	; Mega Damaged 
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Damaged"
	r[8] = 255
	g[8] = 0
	b[8] = 0
	a[8] = 100
	

	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, ANAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadApropos2Vag()

	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]

	string iconbasepath = "widgets/iwant/widgets/library/apropos2/vaginal/vag"
   ; Vaginal
	; Not Damaged
	s[0] = iconbasepath + "0.dds"
	d[0] = "Normal"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 33
	; Slightly Exposed
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Damaged"
	r[1] = 255
	g[1] = 192
	b[1] = 224
	a[1] = 75
	; Moderately Damaged
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Damaged"
	r[2] = 255
	g[2] = 142
	b[2] = 142
	a[2] = 100
	; Highly Damaged
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Damaged"
	r[3] = 255
	g[3] = 114
	b[3] = 114
	a[3] = 100
	; Extremely Damaged
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Damaged"
	r[4] = 255
	g[4] = 114
	b[4] = 114
	a[4] = 100
	; Completely Damaged
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Damaged" ; 
	r[5] = 255 
	g[5] = 85
	b[5] = 85
	a[5] = 100
	; Totally Damaged
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Damaged"
	r[6] = 255
	g[6] = 57
	b[6] = 57
	a[6] = 100
	; Super Damaged
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Damaged"
	r[7] = 255
	g[7] = 28
	b[7] = 28
	a[7] = 100
	; Mega Damaged 
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Damaged"
	r[8] = 255
	g[8] = 0
	b[8] = 0
	a[8] = 100

	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, VAG_STATE, d, s, r, g, b, a)
EndFunction

Function _loadCumIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/fhu/total/cum"
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 251
	g[0] = 245
	b[0] = 233
	a[0] = 33
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Filled"
	r[1] = 251
	g[1] = 245
	b[1] = 233
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Filled"
	r[2] = 251
	g[2] = 245
	b[2] = 233
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Filled"
	r[3] = 251
	g[3] = 245
	b[3] = 233
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Filled"
	r[4] = 251
	g[4] = 245
	b[4] = 233
	a[4] = 100
	; Completely Filled
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Filled" 
	r[5] = 251 
	g[5] = 245
	b[5] = 233
	a[5] = 100
	; Totally Filled
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Filled"
	r[6] = 251
	g[6] = 245
	b[6] = 233
	a[6] = 100
	; Super Filled
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Filled"
	r[7] = 251
	g[7] = 245
	b[7] = 233
	a[7] = 100
	; Mega Filled
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Filled"
	r[8] = 251
	g[8] = 245
	b[8] = 233
	a[8] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, CUM_STATE, d, s, r, g, b, a)

EndFunction

Function _loadCumAnalIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/fhu/anal/cum"
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 251
	g[0] = 245
	b[0] = 233
	a[0] = 33
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Filled"
	r[1] = 251
	g[1] = 245
	b[1] = 233
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Filled"
	r[2] = 251
	g[2] = 245
	b[2] = 233
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Filled"
	r[3] = 251
	g[3] = 245
	b[3] = 233
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Filled"
	r[4] = 251
	g[4] = 245
	b[4] = 233
	a[4] = 100
	; Completely Filled
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Filled" 
	r[5] = 251 
	g[5] = 245
	b[5] = 233
	a[5] = 100
	; Totally Filled
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Filled"
	r[6] = 251
	g[6] = 245
	b[6] = 233
	a[6] = 100
	; Super Filled
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Filled"
	r[7] = 251
	g[7] = 245
	b[7] = 233
	a[7] = 100
	; Mega Filled
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Filled"
	r[8] = 251
	g[8] = 245
	b[8] = 233
	a[8] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, CUM_ANAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadCumVaginalIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/fhu/vaginal/cum"
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 251
	g[0] = 245
	b[0] = 233
	a[0] = 33
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly Filled"
	r[1] = 251
	g[1] = 245
	b[1] = 233
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately Filled"
	r[2] = 251
	g[2] = 245
	b[2] = 233
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly Filled"
	r[3] = 251
	g[3] = 245
	b[3] = 233
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely Filled"
	r[4] = 251
	g[4] = 245
	b[4] = 233
	a[4] = 100
	; Completely Filled
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely Filled" 
	r[5] = 251
	g[5] = 245
	b[5] = 233
	a[5] = 100
	; Totally Filled
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally Filled"
	r[6] = 251
	g[6] = 245
	b[6] = 233
	a[6] = 100
	; Super Filled
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super Filled"
	r[7] = 251
	g[7] = 245
	b[7] = 233
	a[7] = 100
	; Mega Filled
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega Filled"
	r[8] = 251
	g[8] = 245
	b[8] = 233
	a[8] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, CUM_VAGINAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadMilkIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/mme/milk/milk"
	string status = " Filled" 
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 253
	g[0] = 255
	b[0] = 245
	a[0] = 33
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly" + status
	r[1] = 253
	g[1] = 255
	b[1] = 245
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately" + status
	r[2] = 253
	g[2] = 255
	b[2] = 245
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly" + status
	r[3] = 253
	g[3] = 255
	b[3] = 245
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely" + status
	r[4] = 253
	g[4] = 255
	b[4] = 245
	a[4] = 100
	; Completely Filled
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely" + status
	r[5] = 253 
	g[5] = 255
	b[5] = 245
	a[5] = 100
	; Totally Filled
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally" + status
	r[6] = 253
	g[6] = 255
	b[6] = 245
	a[6] = 100
	; Super Filled
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super" + status
	r[7] = 253
	g[7] = 255
	b[7] = 245
	a[7] = 100
	; Mega Filled
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega" + status
	r[8] = 253
	g[8] = 255
	b[8] = 245
	a[8] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, MILK_STATE, d, s, r, g, b, a)

EndFunction

Function _loadLactacidIcons()
	s = new String[9]
	d = new String[9]
	r = new Int[9]
	g = new Int[9]
	b = new Int[9]
	a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/mme/lactacid/lact"
	string status = " Filled" 
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 33
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly" + status
	r[1] = 255
	g[1] = 255
	b[1] = 255
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately" + status
	r[2] = 255
	g[2] = 255
	b[2] = 255
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly" + status
	r[3] = 255
	g[3] = 255
	b[3] = 255
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely" + status
	r[4] = 255
	g[4] = 255
	b[4] = 255
	a[4] = 100
	; Completely Filled
	s[5] = iconbasepath + "5.dds"
	d[5] = "Completely" + status
	r[5] = 255 
	g[5] = 255
	b[5] = 255
	a[5] = 100
	; Totally Filled
	s[6] = iconbasepath + "6.dds"
	d[6] = "Totally" + status
	r[6] = 255
	g[6] = 255
	b[6] = 255
	a[6] = 100
	; Super Filled
	s[7] = iconbasepath + "7.dds"
	d[7] = "Super" + status
	r[7] = 255
	g[7] = 255
	b[7] = 255
	a[7] = 100
	; Mega Filled
	s[8] = iconbasepath + "8.dds"
	d[8] = "Mega" + status
	r[8] = 255
	g[8] = 255
	b[8] = 255
	a[8] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(MODNAME, LACTACID_STATE, d, s, r, g, b, a)

EndFunction

Function _loadPregnancyIcons()
	;DEPRECATED
EndFunction

Function updateTo110()
	If !_loaded
		slw_log.WriteLog("iBars not loaded yet. removing old pregnancy icons failed", 2)
		Return
	endIf
	iBars.releaseIcon(MODNAME,PREGNANCY_STATE)
EndFunction