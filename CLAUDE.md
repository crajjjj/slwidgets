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
