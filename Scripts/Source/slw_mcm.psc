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


; SCRIPT VERSION
; https://github.com/schlangster/skyui/wiki/MCM-Advanced-Features#incremental-upgrading
int function GetVersion()
	return slw_util.GetVersion()
endFunction

event OnConfigInit()
	ModName = slwGetModName()
	Notification("MCM menu initialized.")
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
	
	AddHeaderOption("Pregnancy")
	_pregnancyToggle = addToggleOption("Pregnancy Icon Enabled", isPregnant)
	
EndFunction

Function Toggles()
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
	AddHeaderOption("SexLab Parasites")
	_slpToggle = addToggleOption("Parasites Icon Enabled", isSLP)
EndFunction

Function Debug()
    SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddHeaderOption("SL Widgets. Version: " + GetVersionString())
	AddEmptyOption()
	AddHeaderOption("Dependency check")
	AddTextOptionST("CheckSLA", "Sexlab Aroused(SexLabAroused.esm)", StringIfElse(slax.isInterfaceActive() , "INSTALLED", "NOT INSTALLED"), OPTION_FLAG_DISABLED)
	AddTextOptionST("CheckApropos2", "Apropos 2 (Apropos2.esp)", StringIfElse(apropos2.isInterfaceActive() , "INSTALLED", "NOT INSTALLED"), OPTION_FLAG_DISABLED)
	AddTextOptionST("CheckFHU", "Fill Her Up(sr_FillHerUp.esp)", StringIfElse(fhu.isInterfaceActive() , "INSTALLED", "NOT INSTALLED"), OPTION_FLAG_DISABLED)
	AddTextOptionST("CheckMME", "Milk Mod Economy (MilkModNEW.esp)", StringIfElse(mme.isInterfaceActive() , "INSTALLED", "NOT INSTALLED"), OPTION_FLAG_DISABLED)
	AddTextOptionST("CheckPreg", "Pregnancy deps", StringIfElse(pregnancy.isInterfaceActive() , "INSTALLED", "NOT INSTALLED"), OPTION_FLAG_DISABLED)
	AddTextOptionST("CheckSLP", "Sexlab parasites(SexLab-Parasites.esp)", StringIfElse(slp.isInterfaceActive() , "INSTALLED", "NOT INSTALLED"), OPTION_FLAG_DISABLED)
	AddEmptyOption()

	AddTextOptionST("UpdateDeps","Reload dependencies","ClickHere", OPTION_FLAG_NONE)
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

	if !pregnancy.isInterfaceActive()
		isPregnant = false
	endIf

	if !slp.isInterfaceActive()
		isSLP = false
	endIf
endFunction

Event onOptionHighlight(int mcm_option)
	If (mcm_option == _updateIntervalSlider)
		SetInfoText("Set the update interval of the widget.")
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
	elseIf(mcm_option == _pregnancyToggle)
		isPregnant = !isPregnant
		setToggleOptionValue(mcm_option, isPregnant)
	elseIf(mcm_option == _slpToggle)
		isSLP = !isSLP
		setToggleOptionValue(mcm_option, isSLP)
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
        Utility.Wait(2)

		SetTextOptionValueST("ClickHere")
        SetOptionFlagsST(OPTION_FLAG_NONE)
        ForcePageReset()
    EndEvent
EndState