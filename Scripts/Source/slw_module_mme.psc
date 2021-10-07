Scriptname slw_module_mme extends slw_base_module  
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

;MME
String MILK_STATE = "MMEMilk"
String LACTACID_STATE = "MMELactacid"

Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

Function initInterface()
	If (!Module_Ready && isMMEReady())
		slw_log.WriteLog("ModuleMME: MilkModNEW.esp found")
		Module_Ready = true 
	endif
EndFunction

Event onWidgetReload(iWant_Status_Bars iBars)
	if(config.module_mme_milk && isInterfaceActive())
		_loadMilkIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),MILK_STATE)
	endif

	if(config.module_mme_lactacid && isInterfaceActive())
		_loadLactacidIcons(iBars)
	else
		iBars.releaseIcon(slwGetModName(),LACTACID_STATE)
	endif
EndEvent

Event onWidgetStatusUpdate(iWant_Status_Bars iBars)
	if (config.module_mme_milk && isInterfaceActive())
		iBars.setIconStatus(slwGetModName(), MILK_STATE, getMilkLevel())
	endIf

	if (config.module_mme_lactacid && isInterfaceActive())
		iBars.setIconStatus(slwGetModName(), LACTACID_STATE, getLactacidLevel())
	endIf
EndEvent

Int Function getMilkLevel()
		float milkCur = MME_Storage.getMilkCurrent(playerRef)
		float milkMax = MME_Storage.getMilkMaximum(playerRef)
		if milkMax <= 0
			milkMax = 1
		endif
		Int milkLevel = ((milkCur / milkMax) * 100) as Int
		return _percentToState9(milkLevel)
EndFunction

Int Function getLactacidLevel()
		float lactCur = MME_Storage.getLactacidCurrent(playerRef)
		float lactMax = MME_Storage.getLactacidMaximum(playerRef)
		if lactMax <= 0
			lactMax = 1
		endif
		Int lactacidLevel = ((lactCur / lactMax) * 100) as Int
		return _percentToState9(lactacidLevel)
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

