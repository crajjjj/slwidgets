Scriptname slw_menu extends SKI_ConfigBase
import slw_util
import slw_log


slw_config Property config auto
slw_widget_controller Property widget_controller auto

int _update_interval_slider
int _sla_arousal_Toggle

String[] _presetNames
String[] _settingsPresetNames
Bool _togglesDirty = false
Bool _npcDirty = false
int _sla_exposure_Toggle
int _apropos_two_wt_Toggle
int _fhu_cum_Toggle
int _fhu_cum_Anal_Toggle
int _fhu_cum_Vaginal_Toggle
int _fhu_cum_Oral_Toggle
int _mme_milk_Toggle
int _mme_lactacid_Toggle
int _parasites_mod_Toggle
int _pregnancy_mod_Toggle
int _paf_pee_Toggle
int _paf_poo_Toggle
int _defeat_mod_Toggle
; 3.0.0 icons
int _sh_food_Toggle
int _sh_thirst_Toggle
int _sh_cold_Toggle
int _sh_fatigue_Toggle
int _dirtiness_Toggle
int _wetness_Toggle
int _sph_pubic_Toggle
int _sph_armpit_Toggle
int _baby_health_Toggle
int _stress_Toggle
int _fear_Toggle
int _injuries_Toggle
int _diseases_Toggle
; The willpower bar's own options from 2.2.6, now meter 0 of the stack.
; Unused; kept so the saves that hold them load clean.
int _slove_willpower_Toggle
int _slove_bar_x_slider
int _slove_bar_y_slider
int _slove_bar_scale_slider
int _meters_always_toggle
int _meters_hold_slider
int _meters_x_slider
int _meters_y_slider
int _meters_scale_slider
; one toggle per meter, indexed by meter number (slw_config.getMeterPresetKey)
int[] _meter_toggle

; NPC Tracking page option IDs (resolved each OnPageReset)
int _npc_hotkey_option
int _npc_reset_layout_option
int _npc_group_x_slider
int _npc_group_y_slider
int _npc_vertical_spacing_slider
int _npc_label_font_menu
int _npc_label_size_slider
int[] _npc_clear_option
int[] _npc_sla_arousal_toggle
int[] _npc_sla_exposure_toggle
int[] _npc_ap2_toggle
int[] _npc_fhu_cum_toggle
int[] _npc_fhu_anal_toggle
int[] _npc_fhu_vaginal_toggle
int[] _npc_fhu_oral_toggle
int[] _npc_mme_milk_toggle
int[] _npc_mme_lactacid_toggle
int[] _npc_slp_toggle
int[] _npc_preg_toggle
int[] _npc_dirt_toggle
int[] _npc_wet_toggle
int[] _npc_baby_toggle
int[] _npc_label_x_slider
int[] _npc_label_y_slider
int[] _npc_custom_label_option



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
	If _togglesDirty || _npcDirty
		_togglesDirty = false
		_npcDirty = false
		widget_controller.toggleUpdateWidgets()
	EndIf
EndEvent

Event OnConfigOpen()
		Pages = New String[5]
		Pages[0] = "$SLW_General_Page"
		Pages[1] = "$SLW_Toggles_Page"
		Pages[2] = "$SLW_Meters_Page"
		Pages[3] = "$SLW_NPC_Page"
		Pages[4] = "$SLW_Debug_Page"
EndEvent

Event OnPageReset(string page)
	;config.moduleSyncConfig()

	if (page == "$SLW_General_Page")
		General()
	elseIf (page == "$SLW_Toggles_Page")
		Toggles()
	elseIf (page == "$SLW_Meters_Page")
		Meters()
	elseIf (page == "$SLW_NPC_Page")
		NpcTracking()
	elseIf (page == "$SLW_Debug_Page")
		Debug()
	endIf
EndEvent

event OnVersionUpdate(int a_version)
	; a_version is the new version, CurrentVersion is the old version
	If a_version >= 30000 && CurrentVersion < 30000
		Debug.Trace(self + ": Updating script to version 30000")
		; 3.0.0: thirteen new icons. Their switches are properties with
		; defaults and the modules register their icons on the next widget
		; reload, so there is nothing to migrate; the block marks the step.
	EndIf
endEvent

Function General()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$SLW_General")
	int enableflag = _getFlag(widget_controller.isLoaded())
	AddTextOptionST("TOGGLE_MOD_STATE","$SLW_Mod_Toggle", StringIfElse(config.slw_stopped , "$SLW_Enable", "$SLW_Disable"), enableflag)
	Int sliderFlag = _getFlag()
	_update_interval_slider = AddSliderOption("$SLW_Update_Interval", config.updateInterval, "{0}", sliderFlag)

	AddMenuOptionST("SETTINGS_PRESET_MENU_STATE", "$SLW_Settings_Preset", config.activeSettingsPreset, sliderFlag)
	AddTextOptionST("SAVE_SETTINGS_PRESET_STATE", "$SLW_Save_Settings_Preset", "$SLW_GO", 0)
	AddMenuOptionST("PRESET_MENU_STATE", "$SLW_Color_Preset", config.activePreset, sliderFlag)
EndFunction

Function Toggles()
    SetCursorFillMode(TOP_TO_BOTTOM)
    SetCursorPosition(0)
	AddHeaderOption("$SLW_Static")
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
	_fhu_cum_Oral_Toggle = addToggleOption("$SLW_FHU_OI", config.module_fhu_cum_oral, fhuFlag)
	
	AddHeaderOption("$SLW_MME") 
	_mme_milk_Toggle = addToggleOption("$SLW_MME_MI", config.module_mme_milk,_getFlag(config.module_mme.isInterfaceActive()))
	_mme_lactacid_Toggle = addToggleOption("$SLW_MME_LI", config.module_mme_lactacid, _getFlag(isMMEReady()))

	AddHeaderOption("$SLW_Needs")
	Int pafFlag = _getFlag(config.module_paf.isInterfaceActive()) 
	_paf_pee_Toggle = addToggleOption("$SLW_Needs_Pee", config.module_paf_pee, pafFlag)
	_paf_poo_Toggle = addToggleOption("$SLW_Needs_Poop", config.module_paf_poo, pafFlag)

	AddHeaderOption("$SLW_SunHelm")
	Int shFlag = _getFlag(config.module_sunhelm.isInterfaceActive())
	_sh_food_Toggle = addToggleOption("$SLW_SH_Food", config.module_sh_food, shFlag)
	_sh_thirst_Toggle = addToggleOption("$SLW_SH_Thirst", config.module_sh_thirst, shFlag)
	_sh_cold_Toggle = addToggleOption("$SLW_SH_Cold", config.module_sh_cold, shFlag)
	_sh_fatigue_Toggle = addToggleOption("$SLW_SH_Fatigue", config.module_sh_fatigue, shFlag)

	AddHeaderOption("$SLW_Hygiene")
	_dirtiness_Toggle = addToggleOption("$SLW_Dirtiness_Icon", config.module_dirtiness, _getFlag(config.module_hygiene.Plugin_Bathing))
	_wetness_Toggle = addToggleOption("$SLW_Wetness_Icon", config.module_wetness, _getFlag(config.module_hygiene.Plugin_WetFunction))

	AddHeaderOption("$SLW_SPH")
	Int sphFlag = _getFlag(config.module_sph.isInterfaceActive())
	_sph_pubic_Toggle = addToggleOption("$SLW_SPH_Pubic", config.module_sph_pubic, sphFlag)
	_sph_armpit_Toggle = addToggleOption("$SLW_SPH_Armpit", config.module_sph_armpit, sphFlag)

	AddHeaderOption("$SLW_BabyHealth")
	_baby_health_Toggle = addToggleOption("$SLW_BabyHealth_Icon", config.module_baby_health, _getFlag(config.module_baby.isInterfaceActive()))

	AddHeaderOption("$SLW_StressFear")
	Int safFlag = _getFlag(config.module_stress.isInterfaceActive())
	_stress_Toggle = addToggleOption("$SLW_Stress_Icon", config.module_saf_stress, safFlag)
	_fear_Toggle = addToggleOption("$SLW_Fear_Icon", config.module_saf_fear, safFlag)

	AddHeaderOption("$SLW_Health")
	_injuries_Toggle = addToggleOption("$SLW_Injuries_Icon", config.module_injuries, _getFlag(config.module_health.Plugin_BladeBlunt))
	_diseases_Toggle = addToggleOption("$SLW_Diseases_Icon", config.module_diseases, _getFlag(config.module_health.isInterfaceActive()))

	AddHeaderOption("$SLW_Conditional")
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

; The bars, as opposed to the Status Bars icons: one stack of iWant Widgets
; meters with one place and size. Left: how the stack shows and where.
; Right: a switch per meter, grouped by mod, in stack order.
Function Meters()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	If !_meter_toggle || _meter_toggle.Length != config.getMeterCount()
		_meter_toggle = Utility.CreateIntArray(config.getMeterCount(), -1)
	EndIf
	AddHeaderOption("$SLW_Meters")
	_meters_always_toggle = AddToggleOption("$SLW_Meters_Always", widget_controller.metersAlwaysShow)
	_meters_hold_slider = AddSliderOption("$SLW_Meters_Hold", widget_controller.metersHoldSeconds, "{0} s", _getFlag(!widget_controller.metersAlwaysShow))
	_meters_x_slider = AddSliderOption("$SLW_Meters_X", widget_controller.metersX, "{0}")
	_meters_y_slider = AddSliderOption("$SLW_Meters_Y", widget_controller.metersY, "{0}")
	_meters_scale_slider = AddSliderOption("$SLW_Meters_Scale", widget_controller.metersScale, "{0}%")

	SetCursorPosition(1)
	AddHeaderOption("$SLW_SLOVE")
	_addMeterToggle(0, isSloveReady())
	AddHeaderOption("$SLW_Sexlab_Aroused")
	_addMeterToggle(1, config.module_sla.isInterfaceActive())
	AddHeaderOption("$SLW_FHU")
	Bool fhuLoaded = config.module_fhu.isInterfaceActive()
	Int i = 2
	While i <= 5
		_addMeterToggle(i, fhuLoaded)
		i += 1
	EndWhile
	AddHeaderOption("$SLW_Apropos2")
	Bool wtLoaded = config.module_apropos_two.isInterfaceActive()
	i = 6
	While i < config.getMeterCount()
		_addMeterToggle(i, wtLoaded)
		i += 1
	EndWhile
EndFunction

Function _addMeterToggle(Int meter, Bool loaded)
	_meter_toggle[meter] = AddToggleOption(_meterLabel(meter), config.isMeterOn(meter), _getFlag(loaded))
EndFunction

; Each label is one translation key, spelled out whole rather than built from
; parts. Papyrus keeps one copy per string regardless of case, so
; "$SLW_Meter_" + "willpower" came out as "$SLW_Meter_Willpower" once another
; loaded script had used that casing first, and the translation lookup is
; case-sensitive: the MCM showed the raw key. A whole literal has no other copy
; to take its casing from.
String Function _meterLabel(Int meter)
	If meter == 0
		Return "$SLW_Meter_willpower"
	ElseIf meter == 1
		Return "$SLW_Meter_arousal"
	ElseIf meter == 2
		Return "$SLW_Meter_fhu_total"
	ElseIf meter == 3
		Return "$SLW_Meter_fhu_vaginal"
	ElseIf meter == 4
		Return "$SLW_Meter_fhu_anal"
	ElseIf meter == 5
		Return "$SLW_Meter_fhu_oral"
	ElseIf meter == 6
		Return "$SLW_Meter_wt_vaginal"
	ElseIf meter == 7
		Return "$SLW_Meter_wt_anal"
	EndIf
	Return "$SLW_Meter_wt_oral"
EndFunction

; Meter number of a meter toggle, -1 for any other option.
Int Function _findMeterForOption(Int mcm_option)
	If !_meter_toggle
		Return -1
	EndIf
	Int i = 0
	While i < _meter_toggle.Length
		If _meter_toggle[i] == mcm_option
			Return i
		EndIf
		i += 1
	EndWhile
	Return -1
EndFunction

String Function _slotName(Int slot)
	Actor a = config.getNpcSlot(slot)
	If a
		Return a.GetDisplayName()
	EndIf
	Return "(empty)"
EndFunction

Function _initNpcOptionArrays()
	If !_npc_clear_option
		_npc_clear_option = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_sla_arousal_toggle
		_npc_sla_arousal_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_sla_exposure_toggle
		_npc_sla_exposure_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_ap2_toggle
		_npc_ap2_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_fhu_cum_toggle
		_npc_fhu_cum_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_fhu_anal_toggle
		_npc_fhu_anal_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_fhu_vaginal_toggle
		_npc_fhu_vaginal_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_fhu_oral_toggle
		_npc_fhu_oral_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_mme_milk_toggle
		_npc_mme_milk_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_mme_lactacid_toggle
		_npc_mme_lactacid_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_slp_toggle
		_npc_slp_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_preg_toggle
		_npc_preg_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_dirt_toggle
		_npc_dirt_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_wet_toggle
		_npc_wet_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_baby_toggle
		_npc_baby_toggle = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_label_x_slider
		_npc_label_x_slider = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_label_y_slider
		_npc_label_y_slider = Utility.CreateIntArray(4, -1)
	EndIf
	If !_npc_custom_label_option
		_npc_custom_label_option = Utility.CreateIntArray(4, -1)
	EndIf
EndFunction

String Function _customLabelDisplay(Int slot)
	String s = config.getNpcCustomLabel(slot)
	If s == ""
		Return "$SLW_NPC_Custom_Label_None"
	EndIf
	Return s
EndFunction

Function NpcTracking()
	_initNpcOptionArrays()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)

	AddHeaderOption("$SLW_NPC_Tracking")
	_npc_hotkey_option = AddKeyMapOption("$SLW_NPC_Hotkey", config.npcHotkey)
	_npc_group_x_slider = AddSliderOption("$SLW_NPC_Group_X", widget_controller.npcGroupX, "{0}", OPTION_FLAG_NONE)
	_npc_group_y_slider = AddSliderOption("$SLW_NPC_Group_Y", widget_controller.npcGroupY, "{0}", OPTION_FLAG_NONE)
	_npc_vertical_spacing_slider = AddSliderOption("$SLW_NPC_Vertical_Spacing", widget_controller.npcVerticalSpacing, "{0}", OPTION_FLAG_NONE)
	_npc_reset_layout_option = AddTextOption("$SLW_NPC_Reset_Layout", "$SLW_GO", OPTION_FLAG_NONE)
	AddHeaderOption("$SLW_NPC_Label_Style")
	_npc_label_font_menu = AddMenuOption("$SLW_NPC_Label_Font", _currentFontLabel(), OPTION_FLAG_NONE)
	_npc_label_size_slider = AddSliderOption("$SLW_NPC_Label_Size", widget_controller.npcLabelSize, "{0}", OPTION_FLAG_NONE)
	AddColorOptionST("NPC_LABEL_COLOR_STATE", "$SLW_NPC_Label_Color", widget_controller.getNpcLabelColorPacked())
	AddEmptyOption()

	Int slot = 1
	While slot <= 3
		; A SkyUI column holds 64 options; the globals and three slots are 68, so
		; slots 2 and 3 go to the right column.
		If slot == 2
			SetCursorPosition(1)
		EndIf
		; Header label is built dynamically with the actor name; SkyUI only resolves
		; $KEY when the whole label is a single key, so the prefix stays in English.
		AddHeaderOption("NPC Slot " + slot + ":  " + _slotName(slot))
		Int slotFlag = OPTION_FLAG_NONE
		If !config.getNpcSlot(slot)
			slotFlag = OPTION_FLAG_DISABLED
		EndIf
		_npc_clear_option[slot] = AddTextOption("$SLW_NPC_Clear", "$SLW_GO", slotFlag)
		_npc_sla_arousal_toggle[slot] = AddToggleOption("$SLW_Arousal_Icon_Enabled", config.getSlotModuleEnable(slot, config.MOD_SLA_AROUSAL), slotFlag)
		_npc_sla_exposure_toggle[slot] = AddToggleOption("$SLW_Exposure_Icon_Enabled", config.getSlotModuleEnable(slot, config.MOD_SLA_EXPOSURE), slotFlag)
		_npc_ap2_toggle[slot] = AddToggleOption("$SLW_WT_Icon_Enabled", config.getSlotModuleEnable(slot, config.MOD_AP2), slotFlag)
		_npc_fhu_cum_toggle[slot] = AddToggleOption("$SLW_FHU_TI", config.getSlotModuleEnable(slot, config.MOD_FHU_CUM), slotFlag)
		_npc_fhu_vaginal_toggle[slot] = AddToggleOption("$SLW_FHU_VI", config.getSlotModuleEnable(slot, config.MOD_FHU_VAGINAL), slotFlag)
		_npc_fhu_anal_toggle[slot] = AddToggleOption("$SLW_FHU_AI", config.getSlotModuleEnable(slot, config.MOD_FHU_ANAL), slotFlag)
		_npc_fhu_oral_toggle[slot] = AddToggleOption("$SLW_FHU_OI", config.getSlotModuleEnable(slot, config.MOD_FHU_ORAL), slotFlag)
		_npc_mme_milk_toggle[slot] = AddToggleOption("$SLW_MME_MI", config.getSlotModuleEnable(slot, config.MOD_MME_MILK), slotFlag)
		_npc_mme_lactacid_toggle[slot] = AddToggleOption("$SLW_MME_LI", config.getSlotModuleEnable(slot, config.MOD_MME_LACTACID), slotFlag)
		_npc_slp_toggle[slot] = AddToggleOption("$SLW_SLP_Icon", config.getSlotModuleEnable(slot, config.MOD_SLP), slotFlag)
		_npc_preg_toggle[slot] = AddToggleOption("$SLW_Pregnancy_Icons", config.getSlotModuleEnable(slot, config.MOD_PREG), slotFlag)
		_npc_dirt_toggle[slot] = AddToggleOption("$SLW_Dirtiness_Icon", config.getSlotModuleEnable(slot, config.MOD_DIRT), slotFlag)
		_npc_wet_toggle[slot] = AddToggleOption("$SLW_Wetness_Icon", config.getSlotModuleEnable(slot, config.MOD_WET), slotFlag)
		_npc_baby_toggle[slot] = AddToggleOption("$SLW_BabyHealth_Icon", config.getSlotModuleEnable(slot, config.MOD_BABY), slotFlag)
		_npc_label_x_slider[slot] = AddSliderOption("$SLW_NPC_Label_OffsetX", widget_controller.getNpcLabelOffsetX(slot), "{0}", slotFlag)
		_npc_label_y_slider[slot] = AddSliderOption("$SLW_NPC_Label_OffsetY", widget_controller.getNpcLabelOffsetY(slot), "{0}", slotFlag)
		_npc_custom_label_option[slot] = AddInputOption("$SLW_NPC_Custom_Label", _customLabelDisplay(slot), slotFlag)
		slot += 1
	EndWhile
EndFunction

Int Function _findNpcSlotForOption(Int opt, Int[] arr)
	Int i = 1
	While i <= 3
		If arr[i] == opt
			Return i
		EndIf
		i += 1
	EndWhile
	Return 0
EndFunction

Function Debug()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddHeaderOption("SLWidgets. Version: " + GetVersionString())
	AddEmptyOption()
	AddTextOptionST("UPDATE_DEPENDENCIES_STATE","$SLW_Recheck","$SLW_GO", OPTION_FLAG_NONE)
	
	AddHeaderOption("$SLW_Dependency_check")
	AddTextOption("$SLW_Iwant_SB_Check", StringIfElse( widget_controller.isLoaded() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_Iwant_SB_Patch_Check", StringIfElse( widget_controller.hasBarsAPI() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SLA_Check", StringIfElse( isSLAReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_Appr2_Check", StringIfElse( isAprReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_FHU_Check", StringIfElse( isFHUReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_MME_Check", StringIfElse( isMMEReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_MAL_Check", StringIfElse( isMALReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SLP_Check", StringIfElse( isSLPReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_pregnancy")
	AddTextOption("$SLW_HP_Check", StringIfElse( isHPReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_FM3_Check", StringIfElse( isFM3Ready() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_FM3T_Check", StringIfElse( isFM3TweaksReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_FMR_Check", StringIfElse( isFMReloadedReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_BF_Check", StringIfElse( isBFReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_EF_Check", StringIfElse( isEFReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_EC_Check", StringIfElse( isECReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_ES_Check", StringIfElse( isESReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_ED_Check", StringIfElse( isEDReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SGO4_Check", StringIfElse( isSGO4Ready() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_COF_Check", StringIfElse( isCurseOfLifeReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_needs")
	AddTextOption("$SLW_PAF_Check", StringIfElse( isPAFReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_MND_Check", StringIfElse( isMiniNeedsReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_ALP_Check", StringIfElse( isAlivePeeingReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_PNO_Check", StringIfElse( isPNOReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_defeat")
	AddTextOption("$SLW_SLD_Check", StringIfElse( isSLDefeatReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SLOVE_Check", StringIfElse( isSloveReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddHeaderOption("$SLW_Dependency_check_survival")
	AddTextOption("$SLW_SH_Check", StringIfElse( isSunHelmReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SHD_Check", StringIfElse( isSunHelmDiseasesReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_BIS_Check", StringIfElse( isBathingReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_WFR_Check", StringIfElse( isWetFunctionReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_WFNG_Check", StringIfElse( isWetFunctionNGReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SPH_Check", StringIfElse( isSPHReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SAF_Check", StringIfElse( isStressFearReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_BNB_Check", StringIfElse( isBladeBluntReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)

	AddTextOptionST("ADD_EMPTY_ICON_STATE","$SLW_Empty_Icon_Add","$SLW_Add", OPTION_FLAG_NONE)
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
	ElseIf (mcm_option == _fhu_cum_Oral_Toggle)
		SetInfoText("$SLW_FHU_Oral_Toggle_Info")
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
	ElseIf (mcm_option == _sh_food_Toggle)
		SetInfoText("$SLW_SH_Food_Info")
	ElseIf (mcm_option == _sh_thirst_Toggle)
		SetInfoText("$SLW_SH_Thirst_Info")
	ElseIf (mcm_option == _sh_cold_Toggle)
		SetInfoText("$SLW_SH_Cold_Info")
	ElseIf (mcm_option == _sh_fatigue_Toggle)
		SetInfoText("$SLW_SH_Fatigue_Info")
	ElseIf (mcm_option == _dirtiness_Toggle)
		SetInfoText("$SLW_Dirtiness_Info")
	ElseIf (mcm_option == _wetness_Toggle)
		SetInfoText("$SLW_Wetness_Info")
	ElseIf (mcm_option == _sph_pubic_Toggle)
		SetInfoText("$SLW_SPH_Pubic_Info")
	ElseIf (mcm_option == _sph_armpit_Toggle)
		SetInfoText("$SLW_SPH_Armpit_Info")
	ElseIf (mcm_option == _baby_health_Toggle)
		SetInfoText("$SLW_BabyHealth_Info")
	ElseIf (mcm_option == _stress_Toggle)
		SetInfoText("$SLW_Stress_Info")
	ElseIf (mcm_option == _fear_Toggle)
		SetInfoText("$SLW_Fear_Info")
	ElseIf (mcm_option == _injuries_Toggle)
		SetInfoText("$SLW_Injuries_Info")
	ElseIf (mcm_option == _diseases_Toggle)
		SetInfoText("$SLW_Diseases_Info")
	ElseIf (mcm_option == _meters_always_toggle)
		SetInfoText("$SLW_Meters_Always_Info")
	ElseIf (mcm_option == _meters_hold_slider)
		SetInfoText("$SLW_Meters_Hold_Info")
	ElseIf (mcm_option == _meters_x_slider)
		SetInfoText("$SLW_Meters_X_Info")
	ElseIf (mcm_option == _meters_y_slider)
		SetInfoText("$SLW_Meters_Y_Info")
	ElseIf (mcm_option == _meters_scale_slider)
		SetInfoText("$SLW_Meters_Scale_Info")
	Else
		Int meter = _findMeterForOption(mcm_option)
		If meter == 0
			SetInfoText("$SLW_Willpower_Bar_Info")
		ElseIf meter == 1
			SetInfoText("$SLW_Meter_Arousal_Info")
		ElseIf meter >= 2 && meter <= 5
			SetInfoText("$SLW_Meter_FHU_Info")
		ElseIf meter >= 6
			SetInfoText("$SLW_Meter_WT_Info")
		EndIf
	endIf
EndEvent

Event onOptionSelect(int mcm_option)
	Bool _v = False
	_togglesDirty = true
	if(mcm_option == _sla_arousal_Toggle)
		_v = !config.module_sla_arousal
		config.module_sla_arousal = _v
		setToggleOptionValue(mcm_option, _v) 
	elseIf(mcm_option == _sla_exposure_Toggle)
		_v = !config.module_sla_exposure
		config.module_sla_exposure = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _apropos_two_wt_Toggle)
		_v = !config.module_apropos_two_wt
		config.module_apropos_two_wt = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _fhu_cum_Toggle)
		_v = !config.module_fhu_cum
		config.module_fhu_cum = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _fhu_cum_Vaginal_Toggle)
		_v = !config.module_fhu_cum_vaginal
		config.module_fhu_cum_vaginal = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _fhu_cum_Anal_Toggle)
		_v = !config.module_fhu_cum_anal
		config.module_fhu_cum_anal = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _fhu_cum_Oral_Toggle)
		_v = !config.module_fhu_cum_oral
		config.module_fhu_cum_oral = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _mme_milk_Toggle)
		_v = !config.module_mme_milk
		config.module_mme_milk = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _mme_lactacid_Toggle)
		_v = !config.module_mme_lactacid
		config.module_mme_lactacid = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _paf_pee_Toggle)
		_v = !config.module_paf_pee
		config.module_paf_pee = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _paf_poo_Toggle)
		_v = !config.module_paf_poo
		config.module_paf_poo = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _parasites_mod_Toggle)
		_v = !config.module_parasites_enabled
		config.module_parasites_enabled = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _pregnancy_mod_Toggle)
		_v = !config.module_pregnancy_enabled
		config.module_pregnancy_enabled = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _defeat_mod_Toggle)
		_v = !config.module_defeat_enabled
		config.module_defeat_enabled = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _sh_food_Toggle)
		_v = !config.module_sh_food
		config.module_sh_food = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _sh_thirst_Toggle)
		_v = !config.module_sh_thirst
		config.module_sh_thirst = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _sh_cold_Toggle)
		_v = !config.module_sh_cold
		config.module_sh_cold = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _sh_fatigue_Toggle)
		_v = !config.module_sh_fatigue
		config.module_sh_fatigue = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _dirtiness_Toggle)
		_v = !config.module_dirtiness
		config.module_dirtiness = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _wetness_Toggle)
		_v = !config.module_wetness
		config.module_wetness = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _sph_pubic_Toggle)
		_v = !config.module_sph_pubic
		config.module_sph_pubic = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _sph_armpit_Toggle)
		_v = !config.module_sph_armpit
		config.module_sph_armpit = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _baby_health_Toggle)
		_v = !config.module_baby_health
		config.module_baby_health = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _stress_Toggle)
		_v = !config.module_saf_stress
		config.module_saf_stress = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _fear_Toggle)
		_v = !config.module_saf_fear
		config.module_saf_fear = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _injuries_Toggle)
		_v = !config.module_injuries
		config.module_injuries = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _diseases_Toggle)
		_v = !config.module_diseases
		config.module_diseases = _v
		setToggleOptionValue(mcm_option, _v)
	elseIf(mcm_option == _meters_always_toggle)
		_v = !widget_controller.metersAlwaysShow
		widget_controller.metersAlwaysShow = _v
		setToggleOptionValue(mcm_option, _v)
		SetOptionFlags(_meters_hold_slider, _getFlag(!_v))
	Else
		Int meter = _findMeterForOption(mcm_option)
		If meter >= 0
			_v = !config.isMeterOn(meter)
			config.setMeterOn(meter, _v)
			setToggleOptionValue(mcm_option, _v)
			widget_controller.requestMetersRebuild()
		Else
			_handleNpcPageSelect(mcm_option)
		EndIf
	endIf
EndEvent

Function _handleNpcPageSelect(Int mcm_option)
	_initNpcOptionArrays()
	If mcm_option == _npc_reset_layout_option
		widget_controller.applyDefaultNpcBarLayout()
		_npcDirty = true
		Return
	EndIf
	Int slot = _findNpcSlotForOption(mcm_option, _npc_clear_option)
	If slot > 0
		config.clearNpcSlot(slot)
		_npcDirty = true
		ForcePageReset()
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_sla_arousal_toggle, config.MOD_SLA_AROUSAL)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_sla_exposure_toggle, config.MOD_SLA_EXPOSURE)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_ap2_toggle, config.MOD_AP2)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_fhu_cum_toggle, config.MOD_FHU_CUM)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_fhu_anal_toggle, config.MOD_FHU_ANAL)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_fhu_vaginal_toggle, config.MOD_FHU_VAGINAL)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_fhu_oral_toggle, config.MOD_FHU_ORAL)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_mme_milk_toggle, config.MOD_MME_MILK)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_mme_lactacid_toggle, config.MOD_MME_LACTACID)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_slp_toggle, config.MOD_SLP)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_preg_toggle, config.MOD_PREG)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_dirt_toggle, config.MOD_DIRT)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_wet_toggle, config.MOD_WET)
		Return
	EndIf
	If _tryToggleSubCode(mcm_option, _npc_baby_toggle, config.MOD_BABY)
		Return
	EndIf
EndFunction

Bool Function _tryToggleSubCode(Int mcm_option, Int[] arr, Int subCode)
	Int slot = _findNpcSlotForOption(mcm_option, arr)
	If slot <= 0
		Return False
	EndIf
	Bool nv = !config.getSlotModuleEnable(slot, subCode)
	config.setSlotModuleEnable(slot, subCode, nv)
	setToggleOptionValue(mcm_option, nv)
	_npcDirty = true
	Return True
EndFunction

; Curated set of fonts that ship with Skyrim and render legibly at HUD sizes.
; Index 0 is the safe default ($EverywhereFont supports all character ranges).
String[] Function _getFontKeys()
	String[] keys = new String[7]
	keys[0] = "$EverywhereFont"
	keys[1] = "$EverywhereBoldFont"
	keys[2] = "$EverywhereMediumFont"
	keys[3] = "$SkyrimBooks"
	keys[4] = "$SkyrimBooks_Gaelic"
	keys[5] = "$HandwrittenFont"
	keys[6] = "$DragonFont"
	Return keys
EndFunction

String[] Function _getFontLabels()
	String[] labels = new String[7]
	labels[0] = "Default (Everywhere)"
	labels[1] = "Everywhere Bold"
	labels[2] = "Everywhere Medium"
	labels[3] = "Skyrim Books"
	labels[4] = "Skyrim Books Gaelic"
	labels[5] = "Handwritten"
	labels[6] = "Dragon"
	Return labels
EndFunction

Int Function _findFontIndex(String fontKey)
	String[] keys = _getFontKeys()
	Int i = 0
	While i < keys.Length
		If keys[i] == fontKey
			Return i
		EndIf
		i += 1
	EndWhile
	Return 0
EndFunction

String Function _currentFontLabel()
	String[] labels = _getFontLabels()
	Return labels[_findFontIndex(widget_controller.npcLabelFont)]
EndFunction

Event OnOptionMenuOpen(Int mcm_option)
	If mcm_option == _npc_label_font_menu
		SetMenuDialogOptions(_getFontLabels())
		SetMenuDialogStartIndex(_findFontIndex(widget_controller.npcLabelFont))
	EndIf
EndEvent

Event OnOptionMenuAccept(Int mcm_option, Int index)
	If mcm_option == _npc_label_font_menu
		String[] keys = _getFontKeys()
		String[] labels = _getFontLabels()
		If index >= 0 && index < keys.Length
			widget_controller.setNpcLabelFont(keys[index])
			SetMenuOptionValue(mcm_option, labels[index])
		EndIf
	EndIf
EndEvent

Event OnOptionInputOpen(Int mcm_option)
	_initNpcOptionArrays()
	Int slot = _findNpcSlotForOption(mcm_option, _npc_custom_label_option)
	If slot > 0
		SetInputDialogStartText(config.getNpcCustomLabel(slot))
	EndIf
EndEvent

Event OnOptionInputAccept(Int mcm_option, String value)
	_initNpcOptionArrays()
	Int slot = _findNpcSlotForOption(mcm_option, _npc_custom_label_option)
	If slot > 0
		config.setNpcCustomLabel(slot, value)
		widget_controller.refreshNpcLabel(slot)
		SetInputOptionValue(mcm_option, _customLabelDisplay(slot))
	EndIf
EndEvent

Event OnOptionKeyMapChange(Int mcm_option, Int newKey, String conflictControl, String conflictName)
	If mcm_option == _npc_hotkey_option
		config.setHotkey(newKey)
		SetKeyMapOptionValue(mcm_option, newKey)
	EndIf
EndEvent

Event OnOptionSliderOpen(Int mcm_option)
	If (mcm_option == _update_interval_slider)
		SetSliderDialogStartValue(config.updateInterval)
		SetSliderDialogRange(1, 60)
		SetSliderDialogInterval(1.00)
		SetSliderDialogDefaultValue(5)
		Return
	endIf
	If mcm_option == _meters_hold_slider
		SetSliderDialogStartValue(widget_controller.metersHoldSeconds)
		SetSliderDialogRange(2, 120)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(10)
		Return
	EndIf
	; Same ranges as the NPC group anchor below: the 1280x720 stage plus the
	; margins of an extended-stage HUD or the Prisma renderer.
	If mcm_option == _meters_x_slider
		SetSliderDialogStartValue(widget_controller.metersX)
		SetSliderDialogRange(-1280, 2560)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(1150)
		Return
	EndIf
	If mcm_option == _meters_y_slider
		SetSliderDialogStartValue(widget_controller.metersY)
		SetSliderDialogRange(-720, 719)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(360)
		Return
	EndIf
	If mcm_option == _meters_scale_slider
		SetSliderDialogStartValue(widget_controller.metersScale)
		SetSliderDialogRange(20, 200)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(60)
		Return
	EndIf
	_initNpcOptionArrays()
	If mcm_option == _npc_group_x_slider
		SetSliderDialogStartValue(widget_controller.npcGroupX)
		; iWant's Flash stage is fixed at 1280x720 and gets scaled by Skyrim
		; to fit 16:9 monitors. On ultrawide (21:9 / 32:9), vanilla Skyrim
		; leaves pillarboxes on either side — the 16:9 safe area ends at
		; 1279. HUD overhauls (SkyHUD, etc.) extend the stage horizontally;
		; with one installed, X up to ~1680 fills 21:9 and ~2560 fills 32:9.
		; The Prisma renderer instead centers the 1280 stage, so its ultrawide
		; margins sit at NEGATIVE X (about -200 on 21:9, -640 on 32:9).
		; Coordinates are icon centers, so small negatives also let a bar
		; tuck flush against (or past) the screen edge on any monitor.
		SetSliderDialogRange(-1280, 2560)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(1100)
		Return
	EndIf
	If mcm_option == _npc_group_y_slider
		SetSliderDialogStartValue(widget_controller.npcGroupY)
		SetSliderDialogRange(-720, 719)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(600)
		Return
	EndIf
	If mcm_option == _npc_vertical_spacing_slider
		SetSliderDialogStartValue(widget_controller.npcVerticalSpacing)
		; Min 50 = very compact (labels may overlap previous NPC's secondary
		; bar). Default 105 = comfortable label clearance. Max 200 = loose.
		SetSliderDialogRange(50, 200)
		SetSliderDialogInterval(5.0)
		SetSliderDialogDefaultValue(105)
		Return
	EndIf
	If mcm_option == _npc_label_size_slider
		SetSliderDialogStartValue(widget_controller.npcLabelSize)
		SetSliderDialogRange(10, 60)
		SetSliderDialogInterval(1.0)
		SetSliderDialogDefaultValue(24)
		Return
	EndIf
	Int slot = _findNpcSlotForOption(mcm_option, _npc_label_x_slider)
	If slot > 0
		SetSliderDialogStartValue(widget_controller.getNpcLabelOffsetX(slot))
		SetSliderDialogRange(-200, 200)
		SetSliderDialogInterval(2.0)
		SetSliderDialogDefaultValue(0)
		Return
	EndIf
	slot = _findNpcSlotForOption(mcm_option, _npc_label_y_slider)
	If slot > 0
		SetSliderDialogStartValue(widget_controller.getNpcLabelOffsetY(slot))
		SetSliderDialogRange(-200, 200)
		SetSliderDialogInterval(2.0)
		SetSliderDialogDefaultValue(0)
		Return
	EndIf
EndEvent

Bool Function _handleNpcSliderAccept(Int mcm_option, Float value)
	_initNpcOptionArrays()
	If mcm_option == _npc_group_x_slider
		Int newX = value As Int
		widget_controller.setNpcGroupPos(newX, widget_controller.npcGroupY)
		widget_controller._layoutNpcBars()
		SetSliderOptionValue(mcm_option, newX, "{0}")
		Return True
	EndIf
	If mcm_option == _npc_group_y_slider
		Int newY = value As Int
		widget_controller.setNpcGroupPos(widget_controller.npcGroupX, newY)
		widget_controller._layoutNpcBars()
		SetSliderOptionValue(mcm_option, newY, "{0}")
		Return True
	EndIf
	If mcm_option == _npc_vertical_spacing_slider
		Int newV = value As Int
		widget_controller.setNpcVerticalSpacing(newV)
		SetSliderOptionValue(mcm_option, newV, "{0}")
		Return True
	EndIf
	If mcm_option == _npc_label_size_slider
		Int newSize = value As Int
		widget_controller.setNpcLabelSize(newSize)
		SetSliderOptionValue(mcm_option, newSize, "{0}")
		Return True
	EndIf
	Int slot = _findNpcSlotForOption(mcm_option, _npc_label_x_slider)
	If slot > 0
		Int newX = value As Int
		widget_controller.setNpcLabelOffset(slot, newX, widget_controller.getNpcLabelOffsetY(slot))
		SetSliderOptionValue(mcm_option, newX, "{0}")
		Return True
	EndIf
	slot = _findNpcSlotForOption(mcm_option, _npc_label_y_slider)
	If slot > 0
		Int newY = value As Int
		widget_controller.setNpcLabelOffset(slot, widget_controller.getNpcLabelOffsetX(slot), newY)
		SetSliderOptionValue(mcm_option, newY, "{0}")
		Return True
	EndIf
	Return False
EndFunction

Event OnOptionSliderAccept(Int mcm_option, Float Value)
	If (mcm_option == _update_interval_slider)
		config.updateInterval = Value as Int
		SetSliderOptionValue(mcm_option, Value, "{0}")
		Return
	EndIf
	; The meter stack is rebuilt as the menu closes (requestMetersRebuild),
	; through the toggle pass OnConfigClose runs for a dirty page.
	If mcm_option == _meters_hold_slider
		widget_controller.metersHoldSeconds = Value as Int
		SetSliderOptionValue(mcm_option, Value, "{0} s")
		Return
	EndIf
	If mcm_option == _meters_x_slider
		widget_controller.setMetersLayout(Value as Int, widget_controller.metersY, widget_controller.metersScale)
		_togglesDirty = true
		SetSliderOptionValue(mcm_option, Value, "{0}")
		Return
	EndIf
	If mcm_option == _meters_y_slider
		widget_controller.setMetersLayout(widget_controller.metersX, Value as Int, widget_controller.metersScale)
		_togglesDirty = true
		SetSliderOptionValue(mcm_option, Value, "{0}")
		Return
	EndIf
	If mcm_option == _meters_scale_slider
		widget_controller.setMetersLayout(widget_controller.metersX, widget_controller.metersY, Value as Int)
		_togglesDirty = true
		SetSliderOptionValue(mcm_option, Value, "{0}%")
		Return
	EndIf
	_handleNpcSliderAccept(mcm_option, Value)
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

State NPC_LABEL_COLOR_STATE
	Event OnColorOpenST()
		SetColorDialogStartColor(widget_controller.getNpcLabelColorPacked())
		SetColorDialogDefaultColor(0xFFFFFF)
	EndEvent

	Event OnColorAcceptST(Int color)
		widget_controller.setNpcLabelColorPacked(color)
		SetColorOptionValueST(widget_controller.getNpcLabelColorPacked())
	EndEvent

	Event OnDefaultST()
		widget_controller.setNpcLabelColorPacked(0xFFFFFF)
		SetColorOptionValueST(widget_controller.getNpcLabelColorPacked())
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLW_NPC_Label_Color_Info")
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
	
	Event OnHighlightST()
		SetInfoText("$SLW_Empty_Icon_Add_Info")
    EndEvent
EndState

State TOGGLE_MOD_STATE
    Event OnSelectST()
        SetOptionFlagsST(OPTION_FLAG_DISABLED)
        SetTextOptionValueST("$SLW_Working")
		config.slw_stopped = !config.slw_stopped
		Bool stopped = config.slw_stopped
		if stopped
			;disable flow
			widget_controller.stopUpdates()
			config.moduleReset()
			widget_controller.reloadWidgets()
			_togglesDirty = false
			SetTextOptionValueST("$SLW_Enable")
		Else
			;enable flow
			config.moduleReset()
			config.moduleSetup()
			widget_controller.reloadWidgets()
			_togglesDirty = false
			widget_controller.startUpdates()
			SetTextOptionValueST("$SLW_Disable")
		endif
        SetOptionFlagsST(OPTION_FLAG_NONE)
		; WaitMenuMode and ShowMessage yield the UI and invalidate SkyUI's
		; current-option-state, so every ...ST call must run before them — a
		; ...ST call afterwards throws "outside a valid option state".
		Utility.WaitMenuMode(1)
		if stopped
			ShowMessage("$SLW_Disabled", false)
		Else
			ShowMessage("$SLW_Enabled", false)
		endif
    EndEvent
	
	Event OnHighlightST()
		if config.slw_stopped
			SetInfoText("$SLW_Disabled_Info")
		Else
			SetInfoText("$SLW_Enabled_Info")
		endif
       
    EndEvent
EndState

State PRESET_MENU_STATE
	Event OnMenuOpenST()
		_presetNames = config.getPresetNames()
		Int si = 0
		Int pi = 0
		While pi < _presetNames.Length
			If _presetNames[pi] == config.activePreset
				si = pi
			EndIf
			pi = pi + 1
		EndWhile
		SetMenuDialogOptions(_presetNames)
		SetMenuDialogStartIndex(si)
	EndEvent

	Event OnMenuAcceptST(Int index)
		If !_presetNames || index < 0 || index >= _presetNames.Length
			Return
		EndIf
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetMenuOptionValueST("$SLW_Working")
		config.activePreset = _presetNames[index]
		config.loadPreset(config.activePreset)
		widget_controller.reloadWidgets()
		_togglesDirty = false
		SetMenuOptionValueST(config.activePreset)
		SetOptionFlagsST(OPTION_FLAG_NONE)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLW_Color_Preset_Info")
	EndEvent
EndState

State SETTINGS_PRESET_MENU_STATE
	Event OnMenuOpenST()
		_settingsPresetNames = config.getSettingsPresetNames()
		Int si = 0
		Int pi = 0
		While pi < _settingsPresetNames.Length
			If _settingsPresetNames[pi] == config.activeSettingsPreset
				si = pi
			EndIf
			pi = pi + 1
		EndWhile
		SetMenuDialogOptions(_settingsPresetNames)
		SetMenuDialogStartIndex(si)
	EndEvent

	Event OnMenuAcceptST(Int index)
		If !_settingsPresetNames || index < 0 || index >= _settingsPresetNames.Length
			Return
		EndIf
		SetOptionFlagsST(OPTION_FLAG_DISABLED)
		SetMenuOptionValueST("$SLW_Working")
		If !config.loadSettingsPreset(_settingsPresetNames[index])
			SetMenuOptionValueST(config.activeSettingsPreset)
			SetOptionFlagsST(OPTION_FLAG_NONE)
			Return
		EndIf
		config.activeSettingsPreset = _settingsPresetNames[index]
		config.loadPreset(config.activePreset)
		config.moduleReset()
		config.moduleSetup()
		widget_controller.reloadWidgets()
		_togglesDirty = false
		SetMenuOptionValueST(config.activeSettingsPreset)
		SetOptionFlagsST(OPTION_FLAG_NONE)
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLW_Settings_Preset_Info")
	EndEvent
EndState

State SAVE_SETTINGS_PRESET_STATE
	Event OnSelectST()
		String path = "..\\SlWidgets\\SettingsPresets\\" + config.activeSettingsPreset
		If jsonutil.JsonExists(path)
			If !ShowMessage("$SLW_Overwrite_Settings_Preset_Question", true, "$Accept", "$Cancel")
				Return
			EndIf
		EndIf
		If config.saveSettingsPreset(config.activeSettingsPreset)
			ShowMessage("$SLW_Settings_Preset_Saved", false, "$Accept")
		Else
			ShowMessage("$SLW_Settings_Preset_Save_Failed", false, "$Accept")
		EndIf
	EndEvent

	Event OnHighlightST()
		SetInfoText("$SLW_Save_Settings_Preset_Info")
	EndEvent
EndState


int Function _getFlag(Bool cond = true)
	If  !cond
   		return OPTION_FLAG_DISABLED
	Else
   		return OPTION_FLAG_NONE
	EndIf
EndFunction