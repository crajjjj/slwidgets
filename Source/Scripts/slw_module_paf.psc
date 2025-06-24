Scriptname slw_module_paf extends slw_base_module  
import slw_log
import slw_util
import slw_interface_paf
import slw_interface_mnd
import slw_interface_alp
import slw_interface_pno

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto
;--------------------------------------------------

;PAF
Quest paf
;MiniNeeds
Quest mnd
Quest pno
;Alive peeing
GlobalVariable apb
GlobalVariable apbm

String PEE_STATE = "PAF_PEE"
String POOP_STATE = "PAF_POOP"
int EMPTY = -1
int pee_state_prv = -1
int poop_state_prv = -1
;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

;override
Function resetInterface()
	pee_state_prv = EMPTY
	poop_state_prv = EMPTY
	Module_Ready = false
EndFunction

;override
Function initInterface()
	If (!Module_Ready && isPAFReady())
		slw_log.WriteLog("ModulePAF: PeeAndFart.esp/Paf Fixes and Addons.esp found")
		paf = Game.GetFormFromFile(0x0012C8, "PeeAndFart.esp") As Quest
		if !paf
		paf = Game.GetFormFromFile(0x000008FB, "Paf Fixes and Addons.esp") As Quest
		endif
		if paf
			Module_Ready = true
		else
			slw_log.WriteLog("ModulePAF: PAF_MainQuestScript not found", 2)
		endif
	endif

	If (!Module_Ready && isMiniNeedsReady())
		slw_log.WriteLog("ModulePAF: MiniNeeds.esp found")
		mnd = Game.GetFormFromFile(0x12C4, "MiniNeeds.esp") as Quest
		if mnd
			Module_Ready = true 
		else
			slw_log.WriteLog("ModulePAF: mndController not found", 2)
		endif
	endif

	If (!Module_Ready && isAlivePeeingReady())
		slw_log.WriteLog("ModulePAF: AlivePeeingSE.esp found")
		apb = Game.GetFormFromFile(0x026E08, "AlivePeeingSE.esp") as GlobalVariable
		apbm = Game.GetFormFromFile(0x026E04, "AlivePeeingSE.esp") as GlobalVariable
		if apb && apbm
			Module_Ready = true 
		else
			slw_log.WriteLog("ModulePAF: APB or APBM not found", 2)
		endif
	endif

	If (!Module_Ready && isPNOReady())
		slw_log.WriteLog("ModulePAF: Private Needs - Orgasm.esp found")
		pno = Game.GetFormFromFile(0x87B, "Private Needs - Orgasm.esp") As Quest
		if pno
			Module_Ready = true
		else
			slw_log.WriteLog("ModulePAF: PNO_MainQuest not found", 2)
		endif
	endif
	
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	pee_state_prv = EMPTY
	poop_state_prv = EMPTY
	if(config.isOn(config.module_paf_pee) && isInterfaceActive())
		_loadPeeIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),PEE_STATE)
	endif
		
	if(config.isOn(config.module_paf_poo) && isInterfaceActive())
		_loadPooIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),POOP_STATE)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.isOn(config.module_paf_pee) && isInterfaceActive())
		int pee_state_curr = getPeeLevel()
		if pee_state_prv == EMPTY || pee_state_prv != pee_state_curr
			iBars.setIconStatus(slwGetModName(), PEE_STATE, pee_state_curr )
			pee_state_prv = pee_state_curr
		endif
	endIf
	if (config.isOn(config.module_paf_poo) && isInterfaceActive())
		int poop_state_curr = getPoopLevel()
		if poop_state_prv == EMPTY || poop_state_prv != poop_state_curr
			iBars.setIconStatus(slwGetModName(), POOP_STATE, poop_state_curr )
			poop_state_prv = poop_state_curr
		endif
	endIf
EndEvent

;states 0-4
Int Function getPeeLevel()
	if !isInterfaceActive()
		return 0
	endif
	if paf
		return getPeeLevelPAF(paf)
	endif	
	if pno
		return getPeeLevelPNO(pno)
	endif	
	if mnd
		return getPeeLevelMND(mnd)
	endif
	if apb && apbm
		return getPeeLevelALP(apb, apbm)
	endif
	return 0
EndFunction
;states 0-4
Int Function getPoopLevel()
	if !isInterfaceActive()
		return 0
	endif
	if paf
		return getPoopLevelPAF(paf)
	endif
	if pno
		return getPoopLevelPNO(pno)
	endif	
	if mnd
		return getPoopLevelMND(mnd)
	endif
	return 0
EndFunction



Function _loadPeeIcons(iWant_Status_Bars iBars)
	String[] s = new String[5]
	String[] d = new String[5]
	Int[] r = new Int[5]
	Int[] g = new Int[5]
	Int[] b = new Int[5]
	Int[] a = new Int[5]
	string iconbasepath = "widgets/iwant/widgets/library/paf/pee/pee"
	string status = " Filled" 
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 236
	g[0] = 183
	b[0] = 83
	a[0] = 33
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly" + status
	r[1] = 236
	g[1] = 183
	b[1] = 83
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately" + status
	r[2] = 236
	g[2] = 183
	b[2] = 83
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly" + status
	r[3] = 236
	g[3] = 183
	b[3] = 83
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely" + status
	r[4] = 236
	g[4] = 183
	b[4] = 83
	a[4] = 100
	
	; This will fail silently if the icon is already loaded 
	iBars.loadIcon(slwGetModName(), PEE_STATE, d, s, r, g, b, a)

EndFunction

Function _loadPooIcons(iWant_Status_Bars iBars)
	String[] s = new String[5]
	String[] d = new String[5]
	Int[] r = new Int[5]
	Int[] g = new Int[5]
	Int[] b = new Int[5]
	Int[] a = new Int[5]
	string iconbasepath = "widgets/iwant/widgets/library/paf/poop/poop"
	string status = " Filled" 
	; Empty
	s[0] = iconbasepath + "0.dds"
	d[0] = "Empty"
	r[0] = 100
	g[0] = 70
	b[0] = 36
	a[0] = 50
	; Slightly Filled
	s[1] = iconbasepath + "1.dds"
	d[1] = "Slightly" + status
	r[1] = 100
	g[1] = 70
	b[1] = 36
	a[1] = 75
	; Moderately Filled
	s[2] = iconbasepath + "2.dds"
	d[2] = "Moderately" + status
	r[2] = 100
	g[2] = 70
	b[2] = 36
	a[2] = 100
	; Highly Filled
	s[3] = iconbasepath + "3.dds"
	d[3] = "Highly" + status
	r[3] = 100
	g[3] = 70
	b[3] = 36
	a[3] = 100
	; Extremely Filled
	s[4] = iconbasepath + "4.dds"
	d[4] = "Extremely" + status
	r[4] = 100
	g[4] = 70
	b[4] = 36
	a[4] = 100
	
	; This will fail silently if the icon is already loaded
	iBars.loadIcon(slwGetModName(), POOP_STATE, d, s, r, g, b, a)

EndFunction
