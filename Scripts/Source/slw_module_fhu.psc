Scriptname slw_module_fhu extends slw_base_module  
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto
;--------------------------------------------------
;FHU
Quest FhuInflateQuest

String CUM_STATE = "FHUCum"
String CUM_ANAL_STATE = "FHUCumAnal"
String CUM_VAGINAL_STATE = "FHUCumVaginal"

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

;override
Function resetInterface()
	Module_Ready = false
EndFunction

;override
Function initInterface()
	If (!Module_Ready && isFHUReady())
		slw_log.WriteLog("ModuleFHU: sr_FillHerUp.esp found")
		FhuInflateQuest = Game.GetFormFromFile(0x000D63,"sr_FillHerUp.esp") as Quest
		if FhuInflateQuest	
			Module_Ready = true 
		else
			slw_log.WriteLog("FhuInflateQuest not found", 2)
		endif
	endif
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	if(config.module_fhu_cum && isInterfaceActive())
		_loadCumIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),CUM_STATE)
	endif
	if(config.module_fhu_cum_anal && isInterfaceActive())
		_loadCumAnalIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),CUM_ANAL_STATE)
	endif
	if(config.module_fhu_cum_vaginal && isInterfaceActive())
		_loadCumVaginalIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),CUM_VAGINAL_STATE)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if !isInterfaceActive()
		return
	endif
	if config.module_fhu_cum 
		iBars.setIconStatus(slwGetModName(), CUM_STATE, GetCumAmount(PlayerRef, FhuInflateQuest))
	endIf
	if config.module_fhu_cum_anal
		iBars.setIconStatus(slwGetModName(), CUM_ANAL_STATE, GetCumAmountAnal(PlayerRef, FhuInflateQuest))
	endIf
	if config.module_fhu_cum_vaginal
		iBars.setIconStatus(slwGetModName(), CUM_VAGINAL_STATE, GetCumAmountVag(PlayerRef, FhuInflateQuest))
	endIf
EndEvent

Function _loadCumIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]

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
	iBars.loadIcon(slwGetModName(), CUM_STATE, d, s, r, g, b, a)

EndFunction

Function _loadCumAnalIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), CUM_ANAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadCumVaginalIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), CUM_VAGINAL_STATE, d, s, r, g, b, a)

EndFunction


