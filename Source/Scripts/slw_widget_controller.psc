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

;init ibars
Event OniWantStatusBarsReady(String eventName, String strArg, Float numArg, Form sender)
	If eventName == STATUS_BARS_EVENT_NAME
		iBars = sender As iWant_Status_Bars
		if iBars
			WriteLog("WidgetController: iBars ready")
			config.loadPreset(config.activePreset)
			_restoreNpcLabelsAndIcons()
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
	;
	RegisterForSingleUpdate(3)
EndFunction

Function stopUpdates()
	UnregisterForUpdate()
	UnregisterForModEvent(STATUS_BARS_EVENT_NAME)
	_hideAllNpcLabels()
EndFunction

Function _hideAllNpcLabels()
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		_hideNpcLabel(slot)
		slot += 1
	EndWhile
EndFunction

;Main update function
Event OnUpdate()
	if config.slw_stopped
		return
	endif
	if !iBars || !iBars.isReady()
		RegisterForSingleUpdate(config.updateInterval)
		return
	endif
	If !PlayerRef
		PlayerRef = Game.GetPlayer()
	EndIf
	; Slot 0 — player, always updates
	config.moduleWidgetStateUpdate(iBars, PlayerRef, 0)
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
	RegisterForSingleUpdate(config.updateInterval)
EndEvent

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
	_ensurePresentPrv()
	Int slot = 1
	Int total = getSlotCount()
	While slot < total
		Actor t = config.getNpcSlot(slot)
		If t
			If !config.slw_stopped
				; Always reload — even for absent NPCs — so toggle changes
				; from MCM take effect for the slot's bars. _ensureNpcLabel
				; auto-suffixes "(away)" when the NPC isn't present.
				config.moduleWidgetReload(iBars, t, slot)
				_reconcileNpcBars(slot)
				_ensureNpcLabel(slot, t)
				_applyBarVisibilityToLabel(slot)
				_slot_present_prv[slot] = _isNpcPresent(t)
			Else
				; Mod stopped — release the slot's icons and tear down label.
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
	If !iBars || !iBars.isReady() || config.slw_stopped
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
		If t && !config.slw_stopped
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
	String[] names = new String[26]
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
	Return names
EndFunction

; Move a single icon (by name) into one of the slot's two dedicated bars if
; it isn't already in either. Primary bar first; secondary as overflow.
; Returns True if the icon was actually moved so the caller can trigger
; a single _drawAllBars to update Flash positions.
Bool Function _placeOneIconInSlotBar(String iconName, Int slot)
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
	If !iBars || !iBars.isReady() || slot <= 0
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
	Int bar = _getBarForSlot(slot)
	If !iBars._getBarVisible(bar) || _isBarAutoHidden(bar)
		_hideNpcLabel(slot)
	EndIf
EndFunction

; iWant's autohide doesn't flip statusBarVisible — it fades widget alpha
; via Scaleform transitions. We detect the faded state by comparing the
; bar's last-change timestamp (patched into iWant) against autoHideTime.
; +0.5s grace for the fade-out transition (iWant fades over 15 frames =
; 0.5s at 30fps).
Bool Function _isBarAutoHidden(Int bar)
	If !iBars._getBarShowOnChange(bar)
		Return False
	EndIf
	Float t = iBars._getBarLastChangeTime(bar)
	If t <= 0.0
		Return True
	EndIf
	Float window = iBars._getBarAutoHideTime(bar) As Float
	Return Utility.GetCurrentRealTime() > t + window + 0.5
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


