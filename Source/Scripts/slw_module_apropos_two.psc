Scriptname slw_module_apropos_two extends slw_base_module  
import slw_log
import slw_util
import slw_interface_appr2

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

;--------------------------------------------------
;Apropos2
Quest ActorsQuest
String VAG_STATE = "AP2Vaginal"
String ANAL_STATE = "AP2Anal"
String ORAL_STATE = "AP2Oral"
int EMPTY = -1
int vag_prv = -1
int oral_prv = -1
int anal_prv = -1

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

;override
Function resetInterface()
	vag_prv = EMPTY
	oral_prv = EMPTY
   	anal_prv = EMPTY
	Module_Ready = false
EndFunction

;override
Function initInterface()
	If (!Module_Ready && isAprReady())
		slw_log.WriteLog("ModuleAPR: Apropos2.esp found")

		;ActorsQuest = Game.GetFormFromFile(0x02902C, "Apropos2.esp") as Quest
		ActorsQuest = Quest.GetQuest("Apropos2Actors")
		
		if !ActorsQuest
			slw_log.WriteLog("ModuleAPR: Apropos2.esp is not yet initialised")
			return
		endif

		Module_Ready = true
		if GetAproposAlias(PlayerRef, ActorsQuest) == None
			String akActorName = playerRef.GetLeveledActorBase().GetName()
			slw_log.WriteLog("Actor "+ akActorName + " is not yet registered in Apropos2")
		EndIf
	endif
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	vag_prv = EMPTY
	oral_prv = EMPTY
   	anal_prv = EMPTY
	if(config.isOn(config.module_apropos_two_wt) && isInterfaceActive())
		_loadApropos2Oral(iBars)
		_loadApropos2Anal(iBars)
		_loadApropos2Vag(iBars)
	else
		iBars.releaseIcon(slwGetModName(),ORAL_STATE)
		iBars.releaseIcon(slwGetModName(),ANAL_STATE)
		iBars.releaseIcon(slwGetModName(),VAG_STATE)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.isOn(config.module_apropos_two_wt) && isInterfaceActive())
		int oral_curr = GetWearStateOral(PlayerRef, ActorsQuest)
		if oral_prv == EMPTY || oral_curr != oral_prv
			iBars.setIconStatus(slwGetModName(), ORAL_STATE, oral_curr)
			oral_prv = oral_curr
		endif
		int anal_curr = GetWearStateAnal(PlayerRef, ActorsQuest)
		if anal_prv == EMPTY || anal_curr != anal_prv
			iBars.setIconStatus(slwGetModName(), ANAL_STATE, anal_curr)
			anal_prv = anal_curr
		endif
		int vag_curr = GetWearStateVaginal(PlayerRef, ActorsQuest)
		if vag_prv == EMPTY || vag_curr != vag_prv
			iBars.setIconStatus(slwGetModName(), VAG_STATE, vag_curr)
			vag_prv = vag_curr
		endif
	endIf
EndEvent



Function _loadApropos2Oral(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), ORAL_STATE, d, s, r, g, b, a)
EndFunction

Function _loadApropos2Anal(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), ANAL_STATE, d, s, r, g, b, a)

EndFunction

Function _loadApropos2Vag(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), VAG_STATE, d, s, r, g, b, a)
EndFunction



