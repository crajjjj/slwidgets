# SL Widgets — Project Notes for Claude

## Git Commits
Do **not** include `Co-Authored-By` trailer in commit messages.

## Project Type
Skyrim SE mod. Scripts are written in **Papyrus** (`.psc`), compiled to `.pex`.

## Key Files
| File | Purpose |
|------|---------|
| `Source/Scripts/slw_util.psc` | Global helpers, all `isXxxReady()` dependency checks |
| `Source/Scripts/slw_config.psc` | Central config; wires all modules, holds toggle properties |
| `Source/Scripts/slw_base_module.psc` | Base class for all modules (extends Quest) |
| `Source/Scripts/slw_module_mme.psc` | Milk module: MME + SGO4 + MAL |
| `Source/Scripts/slw_menu.psc` | MCM menu (extends SKI_ConfigBase) |
| `Source/Scripts/slw_interface_sgo4.psc` | Thin wrapper for SGO4 script API |
| `Interface/Translations/SLWidgets_*.txt` | MCM translation strings (10 languages) |

## Module Pattern
All modules extend `slw_base_module` and override:
- `isInterfaceActive()` — returns true if any supported plugin is loaded
- `initInterface()` — detect plugins, set `Plugin_Xxx = true`, register events
- `resetInterface()` — clear all plugin flags and state
- `onWidgetReload(iBars)` — load/release icons, reset `_*_prv` state
- `onWidgetStatusUpdate(iBars)` — read current value, call `iBars.setIconStatus()` only on change

State change tracking pattern: store previous state in `int _foo_prv = -1` (EMPTY sentinel), update icon only when `prv == EMPTY || prv != curr`.

## Adding Support for a New Mod
1. Add `isXxxReady()` to `slw_util.psc` using `isDependencyReady("Mod.esp")`
2. Add `Plugin_Xxx` flag to the relevant module
3. `initInterface()`: detect + init; `resetInterface()`: clear
4. `onWidgetReload`: load icons when active; `onWidgetStatusUpdate`: update icon state
5. Add config toggle property to `slw_config.psc` if user-togglable
6. Add MCM toggle to `slw_menu.psc` Toggles page; add dependency check to Debug page
7. Add translation key to all 10 `Interface/Translations/SLWidgets_*.txt` files

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
