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


Int property updateInterval = 5 auto hidden

Bool property module_sla_arousal = True auto hidden
Bool property module_sla_exposure = True auto hidden
Bool property module_apropos_two_wt = True auto hidden
Bool property module_fhu_cum = True auto hidden
Bool property module_fhu_cum_anal = True auto hidden
Bool property module_fhu_cum_vaginal = True auto hidden
Bool property module_mme_milk = True auto hidden
Bool property module_mme_lactacid = True auto hidden

Bool property module_parasites_enabled = True auto hidden
Bool property module_pregnancy_enabled = True auto hidden

Function setupModules()
	WriteLog("Setting up modules")
	module_sla.setupModule()
	module_apropos_two.setupModule()
	module_fhu.setupModule()
	module_mme.setupModule()
	module_slp.setupModule()
	module_pregnancy.setupModule()
EndFunction

;doesn't work async with ibars
Function widgetReload(iWant_Status_Bars iBars)
	WriteLog("Widget reload triggered")
	module_sla.onWidgetReload(iBars)
	module_apropos_two.onWidgetReload(iBars)
	module_fhu.onWidgetReload(iBars)
	module_mme.onWidgetReload(iBars)
	module_slp.onWidgetReload(iBars)
	module_pregnancy.onWidgetReload(iBars)
EndFunction

;doesn't work async with ibars
Function stateStatusUpdate(iWant_Status_Bars iBars)
	module_sla.onWidgetStatusUpdate(iBars)
	module_apropos_two.onWidgetStatusUpdate(iBars)
	module_fhu.onWidgetStatusUpdate(iBars)
	module_mme.onWidgetStatusUpdate(iBars)
	module_slp.onWidgetStatusUpdate(iBars)
	module_pregnancy.onWidgetStatusUpdate(iBars)
EndFunction

;disable toggles if module is not ready because of dependency check
Function syncModules()
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
	
EndFunction

;to deal with upgrades later
Function SetDefaults()
	WriteLog("Setting Defaults")
    updateInterval = 5

	module_sla_arousal = True
    module_sla_exposure = True
	module_apropos_two_wt = True
	module_fhu_cum = True
	module_fhu_cum_anal = True
	module_fhu_cum_vaginal = True
	module_mme_milk = True
	module_mme_lactacid = True

	module_parasites_enabled = True
	module_pregnancy_enabled = True
EndFunction