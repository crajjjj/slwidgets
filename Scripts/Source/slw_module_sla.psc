Scriptname slw_module_sla extends slw_base_module  
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto
;--------------------------------------------------

;SLA
slaFrameworkScr sla

String AROUSAL_STATE = "Arousal"
String EXPOSURE_STATE = "Exposure"

Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

Function initInterface()
	If (!Module_Ready && isSLAReady())
		slw_log.WriteLog("ModuleSLA: SexLabAroused.esm found")
		sla = Game.GetFormFromFile(0x4290F, "SexLabAroused.esm") As slaFrameworkScr
		if sla	
			Module_Ready = true 
		else
			slw_log.WriteLog("ModuleSLA: slaFrameworkScr not found", 2)
		endif
	endif
EndFunction

Event onWidgetReload(iWant_Status_Bars iBars)
	if(config.module_sla_arousal && isInterfaceActive())
		_loadArousedIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),AROUSAL_STATE)
	endif
		
	if(config.module_sla_exposure && isInterfaceActive())
		_loadExposureIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),EXPOSURE_STATE)
	endif
EndEvent

Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if(config.module_sla_arousal && isInterfaceActive())
		iBars.setIconStatus(slwGetModName(), AROUSAL_STATE, getArousalLevel())
	endif
	if(config.module_sla_exposure && isInterfaceActive())
		iBars.setIconStatus(slwGetModName(), EXPOSURE_STATE, getExposureLevel())
	endif	
EndEvent


Int Function getArousalLevel()
	if !isInterfaceActive()
		return 0
	endif
	Int arousal = sla.GetActorArousal(playerRef)
	return _percentToState(arousal)
EndFunction

Int Function getExposureLevel()
	if !isInterfaceActive()
		return 0
	endif
	Int exposure = sla.GetActorExposure(playerRef)
	return _percentToState(exposure)
EndFunction
	

Function _loadArousedIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), AROUSAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadExposureIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), EXPOSURE_STATE, d, s, r, g, b, a)

EndFunction
