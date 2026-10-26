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
; 3.0.0: survival, hygiene, hair, baby health, stress, injuries and diseases
slw_module_sunhelm property module_sunhelm auto
slw_module_hygiene property module_hygiene auto
slw_module_sph property module_sph auto
slw_module_baby property module_baby auto
slw_module_stress property module_stress auto
slw_module_health property module_health auto


Int property updateInterval = 5 auto hidden
String property activePreset = "Default" auto hidden
String property activeSettingsPreset = "Default" auto hidden
Bool property slw_stopped = True auto hidden

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
; 3.0.0 icons, player switches. Dirtiness, wetness and baby health are also
; per NPC slot (MOD_DIRT, MOD_WET, MOD_BABY); the rest are player only.
Bool property module_sh_food = True auto hidden
Bool property module_sh_thirst = True auto hidden
Bool property module_sh_cold = True auto hidden
Bool property module_sh_fatigue = True auto hidden
Bool property module_dirtiness = True auto hidden
Bool property module_wetness = True auto hidden
Bool property module_sph_pubic = True auto hidden
Bool property module_sph_armpit = True auto hidden
Bool property module_baby_health = True auto hidden
Bool property module_saf_stress = True auto hidden
Bool property module_saf_fear = True auto hidden
Bool property module_injuries = True auto hidden
Bool property module_diseases = True auto hidden
; SLO VE willpower: a bar (iWant Widgets meter), not a status icon. Meter 0 of
; the meter stack, and its switch (isMeterOn(0)), player only.
Bool property module_slove_willpower = True auto hidden

; The meter stack (slw_widget_controller): one switch per meter, player only.
; Indexed by meter number, see getMeterPresetKey; slot 0 is unused, willpower keeps
; module_slove_willpower. Lazily created, all on.
Bool[] _meter_use

; NPC tracking — slot 0 is player (handled by widget_controller.PlayerRef), slots 1..N_NPC are NPCs
Actor Property npc1 Auto Hidden
Actor Property npc2 Auto Hidden
Actor Property npc3 Auto Hidden

; Label widget IDs for NPC slots (set when iWant widgets are initialized; -1 = not yet created)
Int Property npc1_labelId = -1 Auto Hidden
Int Property npc2_labelId = -1 Auto Hidden
Int Property npc3_labelId = -1 Auto Hidden

; Custom label text per NPC slot. Empty string falls back to the actor's display name.
String Property npc1_customLabel = "" Auto Hidden
String Property npc2_customLabel = "" Auto Hidden
String Property npc3_customLabel = "" Auto Hidden

; Hotkey for crosshair-pick assignment (-1 = unset)
Int Property npcHotkey = -1 Auto Hidden

; Per-slot sub-toggle enables. Arrays sized N_SLOTS=4 (index 0 is player, 1..3 are NPCs).
; Each parallels a player sub-toggle (module_sla_arousal etc.) so NPCs can opt in
; to specific icons independently of the player.
Bool[] _slot_use_sla_arousal
Bool[] _slot_use_sla_exposure
Bool[] _slot_use_ap2
Bool[] _slot_use_fhu_cum
Bool[] _slot_use_fhu_anal
Bool[] _slot_use_fhu_vaginal
Bool[] _slot_use_fhu_oral
Bool[] _slot_use_mme_milk
Bool[] _slot_use_mme_lactacid
Bool[] _slot_use_slp
Bool[] _slot_use_preg
Bool[] _slot_use_dirt
Bool[] _slot_use_wet
Bool[] _slot_use_baby

; Sub-toggle codes for isOnForSlot lookup
Int Property MOD_SLA_AROUSAL = 1 AutoReadOnly
Int Property MOD_SLA_EXPOSURE = 2 AutoReadOnly
Int Property MOD_AP2 = 3 AutoReadOnly
Int Property MOD_FHU_CUM = 4 AutoReadOnly
Int Property MOD_FHU_ANAL = 5 AutoReadOnly
Int Property MOD_FHU_VAGINAL = 6 AutoReadOnly
Int Property MOD_FHU_ORAL = 7 AutoReadOnly
Int Property MOD_MME_MILK = 8 AutoReadOnly
Int Property MOD_MME_LACTACID = 9 AutoReadOnly
Int Property MOD_SLP = 10 AutoReadOnly
Int Property MOD_PREG = 11 AutoReadOnly
Int Property MOD_DIRT = 12 AutoReadOnly
Int Property MOD_WET = 13 AutoReadOnly
Int Property MOD_BABY = 14 AutoReadOnly

Event OnInit()
	_ensureSlotToggles()
	If npcHotkey >= 0
		RegisterForKey(npcHotkey)
	EndIf
EndEvent

Function _ensureSlotToggles()
	; Player (slot 0) defaults every sub-toggle on. NPCs default to a curated
	; subset that fits in a single 10-position iWant bar at steady state:
	;   SLA Arousal (1) + AP2 (3 icons under one toggle) + FHU Cum total (1)
	;   + MME Milk (1) + Pregnancy (~5 peak) ≈ 10 icons.
	; Other sub-toggles are off by default for NPCs — enabling them per slot
	; can push past the bar cap and overflow into another NPC's bar.
	If !_slot_use_sla_arousal
		_slot_use_sla_arousal = Utility.CreateBoolArray(4, True)
	EndIf
	If !_slot_use_sla_exposure
		_slot_use_sla_exposure = new Bool[4]
		_slot_use_sla_exposure[0] = True
	EndIf
	If !_slot_use_ap2
		_slot_use_ap2 = Utility.CreateBoolArray(4, True)
	EndIf
	If !_slot_use_fhu_cum
		_slot_use_fhu_cum = Utility.CreateBoolArray(4, True)
	EndIf
	If !_slot_use_fhu_anal
		_slot_use_fhu_anal = new Bool[4]
		_slot_use_fhu_anal[0] = True
	EndIf
	If !_slot_use_fhu_vaginal
		_slot_use_fhu_vaginal = new Bool[4]
		_slot_use_fhu_vaginal[0] = True
	EndIf
	If !_slot_use_fhu_oral
		_slot_use_fhu_oral = new Bool[4]
		_slot_use_fhu_oral[0] = True
	EndIf
	If !_slot_use_mme_milk
		_slot_use_mme_milk = Utility.CreateBoolArray(4, True)
	EndIf
	If !_slot_use_mme_lactacid
		_slot_use_mme_lactacid = new Bool[4]
		_slot_use_mme_lactacid[0] = True
	EndIf
	If !_slot_use_slp
		_slot_use_slp = new Bool[4]
		_slot_use_slp[0] = True
	EndIf
	If !_slot_use_preg
		_slot_use_preg = Utility.CreateBoolArray(4, True)
	EndIf
	; 3.0.0: off for NPCs by default, same bar-cap reasoning as above
	If !_slot_use_dirt
		_slot_use_dirt = new Bool[4]
		_slot_use_dirt[0] = True
	EndIf
	If !_slot_use_wet
		_slot_use_wet = new Bool[4]
		_slot_use_wet[0] = True
	EndIf
	If !_slot_use_baby
		_slot_use_baby = new Bool[4]
		_slot_use_baby[0] = True
	EndIf
EndFunction

; Per-slot sub-toggles are independent of each other. The only global gate is
; slw_stopped (the master enable/disable). For slot 0 the player's existing
; sub-toggle (module_sla_arousal etc.) is the per-slot toggle; for NPC slots
; the _slot_use_* arrays store the toggle. Module dependency presence is
; checked separately by each module's isInterfaceActive().
Bool Function isOnForSlot(Bool playerSubToggle, Int slot, Int subCode)
	If slw_stopped
		Return False
	EndIf
	If slot == 0
		Return playerSubToggle
	EndIf
	Return getSlotModuleEnable(slot, subCode)
EndFunction

Bool Function getSlotModuleEnable(Int slot, Int subCode)
	_ensureSlotToggles()
	If subCode == MOD_SLA_AROUSAL
		Return _slot_use_sla_arousal[slot]
	ElseIf subCode == MOD_SLA_EXPOSURE
		Return _slot_use_sla_exposure[slot]
	ElseIf subCode == MOD_AP2
		Return _slot_use_ap2[slot]
	ElseIf subCode == MOD_FHU_CUM
		Return _slot_use_fhu_cum[slot]
	ElseIf subCode == MOD_FHU_ANAL
		Return _slot_use_fhu_anal[slot]
	ElseIf subCode == MOD_FHU_VAGINAL
		Return _slot_use_fhu_vaginal[slot]
	ElseIf subCode == MOD_FHU_ORAL
		Return _slot_use_fhu_oral[slot]
	ElseIf subCode == MOD_MME_MILK
		Return _slot_use_mme_milk[slot]
	ElseIf subCode == MOD_MME_LACTACID
		Return _slot_use_mme_lactacid[slot]
	ElseIf subCode == MOD_SLP
		Return _slot_use_slp[slot]
	ElseIf subCode == MOD_PREG
		Return _slot_use_preg[slot]
	ElseIf subCode == MOD_DIRT
		Return _slot_use_dirt[slot]
	ElseIf subCode == MOD_WET
		Return _slot_use_wet[slot]
	ElseIf subCode == MOD_BABY
		Return _slot_use_baby[slot]
	EndIf
	Return True
EndFunction

Function setSlotModuleEnable(Int slot, Int subCode, Bool enabled)
	_ensureSlotToggles()
	If subCode == MOD_SLA_AROUSAL
		_slot_use_sla_arousal[slot] = enabled
	ElseIf subCode == MOD_SLA_EXPOSURE
		_slot_use_sla_exposure[slot] = enabled
	ElseIf subCode == MOD_AP2
		_slot_use_ap2[slot] = enabled
	ElseIf subCode == MOD_FHU_CUM
		_slot_use_fhu_cum[slot] = enabled
	ElseIf subCode == MOD_FHU_ANAL
		_slot_use_fhu_anal[slot] = enabled
	ElseIf subCode == MOD_FHU_VAGINAL
		_slot_use_fhu_vaginal[slot] = enabled
	ElseIf subCode == MOD_FHU_ORAL
		_slot_use_fhu_oral[slot] = enabled
	ElseIf subCode == MOD_MME_MILK
		_slot_use_mme_milk[slot] = enabled
	ElseIf subCode == MOD_MME_LACTACID
		_slot_use_mme_lactacid[slot] = enabled
	ElseIf subCode == MOD_SLP
		_slot_use_slp[slot] = enabled
	ElseIf subCode == MOD_PREG
		_slot_use_preg[slot] = enabled
	ElseIf subCode == MOD_DIRT
		_slot_use_dirt[slot] = enabled
	ElseIf subCode == MOD_WET
		_slot_use_wet[slot] = enabled
	ElseIf subCode == MOD_BABY
		_slot_use_baby[slot] = enabled
	EndIf
EndFunction

; --- Meter stack ---

Int Function getMeterCount()
	Return 9
EndFunction

; Meter numbers, which are also the stack's top-to-bottom order:
; 0 SLO VE willpower, 1 arousal, 2-5 Fill Her Up total / vaginal / anal /
; oral, 6-8 Apropos2 wear and tear vaginal / anal / oral.
; The meter's key in a settings preset. Each is one whole literal: JsonUtil's
; path functions match keys verbatim and case-sensitively, and Papyrus keeps
; one casing per string, so a key built from parts ("meter." + "arousal") can
; come out in another script's casing ("Arousal") and miss the file's key.
; Willpower travels as module_slove_willpower instead.
String Function getMeterPresetKey(Int meter)
	If meter == 1
		Return "meter.arousal"
	ElseIf meter == 2
		Return "meter.fhu_total"
	ElseIf meter == 3
		Return "meter.fhu_vaginal"
	ElseIf meter == 4
		Return "meter.fhu_anal"
	ElseIf meter == 5
		Return "meter.fhu_oral"
	ElseIf meter == 6
		Return "meter.wt_vaginal"
	ElseIf meter == 7
		Return "meter.wt_anal"
	ElseIf meter == 8
		Return "meter.wt_oral"
	EndIf
	Return "meter.willpower"
EndFunction

Function _ensureMeterToggles()
	If !_meter_use
		_meter_use = Utility.CreateBoolArray(9, True)
	EndIf
EndFunction

; Willpower's switch predates the stack and stays module_slove_willpower, the
; name existing saves and settings presets know it by.
Bool Function isMeterOn(Int meter)
	If meter == 0
		Return module_slove_willpower
	EndIf
	_ensureMeterToggles()
	Return _meter_use[meter]
EndFunction

Function setMeterOn(Int meter, Bool enabled)
	If meter == 0
		module_slove_willpower = enabled
		Return
	EndIf
	_ensureMeterToggles()
	_meter_use[meter] = enabled
EndFunction

; All switches in one array, for a caller that reads every one of them each
; pass and would otherwise pay a cross-script call per meter. Read only.
Bool[] Function getMeterSwitches()
	_ensureMeterToggles()
	_meter_use[0] = module_slove_willpower
	Return _meter_use
EndFunction

; Wraps iBars.loadIcon. For NPC slots, registers the icon without triggering
; iWant's auto-placement draw, relocates the bar assignment to the slot's
; dedicated bar, then triggers a single _drawAllBars so the icon appears
; directly in the NPC bar instead of momentarily at bar 0 (the player's bar).
Int Function loadIconForSlot(iWant_Status_Bars iBars, String iconName, String[] stateNames, String[] files, Int[] r, Int[] g, Int[] b, Int[] a, Int slot)
	If slot == 0
		; Player — let iWant handle placement as usual
		Return iBars.loadIcon(slwGetModName(), iconName, stateNames, files, r, g, b, a)
	EndIf
	; NPC — suppress the initial draw, relocate, then redraw once
	Int id = iBars.loadIcon(slwGetModName(), iconName, stateNames, files, r, g, b, a, False)
	If widget_controller
		widget_controller._placeOneIconInSlotBar(iconName, slot)
		iBars._drawAllBars()
	EndIf
	Return id
EndFunction

; --- NPC slot management ---

Actor Function getNpcSlot(Int slot)
	If slot == 1
		Return npc1
	ElseIf slot == 2
		Return npc2
	ElseIf slot == 3
		Return npc3
	EndIf
	Return None
EndFunction

Function setNpcSlot(Int slot, Actor a)
	If slot == 1
		npc1 = a
	ElseIf slot == 2
		npc2 = a
	ElseIf slot == 3
		npc3 = a
	EndIf
EndFunction

Int Function getNpcLabelId(Int slot)
	If slot == 1
		Return npc1_labelId
	ElseIf slot == 2
		Return npc2_labelId
	ElseIf slot == 3
		Return npc3_labelId
	EndIf
	Return -1
EndFunction

Function setNpcLabelId(Int slot, Int id)
	If slot == 1
		npc1_labelId = id
	ElseIf slot == 2
		npc2_labelId = id
	ElseIf slot == 3
		npc3_labelId = id
	EndIf
EndFunction

String Function getNpcCustomLabel(Int slot)
	If slot == 1
		Return npc1_customLabel
	ElseIf slot == 2
		Return npc2_customLabel
	ElseIf slot == 3
		Return npc3_customLabel
	EndIf
	Return ""
EndFunction

Function setNpcCustomLabel(Int slot, String text)
	If slot == 1
		npc1_customLabel = text
	ElseIf slot == 2
		npc2_customLabel = text
	ElseIf slot == 3
		npc3_customLabel = text
	EndIf
EndFunction

; Returns slot index where this actor is already tracked, or 0 if not.
Int Function findNpcSlot(Actor a)
	If !a
		Return 0
	EndIf
	If a == npc1
		Return 1
	ElseIf a == npc2
		Return 2
	ElseIf a == npc3
		Return 3
	EndIf
	Return 0
EndFunction

; Returns first empty NPC slot index (1..N_NPC), or 0 if none.
Int Function findFirstEmptyNpcSlot()
	If !npc1
		Return 1
	EndIf
	If !npc2
		Return 2
	EndIf
	If !npc3
		Return 3
	EndIf
	Return 0
EndFunction

Function setHotkey(Int keyCode)
	If npcHotkey >= 0
		UnregisterForKey(npcHotkey)
	EndIf
	npcHotkey = keyCode
	If npcHotkey >= 0
		RegisterForKey(npcHotkey)
	EndIf
EndFunction

Event OnKeyDown(Int keyCode)
	If keyCode != npcHotkey
		Return
	EndIf
	; Refuse when mod is disabled — otherwise we'd create a name label with no
	; icons under it (modules early-return when stopped).
	If slw_stopped
		Debug.Notification("SLWidgets: enable the mod first in MCM")
		Return
	EndIf
	; Block hotkey while any menu is open (MCM, inventory, magic, container,
	; loading, main menu, dialogue, etc.) and while the player isn't loaded.
	If Utility.IsInMenuMode()
		Return
	EndIf
	Actor player = Game.GetPlayer()
	If !player || !player.Is3DLoaded()
		Return
	EndIf
	ObjectReference target = Game.GetCurrentCrosshairRef()
	If !target
		Return
	EndIf
	Actor a = target As Actor
	If !a || a == player
		Return
	EndIf
	; If actor already tracked, toggle off (clear that slot).
	Int existing = findNpcSlot(a)
	If existing > 0
		clearNpcSlot(existing)
		Debug.Notification("SLWidgets: cleared NPC slot " + existing + " (" + a.GetDisplayName() + ")")
		Return
	EndIf
	; NPC tracking needs the iWant Status Bars 2.10 API, so refuse new
	; assignments on older releases instead of registering icons that can
	; never be reconciled into the slot's bars. Clearing (above) stays
	; allowed so leftover slots from an old save can be cleaned up.
	If widget_controller && !widget_controller.hasBarsAPI()
		Debug.Notification("SLWidgets: NPC tracking needs iWant Status Bars 2.10 or newer (see Debug page)")
		Return
	EndIf
	; Otherwise assign to first empty slot, or refuse if all full.
	Int empty = findFirstEmptyNpcSlot()
	If empty == 0
		Debug.Notification("SLWidgets: All NPC slots full - clear one in MCM.")
		Return
	EndIf
	setNpcSlot(empty, a)
	Debug.Notification("SLWidgets: tracking " + a.GetDisplayName() + " in NPC slot " + empty)
	; Trigger reload so icons for the new slot get registered
	If widget_controller
		widget_controller.reloadNpcSlot(empty)
	EndIf
EndEvent

Function clearNpcSlot(Int slot)
	Actor a = getNpcSlot(slot)
	setNpcSlot(slot, None)
	If widget_controller
		widget_controller.releaseNpcSlot(slot)
	EndIf
EndFunction

Function moduleSetup()
	module_sla.moduleSetup()
	module_apropos_two.moduleSetup()
	module_fhu.moduleSetup()
	module_mme.moduleSetup()
	module_slp.moduleSetup()
	module_pregnancy.moduleSetup()
	module_paf.moduleSetup()
	module_defeat.moduleSetup()
	module_sunhelm.moduleSetup()
	module_hygiene.moduleSetup()
	module_sph.moduleSetup()
	module_baby.moduleSetup()
	module_stress.moduleSetup()
	module_health.moduleSetup()
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
	module_sunhelm.moduleReset()
	module_hygiene.moduleReset()
	module_sph.moduleReset()
	module_baby.moduleReset()
	module_stress.moduleReset()
	module_health.moduleReset()
EndFunction

; The modules that track NPCs get every slot; the player-only ones (PAF,
; Defeat, and of the 3.0.0 set SunHelm, SPH, Stress and Fear, injuries and
; diseases) only slot 0.
Function moduleWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	module_sla.onWidgetToggleUpdate(iBars, target, slot)
	module_apropos_two.onWidgetToggleUpdate(iBars, target, slot)
	module_fhu.onWidgetToggleUpdate(iBars, target, slot)
	module_mme.onWidgetToggleUpdate(iBars, target, slot)
	module_slp.onWidgetToggleUpdate(iBars, target, slot)
	module_pregnancy.onWidgetToggleUpdate(iBars, target, slot)
	module_hygiene.onWidgetToggleUpdate(iBars, target, slot)
	module_baby.onWidgetToggleUpdate(iBars, target, slot)
	If slot == 0
		module_paf.onWidgetToggleUpdate(iBars, target, slot)
		module_defeat.onWidgetToggleUpdate(iBars, target, slot)
		module_sunhelm.onWidgetToggleUpdate(iBars, target, slot)
		module_sph.onWidgetToggleUpdate(iBars, target, slot)
		module_stress.onWidgetToggleUpdate(iBars, target, slot)
		module_health.onWidgetToggleUpdate(iBars, target, slot)
	EndIf
EndFunction

;doesn't work async with ibars
Function moduleWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	module_sla.onWidgetReload(iBars, target, slot)
	module_apropos_two.onWidgetReload(iBars, target, slot)
	module_fhu.onWidgetReload(iBars, target, slot)
	module_mme.onWidgetReload(iBars, target, slot)
	module_slp.onWidgetReload(iBars, target, slot)
	module_pregnancy.onWidgetReload(iBars, target, slot)
	module_hygiene.onWidgetReload(iBars, target, slot)
	module_baby.onWidgetReload(iBars, target, slot)
	If slot == 0
		module_paf.onWidgetReload(iBars, target, slot)
		module_defeat.onWidgetReload(iBars, target, slot)
		module_sunhelm.onWidgetReload(iBars, target, slot)
		module_sph.onWidgetReload(iBars, target, slot)
		module_stress.onWidgetReload(iBars, target, slot)
		module_health.onWidgetReload(iBars, target, slot)
	EndIf
EndFunction

;doesn't work async with ibars
Function moduleWidgetStateUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	module_sla.onWidgetStatusUpdate(iBars, target, slot)
	module_apropos_two.onWidgetStatusUpdate(iBars, target, slot)
	module_fhu.onWidgetStatusUpdate(iBars, target, slot)
	module_mme.onWidgetStatusUpdate(iBars, target, slot)
	module_slp.onWidgetStatusUpdate(iBars, target, slot)
	module_pregnancy.onWidgetStatusUpdate(iBars, target, slot)
	module_hygiene.onWidgetStatusUpdate(iBars, target, slot)
	module_baby.onWidgetStatusUpdate(iBars, target, slot)
	If slot == 0
		module_paf.onWidgetStatusUpdate(iBars, target, slot)
		module_defeat.onWidgetStatusUpdate(iBars, target, slot)
		module_sunhelm.onWidgetStatusUpdate(iBars, target, slot)
		module_sph.onWidgetStatusUpdate(iBars, target, slot)
		module_stress.onWidgetStatusUpdate(iBars, target, slot)
		module_health.onWidgetStatusUpdate(iBars, target, slot)
	EndIf
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
	module_sh_food = True
	module_sh_thirst = True
	module_sh_cold = True
	module_sh_fatigue = True
	module_dirtiness = True
	module_wetness = True
	module_sph_pubic = True
	module_sph_armpit = True
	module_baby_health = True
	module_saf_stress = True
	module_saf_fear = True
	module_injuries = True
	module_diseases = True
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
	module_fhu_cum_oral = false
	module_mme_milk = false
	module_mme_lactacid = false
	module_parasites_enabled = false
	module_pregnancy_enabled = false
	module_paf_pee = false
	module_paf_poo = false
	module_defeat_enabled = false
	module_sh_food = false
	module_sh_thirst = false
	module_sh_cold = false
	module_sh_fatigue = false
	module_dirtiness = false
	module_wetness = false
	module_sph_pubic = false
	module_sph_armpit = false
	module_baby_health = false
	module_saf_stress = false
	module_saf_fear = false
	module_injuries = false
	module_diseases = false
EndFunction

Bool function isOn(bool prop)
	return !slw_stopped && prop
endFunction

Function loadPreset(String presetName)
	If _iconColors
		JValue.release(_iconColors)
		_iconColors = 0
	EndIf
	_iconColors = JValue.readFromFile("Data/SKSE/Plugins/SlWidgets/IconPresets/" + presetName + ".json")
	If _iconColors
		JValue.retain(_iconColors)
	EndIf
EndFunction

Function ApplyIconColors(String iconKey, Int[] r, Int[] g, Int[] b, Int[] a)
	If !_iconColors
		Return
	EndIf
	String base = "." + iconKey + "."
	Int jR = JValue.solveObj(_iconColors, base + "r")
	Int jG = JValue.solveObj(_iconColors, base + "g")
	Int jB = JValue.solveObj(_iconColors, base + "b")
	Int jA = JValue.solveObj(_iconColors, base + "a")
	If !jR && !jG && !jB && !jA
		Return
	EndIf
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
	String dir = "Data/SKSE/Plugins/SlWidgets/IconPresets"
	String[] names = MiscUtil.FilesInFolder(dir, ".json")
	If !names || names.Length == 0
		String[] fallback = new String[1]
		fallback[0] = "Default"
		Return fallback
	EndIf
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

String[] Function getSettingsPresetNames()
	String dir = "Data/SKSE/Plugins/SlWidgets/SettingsPresets"
	String[] names = MiscUtil.FilesInFolder(dir, ".json")
	If !names || names.Length == 0
		String[] fallback = new String[1]
		fallback[0] = "Default"
		Return fallback
	EndIf
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

Bool Function loadSettingsPreset(String presetName)
	String path = "..\\SlWidgets\\SettingsPresets\\" + presetName
	If !jsonutil.IsGood(path)
		WriteLog("SLWidgets: Can't load settings preset '" + presetName + "'. Errors: {" + jsonutil.getErrors(path) + "}", 2)
		Return false
	EndIf
	updateInterval = jsonutil.GetPathIntValue(path, "updateInterval", updateInterval)
	activePreset = jsonutil.GetPathStringValue(path, "activePreset", activePreset)
	module_sla_arousal = jsonutil.GetPathBoolValue(path, "module_sla_arousal", module_sla_arousal)
	module_sla_exposure = jsonutil.GetPathBoolValue(path, "module_sla_exposure", module_sla_exposure)
	module_apropos_two_wt = jsonutil.GetPathBoolValue(path, "module_apropos_two_wt", module_apropos_two_wt)
	module_fhu_cum = jsonutil.GetPathBoolValue(path, "module_fhu_cum", module_fhu_cum)
	module_fhu_cum_anal = jsonutil.GetPathBoolValue(path, "module_fhu_cum_anal", module_fhu_cum_anal)
	module_fhu_cum_vaginal = jsonutil.GetPathBoolValue(path, "module_fhu_cum_vaginal", module_fhu_cum_vaginal)
	module_fhu_cum_oral = jsonutil.GetPathBoolValue(path, "module_fhu_cum_oral", module_fhu_cum_oral)
	module_mme_milk = jsonutil.GetPathBoolValue(path, "module_mme_milk", module_mme_milk)
	module_mme_lactacid = jsonutil.GetPathBoolValue(path, "module_mme_lactacid", module_mme_lactacid)
	module_parasites_enabled = jsonutil.GetPathBoolValue(path, "module_parasites_enabled", module_parasites_enabled)
	module_pregnancy_enabled = jsonutil.GetPathBoolValue(path, "module_pregnancy_enabled", module_pregnancy_enabled)
	module_paf_pee = jsonutil.GetPathBoolValue(path, "module_paf_pee", module_paf_pee)
	module_paf_poo = jsonutil.GetPathBoolValue(path, "module_paf_poo", module_paf_poo)
	module_defeat_enabled = jsonutil.GetPathBoolValue(path, "module_defeat_enabled", module_defeat_enabled)
	module_slove_willpower = jsonutil.GetPathBoolValue(path, "module_slove_willpower", module_slove_willpower)
	module_sh_food = jsonutil.GetPathBoolValue(path, "module_sh_food", module_sh_food)
	module_sh_thirst = jsonutil.GetPathBoolValue(path, "module_sh_thirst", module_sh_thirst)
	module_sh_cold = jsonutil.GetPathBoolValue(path, "module_sh_cold", module_sh_cold)
	module_sh_fatigue = jsonutil.GetPathBoolValue(path, "module_sh_fatigue", module_sh_fatigue)
	module_dirtiness = jsonutil.GetPathBoolValue(path, "module_dirtiness", module_dirtiness)
	module_wetness = jsonutil.GetPathBoolValue(path, "module_wetness", module_wetness)
	module_sph_pubic = jsonutil.GetPathBoolValue(path, "module_sph_pubic", module_sph_pubic)
	module_sph_armpit = jsonutil.GetPathBoolValue(path, "module_sph_armpit", module_sph_armpit)
	module_baby_health = jsonutil.GetPathBoolValue(path, "module_baby_health", module_baby_health)
	module_saf_stress = jsonutil.GetPathBoolValue(path, "module_saf_stress", module_saf_stress)
	module_saf_fear = jsonutil.GetPathBoolValue(path, "module_saf_fear", module_saf_fear)
	module_injuries = jsonutil.GetPathBoolValue(path, "module_injuries", module_injuries)
	module_diseases = jsonutil.GetPathBoolValue(path, "module_diseases", module_diseases)
	_loadMeterSettings(path)
	_loadNpcSlotToggles(path)
	Return true
EndFunction

; Everything on the Meters page: which meters are on, how they show, and the
; stack's place and size. Willpower's switch travels as module_slove_willpower,
; so the loops start at meter 1. A preset without these keys (older ones, the
; shipped ones) leaves the current values alone.
Function _loadMeterSettings(String path)
	_ensureMeterToggles()
	Int i = 1
	While i < getMeterCount()
		_meter_use[i] = jsonutil.GetPathBoolValue(path, getMeterPresetKey(i), _meter_use[i])
		i += 1
	EndWhile
	slw_widget_controller wc = widget_controller
	If !wc
		Return
	EndIf
	wc.metersAlwaysShow = jsonutil.GetPathBoolValue(path, "meters.alwaysshow", wc.metersAlwaysShow)
	; A preset is a file anyone can edit: held to the MCM's slider ranges, so a
	; 0 cannot make every meter invisible (no hold time, zero size).
	wc.metersHoldSeconds = _clampInt(jsonutil.GetPathIntValue(path, "meters.holdseconds", wc.metersHoldSeconds), 2, 120)
	; Only a real move goes through the layout setter: it rebuilds the stack
	; and shows it for half a minute at the new place.
	Int x = _clampInt(jsonutil.GetPathIntValue(path, "meters.x", wc.metersX), -1280, 2560)
	Int y = _clampInt(jsonutil.GetPathIntValue(path, "meters.y", wc.metersY), -720, 719)
	Int scale = _clampInt(jsonutil.GetPathIntValue(path, "meters.scale", wc.metersScale), 20, 200)
	If x != wc.metersX || y != wc.metersY || scale != wc.metersScale
		wc.setMetersLayout(x, y, scale)
	EndIf
EndFunction

Int Function _clampInt(Int value, Int low, Int high)
	If value < low
		Return low
	ElseIf value > high
		Return high
	EndIf
	Return value
EndFunction

Function _saveMeterSettings(String path)
	_ensureMeterToggles()
	Int i = 1
	While i < getMeterCount()
		jsonutil.SetPathIntValue(path, getMeterPresetKey(i), _meter_use[i] as Int)
		i += 1
	EndWhile
	slw_widget_controller wc = widget_controller
	If !wc
		Return
	EndIf
	jsonutil.SetPathIntValue(path, "meters.alwaysshow", wc.metersAlwaysShow as Int)
	jsonutil.SetPathIntValue(path, "meters.holdseconds", wc.metersHoldSeconds)
	jsonutil.SetPathIntValue(path, "meters.x", wc.metersX)
	jsonutil.SetPathIntValue(path, "meters.y", wc.metersY)
	jsonutil.SetPathIntValue(path, "meters.scale", wc.metersScale)
EndFunction

Function _loadNpcSlotToggles(String path)
	_ensureSlotToggles()
	Int slot = 1
	While slot <= 3
		String base = "npc." + slot + "."
		_slot_use_sla_arousal[slot] = jsonutil.GetPathBoolValue(path, base + "sla_arousal", _slot_use_sla_arousal[slot])
		_slot_use_sla_exposure[slot] = jsonutil.GetPathBoolValue(path, base + "sla_exposure", _slot_use_sla_exposure[slot])
		_slot_use_ap2[slot] = jsonutil.GetPathBoolValue(path, base + "ap2", _slot_use_ap2[slot])
		_slot_use_fhu_cum[slot] = jsonutil.GetPathBoolValue(path, base + "fhu_cum", _slot_use_fhu_cum[slot])
		_slot_use_fhu_anal[slot] = jsonutil.GetPathBoolValue(path, base + "fhu_anal", _slot_use_fhu_anal[slot])
		_slot_use_fhu_vaginal[slot] = jsonutil.GetPathBoolValue(path, base + "fhu_vaginal", _slot_use_fhu_vaginal[slot])
		_slot_use_fhu_oral[slot] = jsonutil.GetPathBoolValue(path, base + "fhu_oral", _slot_use_fhu_oral[slot])
		_slot_use_mme_milk[slot] = jsonutil.GetPathBoolValue(path, base + "mme_milk", _slot_use_mme_milk[slot])
		_slot_use_mme_lactacid[slot] = jsonutil.GetPathBoolValue(path, base + "mme_lactacid", _slot_use_mme_lactacid[slot])
		_slot_use_slp[slot] = jsonutil.GetPathBoolValue(path, base + "slp", _slot_use_slp[slot])
		_slot_use_preg[slot] = jsonutil.GetPathBoolValue(path, base + "preg", _slot_use_preg[slot])
		_slot_use_dirt[slot] = jsonutil.GetPathBoolValue(path, base + "dirt", _slot_use_dirt[slot])
		_slot_use_wet[slot] = jsonutil.GetPathBoolValue(path, base + "wet", _slot_use_wet[slot])
		_slot_use_baby[slot] = jsonutil.GetPathBoolValue(path, base + "baby", _slot_use_baby[slot])
		slot += 1
	EndWhile
EndFunction

Bool Function saveSettingsPreset(String presetName)
	String path = "..\\SlWidgets\\SettingsPresets\\" + presetName
	jsonutil.SetPathIntValue(path, "updateInterval", updateInterval)
	jsonutil.SetPathStringValue(path, "activePreset", activePreset)
	jsonutil.SetPathIntValue(path, "module_sla_arousal", module_sla_arousal as Int)
	jsonutil.SetPathIntValue(path, "module_sla_exposure", module_sla_exposure as Int)
	jsonutil.SetPathIntValue(path, "module_apropos_two_wt", module_apropos_two_wt as Int)
	jsonutil.SetPathIntValue(path, "module_fhu_cum", module_fhu_cum as Int)
	jsonutil.SetPathIntValue(path, "module_fhu_cum_anal", module_fhu_cum_anal as Int)
	jsonutil.SetPathIntValue(path, "module_fhu_cum_vaginal", module_fhu_cum_vaginal as Int)
	jsonutil.SetPathIntValue(path, "module_fhu_cum_oral", module_fhu_cum_oral as Int)
	jsonutil.SetPathIntValue(path, "module_mme_milk", module_mme_milk as Int)
	jsonutil.SetPathIntValue(path, "module_mme_lactacid", module_mme_lactacid as Int)
	jsonutil.SetPathIntValue(path, "module_parasites_enabled", module_parasites_enabled as Int)
	jsonutil.SetPathIntValue(path, "module_pregnancy_enabled", module_pregnancy_enabled as Int)
	jsonutil.SetPathIntValue(path, "module_paf_pee", module_paf_pee as Int)
	jsonutil.SetPathIntValue(path, "module_paf_poo", module_paf_poo as Int)
	jsonutil.SetPathIntValue(path, "module_defeat_enabled", module_defeat_enabled as Int)
	jsonutil.SetPathIntValue(path, "module_slove_willpower", module_slove_willpower as Int)
	jsonutil.SetPathIntValue(path, "module_sh_food", module_sh_food as Int)
	jsonutil.SetPathIntValue(path, "module_sh_thirst", module_sh_thirst as Int)
	jsonutil.SetPathIntValue(path, "module_sh_cold", module_sh_cold as Int)
	jsonutil.SetPathIntValue(path, "module_sh_fatigue", module_sh_fatigue as Int)
	jsonutil.SetPathIntValue(path, "module_dirtiness", module_dirtiness as Int)
	jsonutil.SetPathIntValue(path, "module_wetness", module_wetness as Int)
	jsonutil.SetPathIntValue(path, "module_sph_pubic", module_sph_pubic as Int)
	jsonutil.SetPathIntValue(path, "module_sph_armpit", module_sph_armpit as Int)
	jsonutil.SetPathIntValue(path, "module_baby_health", module_baby_health as Int)
	jsonutil.SetPathIntValue(path, "module_saf_stress", module_saf_stress as Int)
	jsonutil.SetPathIntValue(path, "module_saf_fear", module_saf_fear as Int)
	jsonutil.SetPathIntValue(path, "module_injuries", module_injuries as Int)
	jsonutil.SetPathIntValue(path, "module_diseases", module_diseases as Int)
	_saveMeterSettings(path)
	_saveNpcSlotToggles(path)
	If !jsonutil.Save(path, false)
		WriteLog("SLWidgets: Error saving settings preset '" + presetName + "'", 2)
		Return false
	EndIf
	Return true
EndFunction

Function _saveNpcSlotToggles(String path)
	_ensureSlotToggles()
	Int slot = 1
	While slot <= 3
		String base = "npc." + slot + "."
		jsonutil.SetPathIntValue(path, base + "sla_arousal", _slot_use_sla_arousal[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "sla_exposure", _slot_use_sla_exposure[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "ap2", _slot_use_ap2[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "fhu_cum", _slot_use_fhu_cum[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "fhu_anal", _slot_use_fhu_anal[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "fhu_vaginal", _slot_use_fhu_vaginal[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "fhu_oral", _slot_use_fhu_oral[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "mme_milk", _slot_use_mme_milk[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "mme_lactacid", _slot_use_mme_lactacid[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "slp", _slot_use_slp[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "preg", _slot_use_preg[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "dirt", _slot_use_dirt[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "wet", _slot_use_wet[slot] as Int)
		jsonutil.SetPathIntValue(path, base + "baby", _slot_use_baby[slot] as Int)
		slot += 1
	EndWhile
EndFunction