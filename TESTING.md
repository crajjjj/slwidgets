# SL Widgets — Smoke Tests

Manual test scenarios for validating builds before release. Each section is independent — run the **Quick smoke** after every build, the **Full E2E** before tagging a release, and pull from **Regression** + **Edge cases** when changing the relevant area.

Test environment: a save with an active follower (Lydia or similar) and at least one other named NPC accessible (e.g., in Whiterun). For multi-NPC scenarios, save in Whiterun market — 3 named NPCs always in range.

Symbols: ✅ pass criteria, ⚠️ known issue, ❌ regression sign.

---

## Quick smoke (~5 minutes)

Run after every compile. If any of these fail, do not ship the build.

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| Q1 | Mod loads cleanly | New game with mod active → wait for MCM init | MCM "SLWidgets" appears, no errors in `Papyrus.0.log`, Debug page shows dependencies ✅ |
| Q2 | Player widgets render | Open MCM Toggles → verify icons all enabled → close MCM | Player arousal/milk/etc. icons appear in iWant bar 0 (or wherever player's bars are configured) ✅ |
| Q3 | Bind hotkey | MCM → NPC Tracking → click "Pick Hotkey" → press X (or any free key) | Hotkey row shows the bound key ✅ |
| Q4 | Hotkey-pick NPC | Aim at follower, press hotkey | Notification "tracking Lydia in NPC slot 1", icons appear in iWant bars 4-5, label "Lydia" above bar 4 ✅ |
| Q5 | Hotkey toggle-off | Aim at same NPC, press hotkey again | Notification "cleared NPC slot 1", icons + label disappear ✅ |

---

## Full end-to-end

Run before tagging a release or after substantial refactors.

### Assignment / clearing

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| A1 | Assign 3 NPCs | Hotkey on 3 different NPCs in sequence | All 3 slot blocks in MCM NPC Tracking show actor names; 6 NPC bars visible (4,5,6,7,8,9) ✅ |
| A2 | Slots full guard | With all 3 slots filled, aim at a 4th NPC, press hotkey | Notification "All NPC slots full — clear one in MCM"; no slot replaced ✅ |
| A3 | MCM clear | NPC Tracking → click "Clear Slot 2" | NPC2 icons + label disappear; row shows "(empty)" with toggles disabled ✅ |
| A4 | Re-pick into empty slot | Aim at new NPC, press hotkey | New NPC takes slot 2 (first empty) ✅ |
| A5 | Hotkey blocked in MCM | Open MCM, aim at NPC, press hotkey | No assignment ✅ |
| A6 | Hotkey blocked when disabled | MCM General → Disable Mod → aim at NPC, press hotkey | Notification "enable the mod first in MCM", no assignment ✅ |
| A7 | Hotkey on self | Aim at the player (impossible normally, use console) | No assignment ✅ |

### Per-NPC sub-toggles & independence

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| T1 | Default NPC toggles | Assign NPC1 with default config | NPC1 shows SLA Arousal + AP2 + FHU Cum + MME Milk + Pregnancy icons; NOT SLA Exposure / FHU sub-toggles / MME Lactacid / SLP ✅ |
| T2 | Enable extra for NPC | NPC Tracking → toggle ON SLA Exposure for NPC1 → close MCM | NPC1's Exposure icon appears ✅ |
| T3 | Player ↔ NPC independence | Toggles page: disable SLA Arousal → close MCM | Player arousal icon gone, NPC1's arousal STAYS (decoupled) ✅ |
| T4 | Settings preset includes NPC toggles | NPC Tracking: turn off pregnancy for NPC2 → MCM General → Save Settings Preset → toggle pregnancy ON for NPC2 → load preset back | NPC2's pregnancy toggle returns to OFF ✅ |

### NPC presence

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| P1 | NPC unloaded | Fast travel away from tracked NPC | Within 5–10s NPC's icons + label hide; slot stays assigned (MCM shows name) ✅ |
| P2 | NPC reloaded | Fast travel back to NPC | Within 5s label + icons reappear ✅ |
| P3 | NPC death | Tracked NPC dies in combat | Label + icons hide immediately ✅ |
| P4 | NPC disabled via console | Tracked NPC: `disable` in console | Label + icons hide ✅ |

### Labels — custom text, font, color, size, position

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| L1 | Custom label text | NPC1 slot → Custom label → type "Wife" → Accept | Label above NPC1's bar reads "Wife" immediately ✅ |
| L2 | Revert to actor name | Open Custom label again → clear text → Accept | Label reads the actor's display name again ✅ |
| L3 | Font change | MCM → NPC Label Style → Font dropdown → "Skyrim Books" | Existing labels destroyed and recreated with new font on the spot; new font visible ✅ |
| L4 | Size change | Label Size slider → 36 | Labels recreate at larger size ✅ |
| L5 | Color picker | Label Color row → pick red | All 3 labels turn red instantly (no recreation) ✅ |
| L6 | Color default | Highlight Color row → press SkyUI default key (R) | Labels reset to white (0xFFFFFF) ✅ |
| L7 | Label X/Y fine-tune | Per-slot Label OffsetX slider → 20 | That NPC's label nudges 20px right ✅ |
| L8 | Label follows bar in iWant | Open iWant Status Bars MCM → move NPC1's bar (bar 4) to new position → close iWant MCM | Within 5s SL Widgets label follows to the new bar position ✅ |

### Bar layout / group positioning

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| B1 | Group X drag | NPC Tracking → NPC Group X slider → drag from default to 1280 | All NPC bars + labels move horizontally together; icons stay attached to bars ✅ |
| B2 | Group Y drag | NPC Group Y slider → drag from 600 to 400 | Whole cluster moves up; icons + labels stay aligned ✅ |
| B3 | Reset NPC bar layout | Move bars to weird positions, set custom label offsets → click "Reset NPC bar layout" | Bars return to default positions; label offsets zero; icons follow bars ✅ |
| B4 | Reset preserves user offsets | Set label X offset for NPC1 to +20 → drag group X slider | Group X moves cluster but NPC1's label keeps the +20 offset (group sliders don't wipe offsets) ✅ |

### Dynamic icons

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| D1 | Pregnancy state transition | Track an NPC, advance their pregnancy state (via mod or console) | New trimester icon appears in NPC's bar (4 or 5), NOT bar 0 ✅ |
| D2 | SLP infection | Infect a tracked NPC with a parasite via SLP | Parasite icon appears in NPC's bar ✅ |
| D3 | Multiple state changes | Trigger several state changes on the same NPC | All icons stay in NPC's bars; no spillover to player's bar ✅ |

### Save / load

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| S1 | Save with NPCs assigned | Track 2 NPCs → save game | Save completes without errors ✅ |
| S2 | Load with NPCs assigned | Load that save | Both NPC labels + icons recreate (Flash widgets are recreated since they don't survive saves) ✅ |
| S3 | Save with custom label | Assign NPC, set custom label "Boss" → save → reload | Label still reads "Boss" after reload ✅ |
| S4 | Save with custom font | Change font to "Handwritten" → save → reload | Labels render in Handwritten font after reload ✅ |
| S5 | Save while mod disabled | Disable mod → save → reload | Mod still disabled; no labels visible; no icons ✅ |

### Mod enable / disable

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| E1 | Disable | Track NPCs → MCM General → Disable Mod | All NPC labels hide; all icons release ✅ |
| E2 | Enable | Re-enable Mod | NPC labels + icons reappear for assigned + present NPCs ✅ |
| E3 | Enable with unloaded NPC | Disable, fast travel away, enable | Labels stay hidden until NPC re-enters cell ✅ |

### Preset interactions

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| C1 | Color preset toggle | Track NPC → change color preset in MCM | NPC icons recolor; labels survive (no recreation) ✅ |
| C2 | Settings preset toggle | Track NPC → load a different settings preset | NPC's per-slot toggles update per preset ✅ |

---

## Regression

Issues that have been fixed in prior versions — check these still work.

| # | Issue | Test | Sign of regression |
|---|-------|------|-------------------|
| R1 | Widget pulse animation (v2.1.3) | Watch player icons during steady state — no value changes | ❌ Icons brightening/dimming continuously every tick |
| R2 | iWant init deadlock (v2.1.1) | First load with `Papyrus.0.log` open | ❌ "iWant Status Bars" stuck at "NOT READY" in Debug page for >30s |
| R3 | First-install race (v2.1.2) | New game, fresh install | ❌ Player widgets not appearing until save/reload |
| R4 | Status update caching | Watch Papyrus log during steady state | ❌ Repeated `setIconStatus` log entries when no value actually changed |
| R5 | NPC icons in bar 0 (v2.2.0) | Track an NPC → watch where their icons appear | ❌ NPC icons visible at iWant bar 0 (player's row) even momentarily |
| R6 | Player toggle cascade (pre-v2.2.0 behavior) | Disable player arousal → check NPC | ❌ NPC arousal also disabled (should be independent now) |
| R7 | Hotkey while disabled | Disable mod → press hotkey on NPC | ❌ Label appears with no icons under it |
| R8 | Label survives reset bar layout | Click Reset NPC bar layout | ❌ Labels and icons in wrong positions after reset; ✅ both move together to defaults |

---

## Edge cases

Behavior worth confirming when changing relevant areas.

### Actor identity

- **Vampire transformation** of a tracked NPC → `GetDisplayName()` may return a different name. Label updates only on `_ensureNpcLabel` calls (slot assign / reload / MCM edit), so the old name persists until then. Acceptable.
- **Followers with custom names** (Inigo, Lucien, Sofia, etc.) → label shows the custom name correctly via `GetDisplayName()`.
- **Generic NPCs** ("Bandit", "Whiterun Guard") → label shows the generic name. User can override via Custom label.
- **Tracked NPC removed via mod uninstall** → Actor property may go None on load. `_isNpcPresent(None) == False` → label stays hidden, icons stay released. Slot remains assigned but inert.

### HUD overhauls

- **SkyHUD / iHUD / similar** that extend the Flash stage past 1280×720 → user-stored `npcGroupX/Y` past those bounds rendered correctly when the user originally saved them. Documented in README.
- **Standard hudmenu.swf** → `npcGroupX > 1279` or `npcGroupY > 719` renders off-screen.

### Settings preset compatibility

- **Legacy settings preset** (pre-v2.2.0, no `npc.*` keys) → loads fine, per-slot toggles keep their runtime defaults. Verified via `jsonutil.GetPathBoolValue(path, key, fallback)`.
- **New settings preset loaded on old build** → not tested explicitly, but the extra `npc.*` keys are ignored by older code.

---

## How to interpret results

- All Quick smoke must pass ✅
- All Full E2E should pass ✅ — any ❌ is a release blocker
- Regression checks must pass ✅ — a ❌ means a previously fixed bug is back
- Edge cases are informational, document new behaviors as they're discovered

When something fails, capture:
1. The specific test ID (e.g., L3, P2)
2. What you saw vs. what was expected
3. Relevant `Papyrus.0.log` snippet (filter on `slw_`, `iwant_status_bars`, `iwant_widgets`)
4. Steps to reproduce reliably
