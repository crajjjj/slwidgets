Scriptname slw_menu extends SKI_ConfigBase
import slw_util
import slw_log


slw_config Property config auto
slw_widget_controller Property widget_controller auto

; 3.3.0: this MCM only shows. Every setting is on the SKSE Menu Framework
; menu, section SL Widgets (plugin\, SLWidgetsMenu.dll): enabling the mod,
; the icon switches, meters, NPC tracking, positions and presets.

int _status_option
int _skse_menu_hint


; SCRIPT VERSION
; https://github.com/schlangster/skyui/wiki/MCM-Advanced-Features#incremental-upgrading

int function GetVersion()
	return slw_util.GetVersion()
endFunction

Event OnConfigInit()
	ModName = "SLWidgets"
	Notification("MCM menu initialized.")
EndEvent

Event OnConfigOpen()
	Pages = New String[2]
	Pages[0] = "$SLW_General_Page"
	Pages[1] = "$SLW_Debug_Page"
	_forgetOptionIds()
EndEvent

; SkyUI option ids carry their page's number, and the variables holding them
; live in the save. When the page list changes an id kept from the old
; numbering can equal an option of another page, so every id is forgotten when
; the menu opens; each page sets its own when it is drawn.
Function _forgetOptionIds()
	_status_option = -1
	_skse_menu_hint = -1
EndFunction

Event OnPageReset(string page)
	if (page == "$SLW_General_Page")
		General()
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
	If a_version >= 30001 && CurrentVersion < 30001
		Debug.Trace(self + ": Updating script to version 30001")
		; 3.0.1: the Default preset at full alpha. The widget controller
		; reloads the icons once (ICONS_VERSION), so there is nothing to do here.
	EndIf
	If a_version >= 30200 && CurrentVersion < 30200
		Debug.Trace(self + ": Updating script to version 30200")
		; 3.2.0: the Toggles page and the position sliders moved to the SKSE
		; menu. OnConfigOpen rebuilds Pages every time, so an old save shows the
		; four pages without anything done here; settings presets gained the
		; layout of the bars and the NPC cluster.
	EndIf
	If a_version >= 30300 && CurrentVersion < 30300
		Debug.Trace(self + ": Updating script to version 30300")
		; 3.3.0: this MCM only shows the state and the dependency check; every
		; setting moved to the SKSE menu, which also moves icons between the
		; player bars. Pages is rebuilt on open; nothing in the save changes.
	EndIf
	If a_version >= 30401 && CurrentVersion < 30401
		Debug.Trace(self + ": Updating script to version 30401")
		; 3.4.1: Survival Mode, Dirt and Blood, Just Blood and Combat Wound, and
		; their Maintenance rows. The new switches are properties with defaults,
		; the NPC switch arrays are made on first use and the widget controller
		; reloads the icons once (ICONS_VERSION), so nothing is migrated here.
	EndIf
endEvent

Function General()
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("$SLW_General")
	_status_option = AddTextOption("$SLW_Status", StringIfElse(config.slw_stopped, "$SLW_Status_Off", "$SLW_Status_On"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SkseMenu_Status", _skseMenuState(), OPTION_FLAG_DISABLED)
	AddEmptyOption()
	_skse_menu_hint = AddTextOption("$SLW_SkseMenu_Hint", "", OPTION_FLAG_NONE)
EndFunction

; Whether the settings can be reached: SKSE Menu Framework and this mod's
; page plugin, both found through SKSE (-1 when a plugin is not loaded), and
; the plugin's own report: it registers no page at all on a framework that
; lacks what the pages call.
String Function _skseMenuState()
	If SKSE.GetPluginVersion("SKSEMenuFramework") <= 0
		Return "$SLW_SkseMenu_NoFramework"
	ElseIf SKSE.GetPluginVersion("SLWidgetsMenu") <= 0
		Return "$SLW_SkseMenu_NoPlugin"
	ElseIf config.skseMenuReport == 2
		Return "$SLW_SkseMenu_OldFramework"
	EndIf
	Return "$SLW_OK"
EndFunction

Function Debug()
	SetCursorFillMode(TOP_TO_BOTTOM)
	SetCursorPosition(0)
	AddHeaderOption("SLWidgets. Version: " + GetVersionString())
	AddEmptyOption()

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
	AddTextOption("$SLW_EU_Check", StringIfElse( isEUReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_OMania_Check", StringIfElse( config.OManiaReady , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
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
	AddTextOption("$SLW_SV_Check", StringIfElse( isSurvivalModeReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SMI_Check", StringIfElse( isSurvivalModeImprovedReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SHD_Check", StringIfElse( isSunHelmDiseasesReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_BIS_Check", StringIfElse( isBathingReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_DNB_Check", StringIfElse( isDirtAndBloodReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_WFR_Check", StringIfElse( isWetFunctionReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_WFNG_Check", StringIfElse( isWetFunctionNGReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_JB_Check", StringIfElse( isJustBloodReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SPH_Check", StringIfElse( isSPHReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_SAF_Check", StringIfElse( isStressFearReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_BNB_Check", StringIfElse( isBladeBluntReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
	AddTextOption("$SLW_CW_Check", StringIfElse( isCombatWoundReady() , "$SLW_OK", "$SLW_Not_Found"), OPTION_FLAG_DISABLED)
EndFunction

Event onOptionHighlight(int mcm_option)
	If mcm_option == _skse_menu_hint
		SetInfoText("$SLW_SkseMenu_Info")
	ElseIf mcm_option == _status_option
		SetInfoText("$SLW_Status_Info")
	EndIf
EndEvent
