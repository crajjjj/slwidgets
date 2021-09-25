Scriptname slw_mcm extends SKI_ConfigBase
import slw_util
import slw_log

slw_widget property widget auto
slw_player property player Auto

slw_interface_slax Property slax Auto
slw_interface_apropos_two  property apropos2 auto
slw_interface_fhu property fhu auto
slw_interface_mme property mme auto
slw_interface_pregnancy property pregnancy auto
slw_module_slp property slp auto
slw_module_pregnancy property preg_module Auto

int _updateIntervalSlider
int _arousalToggle
int _exposureToggle
int _damageToggle
int _cumToggle
int _cumAToggle
int _cumVToggle
int _milkToggle
int _lactacidToggle
int _pregnancyToggle
int _slpToggle
int _pregnancyModToggle

Int property updateInterval = 5 auto hidden
Bool property arousal = True auto hidden
Bool property exposure = True auto hidden
Bool property damage = True auto hidden
Bool property cum = True auto hidden
Bool property cuma = True auto hidden
Bool property cumv = True auto hidden
Bool property milk = True auto hidden
Bool property lactacid = True auto hidden
Bool property isPregnant = True auto hidden
Bool property isSLP = True auto hidden
Bool property pregnancy_module_enabled = True auto hidden

; SCRIPT VERSION
; https://github.com/schlangster/skyui/wiki/MCM-Advanced-Features#incremental-upgrading
int function GetVersion()
	return slw_util.GetVersion()
endFunction

event OnConfigInit()
	ModName = slwGetModName()
	Notification("MCM menu initialized.")
endEvent

event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version
	;1.1.0
	if (a_version >= 10100 && CurrentVersion < 10100)
		WriteLog(self + ": Updating script to version 1.1.0")
		isPregnant = false
	endIf

endEvent

Event OnConfigClose()
	widget.UIUpdate()
endEvent


Event OnConfigOpen()
		Pages = New String[3]
		Pages[0] = "General"
		Pages[1] = "Toggles"
		Pages[2] = "Debug"
EndEvent

Event OnPageReset(string page)
	syncInterfaces()

	if (page == "General")
		General()
	elseIf (page == "Toggles")
		Toggles()
	elseIf (page == "Debug")
		Debug()
	endIf
endEvent

Function General()
    SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("General")
	_updateIntervalSlider = AddSliderOption("Update interval", 5, "{0}")
	AddEmptyOption()
	
	AddHeaderOption("Sexlab Aroused")
	_arousalToggle = addToggleOption("Arousal Icon Enabled", arousal)
	_exposureToggle = addToggleOption("Exposure Icon Enabled", exposure)
	
	AddHeaderOption("Apropos 2")
	_damageToggle = addToggleOption("W&T Icon Enabled", damage)
	
	AddHeaderOption("Fill Her Up")
	_cumToggle = addToggleOption("FHU Total Icon Enabled", cum)
	_cumVToggle = addToggleOption("FHU Vaginal Pool Icon Enabled", cumv)
	_cumAToggle = addToggleOption("FHU Anal Pool Icon Enabled", cuma)
	
	AddHeaderOption("Milk Mod Economy")
	_milkToggle = addToggleOption("MME Milk Icon Enabled", milk)
	_lactacidToggle = addToggleOption("MME Lactacid Icon Enabled", lactacid)
	
	;AddHeaderOption("Pregnancy")
	;_pregnancyToggle = addToggleOption("Pregnancy Icon Enabled", isPregnant)
	
EndFunction

Function Toggles()
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
	AddHeaderOption("SexLab Parasites Module")
	_slpToggle = addToggleOption("Parasites Icon Enabled", isSLP)
	AddHeaderOption("Pregnancy Module")
	_pregnancyModToggle = addToggleOption("Pregnancy Icon Enabled", pregnancy_module_enabled)
EndFunction

Function Debug()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddHeaderOption("SL Widgets. Version: " + GetVersionString())
	AddEmptyOption()
	AddTextOptionST("UpdateDeps","Recheck dependencies","GO", OPTION_FLAG_NONE)
	AddTextOptionST("AddEmptyIcon","Add empty icon placeholder(for toggles arrangement)","ADD", OPTION_FLAG_NONE)
	AddHeaderOption("Dependency check: general")
	AddTextOption("iWant Status Bars ready", StringIfElse( widget.isLoaded() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Sexlab Aroused(SexLabAroused.esm)", StringIfElse( isSLAReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Apropos 2 (Apropos2.esp)", StringIfElse( isAprReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Fill Her Up(sr_FillHerUp.esp)", StringIfElse( isFHUReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Milk Mod Economy (MilkModNEW.esp)", StringIfElse( isMMEReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddHeaderOption("Dependency check: toggles")
	AddTextOption("Sexlab parasites(SexLab-Parasites.esp)", StringIfElse( isSLPReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Hentai Pregnancy", StringIfElse( isHPReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("FertilityMode3", StringIfElse( isFM3Ready() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("BeeingFemale", StringIfElse( isBFReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EggFactory", StringIfElse( isEFReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EstrusChaurus", StringIfElse( isECReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EstrusSpider", StringIfElse( isESReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EstrusDwemer", StringIfElse( isEDReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
EndFunction

function syncInterfaces()
	if !slax.isInterfaceActive() 
		arousal = false
		exposure = false
	endIf
	
	if !apropos2.isInterfaceActive()
		damage = false
	endIf

	if !fhu.isInterfaceActive()
		cum = false
		cuma = false
		cumv = false
	endIf

	if !mme.isInterfaceActive()
		milk = false
		lactacid = false
	endIf

	;if !pregnancy.isInterfaceActive()
	;	isPregnant = false
	;endIf

	if !slp.isInterfaceActive()
		isSLP = false
	endIf

	if !preg_module.isInterfaceActive()
		pregnancy_module_enabled = false
	endIf
	
endFunction

Event onOptionHighlight(int mcm_option)
	If (mcm_option == _updateIntervalSlider)
		SetInfoText("Set the update interval of the widget")
	ElseIf (mcm_option == _arousalToggle)
		SetInfoText("Toggle arousal icon")
	ElseIf (mcm_option == _exposureToggle)
		SetInfoText("Toggle exposure icon")
	ElseIf (mcm_option == _damageToggle)
		SetInfoText("Toggle wear and tear icons")
	ElseIf (mcm_option == _cumToggle)
		SetInfoText("Toggle fill her up total pool icon")
	ElseIf (mcm_option == _cumAToggle)
		SetInfoText("Toggle fill her up anal pool icon")
	ElseIf (mcm_option == _cumVToggle)
		SetInfoText("Toggle fill her up vaginal pool icon")
	ElseIf (mcm_option == _milkToggle)
		SetInfoText("Toggle milk icons")
	ElseIf (mcm_option == _lactacidToggle)
		SetInfoText("Toggle lactacid icons")
	ElseIf (mcm_option == _pregnancyToggle)
		SetInfoText("Toggle pregnancy icons")
	ElseIf (mcm_option == _slpToggle)
		SetInfoText("Toggle parasites icons")
	ElseIf (mcm_option == _pregnancyModToggle)
		SetInfoText("Toggle pregnancy module icons")
	endIf
endEvent

Event onOptionSelect(int mcm_option)
	if(mcm_option == _arousalToggle)
		arousal = !arousal 
		setToggleOptionValue(mcm_option, arousal) 
	elseIf(mcm_option == _exposureToggle)
		exposure = !exposure
		setToggleOptionValue(mcm_option, exposure)
	elseIf(mcm_option == _damageToggle)
		damage = !damage
		setToggleOptionValue(mcm_option, damage)
	elseIf(mcm_option == _cumToggle)
		cum = !cum
		setToggleOptionValue(mcm_option, cum)
	elseIf(mcm_option == _cumVToggle)
		cumv = !cumv
		setToggleOptionValue(mcm_option, cumv)
	elseIf(mcm_option == _cumAToggle)
		cuma = !cuma
		setToggleOptionValue(mcm_option, cuma)
	elseIf(mcm_option == _milkToggle)
		milk = !milk
		setToggleOptionValue(mcm_option, milk)
	elseIf(mcm_option == _lactacidToggle)
		lactacid = !lactacid
		setToggleOptionValue(mcm_option, lactacid)
	;elseIf(mcm_option == _pregnancyToggle)
		;isPregnant = !isPregnant
		;setToggleOptionValue(mcm_option, isPregnant)
	elseIf(mcm_option == _slpToggle)
		isSLP = !isSLP
		setToggleOptionValue(mcm_option, isSLP)
	elseIf(mcm_option == _pregnancyModToggle)
		pregnancy_module_enabled = !pregnancy_module_enabled
		setToggleOptionValue(mcm_option, pregnancy_module_enabled)
	endIf
endEvent

Event OnOptionSliderOpen(Int mcm_option)
	If (mcm_option == _updateIntervalSlider)
		SetSliderDialogStartValue(updateInterval)
		SetSliderDialogRange(0, 60)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(5)
	endIf
EndEvent

Event OnOptionSliderAccept(Int mcm_option, Float Value)
	If (mcm_option == _updateIntervalSlider)
		updateInterval=Value as Int
		SetSliderOptionValue(mcm_option, Value, "{0}")
	EndIf
EndEvent

State UpdateDeps
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("Working...")
		
		widget.updateInterfaces()

		SetTextOptionValueST("GO")
        SetOptionFlagsST(OPTION_FLAG_NONE)
        ForcePageReset()
    EndEvent
EndState

State AddEmptyIcon
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("Working...")
		
		widget.LoadEmptyIcon()

		SetTextOptionValueST("ADD")
        SetOptionFlagsST(OPTION_FLAG_NONE)
    EndEvent
EndState