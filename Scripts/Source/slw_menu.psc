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
int _paf_pee_Toggle
int _paf_poo_Toggle
int _defeat_mod_Toggle



; SCRIPT VERSION
; https://github.com/schlangster/skyui/wiki/MCM-Advanced-Features#incremental-upgrading

int function GetVersion()
	return slw_util.GetVersion()
endFunction

Event OnConfigInit()
	ModName = "SLWidgets"
	Notification("MCM menu initialized.")
EndEvent

Event OnConfigClose()
		widget_controller.reloadWidgets()
EndEvent

Event OnConfigOpen()
		Pages = New String[3]
		Pages[0] = "$SLW_General_Page"
		Pages[1] = "$SLW_Toggles_Page"
		Pages[2] = "$SLW_Debug_Page"
EndEvent

Event OnPageReset(string page)
	config.moduleSyncConfig()

	if (page == "$SLW_General_Page")
		General()
	elseIf (page == "$SLW_Toggles_Page")
		Toggles()
	elseIf (page == "$SLW_Debug_Page")
		Debug()
	endIf
EndEvent

Function General()
    SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$SLW_General")
	Int sliderFlag = _getFlag()
	_update_interval_slider = AddSliderOption("$SLW_Update_Interval", config.updateInterval, "{0}", sliderFlag)
	AddEmptyOption()
	
	AddHeaderOption("$SLW_Sexlab_Aroused")
	Int slaFlag = _getFlag(config.module_sla.isInterfaceActive())
	_sla_arousal_Toggle = addToggleOption("$SLW_Arousal_Icon_Enabled", config.module_sla_arousal, slaFlag)
	_sla_exposure_Toggle = addToggleOption("$SLW_Exposure_Icon_Enabled",config.module_sla_exposure, slaFlag)
	
	AddHeaderOption("$SLW_Apropos2")
	Int wtFlag = _getFlag(config.module_apropos_two.isInterfaceActive()) 
	_apropos_two_wt_Toggle = addToggleOption("$SLW_WT_Icon_Enabled", config.module_apropos_two_wt, wtFlag)
	
	AddHeaderOption("$SLW_FHU")
	Int fhuFlag = _getFlag(config.module_fhu.isInterfaceActive()) 
	_fhu_cum_Toggle = addToggleOption("$SLW_FHU_TI", config.module_fhu_cum, fhuFlag)
	_fhu_cum_Vaginal_Toggle = addToggleOption("$SLW_FHU_VI", config.module_fhu_cum_vaginal, fhuFlag)
	_fhu_cum_Anal_Toggle = addToggleOption("$SLW_FHU_AI", config.module_fhu_cum_anal, fhuFlag)
	
	AddHeaderOption("$SLW_MME")
	Int mmeFlag = _getFlag(config.module_mme.isInterfaceActive()) 
	_mme_milk_Toggle = addToggleOption("$SLW_MME_MI", config.module_mme_milk, mmeFlag)
	_mme_lactacid_Toggle = addToggleOption("$SLW_MME_LI", config.module_mme_lactacid, mmeFlag)

	AddHeaderOption("$SLW_Needs")
	Int pafFlag = _getFlag(config.module_paf.isInterfaceActive()) 
	_paf_pee_Toggle = addToggleOption("$SLW_Needs_Pee", config.module_paf_pee, pafFlag)
	_paf_poo_Toggle = addToggleOption("$SLW_Needs_Poop", config.module_paf_poo, pafFlag)
EndFunction

Function Toggles()
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
	AddHeaderOption("$SLW_SLP")
	Int slpFlag = _getFlag(config.module_slp.isInterfaceActive()) 
	_parasites_mod_Toggle = addToggleOption("$SLW_SLP_Icon", config.module_parasites_enabled, slpFlag)
	AddHeaderOption("$SLW_Pregnancy")
	Int pregFlag = _getFlag(config.module_pregnancy.isInterfaceActive())
	_pregnancy_mod_Toggle = addToggleOption("$SLW_Pregnancy_Icons", config.module_pregnancy_enabled, pregFlag)
	AddHeaderOption("$SLW_Defeat")
	Int defeatFlag = _getFlag(config.module_defeat.isInterfaceActive())
	_defeat_mod_Toggle = addToggleOption("$SLW_Defeat_Icon", config.module_defeat_enabled, defeatFlag)
EndFunction

Function Debug()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddHeaderOption("SLWidgets. Version: " + GetVersionString())
	AddEmptyOption()
	AddTextOptionST("TOGGLE_MOD_STATE","$SLW_Debug_Toggle", StringIfElse( config.slw_stopped , "$SLW_Enable", "$SLW_Disable"), OPTION_FLAG_NONE)
	AddTextOptionST("UPDATE_DEPENDENCIES_STATE","$SLW_Recheck","$SLW_GO", OPTION_FLAG_NONE)
	AddTextOptionST("ADD_EMPTY_ICON_STATE","$SLW_Empty_Icon_Add","$SLW_Add", OPTION_FLAG_NONE)
	
	AddHeaderOption("$SLW_User_Settings")
	Int loadSettingsFlagPapyrus = _getFlag(jsonutil.JsonExists(config.slw_settings_path))
	AddTextOptionST("LOAD_USER_SETTINGS_STATE", "$SLW_Load_Settings", "$SLW_GO", loadSettingsFlagPapyrus)
	AddTextOptionST("SAVE_USER_SETTINGS_STATE", "$SLW_Save_Settings", "$SLW_GO", 0)

	AddHeaderOption("$SLW_Dependency_check")
	AddTextOption("$SLW_Iwant_SB_Check", StringIfElse( widget_controller.isLoaded() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SLA_Check", StringIfElse( isSLAReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_Appr2_Check", StringIfElse( isAprReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_FHU_Check", StringIfElse( isFHUReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_MME_Check", StringIfElse( isMMEReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SLP_Check", StringIfElse( isSLPReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_pregnancy")
	AddTextOption("$SLW_HP_Check", StringIfElse( isHPReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_FM3_Check", StringIfElse( isFM3Ready() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_BF_Check", StringIfElse( isBFReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_EF_Check", StringIfElse( isEFReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_EC_Check", StringIfElse( isECReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_ES_Check", StringIfElse( isESReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_ED_Check", StringIfElse( isEDReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_needs")
	AddTextOption("$SLW_PAF_Check", StringIfElse( isPAFReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_MND_Check", StringIfElse( isMiniNeedsReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_ALP_Check", StringIfElse( isAlivePeeingReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_defeat")
	AddTextOption("$SLW_SLD_Check", StringIfElse( isSLDefeatReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
EndFunction



Event onOptionHighlight(int mcm_option)
	If (mcm_option == _update_interval_slider)
		SetInfoText("$SLW_UpdateInterval_Info")
	ElseIf (mcm_option == _sla_arousal_Toggle)
		SetInfoText("$SLW_Arousal_Toggle_Info")
	ElseIf (mcm_option == _sla_exposure_Toggle)
		SetInfoText("$SLW_Exposure_Toggle_Info")
	ElseIf (mcm_option == _apropos_two_wt_Toggle)
		SetInfoText("$SLW_WT_Toggle_Info")
	ElseIf (mcm_option == _fhu_cum_Toggle)
		SetInfoText("$SLW_FHU_Toggle_Info")
	ElseIf (mcm_option == _fhu_cum_Anal_Toggle)
		SetInfoText("$SLW_FHU_Anal_Toggle_Info")
	ElseIf (mcm_option == _fhu_cum_Vaginal_Toggle)
		SetInfoText("$SLW_FHU_Vaginal_Toggle_Info")
	ElseIf (mcm_option == _mme_milk_Toggle)
		SetInfoText("$SLW_MME_Milk_Toggle_Info")
	ElseIf (mcm_option == _mme_lactacid_Toggle)
		SetInfoText("$SLW_MME_Lactacid_Toggle_Info")
	ElseIf (mcm_option == _paf_pee_Toggle)
		SetInfoText("$SLW_PAF_Pee_Info")
	ElseIf (mcm_option == _paf_poo_Toggle)
		SetInfoText("$SLW_PAF_Poo_Info")
	ElseIf (mcm_option == _parasites_mod_Toggle)
		SetInfoText("$SLW_Parasites_Toggle_Info")
	ElseIf (mcm_option == _pregnancy_mod_Toggle)
		SetInfoText("$SLW_Pregnancy_Toggle_Info")
	ElseIf (mcm_option == _defeat_mod_Toggle)
		SetInfoText("$SLW_Defeat_Toggle_Info")
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
	elseIf(mcm_option == _paf_pee_Toggle)
		config.module_paf_pee = !config.module_paf_pee
		setToggleOptionValue(mcm_option, config.module_paf_pee)
	elseIf(mcm_option == _paf_poo_Toggle)
		config.module_paf_poo = !config.module_paf_poo
		setToggleOptionValue(mcm_option, config.module_paf_poo)
	elseIf(mcm_option == _parasites_mod_Toggle)
		config.module_parasites_enabled = !config.module_parasites_enabled
		setToggleOptionValue(mcm_option, config.module_parasites_enabled)
	elseIf(mcm_option == _pregnancy_mod_Toggle)
		config.module_pregnancy_enabled = !config.module_pregnancy_enabled
		setToggleOptionValue(mcm_option, config.module_pregnancy_enabled)
	elseIf(mcm_option == _defeat_mod_Toggle)
		config.module_defeat_enabled = !config.module_defeat_enabled
		setToggleOptionValue(mcm_option, config.module_defeat_enabled)
	endIf
EndEvent

Event OnOptionSliderOpen(Int mcm_option)
	If (mcm_option == _update_interval_slider)
		SetSliderDialogStartValue(config.updateInterval)
		SetSliderDialogRange(1, 60)
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

State UPDATE_DEPENDENCIES_STATE
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("$SLW_Working")
		config.moduleReset()
		config.moduleSetup()
		SetTextOptionValueST("$SLW_GO")
        SetOptionFlagsST(OPTION_FLAG_NONE)
        ForcePageReset()
    EndEvent

	Event OnHighlightST()
        SetInfoText("$SLW_UpdateDeps_Info")
    EndEvent   
EndState

State ADD_EMPTY_ICON_STATE
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("$SLW_Working")
		
		widget_controller.LoadEmptyIcon()

		SetTextOptionValueST("$SLW_Add")
        SetOptionFlagsST(OPTION_FLAG_NONE)
    EndEvent
EndState

State TOGGLE_MOD_STATE
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("$SLW_Working")
		config.slw_stopped = !config.slw_stopped
		if config.slw_stopped
			;disable flow
			config.DisableWidgets()
			config.moduleReset()
			SetTextOptionValueST("$SLW_Enable")
			ShowMessage("$SLW_Disabled", false)
		Else
			;enable flow
			config.SetDefaults()
			config.LoadUserSettingsPapyrus()
			widget_controller.setup()
			SetTextOptionValueST("$SLW_Disable")
			ShowMessage("$SLW_Enabled", false)
		endif
        SetOptionFlagsST(OPTION_FLAG_NONE)
    EndEvent
	
	Event OnHighlightST()
        SetInfoText("$SLW_EnabledDisabled_Info")
    EndEvent
EndState

state SAVE_USER_SETTINGS_STATE
	function OnSelectST()
		if jsonutil.JsonExists(config.slw_settings_path)
			if !ShowMessage("$SLW_Overwrite_Settings_Question", true, "$Accept", "$Cancel")
				return 
			endIf
		endIf
		if config.SaveUserSettingsPapyrus()
			ShowMessage("$SLW_Settings_Saved_Status", false, "$Accept", "$Cancel")
		else
			ShowMessage("$SLW_Save_Settings_Failed_Status", false, "$Accept", "$Cancel")
		endIf
		ForcePageReset()
	endFunction

	function OnHighlightST()
		SetInfoText("$SLW_Save_Settings_Info")
	endFunction
endState

state LOAD_USER_SETTINGS_STATE

	function OnSelectST()

		if ShowMessage("$SLW_Load_Settings_Question", true, "$Accept", "$Cancel")
			if config.LoadUserSettingsPapyrus()
				ShowMessage("$SLW_Settings_Loaded_Status", false, "$Accept", "$Cancel")
			else
				ShowMessage("$SLW_Load_Settings_Failed_Status", false, "$Accept", "$Cancel")
			endIf
		endIf
	endFunction

	function OnHighlightST()
		if jsonutil.JsonExists(config.slw_settings_path)
			SetInfoText("$SLW_Load_Settings_Info")
		else
			SetInfoText("$SLW_Load_Settings_Info_Not_Exist")
		endIf
	endFunction
endState

int Function _getFlag(Bool cond = true)
	if config.slw_stopped
		return OPTION_FLAG_DISABLED
	endif
	If  !cond 	
   		return OPTION_FLAG_DISABLED  
	Else
   		return OPTION_FLAG_NONE
	EndIf  
EndFunction