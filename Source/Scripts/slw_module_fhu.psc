Scriptname slw_module_fhu extends slw_base_module  
import slw_log
import slw_util
import slw_interface_fhu

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto
;--------------------------------------------------
;FHU
Quest FhuInflateQuest

String CUM_STATE = "FHUCum"
String CUM_ANAL_STATE = "FHUCumAnal"
String CUM_VAGINAL_STATE = "FHUCumVaginal"
String CUM_ORAL_STATE = "FHUCumOral"

int EMPTY = -1
int[] cum_state_prv
int[] cum_anal_state_prv
int[] cum_vaginal_state_prv
int[] cum_oral_state_prv

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

Function _ensurePrvArrays()
	If !cum_state_prv
		cum_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !cum_anal_state_prv
		cum_anal_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !cum_vaginal_state_prv
		cum_vaginal_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !cum_oral_state_prv
		cum_oral_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
EndFunction

;override
Function resetInterface()
	cum_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	cum_anal_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
 	cum_vaginal_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
 	cum_oral_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	Module_Ready = false
EndFunction

;override
Function initInterface()
	_ensurePrvArrays()
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
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	cum_state_prv[slot] = EMPTY
	cum_anal_state_prv[slot] = EMPTY
 	cum_vaginal_state_prv[slot] = EMPTY
 	cum_oral_state_prv[slot] = EMPTY
	String cumName = getIconNameForSlot(CUM_STATE, slot)
	String cumAnalName = getIconNameForSlot(CUM_ANAL_STATE, slot)
	String cumVagName = getIconNameForSlot(CUM_VAGINAL_STATE, slot)
	String cumOralName = getIconNameForSlot(CUM_ORAL_STATE, slot)
	iBars.releaseIcon(slwGetModName(), cumName)
	iBars.releaseIcon(slwGetModName(), cumAnalName)
	iBars.releaseIcon(slwGetModName(), cumVagName)
	iBars.releaseIcon(slwGetModName(), cumOralName)
	if !target
		return
	endif
	if(config.isOnForSlot(config.module_fhu_cum, slot, config.MOD_FHU_CUM) && isInterfaceActive())
		_loadCumIcons(iBars, slot)
	endif
	if(config.isOnForSlot(config.module_fhu_cum_anal, slot, config.MOD_FHU_ANAL) && isInterfaceActive())
		_loadCumAnalIcons(iBars, slot)
	endif
	if(config.isOnForSlot(config.module_fhu_cum_vaginal, slot, config.MOD_FHU_VAGINAL) && isInterfaceActive())
		_loadCumVaginalIcons(iBars, slot)
	endif
	if(config.isOnForSlot(config.module_fhu_cum_oral, slot, config.MOD_FHU_ORAL) && isInterfaceActive())
		_loadCumOralIcons(iBars, slot)
	endif
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	String cumName = getIconNameForSlot(CUM_STATE, slot)
	String cumAnalName = getIconNameForSlot(CUM_ANAL_STATE, slot)
	String cumVagName = getIconNameForSlot(CUM_VAGINAL_STATE, slot)
	String cumOralName = getIconNameForSlot(CUM_ORAL_STATE, slot)
	If target && config.isOnForSlot(config.module_fhu_cum, slot, config.MOD_FHU_CUM) && isInterfaceActive()
		_loadCumIcons(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), cumName)
		cum_state_prv[slot] = EMPTY
	EndIf
	If target && config.isOnForSlot(config.module_fhu_cum_anal, slot, config.MOD_FHU_ANAL) && isInterfaceActive()
		_loadCumAnalIcons(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), cumAnalName)
		cum_anal_state_prv[slot] = EMPTY
	EndIf
	If target && config.isOnForSlot(config.module_fhu_cum_vaginal, slot, config.MOD_FHU_VAGINAL) && isInterfaceActive()
		_loadCumVaginalIcons(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), cumVagName)
		cum_vaginal_state_prv[slot] = EMPTY
	EndIf
	If target && config.isOnForSlot(config.module_fhu_cum_oral, slot, config.MOD_FHU_ORAL) && isInterfaceActive()
		_loadCumOralIcons(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), cumOralName)
		cum_oral_state_prv[slot] = EMPTY
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	if !target
		return
	endif
	if !isInterfaceActive()
		return
	endif
	if config.isOnForSlot(config.module_fhu_cum, slot, config.MOD_FHU_CUM)
		int cum_state_curr = GetCumAmount(target, FhuInflateQuest)
		if cum_state_prv[slot] == EMPTY || cum_state_prv[slot] != cum_state_curr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(CUM_STATE, slot), cum_state_curr)
			cum_state_prv[slot] = cum_state_curr
		endif
	endIf
	if config.isOnForSlot(config.module_fhu_cum_anal, slot, config.MOD_FHU_ANAL)
		int cum_anal_state_curr = GetCumAmountAnal(target, FhuInflateQuest)
		if cum_anal_state_prv[slot] == EMPTY || cum_anal_state_prv[slot] != cum_anal_state_curr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(CUM_ANAL_STATE, slot), cum_anal_state_curr)
			cum_anal_state_prv[slot] = cum_anal_state_curr
		endif
	endIf
	if config.isOnForSlot(config.module_fhu_cum_vaginal, slot, config.MOD_FHU_VAGINAL)
		int cum_vag_state_curr = GetCumAmountVag(target, FhuInflateQuest)
		if cum_vaginal_state_prv[slot] == EMPTY || cum_vaginal_state_prv[slot] != cum_vag_state_curr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(CUM_VAGINAL_STATE, slot), cum_vag_state_curr)
			cum_vaginal_state_prv[slot] = cum_vag_state_curr
		endif
	endIf
	if config.isOnForSlot(config.module_fhu_cum_oral, slot, config.MOD_FHU_ORAL)
		int cum_oral_state_curr = GetCumAmountOral(target, FhuInflateQuest)
		if cum_oral_state_prv[slot] == EMPTY || cum_oral_state_prv[slot] != cum_oral_state_curr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(CUM_ORAL_STATE, slot), cum_oral_state_curr)
			cum_oral_state_prv[slot] = cum_oral_state_curr
		endif
	endIf

EndEvent

Function _loadCumIcons(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(CUM_STATE, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(CUM_STATE, slot), d, s, r, g, b, a, slot)

EndFunction

Function _loadCumAnalIcons(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(CUM_ANAL_STATE, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(CUM_ANAL_STATE, slot), d, s, r, g, b, a, slot)

EndFunction

Function _loadCumVaginalIcons(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(CUM_VAGINAL_STATE, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(CUM_VAGINAL_STATE, slot), d, s, r, g, b, a, slot)

EndFunction

Function _loadCumOralIcons(iWant_Status_Bars iBars, Int slot)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
	string iconbasepath = "widgets/iwant/widgets/library/fhu/oral/cum"
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
	config.ApplyIconColors(CUM_ORAL_STATE, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(CUM_ORAL_STATE, slot), d, s, r, g, b, a, slot)

EndFunction
