Scriptname slw_menu extends SKI_ConfigBase
import slw_util
import slw_log


slw_config Property config auto
slw_widget_controller Property widget_controller auto

int _update_interval_slider
int _sla_arousal_Toggle
int _sla_exposure_Toggle
int _apropos_two_wt_Toggle
int _fhu_cum_Toggle
int _fhu_cum_Anal_Toggle
int _fhu_cum_Vaginal_Toggle
int _mme_milk_Toggle
int _mme_lactacid_Toggle
int _parasites_mod_Toggle
int _pregnancy_mod_Toggle

; SCRIPT VERSION
; https://github.com/schlangster/skyui/wiki/MCM-Advanced-Features#incremental-upgrading

int function GetVersion()
	return slw_util.GetVersion()
endFunction

Event OnConfigInit()
	ModName = slwGetModName()
	WriteLog("MCM: Initialising modules")
	config.moduleSetup()
	config.SetDefaults()
	Notification("MCM menu initialized.")
EndEvent

Event OnConfigClose()
	widget_controller.reloadWidgets()
EndEvent

Event OnConfigOpen()
		Pages = New String[3]
		Pages[0] = "General"
		Pages[1] = "Toggles"
		Pages[2] = "Debug"
EndEvent

Event OnPageReset(string page)
	config.moduleSyncConfig()

	if (page == "General")
		General()
	elseIf (page == "Toggles")
		Toggles()
	elseIf (page == "Debug")
		Debug()
	endIf
EndEvent

Function General()
    SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("General")
	_update_interval_slider = AddSliderOption("Update interval", 5, "{0}")
	AddEmptyOption()
	
	AddHeaderOption("Sexlab Aroused")
	Int slaFlag = _getFlag(config.module_sla.isInterfaceActive())
	_sla_arousal_Toggle = addToggleOption("Arousal Icon Enabled", config.module_sla_arousal, slaFlag)
	_sla_exposure_Toggle = addToggleOption("Exposure Icon Enabled",config.module_sla_exposure, slaFlag)
	
	AddHeaderOption("Apropos 2")
	Int wtFlag = _getFlag(config.module_apropos_two.isInterfaceActive()) 
	_apropos_two_wt_Toggle = addToggleOption("W&T Icon Enabled", config.module_apropos_two_wt, wtFlag)
	
	AddHeaderOption("Fill Her Up")
	Int fhuFlag = _getFlag(config.module_fhu.isInterfaceActive()) 
	_fhu_cum_Toggle = addToggleOption("FHU Total Icon Enabled", config.module_fhu_cum, fhuFlag)
	_fhu_cum_Vaginal_Toggle = addToggleOption("FHU Vaginal Pool Icon Enabled", config.module_fhu_cum_vaginal, fhuFlag)
	_fhu_cum_Anal_Toggle = addToggleOption("FHU Anal Pool Icon Enabled", config.module_fhu_cum_anal, fhuFlag)
	
	AddHeaderOption("Milk Mod Economy")
	Int mmeFlag = _getFlag(config.module_mme.isInterfaceActive()) 
	_mme_milk_Toggle = addToggleOption("MME Milk Icon Enabled", config.module_mme_milk, mmeFlag)
	_mme_lactacid_Toggle = addToggleOption("MME Lactacid Icon Enabled", config.module_mme_lactacid, mmeFlag)
EndFunction

Function Toggles()
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
	AddHeaderOption("SexLab Parasites")
	Int slpFlag = _getFlag(config.module_slp.isInterfaceActive()) 
	_parasites_mod_Toggle = addToggleOption("Parasites Icon Enabled", config.module_parasites_enabled, slpFlag)
	AddHeaderOption("Pregnancy")
	Int pregFlag = _getFlag(config.module_pregnancy.isInterfaceActive())
	_pregnancy_mod_Toggle = addToggleOption("Pregnancy Icon Enabled", config.module_pregnancy_enabled, pregFlag)
EndFunction

Function Debug()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddHeaderOption("SL Widgets. Version: " + GetVersionString())
	AddEmptyOption()
	AddTextOptionST("UpdateDeps","Recheck dependencies","GO", OPTION_FLAG_NONE)
	AddTextOptionST("AddEmptyIcon","Add empty icon placeholder(for toggles arrangement)","ADD", OPTION_FLAG_NONE)
	AddHeaderOption("Dependency check:")
	AddTextOption("iWant Status Bars ready", StringIfElse( widget_controller.isLoaded() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Sexlab Aroused(SexLabAroused.esm)", StringIfElse( isSLAReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Apropos 2 (Apropos2.esp)", StringIfElse( isAprReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Fill Her Up(sr_FillHerUp.esp)", StringIfElse( isFHUReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Milk Mod Economy (MilkModNEW.esp)", StringIfElse( isMMEReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("Sexlab parasites(SexLab-Parasites.esp)", StringIfElse( isSLPReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddHeaderOption("Dependency check: pregnancy")
	AddTextOption("Hentai Pregnancy", StringIfElse( isHPReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("FertilityMode3", StringIfElse( isFM3Ready() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("BeeingFemale", StringIfElse( isBFReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EggFactory", StringIfElse( isEFReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EstrusChaurus", StringIfElse( isECReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EstrusSpider", StringIfElse( isESReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
	AddTextOption("EstrusDwemer", StringIfElse( isEDReady() , "OK", "NOT FOUND"), OPTION_FLAG_DISABLED)
EndFunction



Event onOptionHighlight(int mcm_option)
	If (mcm_option == _update_interval_slider)
		SetInfoText("Set the update interval of the widget")
	ElseIf (mcm_option == _sla_arousal_Toggle)
		SetInfoText("Toggle arousal icon")
	ElseIf (mcm_option == _sla_exposure_Toggle)
		SetInfoText("Toggle exposure icon")
	ElseIf (mcm_option == _apropos_two_wt_Toggle)
		SetInfoText("Toggle wear and tear icons")
	ElseIf (mcm_option == _fhu_cum_Toggle)
		SetInfoText("Toggle fill her up total pool icon")
	ElseIf (mcm_option == _fhu_cum_Anal_Toggle)
		SetInfoText("Toggle fill her up anal pool icon")
	ElseIf (mcm_option == _fhu_cum_Vaginal_Toggle)
		SetInfoText("Toggle fill her up vaginal pool icon")
	ElseIf (mcm_option == _mme_milk_Toggle)
		SetInfoText("Toggle milk icons")
	ElseIf (mcm_option == _mme_lactacid_Toggle)
		SetInfoText("Toggle lactacid icons")
	ElseIf (mcm_option == _parasites_mod_Toggle)
		SetInfoText("Toggle parasites icons")
	ElseIf (mcm_option == _pregnancy_mod_Toggle)
		SetInfoText("Toggle pregnancy module icons")
	endIf
EndEvent

Event onOptionSelect(int mcm_option)
	if(mcm_option == _sla_arousal_Toggle)
		config.module_sla_arousal = !config.module_sla_arousal
		setToggleOptionValue(mcm_option, config.module_sla_arousal) 
	elseIf(mcm_option == _sla_exposure_Toggle)
		config.module_sla_exposure = !config.module_sla_exposure
		setToggleOptionValue(mcm_option, config.module_sla_exposure)
	elseIf(mcm_option == _apropos_two_wt_Toggle)
		config.module_apropos_two_wt = !config.module_apropos_two_wt
		setToggleOptionValue(mcm_option, config.module_apropos_two_wt)
	elseIf(mcm_option == _fhu_cum_Toggle)
		config.module_fhu_cum = !config.module_fhu_cum
		setToggleOptionValue(mcm_option, config.module_fhu_cum)
	elseIf(mcm_option == _fhu_cum_Vaginal_Toggle)
		config.module_fhu_cum_vaginal = !config.module_fhu_cum_vaginal
		setToggleOptionValue(mcm_option, config.module_fhu_cum_vaginal)
	elseIf(mcm_option == _fhu_cum_Anal_Toggle)
		config.module_fhu_cum_anal = !config.module_fhu_cum_anal
		setToggleOptionValue(mcm_option, config.module_fhu_cum_anal)
	elseIf(mcm_option == _mme_milk_Toggle)
		config.module_mme_milk = !config.module_mme_milk
		setToggleOptionValue(mcm_option, config.module_mme_milk)
	elseIf(mcm_option == _mme_lactacid_Toggle)
		config.module_mme_lactacid = !config.module_mme_lactacid
		setToggleOptionValue(mcm_option, config.module_mme_lactacid)
	elseIf(mcm_option == _parasites_mod_Toggle)
		config.module_parasites_enabled = !config.module_parasites_enabled
		setToggleOptionValue(mcm_option, config.module_parasites_enabled)
	elseIf(mcm_option == _pregnancy_mod_Toggle)
		config.module_pregnancy_enabled = !config.module_pregnancy_enabled
		setToggleOptionValue(mcm_option, config.module_pregnancy_enabled)
	endIf
EndEvent

Event OnOptionSliderOpen(Int mcm_option)
	If (mcm_option == _update_interval_slider)
		SetSliderDialogStartValue(config.updateInterval)
		SetSliderDialogRange(0, 60)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(5)
	endIf
EndEvent

Event OnOptionSliderAccept(Int mcm_option, Float Value)
	If (mcm_option == _update_interval_slider)
		config.updateInterval=Value as Int
		SetSliderOptionValue(mcm_option, Value, "{0}")
	EndIf
EndEvent

State UpdateDeps
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("Working...")
		
		config.moduleSetup()

		SetTextOptionValueST("GO")
        SetOptionFlagsST(OPTION_FLAG_NONE)
        ForcePageReset()
    EndEvent
EndState

State AddEmptyIcon
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("Working...")
		
		widget_controller.LoadEmptyIcon()

		SetTextOptionValueST("ADD")
        SetOptionFlagsST(OPTION_FLAG_NONE)
    EndEvent
EndState

int Function _getFlag(Bool cond)
	If  !cond 	
   		return OPTION_FLAG_DISABLED  
	Else
   		return  OPTION_FLAG_NONE
	EndIf  
EndFunction