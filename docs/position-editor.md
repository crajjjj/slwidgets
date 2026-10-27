# SKSE Menu

*Since 3.1.* SL Widgets' icon switches, positions and settings presets live in the [SKSE Menu Framework](https://www.nexusmods.com/skyrimspecialedition/mods/120352) menu, and apply while the menu is open, with the game in view. Three pages: **Toggles**, **Positions** and **Presets**. The [MCM](mcm-reference.md) keeps the rest: enabling the mod, the update interval, colour presets, the meter switches, NPC tracking and the dependency check.

---

## Requirements

- SKSE Menu Framework 3.8 or newer.
- The pages themselves, `SLWidgetsMenu.dll`, ship in the SL Widgets archive under `SKSE/Plugins`. They read and write the settings the scripts hold, nothing else.

Without SKSE Menu Framework SL Widgets runs as before, but the icon switches and positions can then only be changed through a [settings preset](customization.md#settings-presets): edit the preset file and load it on the MCM's General page.

---

## Opening it

1. Load a game.
2. Open the SKSE Menu Framework menu with its hotkey.
3. Pick the **SL Widgets** section, then **Toggles**, **Positions** or **Presets**.

The game freezes while the menu is open, but the widgets keep updating, so a change shows on the real icons at once. Move the framework's panel aside if it covers what you are placing.

---

## Toggles

*Since 3.2; the MCM's Toggles page before.* The player's icon switches, grouped by mod. Hover a switch for what the icon shows. A switch whose mod is not installed is greyed out and marked *(not installed)*. A switch applies within a second or two: the icon appears or goes while the menu is still open. The labels come from SL Widgets' own translation files, in the game's language.

The per-NPC switches stay on the MCM's [NPC Tracking](mcm-reference.md#npc-tracking) page, the meter switches on its Meters page.

### Stage icon groups

| Switch | Requires | Description |
|--------|----------|-------------|
| **Arousal Icon Enabled** | `SexLabAroused.esm` | Heart icon tracking arousal (9 stages) |
| **Exposure Icon Enabled** | `SexLabAroused.esm` | Eye icon tracking exposure/nudity (9 stages) |
| **W&T Icon Enabled** | `Apropos2.esp` | Three icons for vaginal, anal, and oral wear & tear (9 stages each) |
| **FHU Total Icon Enabled** | `sr_FillHerUp.esp` | Combined cum pool (9 stages) |
| **FHU Vaginal Pool Icon Enabled** | `sr_FillHerUp.esp` | Vaginal cum pool (9 stages) |
| **FHU Anal Pool Icon Enabled** | `sr_FillHerUp.esp` | Anal cum pool (9 stages) |
| **FHU Oral Pool Icon Enabled** | `sr_FillHerUp.esp` | Oral cum pool (9 stages) |
| **MME/SGO Milk Icon Enabled** | MME, SGO4, or MAL | Milk level (9 stages) |
| **MME Lactacid Icon Enabled** | `MilkModNEW.esp` | Lactacid level (9 stages) |
| **Pee Icon Enabled** | PAF, MiniNeeds, AlivePeeing, or Private Needs | Bladder fill (5 stages) |
| **Poop Icon Enabled** | PAF, MiniNeeds, or Private Needs | Bowel fill (5 stages) |
| **Food / Thirst / Cold / Fatigue Icon Enabled** | `SunHelmSurvival.esp` | SunHelm needs (9 stages each, player only) |
| **Dirtiness Icon Enabled** | `Bathing in Skyrim.esp` (Renewed) | Dirt percentage (9 stages), also per NPC slot |
| **Wetness Icon Enabled** | `WetFunctionNG.esp` or `WetFunction.esp` | Wetness (9 stages), also per NPC slot |
| **Pubic / Armpit Hair Icon Enabled** | `SPH - Skyrim Pubic Hair.esp` | Hair length (6 / 7 stages, player only) |
| **Baby Health Icon Enabled** | `BeeingFemale.esm` | Unborn health while pregnant (9 stages), also per NPC slot |
| **Stress / Fear Icon Enabled** | `Stress and Fear.esp` | Stress (9 stages) and phobia count (player only) |
| **Injuries Icon Enabled** | `BladeAndBlunt.esp` | Injury severity (4 stages, player only) |
| **Diseases Icon Enabled** | none (`SunHelmDiseases.esp` for stages 2 and 3) | Worst disease stage, shown only while a disease is held (player only) |

### Toggle icon groups

| Switch | Requires | Description |
|--------|----------|-------------|
| **Parasites Icons Enabled** | `SexLab-Parasites.esp` | Spider egg and chaurus worm infection indicators |
| **Pregnancy Icons Enabled** | Any pregnancy mod | Full set of pregnancy state icons for all detected pregnancy mods |
| **Defeat Icon Enabled** | `SexLabDefeat.esp` | Weakened/raped state indicator (player only) |

---

## Positions

*Since 3.1; the position sliders of the MCM's Meters and NPC Tracking pages before 3.2.*

| Group | Sliders | Applies |
|-------|---------|---------|
| Bar 0 to Bar 3 | X, Y, Size, Orientation (iWant's ten shapes) | X and Y follow the slider as you drag; size and orientation when you release it |
| NPC slots | X, Y, Spacing | when you release the slider; the three rows and their name labels move as one cluster |
| Meter stack | X, Y, Scale | when you release the slider; the stack rebuilds a moment later and shows itself for 30 seconds |

**Reset NPC layout** puts the cluster back in its default corner (1100, 600) with spacing 105 and clears the per-slot label offsets. Positions need iWant Status Bars to be up (the icons are showing).

What a change writes:

- **Bars 0 to 3** are iWant's shared bars: the page writes iWant's own X, Y, size and type, the same values its MCM sliders hold, so every mod's icons in that bar move with it.
- **The NPC cluster** writes the anchor of the [NPC Tracking](npc-tracking.md#bar-layout) cluster and its spacing.
- **The meter stack** writes the stack's center and size.

Values are iWant's 1280 × 720 stage units (see [Screen coordinates](customization.md#screen-coordinates)).

---

## Presets

*Since 3.2.* The [settings presets](customization.md#settings-presets): the list, with the active one marked; **Load** the one picked; **Save over** it (after a confirmation); or save the current settings under a new name with **Save as new**. A preset holds the icon switches, the meters, the NPC slot switches and, since 3.2, the layout: the player bars, the NPC cluster and the meter stack.

Loading a preset reloads every icon, which takes a second or two. The MCM's General page loads and saves presets too.

---

## Notes

- Everything the pages change lives in the save, like the MCM's settings.
- Each page has a status line with **Refresh**, which reads the values again after a change in an MCM or iWant's own menu.
- A bar iWant has hidden is marked *(hidden by iWant right now)*; it takes a move all the same.
- The pages and the scripts must come from the same SL Widgets release: an older `slw_bridge.pex` under a newer DLL shows a message on the page instead of the settings.
- On the title screen, with no game loaded, the pages say SL Widgets is not running.
