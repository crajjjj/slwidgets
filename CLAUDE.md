# SL Widgets — Project Notes for Claude

## Git Commits
Do **not** include `Co-Authored-By` trailer in commit messages.

## Project Type
Skyrim SE mod. Scripts are written in **Papyrus** (`.psc`), compiled to `.pex`.

## Build

The user builds manually — do **not** attempt to invoke the compiler or build tools.

```sh
# Papyrus scripts (Skyrim SE compiler)
# Project file: skyrimse.ppj
# Sources: Source/Scripts/*.psc -> compiled .pex
```

## Important: CK-Filled Properties

Script properties filled via the Creation Kit (CK) in the ESP/ESM must NOT be removed from `.psc` files even if unused in code. Removing them breaks the form binding. To clean up, you must also clear the property in the ESP. When in doubt, leave them as dead weight.

## Papyrus Language Notes

### Reserved keywords (case-insensitive, cannot be used as identifiers)
`As`, `Auto`, `AutoReadOnly`, `Bool`, `Else`, `ElseIf`, `EndEvent`, `EndFunction`, `EndIf`, `EndProperty`, `EndState`, `EndWhile`, `Event`, `Extends`, `False`, `Float`, `Function`, `Global`, `If`, `Import`, `Int`, `Length`, `Native`, `New`, `None`, `Parent`, `Property`, `Return`, `ScriptName`, `Self`, `State`, `String`, `True`, `While`

### Control flow
- No `break` or `continue` -- use flags or early `return` to exit loops.
- Only `if/elseif/else/endif` and `while/endwhile`. No for-loops, switch, or do-while.
- Logical `||` and `&&` short-circuit.

### Variables & types
- Five base types: `Bool`, `Int`, `Float`, `String`, plus object references and arrays.
- Value types (Bool/Int/Float/String) are copied on assignment. Objects/arrays are by reference.
- Variables inside `while` loops persist across iterations (NOT reset each iteration). Always initialize explicitly.
- Script-level variables can only be initialized with literals, not expressions. Function-level can use expressions.
- Division by zero and modulus by zero produce undefined results (engine logs error).

### Arrays
- Max 128 elements. Size must be an integer literal (`new int[128]`), not a variable.
- `array[i] += 5` does NOT compile -- use `array[i] = array[i] + 5`.
- No arrays of arrays. Arrays are passed/assigned by reference.
- `Find()`/`RFind()` and SKSE string functions are case-insensitive. `==` string comparison is case-sensitive.

### Properties & optional mod dependencies
- Global/static function calls (e.g. `MME_Storage.getMilkCurrent(...)`) resolve lazily at call time, not script load. Safe to reference optional mods if guarded by `Game.GetModByName()`.
- Properties typed to external scripts resolve at script load -- the type must exist or the script fails to load entirely.
- Auto property getters/setters are external calls in threading context.

### States
- Script can be in only one state at a time. `GotoState("")` returns to empty state.
- State function signatures must exactly match the empty-state definition.
- Call `GotoState()` BEFORE external calls, not after (threading safety).

### Threading
- Only one thread can run a script instance at a time. Any external call (including `Debug.Trace()`, property access on other objects) unlocks the script, allowing other threads in.
- After an external call returns, local assumptions about script state may be stale.
- Internal operations (own variables, own properties, array ops) do NOT unlock.

### Misc gotchas
- Compiler does not check all code paths for return values -- missing returns cause undefined behavior.
- `parent.FunctionName()` calls one level up, not necessarily the base definition.
- Unary minus can misbehave without spaces: write `x = y - 1` not `x = y-1`.

## Code Conventions

- Keep UTF-16 LE BOM encoding for translation files (`Interface/Translations/`).
- Keep edits ASCII unless the file already contains non-ASCII.
- Comments: write them when the WHY is non-obvious — a hidden constraint, a subtle invariant, a workaround for a specific bug, or behavior that would surprise a reader. Multi-line comments are fine when the explanation warrants it. Don't explain WHAT the code does; don't reference callers or issue numbers.

## Key Files
| File | Purpose |
|------|---------|
| `Source/Scripts/slw_util.psc` | Global helpers, all `isXxxReady()` dependency checks, slot constants + `getIconNameForSlot()` |
| `Source/Scripts/slw_config.psc` | Central config; wires all modules, holds player toggle properties, NPC slot management, per-slot sub-toggle arrays, hotkey, settings preset save/load |
| `Source/Scripts/slw_widget_controller.psc` | Main update loop, NPC bar reconciliation, name label management, default layout |
| `Source/Scripts/slw_base_module.psc` | Base class for all modules (extends Quest) |
| `Source/Scripts/slw_module_mme.psc` | Milk module: MME + SGO4 + MAL |
| `Source/Scripts/slw_menu.psc` | MCM menu (extends SKI_ConfigBase) — 4 pages including NPC Tracking |
| `Source/Scripts/slw_interface_sgo4.psc` | Thin wrapper for SGO4 script API |
| `Interface/Translations/SLWidgets_*.txt` | MCM translation strings (10 languages) |

## Module Pattern
All modules extend `slw_base_module` and override:
- `isInterfaceActive()` — returns true if any supported plugin is loaded (dependency check)
- `initInterface()` — detect plugins, set `Plugin_Xxx = true`, register events, allocate `_*_prv` arrays
- `resetInterface()` — clear all plugin flags and state
- `onWidgetReload(iBars, target, slot)` — load/release icons for the given slot+target, reset `_*_prv[slot]`
- `onWidgetToggleUpdate(iBars, target, slot)` — react to MCM toggle changes for the slot
- `onWidgetStatusUpdate(iBars, target, slot)` — read current value from `target`, call `iBars.setIconStatus()` only on change

State change tracking pattern: store previous state in `int[] _foo_prv` (sized N_SLOTS=4, EMPTY=-1 sentinel), update icon only when `prv[slot] == EMPTY || prv[slot] != curr`. Initialize lazily via `_ensurePrvArrays()` helper called at the top of each event handler.

Icon names are slot-aware via `getIconNameForSlot(BASE, slot)` from `slw_util` — slot 0 (player) keeps unsuffixed name for save-compat (`"Arousal"`), NPC slots get `_NPC{n}` suffix (`"Arousal_NPC1"`).

API calls use the `target` parameter, not the module's `PlayerRef` property. The dispatcher in `slw_config.moduleWidgetStateUpdate` passes `PlayerRef` for slot 0 and the assigned NPC actor for slots 1-3. Modules that don't support NPCs (PAF, SLDefeat) get called only with `slot == 0` from the dispatcher.

## Adding Support for a New Mod
1. Add `isXxxReady()` to `slw_util.psc` using `isDependencyReady("Mod.esp")`
2. Add `Plugin_Xxx` flag to the relevant module
3. `initInterface()`: detect + init; `resetInterface()`: clear
4. `onWidgetReload(iBars, target, slot)`: load icons via `getIconNameForSlot()`; `onWidgetStatusUpdate(iBars, target, slot)`: query API with `target`
5. Add config toggle property to `slw_config.psc` (player sub-toggle)
6. If mod supports NPCs: add `_slot_use_X` Bool[] array, `MOD_X` AutoReadOnly Int constant, and entries in `_ensureSlotToggles`/`isOnForSlot`/`getSlotModuleEnable`/`setSlotModuleEnable`. Update modules to call `config.isOnForSlot(playerToggle, slot, MOD_X)` instead of `config.isOn(playerToggle)`.
7. Add MCM toggle to `slw_menu.psc` Toggles page; if NPC-capable, add to NPC Tracking page per slot and `_tryToggleSubCode` ladder
8. Add the icon's base name to `_getOwnedIconBaseNames()` in `slw_widget_controller.psc` so it gets reconciled into NPC bars
9. Add dependency check to MCM Debug page
10. Add translation key to all 10 `Interface/Translations/SLWidgets_*.txt` files
11. Extend settings preset save/load (`_saveNpcSlotToggles` / `_loadNpcSlotToggles`) if NPC-capable

## NPC Tracking Architecture

**Slot model**: `getSlotCount() = 4` (1 player + 3 NPCs). Slot 0 is always the player; slots 1-3 are NPCs assigned via crosshair-pick hotkey. Constants from `slw_util.psc`.

**Multi-target flow**:
- `slw_widget_controller.OnUpdate` iterates slots → calls `config.moduleWidgetStateUpdate(iBars, target, slot)` for each active target
- `config.moduleWidgetStateUpdate` fans out to every module's `onWidgetStatusUpdate(iBars, target, slot)`. PAF and SLDefeat are gated `If slot == 0`.
- Each module uses `target` for API calls, indexes `_*_prv[slot]` for change detection, calls `iBars.setIconStatus(slwGetModName(), getIconNameForSlot(STATE, slot), value)`

**NPC slot assignment** (`slw_config`):
- 3 `Actor Property npcN Auto Hidden` properties
- Hotkey via `RegisterForKey` / `OnKeyDown` reads `Game.GetCurrentCrosshairRef()`, finds slot via `findFirstEmptyNpcSlot()` / `findNpcSlot(actor)`, calls `widget_controller.reloadNpcSlot(slot)` or `releaseNpcSlot(slot)`. Refuses when `slw_stopped` or any menu is open.

**Per-slot sub-toggles** (11 per slot): `_slot_use_sla_arousal`, `_slot_use_sla_exposure`, `_slot_use_ap2`, `_slot_use_fhu_cum/anal/vaginal/oral`, `_slot_use_mme_milk/lactacid`, `_slot_use_slp`, `_slot_use_preg` — all `Bool[]` sized 4, lazy-init in `_ensureSlotToggles`. Module codes `MOD_*` are AutoReadOnly Int constants 1-11.

**Gating logic** (`isOnForSlot`):
- `slw_stopped` is the only global gate
- Slot 0: returns the player's sub-toggle directly (no per-slot gating)
- Slot 1-3: returns `_slot_use_*[slot]` — **independent** of player sub-toggles
- Dependency check (`isInterfaceActive()`) stays in the module

**Bar layout** (`slw_widget_controller`):
- Slot N maps to two iWant bars: primary `slot*2+2` (4, 6, 8), secondary `slot*2+3` (5, 7, 9). Player keeps bars 0-3.
- Group anchored at `(npcGroupX, npcGroupY)`. NPC1 sits at the anchor (bottom of cluster), NPC2/3 stack upward — reversed Y so empty slots leave no visual gap below.
- `_reconcileNpcBars(slot)` walks 26 known icon names from `_getOwnedIconBaseNames()` (cached) and moves each into its slot's primary bar (or secondary if primary is full). Runs every OnUpdate tick to catch dynamic icons (pregnancy state transitions).
- Reconciliation uses iWant internals: `_getIconID`, `_findBarOfIcon`, `_nextFreeBarPosition`, `_setBarIcon`, `_getBarIcon`. Checks free position *before* clearing old to avoid orphaning.

**Name labels** (Flash text widgets via iWant):
- `_ensureNpcLabel(slot, target)` creates via `iBars.iWidgets.loadText(name, font, size, x, y, visible)` on first call, then `setText`/`setPos`/`setVisible` on subsequent calls
- Label IDs cached in `slw_config.npcN_labelId` (Auto Hidden Int, -1 sentinel). Flash widgets don't survive saves → `_restoreNpcLabelsAndIcons` (called from `OniWantStatusBarsReady`) resets IDs to -1 and recreates
- Position: `bar XY + _autoLabelOffset{X,Y}(bar) + per-slot user offset`. Auto offset derived from `_getBarType` + `_getBarIconSize`. User per-slot offsets in `npcN_labelOffset{X,Y}` add on top for fine-tune.
- Recomputed every OnUpdate tick so labels follow the bar when user moves it in iWant's MCM
- `_isNpcPresent(actor)` (`Is3DLoaded && !IsDead && !IsDeleted`) gates visibility. Unloaded NPCs → `_hideNpcLabel(slot)`. `OnUpdate`, `reloadWidgets`, and `_restoreNpcLabelsAndIcons` all check `!slw_stopped && _isNpcPresent(t)` before calling `_ensureNpcLabel`.

**Lifecycle hooks**:
| Trigger | Effect |
|---------|--------|
| Hotkey assign | `config.setNpcSlot` + `controller.reloadNpcSlot` → modules register icons, reconcile, label shown |
| Hotkey toggle-off / MCM Clear | `controller.releaseNpcSlot` → modules release icons, label hidden |
| Game load | `OniWantStatusBarsReady` → `_restoreNpcLabelsAndIcons` resets stale Flash IDs, re-registers icons + labels for assigned slots |
| Mod disable | `stopUpdates` → `_hideAllNpcLabels`, `moduleReset` clears state, `reloadWidgets` releases icons (labels stay hidden due to `slw_stopped` check) |
| Mod enable | `moduleReset` + `moduleSetup` + `reloadWidgets` (labels shown for present NPCs) + `startUpdates` |
| NPC unloads | next OnUpdate tick: `_isNpcPresent == False` → `_hideNpcLabel`. When NPC re-loads → label reappears |

**Settings presets** (`slw_config.loadSettingsPreset` / `saveSettingsPreset`): JSON via PapyrusUtil. Keys `npc.{slot}.{sub_toggle_name}` store per-slot toggles. Helpers `_loadNpcSlotToggles` / `_saveNpcSlotToggles`. Missing keys in legacy presets fall back to runtime values.

## Translation Files
- Encoding: **UTF-16LE with BOM**, CRLF line endings
- Format: `$KEY\tValue` (tab-separated)
- Must use Python (not sed) to edit — sed corrupts the UTF-16LE encoding

## External Mod API Patterns
| Mod | Access pattern |
|-----|---------------|
| MME | Direct global script calls: `MME_Storage.getMilkCurrent(playerRef)` |
| SGO4 | Quest cast via `slw_interface_sgo4.psc`: `Game.GetFormFromFile(0x00182A, "dse-soulgem-oven.esp") as Quest` |
| MAL | Bidirectional mod events: send `MAL_GetPlayerStoredMilk` / `MAL_GetPlayerMilkLimit`, cache responses from `MAL_ReturnPlayer*` events |

## MAL Event Caching Pattern
MAL values are one tick behind by design — `_requestMALUpdate()` fires on each status update tick, return events populate `_mal_milk_cur`/`_mal_milk_max`, and `getMilkLevel()` reads the cache from the previous tick. No sleep needed.

## Icon States
- `percentToState9NotStrict(int percent)` — maps 0–100% to states 0–8 (used for milk, lactacid)
- `percentToState9(int percent)` — stricter thresholds variant
- `percentToState5(int percent)` — maps to states 0–4
