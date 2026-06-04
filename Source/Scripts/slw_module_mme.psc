Scriptname slw_module_mme extends slw_base_module  
import slw_log
import slw_util
import slw_interface_sgo4
;deprecated
Bool Property Module_Ready = false auto hidden

Bool Property Plugin_SGO4 = false auto hidden
Bool Property Plugin_MME = false auto hidden
Bool Property Plugin_MAL = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto
Quest _dse_sgo_QuestDatabase_Main

;MME
String MILK_STATE = "MMEMilk"
String LACTACID_STATE = "MMELactacid"

int EMPTY = -1
int[] milk_state_prv
int[] lactacid_state_prv

;MAL cached values (populated via return events)
float _mal_milk_cur = 0.0
float _mal_milk_max = 0.0

;override
Bool Function isInterfaceActive()
	Return Plugin_MME || Plugin_SGO4 || Plugin_MAL
EndFunction

Function _ensurePrvArrays()
	If !milk_state_prv
		milk_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
	If !lactacid_state_prv
		lactacid_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	EndIf
EndFunction

;override
Function resetInterface()
	milk_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	lactacid_state_prv = Utility.CreateIntArray(getSlotCount(), EMPTY)
	Plugin_MME = false
	Plugin_SGO4 = false
	Plugin_MAL = false
	_mal_milk_cur = 0.0
	_mal_milk_max = 0.0
EndFunction

;override
Function initInterface()
	_ensurePrvArrays()
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
	If (!Plugin_MAL && isMALReady())
		WriteLog("ModuleMilk: Mammaries And Lactation found")
		Plugin_MAL = true
		RegisterForModEvent("MAL_ReturnPlayerStoredMilk", "OnMALReturnPlayerStoredMilk")
		RegisterForModEvent("MAL_ReturnPlayerMilkLimit", "OnMALReturnPlayerMilkLimit")
	endif

	if isInterfaceActive()
		WriteLog("ModuleMilk: active plugins - MME:" + Plugin_MME + " SGO4:" + Plugin_SGO4 + " MAL:" + Plugin_MAL)
	else
		WriteLog("ModuleMilk: no milk mods detected")
	endif
EndFunction

Event OnMALReturnPlayerStoredMilk(Float value)
	_mal_milk_cur = value
EndEvent

Event OnMALReturnPlayerMilkLimit(Float value)
	_mal_milk_max = value
EndEvent

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	milk_state_prv[slot] = EMPTY
	lactacid_state_prv[slot] = EMPTY
	If slot == 0
		_mal_milk_cur = 0.0
		_mal_milk_max = 0.0
	EndIf
	String milkName = getIconNameForSlot(MILK_STATE, slot)
	String lactName = getIconNameForSlot(LACTACID_STATE, slot)
	iBars.releaseIcon(slwGetModName(), milkName)
	iBars.releaseIcon(slwGetModName(), lactName)
	if !target
		return
	endif
	if(config.isOnForSlot(config.module_mme_milk, slot, config.MOD_MME_MILK) && isInterfaceActive())
		_loadMilkIcons(iBars, slot)
	endif
	if(config.isOnForSlot(config.module_mme_lactacid, slot, config.MOD_MME_LACTACID) && Plugin_MME)
		_loadLactacidIcons(iBars, slot)
	endif
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	String milkName = getIconNameForSlot(MILK_STATE, slot)
	String lactName = getIconNameForSlot(LACTACID_STATE, slot)
	If target && config.isOnForSlot(config.module_mme_milk, slot, config.MOD_MME_MILK) && isInterfaceActive()
		_loadMilkIcons(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), milkName)
		milk_state_prv[slot] = EMPTY
	EndIf
	If target && config.isOnForSlot(config.module_mme_lactacid, slot, config.MOD_MME_LACTACID) && Plugin_MME
		_loadLactacidIcons(iBars, slot)
	Else
		iBars.releaseIcon(slwGetModName(), lactName)
		lactacid_state_prv[slot] = EMPTY
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	_ensurePrvArrays()
	if !target
		return
	endif
	if slot == 0 && Plugin_MAL && config.isOnForSlot(config.module_mme_milk, slot, config.MOD_MME_MILK)
		_requestMALUpdate()
	endif
	if (config.isOnForSlot(config.module_mme_milk, slot, config.MOD_MME_MILK) && isInterfaceActive())
		int milk_state_curr = getMilkLevel(target, slot)
		if milk_state_prv[slot] == EMPTY || milk_state_prv[slot] != milk_state_curr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(MILK_STATE, slot), milk_state_curr )
			milk_state_prv[slot] = milk_state_curr
		endif
	endIf

	if (config.isOnForSlot(config.module_mme_lactacid, slot, config.MOD_MME_LACTACID) && Plugin_MME)
		int lactacid_state_curr = getLactacidLevel(target)
		if lactacid_state_prv[slot] == EMPTY || lactacid_state_prv[slot] != lactacid_state_curr
			iBars.setIconStatus(slwGetModName(), getIconNameForSlot(LACTACID_STATE, slot), lactacid_state_curr )
			lactacid_state_prv[slot] = lactacid_state_curr
		endif
	endIf
EndEvent

Int Function getMilkLevel(Actor a, Int slot)
	float milkCur
	float milkMax
	if Plugin_MME
		milkCur = MME_Storage.getMilkCurrent(a)
		milkMax = MME_Storage.getMilkMaximum(a)
	endif
	if Plugin_SGO4
		milkCur = milkCur + getMilkCur(_dse_sgo_QuestDatabase_Main, a)
		milkMax = milkMax + getMilkMax(_dse_sgo_QuestDatabase_Main, a)
	endif
	; MAL is queried via player-targeted mod events — only valid for slot 0
	if slot == 0 && Plugin_MAL
		milkCur = milkCur + _mal_milk_cur
		milkMax = milkMax + _mal_milk_max
	endif
	if milkMax <= 0
		milkMax = 1
	endif
	return percentToState9NotStrict(Math.Ceiling(milkCur/milkMax * 100))
EndFunction

Function _requestMALUpdate()
	int eh = ModEvent.Create("MAL_GetPlayerStoredMilk")
	ModEvent.Send(eh)
	eh = ModEvent.Create("MAL_GetPlayerMilkLimit")
	ModEvent.Send(eh)
EndFunction

Int Function getLactacidLevel(Actor a)
		float lactCur = MME_Storage.getLactacidCurrent(a)
		float lactMax = MME_Storage.getLactacidMaximum(a)
		if lactMax <= 0
			lactMax = 1
		endif
		Int lactacidLevel = ((lactCur / lactMax) * 100) as Int
		return percentToState9NotStrict(lactacidLevel)
EndFunction


Function _loadMilkIcons(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(MILK_STATE, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(MILK_STATE, slot), d, s, r, g, b, a, slot)
EndFunction

Function _loadLactacidIcons(iWant_Status_Bars iBars, Int slot)
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
	config.ApplyIconColors(LACTACID_STATE, r, g, b, a)
	config.loadIconForSlot(iBars, getIconNameForSlot(LACTACID_STATE, slot), d, s, r, g, b, a, slot)

EndFunction

