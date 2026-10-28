# SKSE Menu

Since 3.3 every SL Widgets setting lives in the [SKSE Menu Framework](https://www.nexusmods.com/skyrimspecialedition/mods/120352) menu, section **SL Widgets**, and applies while the menu is open, with the game in view. The [MCM](mcm-reference.md) only shows whether the mod is enabled and which supported mods were found.

---

## Requirements

- **SKSE Menu Framework 3.8 or newer: required.** SL Widgets starts disabled on a new game, and it is switched on here. Without the framework the mod cannot be enabled or set up in game; the MCM's General page says so.
- The pages themselves, `SLWidgetsMenu.dll`, ship in the SL Widgets archive under `SKSE/Plugins`. They read and write the settings the scripts hold, nothing else.

---

## Opening it

1. Load a game.
2. Open the SKSE Menu Framework menu with its hotkey.
3. Pick the **SL Widgets** section, then a page: **General**, **Toggles**, **Meters**, **NPC Tracking**, **Positions** or **Presets**.

The game freezes while the menu is open, but the widgets keep updating, so a change shows on the real icons at once. Move the framework's panel aside if it covers what you are placing. Hover a setting for what it does.

---

## General

| Setting | Default | Description |
|---------|---------|-------------|
| **Mod enabled** | Off | Starts or stops SL Widgets. Stopping removes every icon and stops the update script; starting loads the icons switched on. A new game starts with the mod off, and the switch waits until iWant Status Bars is up (a few seconds after a load) |
| **Update interval** | 5 | Seconds between status checks (1-60). Changes that SLA, Fill Her Up or Apropos2 SE 1.0020+ report (see [Supported Mods](supported-mods.md)) are checked within a second or two whatever the interval |
| **Color Preset** | Default | The icon colour scheme: the `.json` files in `SKSE/Plugins/SlWidgets/IconPresets/` (see [Color presets](customization.md#color-presets)) |

**Maintenance:**

| Button | Description |
|--------|-------------|
| **Reset modules** | Rechecks every supported mod and sets the modules up again. Use it after installing or removing a supported mod mid-session. Available while the mod is enabled |
| **Add icon placeholder** | Loads a transparent placeholder icon into an iWant bar seat, to reserve space when arranging a bar by hand |

---

## Toggles

*Since 3.2.* The player's icon switches, grouped by mod. A switch whose mod is not installed is greyed out and marked *(not installed)*. A switch applies within a second or two: the icon appears or goes while the menu is still open. The labels come from SL Widgets' own translation files, in the game's language.

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

## Meters

Bars rather than status icons: one stack of iWant Widgets meters, for the player only, each with an icon to its left. See [Supported Mods](supported-mods.md#meter-stack). The stack's place and size are on the [Positions](#positions) page.

| Setting | Default | Description |
|---------|---------|-------------|
| **Always Show Meters** | Off | On: every meter stays on screen. Off: a meter appears when its value moves by 5 points or more, or its icon changes stage, and fades out again after the time below. The willpower meter keeps its own rule either way: up during a scene, while willpower is below 100 |
| **Fade Out After** | 10 | Seconds a meter stays up after a change (2-120). Greyed out while meters are always shown |

One switch per meter, grouped by mod, in the order they stack; a switch is greyed out while its mod is not installed. All are off by default:

| Switch | Requires | Description |
|--------|----------|-------------|
| **Willpower Meter Enabled** | `SLOVE.esp` | SLO VE willpower, during a scene: see [Supported Mods](supported-mods.md#slo-ve-willpower-bar) |
| **Arousal Meter Enabled** | `SexLabAroused.esm` | SexLab Aroused arousal |
| **FHU Total / Vaginal Pool / Anal Pool / Oral Pool Meter Enabled** | `sr_FillHerUp.esp` | Fill Her Up pools |
| **Vaginal / Anal / Oral W&T Meter Enabled** | `Apropos2.esp` | Apropos2 wear and tear |

A change rebuilds the stack within a second or two, and it then shows whole for half a minute so you can see where it sits.

---

## NPC Tracking

How tracking works is on the [NPC Tracking](npc-tracking.md) page.

| Setting | Default | Description |
|---------|---------|-------------|
| **Pick Hotkey** | none | **Set**, then press a key: aiming at an NPC and pressing it tracks that NPC in a free slot, pressing it on a tracked NPC stops. **Clear** removes the key. Escape closes the menu rather than becoming the key |
| **Font** | Default (Everywhere) | Font of the three name labels; changing it recreates them |
| **Size** | 24 | Text height of the labels (10-60); changing it recreates them |
| **Label Color** | White | Colour of the labels, applied as you pick it |

Per slot (NPC 1 to 3, named after the actor tracked there; greyed out while the slot is empty):

| Setting | Description |
|---------|-------------|
| **Clear Slot** | Stops tracking that NPC: its icons and label go |
| Icon switches | Arousal, Exposure, W&T, FHU total / vaginal / anal / oral, Milk, Lactacid, Parasites, Pregnancy, Dirtiness, Wetness, Baby health. Independent of the player's switches |
| **Label Offset X / Y** | Nudge the label (±200) from its place above the slot's bar |
| **Custom label** | Shown in place of the actor's name; empty uses the name. Applied on Enter or when you leave the field |

---

## Positions

| Group | Sliders | Applies |
|-------|---------|---------|
| Icon spacing | Spacing % (80-300), **iWant default** | when you release the slider |
| Bar 0 to Bar 3 | X, Y, Size, Orientation (iWant's ten shapes) | X and Y follow the slider as you drag; size and orientation when you release it |
| NPC slots | X, Y, Spacing | when you release the slider; the three rows and their name labels move as one cluster |
| Meter stack | X, Y, Scale | when you release the slider; the stack rebuilds a moment later and shows itself for 30 seconds |

**Reset NPC layout** puts the cluster back in its default corner (1100, 600) with spacing 105 and clears the per-slot label offsets. Positions need iWant Status Bars to be up (the icons are showing).

What a change writes:

- **Icon spacing** (*since 3.4.1*) is how far a line bar (left, right, up, down) puts each icon from the one before, in % of the icon size. iWant's own step is 150, which leaves a gap of about half an icon; 100 puts the icons edge to edge. It is a single iWant value for every line bar, so it changes the NPC bars and other mods' bars too. Circles and half circles keep their shape. iWant saves it with the game; **iWant default** puts back 150.
- **Bars 0 to 3** are iWant's shared bars: the page writes iWant's own X, Y, size and type, the same values its MCM sliders hold, so every mod's icons in that bar move with it.
- **The NPC cluster** writes the anchor of the [NPC Tracking](npc-tracking.md#bar-layout) cluster and its spacing.
- **The meter stack** writes the stack's center and size.

Values are iWant's 1280 × 720 stage units (see [Screen coordinates](customization.md#screen-coordinates)).

### Icons in the bars

*Since 3.3.* Under each player bar, **Icons** lists the icons it holds, in the order the bar draws them, with the mod each comes from. **^** and **v** move an icon one place along its bar; **to 0** ... **to 3** move it to the first free place of another player bar (greyed out while that bar is full, ten icons). Any mod's icon in those bars can be moved, as in iWant's own MCM.

A move lasts until iWant loads that icon again, which puts it back in the first free place: when its switch goes off and on, a preset is loaded, the mod is enabled, or for an icon that comes and goes with its state (pregnancy, diseases, injuries). Then move it again.

---

## Presets

*Since 3.2.* The [settings presets](customization.md#settings-presets): the list, with the active one marked; **Load** the one picked; **Save over** it (after a confirmation); or save the current settings under a new name with **Save as new**. A preset holds the icon switches, the meters, the NPC slot switches and, since 3.2, the layout: the player bars, the NPC cluster and the meter stack (since 3.4.1 the icon spacing too; an older preset leaves the spacing as it is).

Loading a preset reloads every icon, which takes a second or two.

---

## Notes

- Everything the pages change lives in the save.
- Each page has a status line with **Refresh**, which reads the values again after a change in iWant's own menu or on another page.
- A bar iWant has hidden is marked *(hidden by iWant right now)*; it takes a move all the same.
- The pages and the scripts must come from the same SL Widgets release: an older `slw_bridge.pex` under a newer DLL shows a message on the page instead of the settings.
- On the title screen, with no game loaded, the pages say SL Widgets is not running.
