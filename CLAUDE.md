# SL Widgets — Project Notes for Claude

## Git Commits
Do **not** include `Co-Authored-By` trailer in commit messages.

## Project Type
Skyrim SE mod. Scripts are written in **Papyrus** (`.psc`), compiled to `.pex`.

## Build

Papyrus is compiled with Pyro from the repo root; the game must not be
running when the output is deployed:

```sh
# pyro.exe comes with the VSCode papyrus-lang extension
# (%USERPROFILE%\.vscode\extensions\joelday.papyrus-lang-vscode-*\pyro\pyro.exe)
pyro.exe -i skyrimse.ppj --game-path "C:\SteamLibrary\steamapps\common\Skyrim Special Edition"
# Sources: Source/Scripts/*.psc -> Scripts/*.pex; also rewrites Build/SLWidgets.zip
```

The SKSE menu DLL is a separate build (see "SKSE menu plugin" below); run it
before Pyro for a release, since the zip packs the DLL.

### Import order matters (and `skyrimse.ppj` is gitignored)

The ppj holds machine-absolute paths so it is not in the repo — which means
import-order constraints live only here. When two dependency folders ship the
same script name, the FIRST import wins, and compiling against the wrong copy
produces a `.pex` that mismatches at runtime with no compile-time warning:

- **`_JSW_BB_Storage`**: `fmPlus` declares `SpermCount` as `int[]`, while every
  real Fertility Mode variant (3.0.1 and Reloaded) ships `float[]`. A Fertility
  Mode source folder must be imported BEFORE `fmPlus`, or `hasFMSperm()` throws
  "Mismatched types" on every widget update for FM3 users.

### Release archive (3.4.0+: one FOMOD)

`python build_release.py` turns Pyro's `Build/SLWidgets.zip` (the whole mod as
a flat tree; run the plugin build first, since the zip packs the DLL) into
`Build/SLWidgets <version>.zip`, a FOMOD whose one choice is the icon style:
`00 Core` (everything but the icon library and the Default / HideEmpty
presets), `01 Ring Icons`, `02 Classic Icons` (`art/classic/library` +
`art/classic/presets`). The installer XML and the two preview images live in
`fomod/` (`build_icons.py --sheet` draws the images; the packager stamps the
version into `info.xml`, the tracked file included). Either option installs a
COMPLETE library, so the packager refuses a classic library that does not
mirror the ring one file for file. It also checks the DLL version, every DDS
header and the translation files. The user asked for the FOMOD on 2026-10-27
(having turned one down for 3.0.0); until 3.3.0 the classic icons were a
separate overlay zip.
### Icons (3.0.0+)

`python build_icons.py` (Pillow 11.2+ and resvg-py) draws every set under
`Interface/.../library/` from `art/ring/glyphs/*.svg` and writes the shipped
`Default.json` / `HideEmpty.json` colour presets from its ramp (palette A since
3.4.0: white -> ice blue -> violet -> magenta -> red, chosen to stand apart from
the gold-to-red and green-to-red ramps other HUD widget mods use; `CLASSIC_RAMP` is the 3.0 gold ramp,
kept for the classic pack; milk and lactacid keep one colour). Icons stay
white-on-transparent: every colour is an iWant per-stage tint, so a style is
art plus a colour preset. The classic art lives in `art/classic/library` with
its presets in `art/classic/presets`; the sets new in 3.0.0 get their classic
art from the same script, drawn in the classic look (`build(..., classic=True)`:
no ring, a big 6 px outline, bottom fill, nothing inside until it rises), so the
classic library mirrors the ring one file for file. The pubic and armpit sets
are one hand-drawn glyph per stage (`pubic-0..5`, `armpit-0..6` in
`draw_custom_glyphs.py`, weight B of the 2026-10-27 drafts, a razor on the
shaved stage): their rows carry `fills = "full"`: the glyph is drawn full and only the
ring sweeps (`build(..., glyph_frac=1.0)`; `sunhelm/cold` also has a glyph list
but keeps the bottom-up fill). `fillStageColors` in `slw_util` is the same ramp as the code default of
every 3.0.0 icon. `build_willpower_icon.py` now writes the classic brain into
`art/classic`.

Every `.dds` is written through `savedds.save_dxt5`, never `Image.save`:
Pillow's DDS writer puts `(width + 3) * 4` in `dwPitchOrLinearSize` and 32 in
the bit count of a FourCC pixel format, and the 3.0.0 / 3.0.1 icons, shipped
that way, drew as diagonal streaks in the Flash iWant Widgets (two user
reports). nefaram runs the Prisma renderer, which decodes DDS through WIC and
showed them fine, so a release must also be looked at with Prisma disabled.
`build_release.py` refuses to package a library with such a header;
`python savedds.py --check <folder>` lists offenders, `--fix` rewrites them.

### Registering a module script (3.0.0+)

New module scripts need an ESP edit: a script entry on the `SLWidgetsModules`
quest (0x801) with `config` -> 0x800 and `PlayerRef` -> player, and an object
property on `slw_config` (quest 0x800) pointing at 0x801. `dotnet run --project
tools/esp/SlwEsp -- SLWidgets.esp` does both for the names listed in its
`Program.cs` (add a pair there for a new module). Mutagen rewrites the file
(not byte-faithful: it recomputes the header's next FormID), which is fine for
this two-record plugin; check it afterwards (houseCARL / xEdit).

### SKSE menu plugin (`plugin\`, 3.1.0+)

`SLWidgetsMenu.dll`, pages in SKSE Menu Framework's menu (section "SL Widgets"),
and since 3.3.0 the ONLY place settings change: the MCM is read-only (the
user, 2026-10-27: "make it informational only"). It shows General (the
enabled state, whether SKSE Menu Framework and this DLL are loaded, through
`SKSE.GetPluginVersion` of `SKSEMenuFramework` / `SLWidgetsMenu`) and
Maintenance (the dependency check). The mod starts disabled
(`slw_stopped = True`), so SKSE Menu Framework is a HARD requirement: without
it nothing can be enabled. A setting that moves leaves the MCM in the same
release ("no deferred work"). `OnConfigOpen` rebuilds `Pages` on every open,
so a changed page list needs no save migration. Pages, in menu order:

- **General / Meters / NPC Tracking** (3.3.0, `SettingsPage.cpp`): one generic
  page drawing rows the scripts describe (`slw_config.editorGeneral` /
  `editorMeters` / `editorNpc`; the row grammar is in the comment above
  `editorGeneral`: header, text, switch, slider, button, choice, colour,
  hotkey, text field). Every change comes back as `slw_bridge.SetSetting(key,
  value as text)` to `slw_config.editorSet`, which does what the MCM's handler
  for that option did. Work that reloads icons or resets modules (colour
  preset, Reset modules) is owed to `_updatePass` (`requestReload`,
  `requestModuleRecheck`), and so is NPC label and slot work (Clear Slot,
  font, size, offsets, custom label: the values are stored at once,
  `requestLabelRebuild` / `requestNpcRelease` owe the widget work), which
  raced the pass's own label creation. Enable/disable runs the MCM's flows
  (`_editorSetEnabled`) one at a time through `_editorRequestEnabled`, the
  latest wish winning; enabling waits for iWant (`isLoaded`), as the MCM's
  switch did, since icons registered before it are lost for the session.
  The hotkey is captured through the framework's input callback
  (`RegisterInpoutEvent`, sic): the next keyboard key down, consumed, Escape
  excluded (the framework closes on it); the capture disarms when its row
  has not been drawn for 0.5 s (the page was left) or a text field is in
  use. A text field is written on Enter, on losing focus, and when the menu
  closes or the page is left mid-edit. A choice whose current value is not
  listed sends index -1 (nothing selected). A new setting is a row in the
  page's editor function and a branch in `editorSet`; no DLL change.
- The DLL reports at each game load whether its pages registered
  (`slw_bridge.SetMenuReport` -> `slw_config.skseMenuReport`, 1 up, 2 the
  framework lacks a probed export), so the MCM's status line can say the
  framework is too old rather than OK.

- **Toggles** (3.2.0, `TogglesPage.cpp`): the player icon switches, grouped by
  mod, greyed while the mod is not installed. The MCM's Toggles page is gone.
- **Positions** (3.1.0, `PositionsPage.cpp`): sliders for X, Y, size and
  orientation of iWant's player bars 0-3, X, Y and spacing of the NPC cluster,
  X, Y and scale of the meter stack, the NPC layout reset. The MCM's sliders for
  these are gone since 3.2.0 (iWant's own MCM still has its bar sliders). The
  user asked for exactly this and turned down a drag editor with boxes over
  the HUD (built first, then replaced): "I need just x y z and orientation.
  No boxes."
- **Icon spacing** (3.5.0, top of the Positions page, asked by a player: big
  icons left big gaps): iWant's line bars step `size * BAR_SPACING_PERCENTAGE`
  per icon, a private script `Float` (1.5), ONE value for every bar of every
  mod; circles use inline literals and cannot change. No script can reach a
  non-property variable, and SL Widgets redrawing its own bars is undone,
  since iWant runs `_drawAllBars` on every icon status change. So the DLL's
  natives `slw_bridge.GetIWantIconStep` / `SetIWantIconStep` (`Natives.cpp`,
  registered at load, framework or not) find the quest's bound
  `iWant_Status_Bars` object and read / write the variable by name; the
  scripts then `_drawAllBars`. It stays iWant's state, saved with its script
  like the bars (SL Widgets keeps no copy, nothing re-applied at load).
  Percent 80-300 (`Layout::kMin/kMaxIconSpacing`, `Natives::kMin/kMaxIconStep`,
  `slw_widget_controller.ICON_SPACING_MIN/MAX`: keep the three in step);
  layout key `sp=` (0 = out of reach: no DLL per `slw_bridge.hasNatives`, or
  an iWant build without the variable, and the page then says so); preset key
  `bars.spacing`.
- **Icon moves** (3.3.0, on the Positions page): each player bar's icons with
  ^ / v and "to bar N", the one-off moves iWant's own MCM makes
  (`editorMoveIconInBar` swaps with the next seated icon, `editorMoveIconToBar`
  takes the target's `_nextFreeBarPosition`; iWant's `_setBarIcon` clears the
  icon's old seat and sizes it to the bar). The layout string lists the icons
  through their own read, `slw_widget_controller.editorBarIcons`
  (`ic=bar,seat,id,label`, labels from iWant's public `iconLabel[]`), asked
  for only while an Icons list is open since it costs a call into iWant per
  seat; a move acts only while that id still sits in that seat, and the
  neighbour search skips the seats the list leaves out (blank / released). Moves do not stick:
  iWant re-seats an icon in the first free place whenever it is loaded again
  (switch off/on, preset, enable, state icons), and the user accepted that over
  a stored placement re-applied every pass ("its fine they don't stick").
- **Presets** (3.2.0, `PresetsPage.cpp`): the settings presets, load, save over,
  save as new.

The MCM script (`slw_menu`) keeps its two CK-filled properties; the option
variables, handlers and states of the moved pages were removed in 3.3.0 (a
removed script variable is dropped from the save with a log line). SkyUI option ids
carry their page number and the variables holding them live in the save, so
renumbering the pages made old ids match options of another page (a 3.1.0
meter id clicked the 3.2.0 NPC page): `_forgetOptionIds` resets every id on
`OnConfigOpen`. Add any new ID-based option variable to it.

A change is written into the game while the menu is open and the icons follow
(the framework freezes time, Papyrus keeps running). Build from `plugin\`:
`xmake f -m release && xmake`; after a VERSION change `xmake f -c -m release -y && xmake`, since an unchanged configure keeps the old version resource (a 3.3.0 DLL came out of a 3.4.0 tree until the packager's check caught it) (VS 2022, xmake 3.0+, the CommonLibSSE-NG
submodule at `plugin\lib\commonlibsse-ng`, shallow at v7.1.0: `git submodule
update --init --recursive`). The DLL lands in `SKSE\Plugins`, which the ppj zips
with the rest of `SKSE`, so a release build runs it before Pyro;
`build_release.py` refuses a zip without a DLL of the current version.

- **Version**: the target's `on_load` reads `slw_util.GetVersionString()`, the
  same line `build_release.py` reads. The description scope of xmake.lua cannot
  read files, hence the hook. **After a version bump run `xmake f -c -m
  release`** (the `-c` matters): the version resource is a config file xmake
  regenerates only on a clean reconfigure, so a plain rebuild, or `xmake f`
  with unchanged options, keeps the old FileVersion (3.2.0 first built as
  3.1.0.0; the packager caught it). ProductVersion stays 0.0.0.
- **Never installs**: `XSE_TES5_MODS_PATH` is set on this machine and the
  commonlib plugin rule would `xmake install` into `<mods>\SLWidgetsMenu`;
  `on_config` repoints `installdir` and an empty `on_install` replaces the
  rule's. Build with the variable cleared as well.
- **Where state lives**: nowhere new. The DLL is a view over the save. Each
  page reads ONE string through a `Bridge::Query` and writes through setters:
  - Positions reads `slw_widget_controller.editorLayout()` and writes
    `editorSetBarPos` / `editorSetBarSize` / `editorSetBarType` (iWant's setters
    + `_resizeBar` + `_drawBar`, as iWant's MCM does), `editorSetNpcGroup`
    (`setNpcGroupPos` + `_layoutNpcBars`), `editorSetNpcSpacing` and
    `editorSetMeters` (`setMetersLayout` + `_refreshSoon`). The NPC bars and the
    meter stack are never moved bar by bar: the controller re-derives them from
    their anchors.
  - Presets reads `slw_config.editorPresets()` and writes `slw_bridge.LoadPreset`
    / `SavePreset` (`requestPresetLoad` / `requestPresetSave`: owed and served
    at the top of `_updatePass`, before its iWant check, load first, so a save
    never reads a half-applied load; at once while the mod is stopped).
    `slw_config.applySettingsPreset` is the one way to load and use a preset,
    MCM included: it supersedes a load still owed (`forgetOwedPresetLoad`), and
    while the mod is stopped it only stores the values (setting modules up
    would wake a disabled mod; enabling does it). `startUpdates` drops owed
    requests a save carried over. Names are file names: the DLL takes letters,
    digits, space and `- _ ( )`, the bridge refuses path characters again.
  - Toggles reads `slw_config.editorToggles()`: the rows in MCM order, each with
    its property name, its label and help translation keys, its value and the
    MCM's greyed-out condition. `slw_config.setToggleByKey` writes one, then
    `slw_widget_controller.requestTogglePass` owes the `toggleUpdateWidgets`
    pass the MCM runs on close; `_updatePass` serves it, so passes never
    overlap however fast switches are clicked. A new player switch is a row in
    `editorToggles` and a branch in `setToggleByKey`, no DLL change.
- **Labels** come from the mod's own `Interface\Translations\SLWidgets_<LANG>.txt`
  (`Translations.cpp`: the game's `sLanguage`, English filling the gaps, keys
  matched case-insensitively since Papyrus may hand a key back in another
  casing). Keys travel from the scripts as whole literals, as the MCM uses them.
- **Pages share `PageCommon::PageState`**: the read when a page comes up
  (after a 1 s gap without frames), the read owed after a write, Refresh, the
  status line, the timeout message, and `LastRequestAt`, the time the newest
  read was asked for: an answer is no newer than that, so Toggles keeps a
  clicked value only against a read asked for before the click, and Presets
  judges a save or a load only from a read asked for after it (retrying until
  8 s / 15 s, since the work waits for an update pass). ImGui pushes go
  through `IdScope` / `DisabledScope` / `IndentScope`, so an exception cannot
  leave one open in the framework's window.
- **Write rules** (`PositionsPage.cpp`): X and Y of a player bar are written
  every 150 ms while the slider is held (one `_setBarX/Y` + `_drawBar`, cheap);
  size, orientation, the NPC cluster and the meters on release only, since
  each of those is a resize pass, a full `_layoutNpcBars` or a stack rebuild.
  `kCloseMenu` flushes a slider still held. Every page reads back 1.5 s after
  a write (Positions never while a slider is held, Toggles keeping a value
  clicked in the last 4 s) and whenever it comes up after a 1 s gap.
- **The bridge** is `slw_bridge.psc`, hidden global functions the DLL reaches
  with `DispatchStaticCall` on the SKSE task queue; an answer arrives on a VM
  thread. Its signatures are an interface: the VM rejects a call whose argument
  count differs, silently, so never change one, add a function. Each string
  carries `v=1`; `Layout::kVersion` / `Toggles::kVersion` must match (bump
  both sides); a NEW key needs no bump, since `Layout::Parse` skips keys it
  does not know. Never name a Papyrus parameter `key`: `Key` is a vanilla type,
  and the compiler reads the name as the type. Since 3.5.0 the bridge also
  carries the DLL's natives (the other direction); without the DLL they are
  unbound, so callers check `hasNatives()` (`SKSE.GetPluginVersion`) first.
- **Framework facts** (SKSE-Menu-Framework-3 source, 2026-10): registration
  lists are unlocked and the loading screen renders at kDataLoaded, so
  everything registers at `kPostPostLoad`. A blocking window sets
  `Main::freezeTime` (Papyrus runs on), blocks game input and draws the
  cursor. Escape calls `WindowManager::Close` and dispatches `kCloseMenu`.
  nefaram runs 3.8, which lacks `GetMainWindow`; the pages need nothing of it.
- **ImGui rules** as SLO VE's: the vendored header only through `Ui.h`, no
  ImGui structs read, every export used is on the probe list in `Env.cpp`.
  Slider commits follow SLO VE's `IsItemActive` / `wasActive` pattern.

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
- String comparison is case-insensitive everywhere, `==` included, as are `Find()`/`RFind()` and the SKSE string functions. The VM keeps one copy of each string regardless of case, with the casing it was first seen in by ANY loaded script, so a string built at run time can come back in another mod's casing (`"$SLW_Meter_" + "willpower"` came out `$SLW_Meter_Willpower`).
- SkyUI's translation lookup IS case-sensitive, so write every `$` MCM key as one whole literal, never by concatenation (see `slw_menu._meterLabel`).

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
| `Source/Scripts/slw_widget_controller.psc` | Main update loop, NPC bar reconciliation, name label management, default layout; the meter stack (willpower bar included) at the end |
| `Source/Scripts/slw_base_module.psc` | Base class for all modules (extends Quest) |
| `Source/Scripts/slw_module_mme.psc` | Milk module: MME + SGO4 + MAL |
| `Source/Scripts/slw_menu.psc` | MCM (extends SKI_ConfigBase), read-only since 3.3.0: General (enabled state, SKSE menu state) and Maintenance (dependency check). Every setting is on the SKSE menu |
| `Source/Scripts/slw_interface_sgo4.psc` | Thin wrapper for SGO4 script API |
| `Source/Scripts/slw_interface_slove.psc` | SLO VE willpower, read from StorageUtil (no compile-time dependency on SLO VE) |
| `Source/Scripts/slw_module_sunhelm.psc` | 3.0.0: SunHelm food, thirst, cold, fatigue (player only). Holds the need quests as plain `Quest` (a variable typed to a foreign script must resolve when the module loads, which fails without SunHelm); an icon shows only while its quest `IsRunning()`, since SunHelm switches a need off by stopping it |
| `Source/Scripts/slw_interface_sunhelm.psc` | 3.0.0: the global cast helpers for SunHelm (stub types in `Source/ApiHeaders/_SH*.psc`), same pattern as `slw_interface_sgo4` |
| `Source/Scripts/slw_module_hygiene.psc` | 3.0.0: Bathing in Skyrim Renewed dirtiness + Wet Function wetness, player and NPC slots (`MOD_DIRT`, `MOD_WET`). Wetness is on the mods' 0..cap scale (cap 10, dry 1 by default) and shown as (wet - dry) / (cap - dry): WetFunction NG through its `WetFunctionNG.GetWetness` / `GetWetnessCap` natives (stub in `Source/ApiHeaders`), Redux from StorageUtil with its cap / dry read off its MCM quest 0x800 |
| `Source/Scripts/slw_module_sph.psc` | 3.0.0: SPH pubic (6 stages) and armpit (7 stages) hair from SPH's own globals, player only |
| `Source/Scripts/slw_module_baby.psc` | 3.0.0: BeeingFemale unborn health (`FW.UnbornHealth`), shown only while `FW.CurrentState` is 4-7 (not the pregnancy spell, which BF keeps through Replenish), player and NPC slots (`MOD_BABY`), scale inverted (100 = stage 0) |
| `Source/Scripts/slw_module_stress.psc` | 3.0.0: Stress and Fear stress global + phobia count, player only; its toggles are `module_saf_stress` / `module_saf_fear` because `module_stress` is the module object property |
| `Source/Scripts/slw_module_health.psc` | 3.0.0: Blade and Blunt injury spells (4 stages) + worst disease stage over vanilla (Sanguinare included) and SunHelm Diseases spells, player only. `isInterfaceActive()` is always true (vanilla diseases), so the disease icon shows only while a disease is held, and its 50-spell scan is cached 20 s (the phobia count in `slw_module_stress` 15 s) |
| `Source/ApiHeaders/*.psc` | Compile stubs for foreign script types that are cast at runtime (SGO4, SunHelm): only the members SL Widgets reads, `extends Quest`; the cast resolves by script name in game |
| `build_icons.py` | 3.0.0: draws the whole icon set into `Interface/.../library/` from `art/ring/glyphs/*.svg` (needs `pip install pillow resvg-py`), the classic look of the sets new in 3.0.0 into `art/classic/library` (3.4.0), the shipped Default / HideEmpty presets from its ramp; adds the new keys to the white presets and to the classic presets; `--sheet` renders the overviews `docs/assets/ring-style.png` and `classic-style.png` (the classic set, tinted with the classic Default preset but shown in full) and the `fomod/` preview images |
| `art/ring/draw_custom_glyphs.py` | Writes the hand-drawn glyphs (vulva, anus, ovum, belly, sperm, sun, snowflake) into `art/ring/glyphs/`; the rest are game-icons.net files (CC BY 3.0, credits in `art/ring/glyphs/CREDITS.md`) |
| `plugin/` | 3.1.0+: `SLWidgetsMenu.dll`, the SKSE menu pages (xmake + CommonLibSSE-NG, SKSE Menu Framework). `SettingsPage.cpp` (General, Meters, NPC Tracking) / `TogglesPage.cpp` / `PositionsPage.cpp` / `PresetsPage.cpp` the pages, `Layout.cpp` the layout string's model, `Translations.cpp` the MCM strings, `Bridge.cpp` the Papyrus calls, `Env.cpp` the export probe |
| `Source/Scripts/slw_bridge.psc` | 3.1.0: the global functions the DLL calls; forwards to the `editor*` functions at the end of `slw_widget_controller`. Signatures are an interface |
| `build_release.py` | 3.4.0: builds the FOMOD `Build/SLWidgets <version>.zip` from Pyro's zip + `art/classic` + `fomod/`, after checking the DLL version, the DDS headers, the translation files and that the classic library mirrors the ring one; run after the plugin and Papyrus builds |
| `fomod/` | 3.4.0: `info.xml` (version stamped by the packager), `ModuleConfig.xml` (Core + the icon style choice), `ring.png` / `classic.png` previews |
| `tools/esp/SlwEsp/` | Mutagen (dotnet 9) tool that registers module scripts in `SLWidgets.esp` (script on the modules quest + object property on `slw_config`); idempotent, keeps a `.bak` |
| `build_willpower_icon.py` | Draws the classic brain icon of the willpower bar into `art/classic/library/slove/`; the shipped one comes from `build_icons.py` |
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
0. A new module script also needs registering in the ESP (see "Registering a module script" above) and its `slw_module_x Property module_x auto` on `slw_config`. Mind the names: the module object property and the Bool toggles share one namespace on `slw_config` (`module_stress` is the object, so the toggles are `module_saf_stress` / `module_saf_fear`). A stage icon of any length registers with `loadStageIcon(config, iBars, baseName, slot, basepath, captions)` from `slw_util`: it applies the ramp defaults and the colour preset by the BASE name (presets know no `_NPCn` names) and loads through `config.loadIconForSlot`, which puts an NPC slot's icon straight into that slot's bar; captions come from `StringUtil.Split`. An icon that comes and goes keeps a loaded flag and claims it BEFORE the external load call, so a concurrent release cannot leave it stale. A preset key goes in as one whole literal (`slw_config._npcPresetKey`).
1. Add `isXxxReady()` to `slw_util.psc` using `isDependencyReady("Mod.esp")`
2. Add `Plugin_Xxx` flag to the relevant module
3. `initInterface()`: detect + init; `resetInterface()`: clear
4. `onWidgetReload(iBars, target, slot)`: load icons via `getIconNameForSlot()`; `onWidgetStatusUpdate(iBars, target, slot)`: query API with `target`
5. Add config toggle property to `slw_config.psc` (player sub-toggle)
6. If mod supports NPCs: add `_slot_use_X` Bool[] array, `MOD_X` AutoReadOnly Int constant, and entries in `_ensureSlotToggles`/`isOnForSlot`/`getSlotModuleEnable`/`setSlotModuleEnable`. Update modules to call `config.isOnForSlot(playerToggle, slot, MOD_X)` instead of `config.isOn(playerToggle)`.
7. Add the player switch to the SKSE menu: a row in `slw_config.editorToggles` (property name, label and help translation keys, the installed condition) and a branch in `setToggleByKey`; no DLL change. If NPC-capable, add a `_editorNpcModule` row to `slw_config.editorNpc` (the SKSE menu's NPC Tracking page) and keep the code inside the `MOD_SLA_AROUSAL..MOD_BABY` range `_editorSetNpc` accepts (widen it for a new last code)
8. Add the icon's base name to `_getOwnedIconBaseNames()` in `slw_widget_controller.psc` so it gets reconciled into NPC bars
9. Add dependency check to the MCM's Maintenance page (`slw_menu.Debug()`)
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

**Settings presets** (`slw_config.loadSettingsPreset` / `saveSettingsPreset`): JSON via PapyrusUtil. Keys `npc.{slot}.{sub_toggle_name}` store per-slot toggles. Helpers `_loadNpcSlotToggles` / `_saveNpcSlotToggles`. Missing keys in legacy presets fall back to runtime values. Since 3.2.0 they also carry the layout (`_saveLayoutSettings` / `_loadLayoutSettings`): `bars.<0-3>.x` / `.y` / `.size` / `.type` (iWant's player bars through `iBars`; `_barPresetKey` hands out whole literals) and `npcgroup.x` / `.y` / `.spacing`. `_presetInt` leaves a value alone when the file lacks its key (an older preset changes nothing, whatever the current value) and clamps only what the file holds: bars to iWant's own MCM ranges (±10000, size 0-150, type 0-9), the NPC anchor and the meter stack to the Positions page's (`plugin/src/Layout.h`; keep the two in step). The layout is applied only while iWant is up, the NPC part only with `hasBarsAPI()`; otherwise the preset's switches apply and the layout waits for the next load. `applySettingsPreset` is the one way to load a preset and use it (MCM and SKSE menu).

## Meter Stack (2.3.0)

The things here that are NOT Status Bars icons: one stack of iWant Widgets **meters**, player only, at the right edge half way down, each with an icon to its left. Nine meters, numbered in stack order (`slw_config.getMeterPresetKey`): 0 SLO VE willpower (brain icon), 1 SLA arousal, 2-5 FHU total / vaginal / anal / oral, 6-8 Apropos2 W&T vaginal / anal / oral. One position and size for the whole group (`metersX` / `metersY` = the stack's CENTER, `metersScale`), as the user asked. Icon colours (3.0.0): only the shipped `Default` preset is fully visible at every stage (the user's call); `HideEmpty` keeps stage 0 at alpha 0 and the white / classic presets keep their alphas, so the module code defaults (33 / 75) stay as they were. iWant keeps the colours an icon was registered with, so `slw_widget_controller._reloadIconsOnce` (on iWant-ready) runs one `reloadWidgets` per `ICONS_VERSION` (30400 in 3.4.0 for palette A; 30001 in 3.0.1): bump it when the registered icons or their default colours change. Every meter starts switched off since 3.0.0 (the user's ask): `module_slove_willpower` defaults False and `_meter_use` is created all False; a save that already holds them keeps its values, so there is deliberately no migration.

- **No module, no ESP change.** Raw Flash widgets like the NPC name labels, so the code lives in `slw_widget_controller` (the block at the end of the file): `_updateMeters` from `OnUpdate` / `reloadWidgets` / `toggleUpdateWidgets`, `_stopMeters` from `stopUpdates`, `_forgetMeters` from `OniWantStatusBarsReady`. A `slw_base_module` script would have needed a new script binding in `SLWidgets.esp`.
- **Ids die with the game load.** `_forgetMeters` drops them WITHOUT touching the stage: after a load the same numbers may belong to another mod's widgets. Only `_destroyMeters` (in-session) destroys.
- **`_metersGen`** is bumped by `_forgetMeters` (load) and `_stopMeters` (mod disabled). A pass captures it and checks it right after every widget it creates (`_buildMeters`, `_loadMeterIcon`) and on each row of `_drawMeters`; when it moved, the pass destroys the widget it just made and returns without touching `_metersBusy` or the mask. Papyrus saves running stacks and resumes them on load, so a pass saved mid-build is the same case; without this it wrote the old mask over a half-built stack and those rows never appeared.
- **Sizes.** An iWant meter is 334x30 on the stage at 100%, in the Flash widget and in the Prisma renderer alike (read from the Prisma `index.html`); positions are widget CENTERS. A meter is scaled with `setZoom` (iWant's docs: do not `setSize` a meter), the icon with `setSize`.
- **Rows are a bit mask** (`_wantedMeters`): switched on (`config.getMeterSwitches()`, one call for all nine) AND the mod loaded (`isSloveReady()` for willpower, the module's `isInterfaceActive()` for the rest). A changed mask, or `_metersRebuild`, destroys and rebuilds the whole stack (`setPos` has left ghosts before); a row keeps its place while faded out.
- **Switches.** `isMeterOn(0)` is `module_slove_willpower` (the name saves and presets already know); 1-8 live in the `Bool[] _meter_use` (slot 0 unused).
- **Values come from the modules**, not from the icons: `getArousalPercentFor` / `getCumPercentFor` / `getWearStatesFor`, which wrap the `slw_interface_*` percent readers, so the meters work with the status icons switched off. The W&T read walks every alias of the Apropos2 actors quest, so `slw_module_apropos_two._readWearStates` hands out a read younger than 0.5 s again (icons and meters read the player in the same pass). Apropos2 keeps the W&T amount private, so those meters show the stage (0-8) as eighths.
- **The icon follows the stage** the status icon would show (`_meterStage`, same `percentToState9*` thresholds), from the same library paths, so custom packs apply. A library widget's art is fixed at load, so a stage change destroys and reloads the icon widget (`_loadMeterIcon`). Willpower's two "stages" are broken (red brain) and not; the bar flashes on the way to 0.
- **Showing.** Willpower keeps the rule it had as a bar of its own: up while `slw_interface_slove.isInScene` and below 100, whatever the mode. The others: `metersAlwaysShow`, or fade mode (the default), where a change stamps `_meterChangedAt` and the row is up until `metersHoldSeconds` after it. A change is a move of `METER_CHANGE_MIN` (5) points from `_meterSeen`, the value the last change was counted at, or a different icon stage: every 1-point step would keep a slowly draining value (FHU absorption, decaying arousal) up for good. Rows are faded with `doTransition` (15 frames, as Status Bars does). The fade-out is decided on the update tick, NOT with a delayed `doTransition`: the Prisma renderer cancels a pending delayed transition when a new one starts, but nothing here could confirm the Flash original does, and a stale delayed fade would hide a meter that just changed again.
- **`_meterSeen` survives the game load on purpose** (only the ids are forgotten), so the first read after a load is not a change and nothing pops up. A meter never read (-1) counts as changed, so an updated save shows its meters once.
- **MCM changes only flag** (`requestMetersRebuild`, `setMetersLayout`); the next pass rebuilds. The 30 s preview (`_metersPreviewUntil`, willpower included, outside a scene too) starts only outside menu mode: a pass that runs while the menu is open (a preset loaded there, the close pass if menu mode lingers) leaves `_metersPreviewPending` set and asks the loop for a pass, which comes once the menu is closed (updates wait while a menu is open).
- **`_metersBusy`** keeps the tick and the MCM-driven pass from building two stacks at once (every widget call lets the other thread in). A pass that finds it held asks the loop for another pass soon (`_refreshSoon`) instead of dropping the work until the next interval. `_forgetMeters` and `_stopMeters` clear it, together with the `_metersGen` bump that stops the pass holding it.
- **Settings presets** carry `meter.arousal` ... `meter.wt_oral` (1-8; willpower travels as `module_slove_willpower`), `meters.alwaysshow`, `meters.holdseconds`, `meters.x`, `meters.y`, `meters.scale`. Each key is ONE string literal (`getMeterPresetKey`): JsonUtil's `GetPath*` / `SetPath*` match keys verbatim and case-sensitively (only plain `GetValue` / `SetValue` lowercase), and Papyrus keeps one casing per string, so a key built from parts can take another script's casing and miss. Loaded values are clamped to the MCM's slider ranges (`_clampInt`); a preset with a different position goes through `setMetersLayout` (rebuild + preview).
- **2.2.6 leftovers.** The willpower bar had its own place (`willpowerBarX` / `Y` / `Scale`, default 640 / 640 / 60) and widget state (`_willpowerMeterId` ...), and the MCM its own option ids (`_slove_*`). The properties and controller variables are kept declared and unused because saves hold them; the MCM's option ids went with the rest of its options in 3.3.0.

### Willpower value

- **The value is a projection.** SLO VE applies recovery only when the actor's next scene starts, so `slw_interface_slove.getSloveWillpower` adds the recovery for the whole game hours since `SLOVE_LastSexTime` (`SLOVE_RecoverPerHour`, written by SLO VE 0.7.2+; 10 when missing) and treats a break (`SLOVE_BrokenPoints`) as 0 until its hours have passed, then 100. It must stay in step with `SLOVE_Resistance.CalculateStartupResistance` in the SLO VE repo; SLO VE's `docs/authors/integration.md` has the same formula. SLO VE keeps the time stamp current during a scene, which is why the bar does not climb there.
- "In a scene" is `slw_interface_slove.isInScene`: SexLab's animating faction (`SexLab.esm` 0xE50F, the test behind SexLab's own `IsActorActive`, same record on classic and P+), looked up by form id so nothing compiles against SexLab.
- To see it without a scene: change the stack's X, Y or size in the MCM (the 30 s preview). `slovetest willpower 40` (SLO VE's console command; it writes the real willpower) only shows the bar during a scene.

## Event-Driven Refresh (2.3.0)

The update loop polls every `updateInterval` seconds; some mod events pull the next pass forward so icons and meters follow a change in a second or two. Code: the "Event-driven refresh" block in `slw_widget_controller`, right after `stopUpdates`.

| Event | Sender | Delay | Notes |
|---|---|---|---|
| `fhu.playerCumUpdate` (Float, Bool) | Fill Her Up, player only | 0.2 s | after the pool's new amount is stored: fills, absorption, leaks (bursty) |
| `Apropos2WearTearChanged` (standard, sender = actor) | Apropos2 SE 1.0020+ | 0.2 s | added to the user's Apropos2 SE fork for this; stock Apropos2 sends nothing |
| `sla_UpdateComplete` (standard) | SLA NG | 0.2 s | end of SLA's scan, 120 s by default |
| `slaUpdateExposure` (Form, Float), `slaSetArousalEffect` (Form, String, Float, Int, Float, Float), `slaModArousalEffect` (Form, String, Float, Float), `slaOrgasm` (Form, Float), `SexLabOrgasm` (Form, Int, Int) | other mods asking SLA for a change, SexLab | 1.5 s | SLA applies them in its own handler, so the pass waits; SLA NG has no arousal-changed event, and direct native calls into SLA NG are left to polling |

- **Handler signatures must match the pushed arguments exactly** for `ModEvent.Create` events, or the VM never calls the handler; the table copies SLA's and FHU's own handlers.
- Registered in `startUpdates` (every game load, through `slw_system_alias`, since registrations do not survive a load), unregistered in `stopUpdates`. Events for actors that are neither the player nor in an NPC slot are ignored (`_isShown`).
- `_refreshSoon` records the time in `_refreshAt` (the refresh OWED) and re-registers the single update (which REPLACES the pending one), never sooner than `REFRESH_MIN_GAP` (1 s) after the last pass ENDED (`_lastPassEnd`), so long passes cannot run back to back; not when a refresh owed at or before then exists; and not while a pass runs, which schedules what it owes as it ends.
- `OnUpdate` is a guard around `_updatePass`. `_passRunning` is claimed before the first external call (an event arriving at that yield must see the pass as running, or the end of the pass would replace the registration the event made). A tick that arrives while a pass runs marks a refresh owed. At pass start only a refresh that is due is cleared; a later one (an SLA request still landing) stays owed. `_scheduleNextTick` ends every pass with the normal interval or the owed refresh, which waits at least `REFRESH_MIN_GAP` even when its time has gone by (it was asked for after the pass had read that value).
- `startUpdates` (every load) bumps `_passGen` and resets `_passRunning`, `_lastPassEnd` and `_refreshAt`: real-time stamps from the last session (the clock restarts near 0) would hold a refresh off for as long as that session ran. A pass the save carried over sees `_passGen` move and returns without touching the loop.

## Translation Files
- Encoding: **UTF-16LE with BOM**, CRLF line endings
- Format: `$KEY\tValue` (tab-separated)
- Must use Python (not sed) to edit — sed corrupts the UTF-16LE encoding

## HUD Coordinate System

iWant Status Bars (and any other Scaleform-based HUD widget mod) uses Skyrim's **fixed 1280×720 Flash stage**, NOT the monitor's actual pixel dimensions. Skyrim scales the rendered Flash stage to fit whatever resolution the user is running — 1080p, 1440p ultrawide, 4K, anything. The same `(X, Y)` coordinate produces the same visual position on every monitor.

**Implications for new positioning code:**
- Valid range is **0–1279 / 0–719** by default
- Bottom-right anchor for SL Widgets convention: ~1100, ~600 (matches iWant's own bottom-right of ~1210, ~650)
- Slider ranges should default to `0–1279` and `0–719` for X/Y; if you anticipate users with HUD overhauls that extend the stage, allow override (iWant offers a "Position Lock" toggle that unlocks ±10000)
- DO NOT set defaults based on monitor pixel dimensions (1920, 3840, etc.) — those values land off-stage and only render for users with extended-stage HUD mods
- Existing saves that stored off-stage coordinates from earlier dev builds (e.g., `npcGroupX = 1700`) keep those values via property persistence; document that users should reset via MCM if they want the standard stage anchor

0..1279 / 0..719 stays the rule for any position SL Widgets picks itself. iWant's own MCM is more permissive as of 2.10: its X/Y sliders derive their range from the Position Lock toggle, locked to -1280..2559 / -720..1439 (2.09 locked them to the stage, 0..1279 / 0..719) and unlocked to +-10000. That range exists for extended-stage HUD overhauls and for the Prisma renderer, which centers the stage so ultrawide margins sit at negative X. The vestigial `min_pos_*` / `max_pos_*` variables in iWant's MCM are still written by the lock toggle but no longer read.

## iWant Status Bars API requirement

SL Widgets used to ship a patched fork of `iwant_status_bars.psc` /
`_mcm.psc`. Everything in it landed upstream in iWant Status Bars 2.10, so
the fork is gone: the mod now compiles and runs against the stock release.

- Compile-time: `skyrimse.ppj` imports the two dependency folders under
  `mods/build`, each a full extract of its Nexus release with the archive
  kept beside it: `iWant Widgets 1.35/00 - Main/Source/Scripts` and
  `iWant Status Bars 2.11/00 - Main/Source/Scripts`. Bump to a new release
  by extracting it next to these and repointing the two `<Import>` lines,
  which is also why the unversioned `iwantstatusbars` / `iwantWidgets`
  folders are no longer imported. 2.11's scripts still report
  `GetVersion()` 2.10 and every comment in them says 2.10, so 2.10 is the
  API level to code against. There is no in-repo copy to shadow the
  folders any more.
- Runtime: `slw_widget_controller.hasBarsAPI()` probes `iBars.GetAPIVersion()`
  once per bars reset (2.09 and older have no such function, so the call
  errors once into the log and returns 0, which is the detection mechanism)
  and caches the result. Below API 4 the entire NPC-tracking layer is
  disabled: OnUpdate NPC loop, `reloadNpcSlot`, `_restoreNpcLabelsAndIcons`,
  `_reconcileNpcBars`, `_placeOneIconInSlotBar`, `_applyBarVisibilityToLabel`,
  the NPC loops in `reloadWidgets` / `toggleUpdateWidgets`, and the
  label-creation leaf `_ensureNpcLabel`; the assign hotkey refuses with a
  notification (clearing stays allowed), and `reloadWidgets` actively
  releases NPC icons and labels left in the save. Player tracking (slot 0)
  works on any version. The Debug MCM page shows the probe result
  (`$SLW_Iwant_SB_Patch_Check`).
- What 2.10 added that NPC tracking needs: `getBarVisible`,
  `getBarLastChangeTime`, the `_findBarOfIcon` fix (2.09 compares
  `_getBarIcon()` as Bool, and -1 is truthy, so reconciliation would
  duplicate icons every tick), and `loadIcon` guarding `_nextFreeBarPosition`
  against `bar == -1`. Any new 2.10-only iBars call MUST be gated behind
  `hasBarsAPI()`.

## External Mod API Patterns
| Mod | Access pattern |
|-----|---------------|
| MME | Direct global script calls: `MME_Storage.getMilkCurrent(playerRef)` |
| SGO4 | SGO4IF 1.12+ only. `slw_interface_sgo4.getSGO4Database()` resolves the DB via `SGO4_QuestController_Main.Get().Data`; accessors cast the `Quest` to `SGO4_QuestDatabase_Main`. The pre-1.12 `dse_sgo_*` / `dse-soulgem-oven.esp` layout is not supported |
| MAL | Bidirectional mod events: send `MAL_GetPlayerStoredMilk` / `MAL_GetPlayerMilkLimit`, cache responses from `MAL_ReturnPlayer*` events |
| Estrus Unified | `EstrusUnifiedAPI` natives (compile stub in `Source/ApiHeaders`, copied from the mod's source): `GetPregnancyType(actor)` 0/1/2/3 = none/chaurus/spider/dwemer, player and NPC alike; the pregnancy module registers itself for `OnEstrusUnifiedPregnancyChanged`. It replaces the three legacy Estrus plugins, whose form-ID blocks stay off while it is present. Source extract: `mods\build\Estrus Unified 1.1` |

## MAL Event Caching Pattern
MAL values are one tick behind by design — `_requestMALUpdate()` fires on each status update tick, return events populate `_mal_milk_cur`/`_mal_milk_max`, and `getMilkLevel()` reads the cache from the previous tick. No sleep needed.

## Icon States
- `percentToState9NotStrict(int percent)` — maps 0–100% to states 0–8 (used for milk, lactacid)
- `percentToState9(int percent)` — stricter thresholds variant
- `percentToState5(int percent)` — maps to states 0–4
