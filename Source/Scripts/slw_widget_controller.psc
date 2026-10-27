Scriptname slw_widget_controller Extends Quest
import slw_util
import slw_log
iWant_Status_Bars property iBars auto hidden
slw_config Property config Auto
Actor Property PlayerRef Auto

Bool property controller_initialised = False auto hidden

; Per-slot fine-tune offsets added on top of the auto-computed offset.
; Auto offset is derived from iWant's bar shape + icon size so the label
; always sits a sensible distance above the bar regardless of user changes
; in iWant's MCM. Final label position is:
;   (barX + autoOffsetX(bar) + userOffsetX, barY + autoOffsetY(bar) + userOffsetY)
Int Property npc1_labelOffsetX = 0 Auto Hidden
Int Property npc1_labelOffsetY = 0 Auto Hidden
Int Property npc2_labelOffsetX = 0 Auto Hidden
Int Property npc2_labelOffsetY = 0 Auto Hidden
Int Property npc3_labelOffsetX = 0 Auto Hidden
Int Property npc3_labelOffsetY = 0 Auto Hidden

; Each NPC slot gets two iWant bars (20 positions — fits ~17-icon worst case).
; Player keeps bars 0..3 (40 positions). NPC1=4,5  NPC2=6,7  NPC3=8,9.
Int NPC_BARS_PER_SLOT = 2

; Anchor for the NPC bar group. (npcGroupX, npcGroupY) is the position of
; NPC1's primary bar — slot 1 sits at the bottom of the cluster and additional
; slots stack upward. If only NPC1 is assigned, the cluster is just one bar at
; the anchor — no visible empty space below it.
; iWant uses a fixed 1280x720 Flash stage that Skyrim scales to any monitor
; resolution. Defaults match iWant's bottom-right anchor pattern.
Int Property npcGroupX = 1100 Auto Hidden
Int Property npcGroupY = 600 Auto Hidden

; Global label style (applies to all 3 NPC name labels). Font and size are
; baked in at creation by iWant.loadText — changing them requires destroying
; and recreating the widget (handled by refreshAllNpcLabels). Color can be
; applied to an existing widget via setRGB.
String Property npcLabelFont = "$EverywhereFont" Auto Hidden
Int Property npcLabelSize = 24 Auto Hidden
Int Property npcLabelR = 255 Auto Hidden
Int Property npcLabelG = 255 Auto Hidden
Int Property npcLabelB = 255 Auto Hidden

; Vertical spacing between primary/secondary bars within one NPC.
Int NPC_BAR_VSPACING = 40
; Stride between NPCs in the cluster (distance from one NPC's primary bar to
; the next NPC's primary bar). Default 105 = comfortable clearance with the
; default 40px intra-NPC spacing. User-tunable from MCM for cluster
; compactness; going below ~80 risks labels overlapping the previous NPC's
; secondary bar.
Int Property npcVerticalSpacing = 105 Auto Hidden
Int NPC_DEFAULT_ICON_SIZE = 18
Int NPC_DEFAULT_SHAPE = 0  ; line-left — icons grow leftward from the X anchor
                           ; so the bottom-right cluster fits on stage when X is
                           ; near the right edge (1279). Line-right would push
                           ; icons off-screen.

; iWant bar shape codes: 0=line-left, 1=line-right, 2=line-up, 3=line-down,
; 4=circle, 5=orbit, 6=lower half-circle, 7=upper half-circle.

; Per-slot "was the NPC present last OnUpdate tick?" — script-level, doesn't
; survive saves (which is fine: _restoreNpcLabelsAndIcons re-seeds it).
; Used to detect cell load/unload transitions so OnUpdate can refresh the
; label text once (adding/removing the "(away)" suffix) instead of every tick.
Bool[] _slot_present_prv

Function _ensurePresentPrv()
	If !_slot_present_prv
		_slot_present_prv = Utility.CreateBoolArray(4, False)
	EndIf
EndFunction

; Primary bar for the slot (where the label anchors). 1→4, 2→6, 3→8.
Int Function _getBarForSlot(Int slot)
	If slot <= 0
		Return 0
	EndIf
	Return slot * NPC_BARS_PER_SLOT + 2
EndFunction

; Secondary overflow bar. 1→5, 2→7, 3→9.
Int Function _getSecondaryBarForSlot(Int slot)
	If slot <= 0
		Return -1
	EndIf
	Return _getBarForSlot(slot) + 1
EndFunction

Function setNpcGroupPos(Int x, Int y)
	npcGroupX = x
	npcGroupY = y
EndFunction

Function setNpcVerticalSpacing(Int v)
	npcVerticalSpacing = v
	_layoutNpcBars()
EndFunction

; Auto-computed label offsets derived from iWant's bar shape + icon size.
; Shape codes: 0/1/2/3=lines, 4=circle, 5=orbit, 6/7=half-circles.
Int Function _autoLabelOffsetX(Int bar)
	If !iBars
		Return 0
	EndIf
	; Half-icon to the left of the anchor — visually centers a short name
	; on the first icon. Long names extend rightward; user can fine-tune.
	Return -iBars._getBarIconSize(bar) / 2
EndFunction

Int Function _autoLabelOffsetY(Int bar)
	If !iBars
		Return -40
	EndIf
	Int shape = iBars._getBarType(bar)
	Int s = iBars._getBarIconSize(bar)
	If shape <= 3
		; Line (left/right/up/down): place label one icon height above anchor.
		; For up-lines the anchor is at bar bottom; this puts the label inside
		; the line which is wrong, but uncommon enough to leave as a user-tunable.
		Return -(s + 10)
	ElseIf shape == 4 || shape == 5
		; Circle/orbit have radius = iconSize * 2 — label above the top of the ring.
		Return -(s * 2 + 15)
	ElseIf shape >= 6
		; Half-circle has radius = iconSize * 3.
		Return -(s * 3 + 15)
	EndIf
	Return -40
EndFunction

String EMPTY_STATE = "PLACEHOLDER"
String STATUS_BARS_EVENT_NAME = "iWantStatusBarsReady"

int _emptyIconIndex = 0
int _checkPlugins = 0

bool Function isLoaded()
	return controller_initialised && iBars && iBars.isReady()
EndFunction

; True when iWant Status Bars exposes the 2.10 API (GetAPIVersion 4). The
; NPC-tracking layer needs getBarVisible and getBarLastChangeTime, and it
; needs 2.10's _findBarOfIcon fix: 2.09 and older return the wrong bar
; there, which would make reconciliation duplicate icons every tick. NPC
; slots stay disabled entirely when the probe fails. Player tracking works
; on any version.
Bool _iBarsApiProbed = False
Bool _iBarsApiOk = False

Bool Function hasBarsAPI()
	If !iBars
		; Nothing to probe: never report a capability from a stale save value.
		Return False
	EndIf
	If !_iBarsApiProbed
		; On 2.09 and older the call fails into a single Papyrus log error
		; and returns 0, which is the detection mechanism.
		_iBarsApiOk = iBars.GetAPIVersion() >= 4
		_iBarsApiProbed = True
	EndIf
	Return _iBarsApiOk
EndFunction

; Assumed lifecycle: menu OnInit() -> OniWantStatusBarsReady......mcm enable -> setup() (Modules initialisation) -> UpdateIcons() -> ||controller_initialised|| -> UpdateIconStateStatus(in a loop)
Event OnInit()
	slw_log.InitLog()
	If !PlayerRef
		PlayerRef = Game.GetPlayer()
	EndIf
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	controller_initialised = true
	config.loadPreset(config.activePreset)
EndEvent

; iWant keeps an icon's per-stage colours from the call that registered it,
; and nothing re-registers the player's icons on a game load. A save that
; registered its icons with an older build therefore keeps the old colours
; (and lacks icons that build did not have) until a widget reload. This does
; that reload once per ICONS_VERSION: bump it when the registered icons or
; their default colours change. 30001 = 3.0.1 (the Default preset at full
; alpha; also brings 3.0.0's 13 new icons to saves upgraded from 2.3.0).
; 30400 = 3.4.0 (palette A, ice blue to magenta, and the hair glyphs). A read-only property, not a variable: a variable added
; to a script an existing save holds could come up 0 there.
Int Property ICONS_VERSION = 30400 AutoReadOnly Hidden
Int _iconsVersion = 0

Function _reloadIconsOnce()
	If _iconsVersion >= ICONS_VERSION
		Return
	EndIf
	If !iBars || !iBars.isReady()
		; not claimed: the next iWant-ready event tries again
		Return
	EndIf
	; claimed first: a second iWant-ready event during the reload must not
	; start another
	_iconsVersion = ICONS_VERSION
	If config.slw_stopped
		; nothing registered; enabling the mod loads every icon fresh
		Return
	EndIf
	WriteLog("WidgetController: icons registered by an older build, reloading them once")
	reloadWidgets()
EndFunction

;init ibars
Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == STATUS_BARS_EVENT_NAME
		iBars = sender As iWant_Status_Bars
		; The bars instance (or the installed bars script) may have changed —
		; e.g. the user changed Status Bars version mid-save. Re-probe.
		_iBarsApiProbed = False
		_iBarsApiOk = False
		_forgetMeters()
		if iBars
			WriteLog("WidgetController: iBars ready")
			config.loadPreset(config.activePreset)
			_restoreNpcLabelsAndIcons()
			_reloadIconsOnce()
		else
			WriteLog("WidgetController: iBars cast failed from sender", 2)
		endif
	EndIf
EndEvent

;on game reload
;on enable mod button click
;on load settings
Function startUpdates()
	;Notification("WidgetController: moduleSetup")
	;just in case
	UnregisterForUpdate()
	UnregisterForModEvent(STATUS_BARS_EVENT_NAME)
	RegisterForModEvent(STATUS_BARS_EVENT_NAME, "OniWantStatusBarsReady")
	; Runs on every game load. Mod event registrations do not survive one, and
	; the pass bookkeeping is real time from the last session, which restarts
	; near 0 with the game: a stamp left from there would hold a refresh off
	; for as long as that session ran. A pass the save carried over (Papyrus
	; resumes saved stacks) sees _passGen move and leaves the loop alone.
	_registerRefreshEvents()
	; requests from the SKSE menu are per session: one the save carried over is stale
	_presetOwed = ""
	_presetSaveOwed = ""
	_reloadOwed = False
	_recheckOwed = False
	_labelsOwed = False
	_passGen += 1
	_passRunning = False
	_lastPassEnd = 0.0
	_refreshAt = 0.0
	RegisterForSingleUpdate(3)
EndFunction

Function stopUpdates()
	UnregisterForUpdate()
	UnregisterForModEvent(STATUS_BARS_EVENT_NAME)
	_unregisterRefreshEvents()
	_hideAllNpcLabels()
	_stopMeters()
EndFunction

Function _hideAllNpcLabels()
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		_hideNpcLabel(slot)
		slot += 1
	EndWhile
EndFunction

; ---------------------------------------------------------------------------
; Event-driven refresh
; ---------------------------------------------------------------------------
; The loop polls every updateInterval seconds. These mod events pull the next
; pass forward, so a value that just changed reaches the icons and meters in
; a second or two; polling stays the fallback for everything no event covers.
; - fhu.playerCumUpdate (Fill Her Up, player only): sent after a pool's new
;   amount is stored, on every fill, absorption and leak.
; - Apropos2WearTearChanged (Apropos2 SE 1.0020+): sent from the actor on
;   every wear and tear stage change.
; - sla_UpdateComplete (SLA NG): the end of a scan cycle.
; - slaUpdateExposure / slaSetArousalEffect / slaModArousalEffect /
;   slaOrgasm, and SexLabOrgasm: requests that SLA applies in its own
;   handler, so the pass waits a moment for it to land.
; A handler of a ModEvent.Create event must take exactly the arguments the
; sender pushes, or the VM never calls it: the signatures below copy SLA's
; and FHU's own.

; seconds from an event to its pass
Float REFRESH_SOON = 0.2
Float REFRESH_AFTER_SLA = 1.5
; Shortest idle time between the end of a pass and the next pass an event
; asks for, so a burst (FHU leaking, a vibrating device) cannot run passes
; back to back however long a pass takes.
Float REFRESH_MIN_GAP = 1.0
; real time of the pass an event asked for and no pass has served yet,
; 0 = none owed
Float _refreshAt = 0.0
; real time the last pass ended
Float _lastPassEnd = 0.0
Bool _passRunning = False
; bumped on every game load, see startUpdates
Int _passGen = 0

Function _registerRefreshEvents()
	RegisterForModEvent("fhu.playerCumUpdate", "OnFhuPlayerCumUpdate")
	RegisterForModEvent("Apropos2WearTearChanged", "OnApropos2WearTearChanged")
	RegisterForModEvent("sla_UpdateComplete", "OnSlaUpdateComplete")
	RegisterForModEvent("slaUpdateExposure", "OnSlaUpdateExposure")
	RegisterForModEvent("slaSetArousalEffect", "OnSlaSetArousalEffect")
	RegisterForModEvent("slaModArousalEffect", "OnSlaModArousalEffect")
	RegisterForModEvent("slaOrgasm", "OnSlaOrgasm")
	RegisterForModEvent("SexLabOrgasm", "OnSexLabOrgasm")
EndFunction

Function _unregisterRefreshEvents()
	UnregisterForModEvent("fhu.playerCumUpdate")
	UnregisterForModEvent("Apropos2WearTearChanged")
	UnregisterForModEvent("sla_UpdateComplete")
	UnregisterForModEvent("slaUpdateExposure")
	UnregisterForModEvent("slaSetArousalEffect")
	UnregisterForModEvent("slaModArousalEffect")
	UnregisterForModEvent("slaOrgasm")
	UnregisterForModEvent("SexLabOrgasm")
EndFunction

Event OnFhuPlayerCumUpdate(Float current, Bool isAnal)
	_refreshSoon(REFRESH_SOON)
EndEvent

Event OnApropos2WearTearChanged(String eventName, String bodyPart, Float stage, Form sender)
	If _isShown(sender as Actor)
		_refreshSoon(REFRESH_SOON)
	EndIf
EndEvent

Event OnSlaUpdateComplete(String eventName, String strArg, Float numArg, Form sender)
	_refreshSoon(REFRESH_SOON)
EndEvent

Event OnSlaUpdateExposure(Form actorForm, Float exposureValue)
	If _isShown(actorForm as Actor)
		_refreshSoon(REFRESH_AFTER_SLA)
	EndIf
EndEvent

Event OnSlaSetArousalEffect(Form whoF, String effectId, Float initialValue, Int functionId, Float param, Float limit)
	If _isShown(whoF as Actor)
		_refreshSoon(REFRESH_AFTER_SLA)
	EndIf
EndEvent

Event OnSlaModArousalEffect(Form whoF, String effectId, Float modifier, Float limit)
	If _isShown(whoF as Actor)
		_refreshSoon(REFRESH_AFTER_SLA)
	EndIf
EndEvent

Event OnSlaOrgasm(Form whoF, Float enjoyment)
	If _isShown(whoF as Actor)
		_refreshSoon(REFRESH_AFTER_SLA)
	EndIf
EndEvent

Event OnSexLabOrgasm(Form who, Int enjoyment, Int orgasms)
	If _isShown(who as Actor)
		_refreshSoon(REFRESH_AFTER_SLA)
	EndIf
EndEvent

; The player or an actor in an NPC slot: anyone else's change shows nowhere.
Bool Function _isShown(Actor a)
	Return a && (a == PlayerRef || config.findNpcSlot(a) > 0)
EndFunction

; Asks for a pass delay seconds from now, but no sooner than REFRESH_MIN_GAP
; after the last pass ended. Registering a single update replaces the pending
; one, so the loop's own next tick moves with it.
Function _refreshSoon(Float delay)
	If config.slw_stopped
		Return
	EndIf
	Float now = Utility.GetCurrentRealTime()
	Float at = now + delay
	If at < _lastPassEnd + REFRESH_MIN_GAP
		at = _lastPassEnd + REFRESH_MIN_GAP
	EndIf
	; a refresh already owed at or before then covers this one
	If _refreshAt > 0.0 && _refreshAt <= at
		Return
	EndIf
	_refreshAt = at
	; a running pass schedules what it owes as it ends
	If !_passRunning
		RegisterForSingleUpdate(at - now)
	EndIf
EndFunction

; After a pass: the normal tick, or an owed refresh. One whose time has
; already gone by (asked for while the pass ran, after it had read that
; value) is still owed, REFRESH_MIN_GAP from now.
Function _scheduleNextTick()
	Float wait = config.updateInterval as Float
	If _refreshAt > 0.0
		Float owed = _refreshAt - Utility.GetCurrentRealTime()
		If owed < REFRESH_MIN_GAP
			owed = REFRESH_MIN_GAP
		EndIf
		If owed < wait
			wait = owed
		EndIf
	EndIf
	RegisterForSingleUpdate(wait)
EndFunction

;Main update function
Event OnUpdate()
	; One pass at a time, claimed before the first external call: that call
	; lets other threads in, and an event arriving then has to see the pass as
	; running, or the end of this pass would overwrite the refresh it asks for.
	If _passRunning
		; a tick pulled forward while a pass runs: that pass owes one more
		If _refreshAt <= 0.0
			_refreshAt = Utility.GetCurrentRealTime()
		EndIf
		Return
	EndIf
	_passRunning = True
	Int gen = _passGen
	; An owed refresh that is due now is what this pass serves. A later one
	; (an SLA request still landing) stays owed for the end of the pass.
	If _refreshAt <= Utility.GetCurrentRealTime() + 0.1
		_refreshAt = 0.0
	EndIf
	If config.slw_stopped
		_passRunning = False
		Return
	EndIf
	_updatePass()
	If gen != _passGen
		; a game load came in the middle, startUpdates owns the loop now
		Return
	EndIf
	_passRunning = False
	_lastPassEnd = Utility.GetCurrentRealTime()
	_scheduleNextTick()
EndEvent

Function _updatePass()
	; Presets asked for on the SKSE menu, before the iWant check: a load stores
	; its values with iWant down too, as the MCM's does. A load that worked
	; reloaded every icon, which covers a toggle pass owed before it.
	If _presetOwed != ""
		String presetName = _presetOwed
		_presetOwed = ""
		If config.applySettingsPreset(presetName)
			_togglePassOwed = False
		EndIf
	EndIf
	If _presetSaveOwed != ""
		String saveName = _presetSaveOwed
		_presetSaveOwed = ""
		config.savePresetAs(saveName)
	EndIf
	If _recheckOwed
		_recheckOwed = False
		config.moduleReset()
		config.moduleSetup()
	EndIf
	If _reloadOwed
		_reloadOwed = False
		; reloads every icon: a toggle pass owed before it is covered
		_togglePassOwed = False
		reloadWidgets()
	EndIf
	if !iBars || !iBars.isReady()
		return
	endif
	If !PlayerRef
		PlayerRef = Game.GetPlayer()
	EndIf
	If _npcReleaseOwed
		Int slot = 1
		While slot < _npcReleaseOwed.Length
			If _npcReleaseOwed[slot]
				_npcReleaseOwed[slot] = False
				releaseNpcSlot(slot)
				_togglePassOwed = True
			EndIf
			slot += 1
		EndWhile
	EndIf
	If _labelsOwed
		_labelsOwed = False
		refreshAllNpcLabelStyles()
	EndIf
	If _togglePassOwed
		_togglePassOwed = False
		toggleUpdateWidgets()
	EndIf
	; Slot 0 - player, always updates
	config.moduleWidgetStateUpdate(iBars, PlayerRef, 0)
	_updateMeters()
	; Status Bars older than 2.10: the NPC layer stays off, see
	; hasBarsAPI. Keep labels left over from an old save hidden.
	If !hasBarsAPI()
		_hideAllNpcLabels()
		Return
	EndIf
	; Slots 1..N_NPC — NPC targets; skip if unset or not currently loaded/alive.
	; Reconcile every tick — modules can register new icons during a status
	; update (pregnancy state change) and iWant auto-places them in bar 0;
	; reconciling here moves them into the slot's dedicated bar promptly.
	_ensurePresentPrv()
	Int slot = 1
	Int total = getSlotCount()
	Bool anyActive = False
	While slot < total
		Actor t = config.getNpcSlot(slot)
		If t
			anyActive = True
			Bool isNow = _isNpcPresent(t)
			Bool wasPrv = _slot_present_prv[slot]
			If isNow
				config.moduleWidgetStateUpdate(iBars, t, slot)
				_reconcileNpcBars(slot)
			EndIf
			; Absent NPCs: icons stay frozen at their last-known state. The
			; "(away)" label suffix added by _ensureNpcLabel signals that the
			; values are stale. Simplest behavior — no zero pass, no
			; release/reload churn, cluster shape stays constant.
			; Label: rewrite (adds/removes "(away)" suffix) on every presence
			; transition or when the widget was destroyed (e.g. by font/size
			; change while absent); otherwise the cheap visibility-only path.
			If config.getNpcLabelId(slot) < 0 || isNow != wasPrv
				_ensureNpcLabel(slot, t)
			Else
				_showNpcLabel(slot)
			EndIf
			_repositionNpcLabel(slot)
			_applyBarVisibilityToLabel(slot)
			_slot_present_prv[slot] = isNow
		EndIf
		slot += 1
	EndWhile
	; Always redraw when any slot is active — picks up bar position/shape/size
	; changes from iWant's own MCM (which mutates the bar array but doesn't
	; redraw on a schedule we control) within one tick.
	If anyActive
		iBars._drawAllBars()
	EndIf
EndFunction

; True when the actor exists, is loaded into 3D, alive, and not deleted —
; i.e. it makes sense to show their icons + name label on screen.
Bool Function _isNpcPresent(Actor a)
	Return a && a.Is3DLoaded() && !a.IsDead() && !a.IsDeleted()
EndFunction

;ON mcm updates
function reloadWidgets()
	If (!iBars || !iBars.isReady())
		WriteLog("iBars not ready. Reloading widgets failed", 2)
		Return
	endIf
	WriteLogAndPrintConsole("WidgetController: reloading widgets")
	config.moduleWidgetReload(iBars, PlayerRef, 0)
	_updateMeters()
	_ensurePresentPrv()
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		Actor t = config.getNpcSlot(slot)
		If t
			If !config.slw_stopped && hasBarsAPI()
				; Always reload — even for absent NPCs — so toggle changes
				; from MCM take effect for the slot's bars. _ensureNpcLabel
				; auto-suffixes "(away)" when the NPC isn't present.
				config.moduleWidgetReload(iBars, t, slot)
				_reconcileNpcBars(slot)
				_ensureNpcLabel(slot, t)
				_applyBarVisibilityToLabel(slot)
				_slot_present_prv[slot] = _isNpcPresent(t)
			Else
				; Mod stopped, or Status Bars older than 2.10: release the
				; slot's icons and tear down label. There, loaded NPC icons
				; would be
				; auto-placed into the player's bars with reconciliation
				; disabled (see hasBarsAPI), so leftovers in the
				; save are actively released here instead.
				config.moduleWidgetReload(iBars, None, slot)
				_destroyNpcLabel(slot)
				_slot_present_prv[slot] = False
			EndIf
		EndIf
		slot += 1
	EndWhile
	iBars._drawAllBars()
endFunction

function toggleUpdateWidgets()
	If (!iBars || !iBars.isReady())
		Return
	endIf
	config.moduleWidgetToggleUpdate(iBars, PlayerRef, 0)
	_updateMeters()
	; Below Status Bars 2.10 a toggle update would load NPC icons that can never
	; be reconciled into the slot's bars (see hasBarsAPI), so skip the NPC
	; loop; reloadWidgets releases any leftovers.
	If !hasBarsAPI()
		Return
	EndIf
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		Actor t = config.getNpcSlot(slot)
		If t
			config.moduleWidgetToggleUpdate(iBars, t, slot)
		EndIf
		slot += 1
	EndWhile
endFunction

; Called from slw_config when a hotkey-pick assigns a new NPC to a slot.
Function reloadNpcSlot(Int slot)
	If !iBars || !iBars.isReady() || config.slw_stopped || !hasBarsAPI()
		Return
	EndIf
	Actor t = config.getNpcSlot(slot)
	If !t
		Return
	EndIf
	_ensurePresentPrv()
	config.moduleWidgetReload(iBars, t, slot)
	_reconcileNpcBars(slot)
	iBars._drawAllBars()
	_ensureNpcLabel(slot, t)
	_applyBarVisibilityToLabel(slot)
	; Hotkey-pick targets the crosshair actor — always currently present.
	; Seed prv so OnUpdate doesn't see a spurious absent→present transition
	; on the next tick and double-reload.
	_slot_present_prv[slot] = True
EndFunction

; Called from slw_config when a slot is cleared. Modules see target=None and
; release their per-slot icons; the cleared slot is then skipped on OnUpdate.
; Destroys (not just hides) the label widget — setVisible(0) leaves the Flash
; widget alive and any later call to _showNpcLabel/_ensureNpcLabel can bring
; it back; destroy guarantees the slot is visually gone until reassigned.
Function releaseNpcSlot(Int slot)
	If !iBars || !iBars.isReady()
		Return
	EndIf
	_ensurePresentPrv()
	config.moduleWidgetReload(iBars, None, slot)
	_destroyNpcLabel(slot)
	_slot_present_prv[slot] = False
EndFunction

; Restore all NPC slots after a game load (Flash widgets don't survive saves).
Function _restoreNpcLabelsAndIcons()
	If !iBars || !iBars.isReady()
		Return
	EndIf
	_ensurePresentPrv()
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		; Flash widget IDs from a previous session are stale — reset.
		config.setNpcLabelId(slot, -1)
		Actor t = config.getNpcSlot(slot)
		If t && !config.slw_stopped && hasBarsAPI()
			; Always load icons — even for absent NPCs — so the slot's bars
			; show neutral state-0 icons (loadIcon defaults to status 0) and
			; the cluster keeps a consistent shape. _ensureNpcLabel adds the
			; "(away)" suffix when applicable.
			config.moduleWidgetReload(iBars, t, slot)
			_reconcileNpcBars(slot)
			_ensureNpcLabel(slot, t)
			_applyBarVisibilityToLabel(slot)
			_slot_present_prv[slot] = _isNpcPresent(t)
		EndIf
		slot += 1
	EndWhile
	iBars._drawAllBars()
EndFunction

Int Function getNpcLabelOffsetX(Int slot)
	If slot == 1
		Return npc1_labelOffsetX
	ElseIf slot == 2
		Return npc2_labelOffsetX
	ElseIf slot == 3
		Return npc3_labelOffsetX
	EndIf
	Return 0
EndFunction

Int Function getNpcLabelOffsetY(Int slot)
	If slot == 1
		Return npc1_labelOffsetY
	ElseIf slot == 2
		Return npc2_labelOffsetY
	ElseIf slot == 3
		Return npc3_labelOffsetY
	EndIf
	Return 0
EndFunction

Function setNpcLabelOffset(Int slot, Int x, Int y)
	If slot == 1
		npc1_labelOffsetX = x
		npc1_labelOffsetY = y
	ElseIf slot == 2
		npc2_labelOffsetX = x
		npc2_labelOffsetY = y
	ElseIf slot == 3
		npc3_labelOffsetX = x
		npc3_labelOffsetY = y
	EndIf
	; setPos has been seen to leave a ghost widget at the old position when
	; called on a stale ID (same issue _layoutNpcBars works around). Destroy
	; + recreate guarantees exactly one label at the new offset position.
	Actor t = config.getNpcSlot(slot)
	If t && !config.slw_stopped
		_destroyNpcLabel(slot)
		_ensureNpcLabel(slot, t)
	Else
		_repositionNpcLabel(slot)
	EndIf
EndFunction

; Final screen position = bar XY + per-slot offset. Bar XY may change when the
; user moves the bar in iWant MCM, so we recompute every time.
Function _repositionNpcLabel(Int slot)
	If !iBars || !iBars.iWidgets
		Return
	EndIf
	Int id = config.getNpcLabelId(slot)
	If id < 0
		Return
	EndIf
	Int bar = _getBarForSlot(slot)
	Int x = iBars._getBarX(bar) + _autoLabelOffsetX(bar) + getNpcLabelOffsetX(slot)
	Int y = iBars._getBarY(bar) + _autoLabelOffsetY(bar) + getNpcLabelOffsetY(slot)
	iBars.iWidgets.setPos(id, x, y)
EndFunction

Function _ensureNpcLabel(Int slot, Actor target)
	If !iBars || !iBars.iWidgets || !target
		Return
	EndIf
	; Guarding the single creation leaf keeps every MCM path (label offset,
	; custom text, font/size refresh, bar layout) from resurrecting labels
	; below Status Bars 2.10, where the NPC layer is disabled entirely.
	If !hasBarsAPI()
		Return
	EndIf
	Int id = config.getNpcLabelId(slot)
	; User-set custom text takes precedence over actor display name.
	String displayName = config.getNpcCustomLabel(slot)
	If displayName == ""
		displayName = target.GetDisplayName()
	EndIf
	; Slot stays assigned across cell transitions, but the NPC may not be in
	; the current cell. Suffix " (away)" so it's clear the slot is taken-but-
	; inactive rather than appearing as if Lydia is silently present.
	If !_isNpcPresent(target)
		displayName = displayName + " (away)"
	EndIf
	Int bar = _getBarForSlot(slot)
	Int x = iBars._getBarX(bar) + _autoLabelOffsetX(bar) + getNpcLabelOffsetX(slot)
	Int y = iBars._getBarY(bar) + _autoLabelOffsetY(bar) + getNpcLabelOffsetY(slot)
	If id < 0
		id = iBars.iWidgets.loadText(displayName, npcLabelFont, npcLabelSize, x, y, True)
		config.setNpcLabelId(slot, id)
	Else
		iBars.iWidgets.setText(id, displayName)
		iBars.iWidgets.setPos(id, x, y)
		iBars.iWidgets.setVisible(id, 1)
	EndIf
	iBars.iWidgets.setRGB(id, npcLabelR, npcLabelG, npcLabelB)
EndFunction

; Called from MCM after the user edits a slot's custom label so the on-screen
; widget reflects the new text immediately without waiting for a reload.
Function refreshNpcLabel(Int slot)
	Actor t = config.getNpcSlot(slot)
	If t && !config.slw_stopped
		_ensureNpcLabel(slot, t)
	EndIf
EndFunction

; Font/size are baked in at loadText time — destroy + recreate to apply changes.
Function _destroyNpcLabel(Int slot)
	If !iBars || !iBars.iWidgets
		Return
	EndIf
	Int id = config.getNpcLabelId(slot)
	If id >= 0
		iBars.iWidgets.destroy(id)
		config.setNpcLabelId(slot, -1)
	EndIf
EndFunction

; Called from MCM after the user changes font or size — destroys all label
; widgets and recreates them for any assigned slot. _ensureNpcLabel applies
; the "(away)" suffix when the NPC isn't currently in the cell.
Function refreshAllNpcLabelStyles()
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		_destroyNpcLabel(slot)
		Actor t = config.getNpcSlot(slot)
		If t && !config.slw_stopped
			_ensureNpcLabel(slot, t)
		EndIf
		slot += 1
	EndWhile
EndFunction

; Color changes don't require widget recreation — setRGB on the existing widget.
Function applyNpcLabelColors()
	If !iBars || !iBars.iWidgets
		Return
	EndIf
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		Int id = config.getNpcLabelId(slot)
		If id >= 0
			iBars.iWidgets.setRGB(id, npcLabelR, npcLabelG, npcLabelB)
		EndIf
		slot += 1
	EndWhile
EndFunction

Function setNpcLabelFont(String font)
	npcLabelFont = font
	refreshAllNpcLabelStyles()
EndFunction

Function setNpcLabelSize(Int size)
	npcLabelSize = size
	refreshAllNpcLabelStyles()
EndFunction

Function setNpcLabelColor(Int r, Int g, Int b)
	npcLabelR = r
	npcLabelG = g
	npcLabelB = b
	applyNpcLabelColors()
EndFunction

; Convenience wrappers for the MCM color picker, which works with a packed
; 0xRRGGBB Int instead of three separate components.
Int Function getNpcLabelColorPacked()
	Return npcLabelR * 65536 + npcLabelG * 256 + npcLabelB
EndFunction

Function setNpcLabelColorPacked(Int color)
	Int r = color / 65536
	Int g = (color - r * 65536) / 256
	Int b = color - r * 65536 - g * 256
	setNpcLabelColor(r, g, b)
EndFunction

; Base names of every icon a module can register for an NPC slot. Used to
; relocate icons into the slot's dedicated bar after registration. Allocated
; fresh on each call — 26-string allocation is cheap and avoids stale data
; if future updates add icon types (a cached array from a previous version
; would silently miss new entries).
String[] Function _getOwnedIconBaseNames()
	String[] names = new String[29]
	names[0] = "Arousal"
	names[1] = "Exposure"
	names[2] = "AP2Oral"
	names[3] = "AP2Anal"
	names[4] = "AP2Vaginal"
	names[5] = "FHUCum"
	names[6] = "FHUCumAnal"
	names[7] = "FHUCumVaginal"
	names[8] = "FHUCumOral"
	names[9] = "MMEMilk"
	names[10] = "MMELactacid"
	names[11] = "Parasites_SpiderEggs"
	names[12] = "Parasites_ChaurusWorm"
	names[13] = "Parasites_ChaurusWormVag"
	names[14] = "Pregnancy_Basic"
	names[15] = "Pregnancy_Trimester1"
	names[16] = "Pregnancy_Trimester2"
	names[17] = "Pregnancy_Trimester3"
	names[18] = "Pregnancy_CumInflation"
	names[19] = "Pregnancy_Ovulation"
	names[20] = "Pregnancy_Fetus"
	names[21] = "Pregnancy_Eggs"
	names[22] = "Pregnancy_Spider_Eggs"
	names[23] = "Pregnancy_Chaurus_Eggs"
	names[24] = "Pregnancy_Dwemer_Spheres"
	names[25] = "Pregnancy_Gems"
	; 3.0.0: the icons that also track NPCs
	names[26] = "Dirtiness"
	names[27] = "Wetness"
	names[28] = "BF_BabyHealth"
	Return names
EndFunction

; Move a single icon (by name) into one of the slot's two dedicated bars if
; it isn't already in either. Primary bar first; secondary as overflow.
; Returns True if the icon was actually moved so the caller can trigger
; a single _drawAllBars to update Flash positions.
Bool Function _placeOneIconInSlotBar(String iconName, Int slot)
	If !hasBarsAPI()
		Return False
	EndIf
	Int primaryBar = _getBarForSlot(slot)
	Int secondaryBar = _getSecondaryBarForSlot(slot)
	Int id = iBars._getIconID(slwGetModName(), iconName)
	If id == -1
		Return False
	EndIf
	Int currentBar = iBars._findBarOfIcon(id)
	; Already in one of the slot's bars — nothing to do.
	If currentBar == primaryBar || currentBar == secondaryBar
		Return False
	EndIf
	; Pick a destination — primary first, secondary if primary is full.
	; If both are full, leave the icon where it is rather than orphan it.
	Int targetBar = primaryBar
	Int newPos = iBars._nextFreeBarPosition(targetBar)
	If newPos < 0
		targetBar = secondaryBar
		newPos = iBars._nextFreeBarPosition(targetBar)
		If newPos < 0
			Return False
		EndIf
	EndIf
	; Clear old position so iWant's auto-scrub frees the slot
	If currentBar >= 0
		Int p = 0
		Bool found = False
		While p < 10 && !found
			If iBars._getBarIcon(currentBar, p) == id
				iBars._setBarIcon(currentBar, p, -1)
				found = True
			EndIf
			p += 1
		EndWhile
	EndIf
	iBars._setBarIcon(targetBar, newPos, id)
	Return True
EndFunction

; Walk every owned base name and ensure the slot-suffixed icon, if registered,
; sits in the slot's dedicated bar. _setBarIcon only updates iWant's internal
; array — Flash widgets stay at their old positions until _drawAllBars runs.
; Callers must invoke iBars._drawAllBars() themselves after a batch of
; reconciles so icons appear in the right place on the same tick.
Function _reconcileNpcBars(Int slot)
	If !iBars || !iBars.isReady() || slot <= 0 || !hasBarsAPI()
		Return
	EndIf
	String[] bases = _getOwnedIconBaseNames()
	Int i = 0
	While i < bases.Length
		String name = getIconNameForSlot(bases[i], slot)
		_placeOneIconInSlotBar(name, slot)
		i += 1
	EndWhile
EndFunction

; Lay out NPC bars relative to the current group anchor. Preserves the user's
; per-slot label fine-tune offsets. Called when the user nudges the group
; X/Y sliders so dragging doesn't wipe their label customizations.
Function _layoutNpcBars()
	If !iBars || !iBars.isReady()
		Return
	EndIf
	; Per-NPC vertical stride — user-tunable from MCM for cluster compactness.
	Int stride = npcVerticalSpacing
	Int slot = 1
	While slot <= 3
		Int primary = _getBarForSlot(slot)
		Int secondary = _getSecondaryBarForSlot(slot)
		; Slot 1 anchors at groupY (bottom of cluster), higher slots stack upward.
		; Empty slots produce no visible bars, so if only NPC1 is assigned the
		; cluster is just one bar at the anchor with nothing wasted above it.
		Int baseY = npcGroupY - (slot - 1) * stride
		iBars._setBarX(primary, npcGroupX)
		iBars._setBarY(primary, baseY)
		iBars._setBarType(primary, NPC_DEFAULT_SHAPE)
		iBars._setBarIconSize(primary, NPC_DEFAULT_ICON_SIZE)
		iBars._setBarX(secondary, npcGroupX)
		iBars._setBarY(secondary, baseY + NPC_BAR_VSPACING)
		iBars._setBarType(secondary, NPC_DEFAULT_SHAPE)
		iBars._setBarIconSize(secondary, NPC_DEFAULT_ICON_SIZE)
		; Destroy + recreate the label after a bar move. setPos has been seen
		; to leave a ghost widget at the old position when called on a stale
		; ID — recreating guarantees exactly one label at the new bar anchor.
		_destroyNpcLabel(slot)
		Actor t = config.getNpcSlot(slot)
		If t && !config.slw_stopped
			_ensureNpcLabel(slot, t)
		EndIf
		slot += 1
	EndWhile
	; _setBarIconSize only mutates the array — without _resizeAllBars existing
	; icons keep their old visual size until each one's next setIconStatus call
	; (which fires only on state change), causing gradual uneven resizing.
	iBars._resizeAllBars()
	; _setBarX/Y/Type/IconSize don't redraw — without _drawAllBars Flash widgets
	; stay at their last rendered positions.
	iBars._drawAllBars()
EndFunction

; "Reset NPC bar layout" MCM button. Full reset: snaps the group anchor back
; to the bottom-right of iWant's 1280x720 stage, re-applies bar positions,
; and zeroes per-slot label fine-tune offsets so labels return to the pure
; auto position.
Function applyDefaultNpcBarLayout()
	npcGroupX = 1100
	npcGroupY = 600
	npcVerticalSpacing = 105
	_layoutNpcBars()
	Int slot = 1
	While slot <= 3
		setNpcLabelOffset(slot, 0, 0)
		slot += 1
	EndWhile
EndFunction

Function _hideNpcLabel(Int slot)
	If !iBars || !iBars.iWidgets
		Return
	EndIf
	Int id = config.getNpcLabelId(slot)
	If id >= 0
		iBars.iWidgets.setVisible(id, 0)
	EndIf
EndFunction

; Lightweight visibility toggle used on the OnUpdate hot path. Does NOT
; recreate or rewrite the widget — assumes _ensureNpcLabel ran earlier
; (slot assign / game-load restore / reloadWidgets).
Function _showNpcLabel(Int slot)
	If !iBars || !iBars.iWidgets
		Return
	EndIf
	Int id = config.getNpcLabelId(slot)
	If id >= 0
		iBars.iWidgets.setVisible(id, 1)
	EndIf
EndFunction

; If the user toggled the slot's primary bar off via iWant's hide hotkey
; (press-to-toggle or hold-to-show) OR the bar is in autohide mode and
; has timed out since the last status change, the icons disappear — we
; mirror that on the label so it doesn't orphan above empty space.
; Idempotent: cheap setVisible toggle, no widget recreation. Called
; after the regular show/ensure path so bar state always wins.
Function _applyBarVisibilityToLabel(Int slot)
	If !iBars || !iBars.iWidgets
		Return
	EndIf
	; Status Bars older than 2.10 has neither accessor, so leave the
	; label as the presence logic set it.
	If !hasBarsAPI()
		Return
	EndIf
	Int bar = _getBarForSlot(slot)
	If !iBars.getBarVisible(bar) || _isBarAutoHidden(bar)
		_hideNpcLabel(slot)
	EndIf
EndFunction

; iWant's autohide doesn't flip statusBarVisible — it fades widget alpha
; via Scaleform transitions. We detect the faded state by comparing the
; bar's last-change timestamp (Status Bars 2.10) against autoHideTime.
; +0.5s grace for the fade-out transition (iWant fades over 15 frames =
; 0.5s at 30fps).
Bool Function _isBarAutoHidden(Int bar)
	If !iBars._getBarShowOnChange(bar)
		Return False
	EndIf
	Float t = iBars.getBarLastChangeTime(bar)
	If t <= 0.0
		Return True
	EndIf
	Float now = Utility.GetCurrentRealTime()
	; GetCurrentRealTime restarts near 0 each launch but iWant keeps the
	; timestamp in the save, so a value ahead of the clock is last session's.
	; Nothing can be measured from it until the bar next changes.
	If t > now
		Return False
	EndIf
	Float window = iBars._getBarAutoHideTime(bar) As Float
	Return now > t + window + 0.5
EndFunction

;Debug function to arrange iwant status bars icons better - fill empty spaces in the main bar to load/release toggles in a secondary bar
Function loadEmptyIcon()
	If !controller_initialised || !iBars || !iBars.isReady()
		WriteLogAndPrintConsole("iBars not loaded yet. Loading empty icon failed", 2)
		Return
	endIf

	String[] s = new String[1]
	String[] d = new String[1]
	Int[] r = new Int[1]
	Int[] g = new Int[1]
	Int[] b = new Int[1]
	Int[] a = new Int[1]
	
	s[0] = "placeholder.dds"
	d[0] = EMPTY_STATE + _emptyIconIndex
	r[0] = 255
	g[0] = 255
	b[0] = 255
	a[0] = 0
	
	; This will fail silently if the icon is already loaded
	int res = iBars.loadIcon(slwGetModName(), EMPTY_STATE + _emptyIconIndex, d, s, r, g, b, a)
	if res >= 0
		_emptyIconIndex += 1
	endif
	
endFunction

; ---------------------------------------------------------------------------
; Meter stack: SLO VE willpower, SLA arousal, Fill Her Up pools, Apropos2
; wear and tear
; ---------------------------------------------------------------------------
; Player only. One iWant Widgets meter per value with an icon to its left: the
; brain for willpower, otherwise that value's Status Bars icon at the stage the
; icon in the bar shows (so a custom icon pack reaches the stack too). Raw
; Flash widgets like the NPC name labels, not Status Bars icons: the ids die
; with every game load (OniWantStatusBarsReady forgets them) and positions are
; widget CENTERS. An iWant meter is 334x30 on the stage at 100%, in the Flash
; widget and in the Prisma renderer alike; it is scaled with setZoom (iWant's
; docs: do not setSize a meter), the icon with setSize.
;
; (metersX, metersY) is the CENTER of the whole stack on the 1280x720 stage;
; the default sits at the right edge, half way down. Only meters that are
; switched on and whose mod is loaded get a row, top to bottom in meter number
; order (slw_config.getMeterPresetKey), and a row keeps its place while its meter is
; faded out, so each meter is always found in the same spot.
;
; Meter 0, willpower, keeps the rule it had as a bar of its own: up during a
; scene while willpower is below 100, whatever the display mode. The others
; follow metersAlwaysShow.
Int Property metersX = 1150 Auto Hidden
Int Property metersY = 360 Auto Hidden
Int Property metersScale = 60 Auto Hidden
; False: a meter comes up when its value changes and fades out
; metersHoldSeconds later. True: every meter stays up.
Bool Property metersAlwaysShow = False Auto Hidden
Int Property metersHoldSeconds = 10 Auto Hidden

Int METER_W = 334
; icon edge at 100%: a little taller than the 30 px meter
Int METER_ICON = 48
Int METER_ICON_GAP = 6
; row pitch at 100%: the icon plus a gap
Int METER_ROW_PITCH = 56
; the fade Status Bars uses for its icons, 15 frames at 30 fps
Int METER_FADE_FRAMES = 15

Int[] _meterBarId
Int[] _meterIconId
; stage of the icon on screen, -1 = no icon widget
Int[] _meterIconStage
Int[] _meterIconX
Int[] _meterIconY
; percent the meter widget last drew, -1 = nothing yet
Int[] _meterDrawn
; The value a meter last counted a change at, -1 = never. Unlike the ids it
; survives a game load: a meter fades in on a CHANGE, and the first read after
; a load is not one (the value is still the one the save holds).
Int[] _meterSeen
Float[] _meterChangedAt
Bool[] _meterShown
; one bit per meter that has a row on screen, 0 = no stack
Int _metersBuiltMask = 0
Bool _metersRebuild = False
Bool _metersPreviewPending = False
Bool _metersBusy = False
Float _metersPreviewUntil = 0.0
; Bumped whenever the stack's widgets are dropped behind a running pass's back
; (game load, mod disabled). The pass checks it after every widget it creates
; and stops when it moved, so it can neither store an id into the new stack
; nor leave a widget on screen. A pass the save carried over (Papyrus resumes
; saved stacks) is the same case.
Int _metersGen = 0
; In fade mode a meter comes up when its value moves this many points from
; where it last did, or its icon changes stage. Every smaller step would keep
; a slowly draining value (FHU absorption, decaying arousal) up for good.
Int METER_CHANGE_MIN = 5

; The willpower bar's own place and state from 2.2.6, before it became the
; stack's top row. Unused; kept so the saves that hold them load clean.
Int Property willpowerBarX = 640 Auto Hidden
Int Property willpowerBarY = 640 Auto Hidden
Int Property willpowerBarScale = 60 Auto Hidden
Int WILLPOWER_METER_W = 334
Int WILLPOWER_ICON = 48
Int WILLPOWER_ICON_GAP = 6
Int _willpowerMeterId = -1
Int _willpowerIconId = -1
Int _willpowerPrv = -1
Bool _willpowerShown = False
Float _willpowerPreviewUntil = 0.0

Function _ensureMeterArrays()
	If !_meterBarId
		_meterBarId = Utility.CreateIntArray(9, -1)
	EndIf
	If !_meterIconId
		_meterIconId = Utility.CreateIntArray(9, -1)
	EndIf
	If !_meterIconStage
		_meterIconStage = Utility.CreateIntArray(9, -1)
	EndIf
	If !_meterIconX
		_meterIconX = Utility.CreateIntArray(9, 0)
	EndIf
	If !_meterIconY
		_meterIconY = Utility.CreateIntArray(9, 0)
	EndIf
	If !_meterDrawn
		_meterDrawn = Utility.CreateIntArray(9, -1)
	EndIf
	If !_meterSeen
		_meterSeen = Utility.CreateIntArray(9, -1)
	EndIf
	If !_meterChangedAt
		_meterChangedAt = Utility.CreateFloatArray(9, 0.0)
	EndIf
	If !_meterShown
		_meterShown = Utility.CreateBoolArray(9, False)
	EndIf
EndFunction

; The ids belong to a Flash stage that is gone (game load). Drop them without
; touching the stage: the same numbers may be another mod's widgets by now.
; _meterSeen stays.
Function _forgetMeters()
	_ensureMeterArrays()
	_metersGen += 1
	Int i = 0
	While i < 9
		_meterBarId[i] = -1
		_meterIconId[i] = -1
		_meterIconStage[i] = -1
		_meterDrawn[i] = -1
		_meterChangedAt[i] = 0.0
		_meterShown[i] = False
		i += 1
	EndWhile
	_metersBuiltMask = 0
	_metersRebuild = False
	_metersPreviewPending = False
	_metersPreviewUntil = 0.0
	; a pass that held it stops at its next check of _metersGen
	_metersBusy = False
EndFunction

; The mod is being disabled: everything goes, including what a running pass is
; still building, which stops at its next check of _metersGen.
Function _stopMeters()
	_metersGen += 1
	_destroyMeters()
	_metersRebuild = False
	_metersPreviewPending = False
	_metersBusy = False
EndFunction

Function _destroyMeters()
	_ensureMeterArrays()
	Bool live = iBars && iBars.iWidgets && iBars.isReady()
	Int i = 0
	While i < 9
		If live
			If _meterBarId[i] >= 0
				iBars.iWidgets.destroy(_meterBarId[i])
			EndIf
			If _meterIconId[i] >= 0
				iBars.iWidgets.destroy(_meterIconId[i])
			EndIf
		EndIf
		_meterBarId[i] = -1
		_meterIconId[i] = -1
		_meterIconStage[i] = -1
		_meterDrawn[i] = -1
		_meterShown[i] = False
		i += 1
	EndWhile
	_metersBuiltMask = 0
EndFunction

; MCM: the stack changed (a meter switched, a new place or size). It is
; rebuilt, not moved (setPos has left ghosts before, see setNpcLabelOffset),
; and then shown whole for half a minute, willpower included, since in fade
; mode or outside a scene there would otherwise be nothing to look at.
Function requestMetersRebuild()
	_metersRebuild = True
	_metersPreviewPending = True
EndFunction

Function setMetersLayout(Int x, Int y, Int scale)
	metersX = x
	metersY = y
	metersScale = scale
	requestMetersRebuild()
EndFunction

Function _updateMeters()
	If !iBars || !iBars.iWidgets || !iBars.isReady()
		Return
	EndIf
	; One pass at a time: the update tick and the MCM both get here, and every
	; widget call lets the other thread in. Two passes building at once would
	; leave widgets on screen that nothing has an id for. The pass that finds
	; the stack busy asks for another soon instead of waiting out an interval.
	If _metersBusy
		_refreshSoon(REFRESH_SOON)
		Return
	EndIf
	_metersBusy = True
	Int gen = _metersGen
	_ensureMeterArrays()
	If !PlayerRef
		PlayerRef = Game.GetPlayer()
	EndIf
	Bool[] wanted = new Bool[9]
	Int mask = _wantedMeters(wanted)
	If gen != _metersGen
		Return
	EndIf
	If mask != _metersBuiltMask || _metersRebuild
		_metersRebuild = False
		_destroyMeters()
		If mask != 0 && !_buildMeters(wanted, gen)
			Return
		EndIf
		_metersBuiltMask = mask
	EndIf
	; The preview starts outside menus only, or a change made in the MCM (a
	; preset loaded there too) would spend its half minute behind the menu.
	; Updates wait while a menu is open, so the asked-for pass is the first one
	; after it closes.
	If _metersPreviewPending
		If Utility.IsInMenuMode()
			_refreshSoon(REFRESH_SOON)
		Else
			_metersPreviewPending = False
			_metersPreviewUntil = Utility.GetCurrentRealTime() + 30.0
		EndIf
	EndIf
	If mask != 0 && !_drawMeters(wanted, gen)
		Return
	EndIf
	_metersBusy = False
EndFunction

; Which meters get a row: switched on and their mod loaded. Fills wanted and
; returns the same set as a bit mask, so a change of the set is one compare.
Int Function _wantedMeters(Bool[] wanted)
	If config.slw_stopped
		Return 0
	EndIf
	Bool[] switches = config.getMeterSwitches()
	Bool sloveLoaded = isSloveReady()
	Bool slaLoaded = config.module_sla.isInterfaceActive()
	Bool fhuLoaded = config.module_fhu.isInterfaceActive()
	Bool wtLoaded = config.module_apropos_two.isInterfaceActive()
	Int mask = 0
	Int bit = 1
	Int i = 0
	While i < 9
		Bool loaded = wtLoaded
		If i == 0
			loaded = sloveLoaded
		ElseIf i == 1
			loaded = slaLoaded
		ElseIf i <= 5
			loaded = fhuLoaded
		EndIf
		If loaded && switches[i]
			wanted[i] = True
			mask += bit
		EndIf
		bit *= 2
		i += 1
	EndWhile
	Return mask
EndFunction

; Values 0-100 of the wanted meters. Willpower comes from the StorageUtil keys
; SLO VE documents for other mods (slw_interface_slove), so nothing here binds
; to SLO VE's scripts. Apropos2 only shares the wear and tear stage (0-8), so
; those meters move in eighths.
Int[] Function _readMeters(Bool[] wanted)
	Int[] v = Utility.CreateIntArray(9, 0)
	If wanted[0]
		v[0] = slw_interface_slove.getSloveWillpower(PlayerRef)
	EndIf
	If wanted[1]
		v[1] = config.module_sla.getArousalPercentFor(PlayerRef)
	EndIf
	Int i = 2
	While i <= 5
		If wanted[i]
			v[i] = config.module_fhu.getCumPercentFor(PlayerRef, i - 2)
		EndIf
		i += 1
	EndWhile
	If wanted[6] || wanted[7] || wanted[8]
		Int[] wear = config.module_apropos_two.getWearStatesFor(PlayerRef)
		v[6] = wear[0] * 100 / 8
		v[7] = wear[1] * 100 / 8
		v[8] = wear[2] * 100 / 8
	EndIf
	i = 0
	While i < 9
		If v[i] < 0
			v[i] = 0
		ElseIf v[i] > 100
			v[i] = 100
		EndIf
		i += 1
	EndWhile
	Return v
EndFunction

; One row per wanted meter, created faded out; _drawMeters brings them up.
; The icons come later, once the value and so the stage is known. False when
; _metersGen moved under it.
Bool Function _buildMeters(Bool[] wanted, Int gen)
	iWant_Widgets w = iBars.iWidgets
	Int rows = 0
	Int i = 0
	While i < 9
		If wanted[i]
			rows += 1
		EndIf
		i += 1
	EndWhile
	Int pitch = METER_ROW_PITCH * metersScale / 100
	Int iconSize = METER_ICON * metersScale / 100
	Int meterWidth = METER_W * metersScale / 100
	Int iconX = metersX - meterWidth / 2 - iconSize / 2 - METER_ICON_GAP
	Int y = metersY - (rows - 1) * pitch / 2
	i = 0
	While i < 9
		If wanted[i]
			Int id = w.loadMeter(metersX, y, False)
			If gen != _metersGen
				w.destroy(id)
				Return False
			EndIf
			_meterBarId[i] = id
			_meterIconX[i] = iconX
			_meterIconY[i] = y
			w.setZoom(id, metersScale, metersScale)
			_colorMeter(i, id)
			w.setTransparency(id, 0)
			w.setVisible(id, 1)
			y += pitch
		EndIf
		i += 1
	EndWhile
	Return True
EndFunction

; False when _metersGen moved under it.
Bool Function _drawMeters(Bool[] wanted, Int gen)
	Int[] v = _readMeters(wanted)
	Float now = Utility.GetCurrentRealTime()
	Bool preview = now < _metersPreviewUntil
	; willpower drains only in a scene, which is when its row is up
	Bool inScene = wanted[0] && slw_interface_slove.isInScene(PlayerRef)
	Int i = 0
	While i < 9
		If gen != _metersGen
			Return False
		EndIf
		If wanted[i] && _meterBarId[i] >= 0
			Int pct = v[i]
			If pct != _meterDrawn[i]
				iBars.iWidgets.setMeterPercent(_meterBarId[i], pct)
				; willpower broken: the bar flashes on the way to 0
				If i == 0 && pct <= 0 && _meterDrawn[i] > 0
					iBars.iWidgets.doMeterFlash(_meterBarId[i])
				EndIf
				_meterDrawn[i] = pct
			EndIf
			Int stage = _meterStage(i, pct)
			If stage != _meterIconStage[i] && !_loadMeterIcon(i, stage, gen)
				Return False
			EndIf
			; A meter never read before counts as changed, so a fresh install
			; in fade mode shows its meters once instead of nothing at all.
			Int seen = _meterSeen[i]
			Int moved = pct - seen
			If moved < 0
				moved = -moved
			EndIf
			If seen < 0 || moved >= METER_CHANGE_MIN || stage != _meterStage(i, seen)
				_meterChangedAt[i] = now
				_meterSeen[i] = pct
			ElseIf _meterChangedAt[i] > now
				; from the last session: the real-time clock restarts with the game
				_meterChangedAt[i] = 0.0
			EndIf
			Bool show = preview
			If i == 0
				show = show || (inScene && pct < 100)
			Else
				show = show || metersAlwaysShow || (_meterChangedAt[i] > 0.0 && now < _meterChangedAt[i] + metersHoldSeconds)
			EndIf
			If show != _meterShown[i]
				_fadeMeter(i, show)
			EndIf
		EndIf
		i += 1
	EndWhile
	Return True
EndFunction

Function _fadeMeter(Int meter, Bool show)
	Int alpha = 0
	If show
		alpha = 100
	EndIf
	iBars.iWidgets.doTransition(_meterBarId[meter], alpha, METER_FADE_FRAMES)
	If _meterIconId[meter] >= 0
		iBars.iWidgets.doTransition(_meterIconId[meter], alpha, METER_FADE_FRAMES)
	EndIf
	_meterShown[meter] = show
EndFunction

; A library widget's art is fixed at load, so a new stage means a new widget;
; stages change rarely. False when _metersGen moved under it.
Bool Function _loadMeterIcon(Int meter, Int stage, Int gen)
	iWant_Widgets w = iBars.iWidgets
	If _meterIconId[meter] >= 0
		w.destroy(_meterIconId[meter])
		_meterIconId[meter] = -1
	EndIf
	Int iconSize = METER_ICON * metersScale / 100
	Int id = w.loadLibraryWidget(_meterIconPath(meter, stage), _meterIconX[meter], _meterIconY[meter], False)
	If gen != _metersGen
		w.destroy(id)
		Return False
	EndIf
	_meterIconId[meter] = id
	_meterIconStage[meter] = stage
	w.setSize(id, iconSize, iconSize)
	_tintMeterIcon(meter, stage, id)
	If _meterShown[meter]
		w.setTransparency(id, 100)
	Else
		w.setTransparency(id, 0)
	EndIf
	w.setVisible(id, 1)
	Return True
EndFunction

; The stage the meter's icon shows in the Status Bars for the same value.
; Willpower has no status icon: its two stages are broken (0) and not.
Int Function _meterStage(Int meter, Int pct)
	If meter == 0
		If pct <= 0
			Return 0
		EndIf
		Return 1
	ElseIf meter == 1
		Return percentToState9NotStrict(pct)
	ElseIf meter <= 5
		Return percentToState9(pct)
	EndIf
	; back from eighths, rounded: 12 -> 1, 87 -> 7
	Return (pct * 8 + 50) / 100
EndFunction

String Function _meterIconPath(Int meter, Int stage)
	If meter == 0
		; drawn by build_willpower_icon.py
		Return "slove/willpower"
	EndIf
	String base = "apropos2/oral/oral"
	If meter == 1
		base = "sla/arousal/aroused"
	ElseIf meter == 2
		base = "fhu/total/cum"
	ElseIf meter == 3
		base = "fhu/vaginal/cum"
	ElseIf meter == 4
		base = "fhu/anal/cum"
	ElseIf meter == 5
		base = "fhu/oral/cum"
	ElseIf meter == 6
		base = "apropos2/vaginal/vag"
	ElseIf meter == 7
		base = "apropos2/anal/ass"
	EndIf
	Return base + stage
EndFunction

; Willpower purple; the others take the colors of their icons' stages:
; arousal pink, cum cream, wear and tear red.
Function _colorMeter(Int meter, Int id)
	If meter == 0
		iBars.iWidgets.setMeterRGB(id, 200, 164, 255, 86, 50, 164, 255, 255, 255)
	ElseIf meter == 1
		iBars.iWidgets.setMeterRGB(id, 255, 112, 192, 128, 28, 88, 255, 255, 255)
	ElseIf meter <= 5
		iBars.iWidgets.setMeterRGB(id, 251, 245, 233, 128, 118, 100, 255, 255, 255)
	Else
		iBars.iWidgets.setMeterRGB(id, 255, 72, 72, 128, 16, 16, 255, 255, 255)
	EndIf
EndFunction

Function _tintMeterIcon(Int meter, Int stage, Int id)
	If meter == 0
		If stage == 0
			; broken
			iBars.iWidgets.setRGB(id, 255, 96, 96)
		Else
			iBars.iWidgets.setRGB(id, 255, 255, 255)
		EndIf
	ElseIf meter == 1
		iBars.iWidgets.setRGB(id, 255, 140, 202)
	ElseIf meter <= 5
		iBars.iWidgets.setRGB(id, 251, 245, 233)
	Else
		iBars.iWidgets.setRGB(id, 255, 114, 114)
	EndIf
EndFunction

; ---------------------------------------------------------------------------
; Position editor (SLWidgetsMenu.dll, through slw_bridge)
;
; The DLL reads the whole layout as ONE string and writes through the setters
; the MCM uses, so iWant's arrays are only ever touched from the scripts.
; Player bars 0-3 go straight to iWant, as iWant's own MCM does. The NPC bars
; and the meter stack belong to their anchors (_layoutNpcBars, setMetersLayout),
; which is why the DLL moves those as a group and never bar by bar.
;
; Layout string: "v=2|b0=x,y,type,size,visible|...|b9=...
;   |npc=x,y,stride|n1=name|n2=name|n3=name|meters=x,y,scale,rows,always"
; The bars' icons come on their own (editorBarIcons), read only while the
; page shows them: they cost a call into iWant per seat.
; The version is the DLL's Layout::kVersion: bump both when a field changes.
; ---------------------------------------------------------------------------

String Function editorLayout()
	If !iBars || !iBars.isReady()
		Return ""
	EndIf
	String s = "v=2"
	Int bar = 0
	While bar < iBars.TOTAL_STATUS_BARS
		s += "|b" + bar + "=" + iBars._getBarX(bar) + "," + iBars._getBarY(bar) + "," + iBars._getBarType(bar) + "," + iBars._getBarIconSize(bar) + "," + _editorBarVisible(bar)
		bar += 1
	EndWhile
	s += "|npc=" + npcGroupX + "," + npcGroupY + "," + npcVerticalSpacing
	s += "|n1=" + _editorSlotName(1) + "|n2=" + _editorSlotName(2) + "|n3=" + _editorSlotName(3)
	s += "|meters=" + metersX + "," + metersY + "," + metersScale + "," + _editorMeterRows() + "," + (metersAlwaysShow As Int)
	Return s
EndFunction

; The icons of the player bars: "v=1|ic=bar,seat,icon id,label|..."
String Function editorBarIcons()
	If !iBars || !iBars.isReady()
		Return ""
	EndIf
	Return "v=1" + _editorBarIcons()
EndFunction

; The icons seated in the player bars, labelled as iWant labels them ("name -
; mod"). A released icon keeps its seat until the next draw scrubs it, and its
; label already reads "No Icon - No Icon", so it is left out.
String Function _editorBarIcons()
	String s = ""
	String[] labels = iBars.iconLabel
	Int perBar = iBars.ICONS_PER_STATUS_BAR
	Int bar = 0
	While bar < 4
		Int seat = 0
		While seat < perBar
			Int icon = iBars._getBarIcon(bar, seat)
			If icon >= 0 && labels && icon < labels.Length
				String label = labels[icon]
				If label != "" && label != "No Icon - No Icon"
					s += "|ic=" + bar + "," + seat + "," + icon + "," + label
				EndIf
			EndIf
			seat += 1
		EndWhile
		bar += 1
	EndWhile
	Return s
EndFunction

Int Function _editorBarVisible(Int bar)
	If hasBarsAPI()
		Return iBars.getBarVisible(bar) As Int
	EndIf
	Return 1
EndFunction

String Function _editorSlotName(Int slot)
	Actor a = config.getNpcSlot(slot)
	If a
		Return a.GetDisplayName()
	EndIf
	Return ""
EndFunction

Int Function _editorMeterRows()
	Bool[] wanted = new Bool[9]
	Int mask = _wantedMeters(wanted)
	Int rows = 0
	Int i = 0
	While i < 9
		If wanted[i]
			rows += 1
		EndIf
		i += 1
	EndWhile
	Return rows
EndFunction

Function editorSetBarPos(Int bar, Int x, Int y)
	If !iBars || !iBars.isReady() || bar < 0 || bar > 3
		Return
	EndIf
	iBars._setBarX(bar, x)
	iBars._setBarY(bar, y)
	iBars._drawBar(bar)
EndFunction

; Icon moves in the player bars, as iWant's own MCM makes them. iWant puts an
; icon back in the first free seat whenever it is loaded again (a switch off
; and on, a preset, enabling the mod, an icon that comes and goes with its
; state), so a move lasts until then; the user accepted that. Each move acts
; only while the icon still sits where the page saw it, so a list that went
; stale cannot move another icon. _setBarIcon clears an icon from every other
; seat before it seats it, and sizes it to its new bar.

; Swaps the icon with the next icon toward dir (-1 earlier, 1 later) in its
; bar; empty seats between are skipped, as the bar draws without them.
Function editorMoveIconInBar(Int bar, Int seat, Int icon, Int dir)
	If !iBars || !iBars.isReady() || bar < 0 || bar > 3 || icon < 0 || (dir != -1 && dir != 1)
		Return
	EndIf
	Int perBar = iBars.ICONS_PER_STATUS_BAR
	If seat < 0 || seat >= perBar || iBars._getBarIcon(bar, seat) != icon
		Return
	EndIf
	; the next seat the page lists: _editorBarIcons leaves out the blank icon
	; and released ones (label "No Icon - No Icon"), so they are skipped here too
	String[] labels = iBars.iconLabel
	Int other = -1
	Int t = seat + dir
	While t >= 0 && t < perBar && other < 0
		Int candidate = iBars._getBarIcon(bar, t)
		If candidate >= 0 && labels && candidate < labels.Length && labels[candidate] != "" && labels[candidate] != "No Icon - No Icon"
			other = candidate
		Else
			t += dir
		EndIf
	EndWhile
	If other < 0
		Return
	EndIf
	iBars._setBarIcon(bar, seat, other)
	iBars._setBarIcon(bar, t, icon)
	iBars._drawBar(bar)
EndFunction

; Moves the icon to the first free seat of another player bar
Function editorMoveIconToBar(Int bar, Int seat, Int icon, Int target)
	If !iBars || !iBars.isReady() || bar < 0 || bar > 3 || target < 0 || target > 3 || target == bar || icon < 0
		Return
	EndIf
	If seat < 0 || seat >= iBars.ICONS_PER_STATUS_BAR || iBars._getBarIcon(bar, seat) != icon
		Return
	EndIf
	Int free = iBars._nextFreeBarPosition(target)
	If free < 0
		Return
	EndIf
	iBars._setBarIcon(target, free, icon)
	iBars._drawBar(bar)
	iBars._drawBar(target)
EndFunction

Function editorSetBarSize(Int bar, Int size)
	If !iBars || !iBars.isReady() || bar < 0 || bar > 3
		Return
	EndIf
	iBars._setBarIconSize(bar, size)
	iBars._resizeBar(bar)
	iBars._drawBar(bar)
EndFunction

; iWant's bar types, as its MCM applies them (the resize covers an orbit's
; double-sized center icon)
Function editorSetBarType(Int bar, Int type)
	If !iBars || !iBars.isReady() || bar < 0 || bar > 3
		Return
	EndIf
	iBars._setBarType(bar, type)
	iBars._resizeBar(bar)
	iBars._drawBar(bar)
EndFunction

Function editorSetNpcGroup(Int x, Int y)
	setNpcGroupPos(x, y)
	_layoutNpcBars()
EndFunction

Function editorSetNpcSpacing(Int v)
	setNpcVerticalSpacing(v)
EndFunction

; The stack rebuilds on the next pass; ask for one now rather than waiting out
; the interval, so the move shows while the editor is still open.
Function editorSetMeters(Int x, Int y, Int scale)
	setMetersLayout(x, y, scale)
	_refreshSoon(0.2)
EndFunction

; A switch flipped on the SKSE menu's Toggles page. The MCM runs
; toggleUpdateWidgets once when it closes; the SKSE menu has no close the
; scripts can see, so each switch owes the pass and the next update pass
; serves it, which never runs two at once however fast the switches are
; clicked.
Bool _togglePassOwed = False

Function requestTogglePass()
	_togglePassOwed = True
	_refreshSoon(0.2)
EndFunction

; A player bar from a settings preset: all four values at once, one redraw
Function presetSetBar(Int bar, Int x, Int y, Int size, Int type)
	If !iBars || !iBars.isReady() || bar < 0 || bar > 3
		Return
	EndIf
	iBars._setBarX(bar, x)
	iBars._setBarY(bar, y)
	iBars._setBarIconSize(bar, size)
	iBars._setBarType(bar, type)
	iBars._resizeBar(bar)
	iBars._drawBar(bar)
EndFunction

; Presets loaded or saved on the SKSE menu's Presets page. Loading one
; releases and registers every icon again; the MCM does that in menu mode,
; with the update loop waiting, but the SKSE menu does not stop the loop.
; So a load is owed and the next update pass serves it, never alongside
; another pass, and a save waits its turn behind it rather than reading a
; half-applied load. While the mod is switched off no pass runs, and none
; can collide either.
String _presetOwed = ""
String _presetSaveOwed = ""

Function requestPresetLoad(String presetName)
	If config.slw_stopped
		config.applySettingsPreset(presetName)
		Return
	EndIf
	_presetOwed = presetName
	_refreshSoon(0.2)
EndFunction

Function requestPresetSave(String presetName)
	If config.slw_stopped
		config.savePresetAs(presetName)
		Return
	EndIf
	_presetSaveOwed = presetName
	_refreshSoon(0.2)
EndFunction

; A preset was loaded another way (the MCM): it supersedes a load still owed
Function forgetOwedPresetLoad()
	_presetOwed = ""
EndFunction

; Work the SKSE menu's General page owes the update pass: a widget reload
; (a new colour preset) and a module recheck (re-detecting installed mods).
; The MCM did both in menu mode with the loop waiting; served in the pass they
; never run alongside another one.
Bool _reloadOwed = False
Bool _recheckOwed = False

Function requestReload()
	_reloadOwed = True
	_refreshSoon(0.2)
EndFunction

Function requestModuleRecheck()
	_recheckOwed = True
	_refreshSoon(0.2)
EndFunction

; NPC label and slot work from the SKSE menu's NPC Tracking page: destroying
; and recreating labels or releasing a slot's icons while a pass draws the
; same slot left a stray label, so the values are stored at once and the
; widget work is owed to the next pass. With the mod off no pass runs and
; none can collide: the work is done at once, as the MCM did.
Bool _labelsOwed = False
Bool[] _npcReleaseOwed

Function requestLabelRebuild()
	If config.slw_stopped
		refreshAllNpcLabelStyles()
		Return
	EndIf
	_labelsOwed = True
	_refreshSoon(0.2)
EndFunction

Function requestNpcRelease(Int slot)
	If slot < 1 || slot > 3
		Return
	EndIf
	If config.slw_stopped
		releaseNpcSlot(slot)
		Return
	EndIf
	If !_npcReleaseOwed
		_npcReleaseOwed = new Bool[4]
	EndIf
	_npcReleaseOwed[slot] = True
	_refreshSoon(0.2)
EndFunction

; The offsets only; the label is rebuilt where it is owed
Function storeNpcLabelOffset(Int slot, Int x, Int y)
	If slot == 1
		npc1_labelOffsetX = x
		npc1_labelOffsetY = y
	ElseIf slot == 2
		npc2_labelOffsetX = x
		npc2_labelOffsetY = y
	ElseIf slot == 3
		npc3_labelOffsetX = x
		npc3_labelOffsetY = y
	EndIf
EndFunction
