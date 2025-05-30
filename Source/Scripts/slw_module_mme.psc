Scriptname slw_module_mme extends slw_base_module  
import slw_log
import slw_util
import slw_interface_sgo4
;deprecated
Bool Property Module_Ready = false auto hidden

Bool Property Plugin_SGO4 = false auto hidden
Bool Property Plugin_MME = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto
Quest _dse_sgo_QuestDatabase_Main

;MME
String MILK_STATE = "MMEMilk"
String LACTACID_STATE = "MMELactacid"

int EMPTY = -1
int milk_state_prv = -1
int lactacid_state_prv = -1
;override
Bool Function isInterfaceActive()
	Return Plugin_MME || Plugin_SGO4
EndFunction

;override
Function resetInterface()
	milk_state_prv = EMPTY
	lactacid_state_prv = EMPTY
	Plugin_MME = false
	Plugin_SGO4 = false
EndFunction

;override
Function initInterface()
	If (!Plugin_MME && isMMEReady())
		slw_log.WriteLog("ModuleMilk: MilkModNEW.esp found")
		Plugin_MME = true
	endif
	If (!Plugin_SGO4 && isSGO4Ready())
		WriteLog("ModuleMilk: SGO4 found")
		_dse_sgo_QuestDatabase_Main = Game.GetFormFromFile(0x00182A,"dse-soulgem-oven.esp") as Quest 
		Plugin_SGO4 = true
		if !_dse_sgo_QuestDatabase_Main
			WriteLog("ModuleMilk: _dse_sgo_QuestDatabase_Main not found", 2)
		endif
	endif
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars)
	milk_state_prv = EMPTY
	lactacid_state_prv = EMPTY
	if(config.isOn(config.module_mme_milk) && isInterfaceActive())
		_loadMilkIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),MILK_STATE)
	endif

	if(config.isOn(config.module_mme_lactacid) && Plugin_MME)
		_loadLactacidIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),LACTACID_STATE)
	endif
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.isOn(config.module_mme_milk) && isInterfaceActive())
		int milk_state_curr = getMilkLevel()
		if milk_state_prv == EMPTY || milk_state_prv != milk_state_curr
			iBars.setIconStatus(slwGetModName(), MILK_STATE, milk_state_curr )
			milk_state_prv = milk_state_curr
		endif
	endIf

	if (config.isOn(config.module_mme_lactacid) && Plugin_MME)
		int lactacid_state_curr = getLactacidLevel()
		if milk_state_prv == EMPTY || lactacid_state_prv != lactacid_state_curr
			iBars.setIconStatus(slwGetModName(), LACTACID_STATE, lactacid_state_curr )
			lactacid_state_prv = lactacid_state_curr
		endif
	endIf
EndEvent

Int Function getMilkLevel()
	float milkCur
	float milkMax
	if Plugin_MME
		milkCur = MME_Storage.getMilkCurrent(playerRef)
		milkMax = MME_Storage.getMilkMaximum(playerRef)
	endif
	if Plugin_SGO4
		milkCur = milkCur + getMilkCur(_dse_sgo_QuestDatabase_Main, playerRef)
		milkMax = milkMax + getMilkMax(_dse_sgo_QuestDatabase_Main, playerRef)
	endif
	if milkMax <= 0
		milkMax = 1
	endif
	return percentToState9NotStrict(Math.Ceiling(milkCur/milkMax * 100))
EndFunction

Int Function getLactacidLevel()
		float lactCur = MME_Storage.getLactacidCurrent(playerRef)
		float lactMax = MME_Storage.getLactacidMaximum(playerRef)
		if lactMax <= 0
			lactMax = 1
		endif
		Int lactacidLevel = ((lactCur / lactMax) * 100) as Int
		return percentToState9NotStrict(lactacidLevel)
EndFunction


Function _loadMilkIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), MILK_STATE, d, s, r, g, b, a)
EndFunction

Function _loadLactacidIcons(iWant_Status_Bars iBars)
	String[] s = new String[9]
	String[] d = new String[9]
	Int[] r = new Int[9]
	Int[] g = new Int[9]
	Int[] b = new Int[9]
	Int[] a = new Int[9]
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
	iBars.loadIcon(slwGetModName(), LACTACID_STATE, d, s, r, g, b, a)

EndFunction	

