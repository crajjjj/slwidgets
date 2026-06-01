Scriptname slw_config extends Quest
import slw_util
import slw_log

slw_widget_controller Property widget_controller auto

slw_module_sla Property module_sla auto
slw_module_apropos_two  property module_apropos_two auto
slw_module_fhu property module_fhu auto
slw_module_mme property module_mme auto
slw_module_slp property module_slp auto
slw_module_pregnancy property module_pregnancy auto
slw_module_paf property module_paf auto
slw_module_sldefeat property module_defeat auto


Int property updateInterval = 5 auto hidden
String property activePreset = "Default" auto hidden
Bool property slw_stopped = True auto hidden
String property slw_settings_path = "..\\SlWidgets\\UserSettings" auto hidden

Int _iconColors = 0

Bool property module_sla_arousal = True auto hidden
Bool property module_sla_exposure = True auto hidden
Bool property module_apropos_two_wt = True auto hidden
Bool property module_fhu_cum = True auto hidden
Bool property module_fhu_cum_anal = True auto hidden
Bool property module_fhu_cum_vaginal = True auto hidden
Bool property module_fhu_cum_oral = True auto hidden
Bool property module_mme_milk = True auto hidden
Bool property module_mme_lactacid = True auto hidden
Bool property module_parasites_enabled = True auto hidden
Bool property module_pregnancy_enabled = True auto hidden
Bool property module_paf_pee = True auto hidden
Bool property module_paf_poo = True auto hidden
Bool property module_defeat_enabled = True auto hidden

Event OnInit()
EndEvent

Function moduleSetup()
	module_sla.moduleSetup()
	module_apropos_two.moduleSetup()
	module_fhu.moduleSetup()
	module_mme.moduleSetup()
	module_slp.moduleSetup()
	module_pregnancy.moduleSetup()
	module_paf.moduleSetup()
	module_defeat.moduleSetup()
EndFunction

;force modules to reinit after restart
Function moduleReset()
	module_sla.moduleReset()
	module_apropos_two.moduleReset()
	module_fhu.moduleReset()
	module_mme.moduleReset()
	module_slp.moduleReset()
	module_pregnancy.moduleReset()
	module_paf.moduleReset()
	module_defeat.moduleReset()
EndFunction

;doesn't work async with ibars
Function moduleWidgetReload(iWant_Status_Bars iBars)
	module_sla.onWidgetReload(iBars)
	module_apropos_two.onWidgetReload(iBars)
	module_fhu.onWidgetReload(iBars)
	module_mme.onWidgetReload(iBars)
	module_slp.onWidgetReload(iBars)
	module_pregnancy.onWidgetReload(iBars)
	module_paf.onWidgetReload(iBars)
	module_defeat.onWidgetReload(iBars)
EndFunction

;doesn't work async with ibars
Function moduleWidgetStateUpdate(iWant_Status_Bars iBars)
	module_sla.onWidgetStatusUpdate(iBars)
	module_apropos_two.onWidgetStatusUpdate(iBars)
	module_fhu.onWidgetStatusUpdate(iBars)
	module_mme.onWidgetStatusUpdate(iBars)
	module_slp.onWidgetStatusUpdate(iBars)
	module_pregnancy.onWidgetStatusUpdate(iBars)
	module_paf.onWidgetStatusUpdate(iBars)
	module_defeat.onWidgetStatusUpdate(iBars)
EndFunction

;disable toggles if module is not ready because of dependency check
;deprecated
Function moduleSyncConfig()
	if !module_sla.isInterfaceActive() 
		module_sla_arousal = false
		module_sla_exposure = false
	endIf
	
	if !module_apropos_two.isInterfaceActive()
		module_apropos_two_wt = false
	endIf

	if !module_fhu.isInterfaceActive()
		module_fhu_cum = false
		module_fhu_cum_anal = false
		module_fhu_cum_vaginal = false
		module_fhu_cum_oral = false
	endIf

	if !module_mme.isInterfaceActive()
		module_mme_milk = false
		module_mme_lactacid = false
	endIf

	if !module_slp.isInterfaceActive()
		module_parasites_enabled = false
	endIf

	if !module_pregnancy.isInterfaceActive()
		module_pregnancy_enabled = false
	endIf

	if !module_paf.isInterfaceActive()
		module_paf_pee = false
		module_paf_poo = false
	endIf

	if !module_defeat.isInterfaceActive()
		module_defeat_enabled = false
	endIf
	
EndFunction

;to deal with upgrades later
;Not used
Function SetDefaults()
	WriteLog("Setting Defaults")
	slw_stopped = False
    updateInterval = 5

	module_sla_arousal = True
    module_sla_exposure = True
	module_apropos_two_wt = True
	module_fhu_cum = True
	module_fhu_cum_anal = True
	module_fhu_cum_vaginal = True
	module_fhu_cum_oral= True
	module_mme_milk = True
	module_mme_lactacid = True
	module_parasites_enabled = True
	module_pregnancy_enabled = True
	module_paf_pee = True
	module_paf_poo = True
	module_defeat_enabled = True
EndFunction

Function DisableWidgets()
	WriteLog("Disabling widgets")
	slw_stopped = True
	updateInterval = 5

	module_sla_arousal = false
    module_sla_exposure = false
	module_apropos_two_wt = false
	module_fhu_cum = false
	module_fhu_cum_anal = false
	module_fhu_cum_vaginal = false
	module_mme_milk = false
	module_mme_lactacid = false
	module_parasites_enabled = false
	module_pregnancy_enabled = false
	module_paf_pee = false
	module_paf_poo = false
	module_defeat_enabled = false
EndFunction

Bool function LoadUserSettingsPapyrus()
	if !jsonutil.IsGood(slw_settings_path)
		WriteLog("SLWidgets: Can't load user settings. Errors: {" + jsonutil.getErrors(slw_settings_path) + "}", 2)
		return false
	endIf
	slw_stopped = false
	updateInterval = jsonutil.GetPathIntValue(slw_settings_path, "updateInterval", updateInterval)
	activePreset = jsonutil.GetPathStringValue(slw_settings_path, "activePreset", activePreset)
	module_sla_arousal = jsonutil.GetPathBoolValue(slw_settings_path, "module_sla_arousal", module_sla_arousal)
	module_sla_exposure = jsonutil.GetPathBoolValue(slw_settings_path, "module_sla_exposure", module_sla_exposure)
	module_apropos_two_wt = jsonutil.GetPathBoolValue(slw_settings_path, "module_apropos_two_wt", module_apropos_two_wt)
	module_fhu_cum = jsonutil.GetPathBoolValue(slw_settings_path, "module_fhu_cum", module_fhu_cum)
	module_fhu_cum_anal = jsonutil.GetPathBoolValue(slw_settings_path, "module_fhu_cum_anal", module_fhu_cum_anal)
	module_fhu_cum_vaginal = jsonutil.GetPathBoolValue(slw_settings_path, "module_fhu_cum_vaginal", module_fhu_cum_vaginal)
	module_fhu_cum_oral = jsonutil.GetPathBoolValue(slw_settings_path, "module_fhu_cum_oral", module_fhu_cum_oral)
	module_mme_milk = jsonutil.GetPathBoolValue(slw_settings_path, "module_mme_milk", module_mme_milk)
	module_mme_lactacid = jsonutil.GetPathBoolValue(slw_settings_path, "module_mme_lactacid", module_mme_lactacid)
	module_parasites_enabled = jsonutil.GetPathBoolValue(slw_settings_path, "module_parasites_enabled", module_parasites_enabled)
	module_pregnancy_enabled = jsonutil.GetPathBoolValue(slw_settings_path, "module_pregnancy_enabled", module_pregnancy_enabled)
	module_paf_pee = jsonutil.GetPathBoolValue(slw_settings_path, "module_paf_pee", module_paf_pee)
	module_paf_poo = jsonutil.GetPathBoolValue(slw_settings_path, "module_paf_poo", module_paf_poo)
	module_defeat_enabled = jsonutil.GetPathBoolValue(slw_settings_path, "module_defeat_enabled", module_defeat_enabled)
	return true
endFunction

Bool function SaveUserSettingsPapyrus()
	
	jsonutil.SetPathIntValue(slw_settings_path, "updateInterval", updateInterval as Int)
	jsonutil.SetPathStringValue(slw_settings_path, "activePreset", activePreset)
	jsonutil.SetPathIntValue(slw_settings_path, "module_sla_arousal", module_sla_arousal as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_sla_exposure", module_sla_exposure as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_apropos_two_wt", module_apropos_two_wt as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_fhu_cum", module_fhu_cum as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_fhu_cum_anal", module_fhu_cum_anal as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_fhu_cum_vaginal", module_fhu_cum_vaginal as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_fhu_cum_oral", module_fhu_cum_oral as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_mme_milk", module_mme_milk as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_mme_lactacid", module_mme_lactacid as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_parasites_enabled", module_parasites_enabled as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_pregnancy_enabled", module_pregnancy_enabled as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_paf_pee", module_paf_pee as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_paf_poo", module_paf_poo as Int)
	jsonutil.SetPathIntValue(slw_settings_path, "module_defeat_enabled", module_defeat_enabled as Int)
	if !jsonutil.Save(slw_settings_path, false)
		WriteLog("SLWidgets: Error saving user settings", 2)
		return false
	endIf
	return true
endFunction

Bool function isOn(bool prop)
	return !slw_stopped && prop
endFunction

Function loadPreset(String presetName)
	If _iconColors
		JValue.release(_iconColors)
		_iconColors = 0
	EndIf
	_iconColors = JValue.readFromFile("Data/SKSE/Plugins/SlWidgets/Presets/" + presetName + ".json")
	If _iconColors
		JValue.retain(_iconColors)
	EndIf
EndFunction

Function ApplyIconColors(String iconKey, Int[] r, Int[] g, Int[] b, Int[] a)
	If !_iconColors
		Return
	EndIf
	Int jIcon = JValue.solveObj(_iconColors, "." + iconKey)
	If !jIcon
		Return
	EndIf
	Int jR = JValue.solveObj(jIcon, ".r")
	Int jG = JValue.solveObj(jIcon, ".g")
	Int jB = JValue.solveObj(jIcon, ".b")
	Int jA = JValue.solveObj(jIcon, ".a")
	Int i = 0
	If jR
		Int[] pR = JArray.asIntArray(jR)
		While i < r.Length && i < pR.Length
			If pR[i] >= 0
				r[i] = pR[i]
			EndIf
			i = i + 1
		EndWhile
	EndIf
	i = 0
	If jG
		Int[] pG = JArray.asIntArray(jG)
		While i < g.Length && i < pG.Length
			If pG[i] >= 0
				g[i] = pG[i]
			EndIf
			i = i + 1
		EndWhile
	EndIf
	i = 0
	If jB
		Int[] pB = JArray.asIntArray(jB)
		While i < b.Length && i < pB.Length
			If pB[i] >= 0
				b[i] = pB[i]
			EndIf
			i = i + 1
		EndWhile
	EndIf
	i = 0
	If jA
		Int[] pA = JArray.asIntArray(jA)
		While i < a.Length && i < pA.Length
			If pA[i] >= 0
				a[i] = pA[i]
			EndIf
			i = i + 1
		EndWhile
	EndIf
EndFunction

String[] Function getPresetNames()
	Int jDir = JValue.readFromDirectory("Data/SKSE/Plugins/SlWidgets/Presets", "json")
	If !jDir
		String[] fallback = new String[1]
		fallback[0] = "Default"
		Return fallback
	EndIf
	String[] names = JMap.allKeysPArray(jDir)
	JValue.release(jDir)
	Int i = 0
	While i < names.Length
		String fn = names[i]
		Int len = StringUtil.GetLength(fn)
		If len > 5
			names[i] = StringUtil.Substring(fn, 0, len - 5)
		EndIf
		i = i + 1
	EndWhile
	Return names
EndFunction