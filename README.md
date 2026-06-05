SexLab Widgets SSE
=======================

A plugin for iWant Status Bars that adds SexLab-related widgets to Skyrim. Two display mechanics:
- Icons with 9 stages that change dynamically (arousal, milk fill, etc.)
- Icons that appear/disappear on a condition (parasites, pregnancy states, defeat)

113+ icons included. MCM for flexible configuration. Track both the player **and up to three NPCs** simultaneously, each with their own icon set and on-screen name label.


## Supported plugins and icons

### 1) Stages (constantly showing status)

- **SLA SE** (SexLab Aroused / Aroused eXtended / SLAM) — Arousal (face), Exposure (heart)
- **Apropos2** — wear & tear icons (vagina, anus, mouth state)
- **Fill Her Up (Baka)** — cum icons (total + vaginal + anal + oral pool)
- **MME / SGO4 / MAL** — milk (breast), lactacid (bottle)
- **PAF / MiniNeeds / AlivePeeing / Private Needs** — piss (bladder), poop (colon)

### 2) Toggles (appear only on condition)

- **SexLab-Parasite** — spider eggs, chaurus worms (when infected)
- **Pregnancy**: HentaiPregnancy, BeeingFemale, EggFactory, EstrusChaurus, EstrusSpider, EstrusDwemer, SGO4, FM3, Curse of Life — cum inflation, ovulation, trimester icons, fetus, eggs, spider eggs, dwemer spheres, soul gems
- **Defeat**: SLDefeat — weakened/raped (hands on body)


## NPC tracking

Watch up to 3 NPCs alongside the player. Each tracked NPC gets their own bar pair and a floating name label.

### How to use

1. Open MCM → **NPC Tracking** page
2. Bind a **Pick Hotkey** (any free key)
3. In-game: aim at any NPC and press the hotkey
   - **Empty slot available** → that NPC is assigned to the next free slot, their bar + label appear
   - **Already tracking** that NPC → that NPC's slot is cleared (toggle off)
   - **All 3 slots full** → notification asks you to clear one in MCM first
4. Press the **Reset NPC bar layout** button once to apply the default bottom-right cluster layout

### Layout model

- NPC1 anchors at the bottom of the cluster — when only one NPC is assigned, the bar sits near the screen bottom with no empty space below it
- NPC2 stacks above NPC1, NPC3 above NPC2
- Each NPC gets **two iWant bars** (20 icon positions) so heavily-configured NPCs don't overflow
- The whole cluster moves as one via **NPC group X** / **NPC group Y** sliders — no need to position each bar individually
- Bars 7–9 (default NPC range) leave bars 0–6 (70 positions) to the player and other addons

### Note on monitor resolutions and widescreen

iWant Status Bars (and SL Widgets through it) uses Skyrim's **fixed 1280×720 Flash HUD stage** — Skyrim scales it to fit any monitor. The same X/Y values produce the same on-screen position whether you're on 1080p, 1440p ultrawide, 4K, or 32:9 super-ultrawide. **Widescreen users do not need different coordinates than 1080p users.**

NPC group sliders: X goes 0–2560, Y goes 0–719. The 16:9 safe area ends at X=1279 — going past it requires a HUD overhaul (SkyHUD, etc.) that extends the Flash stage horizontally; without one, icons past 1279 are clipped. For ultrawide users with an extended-stage HUD: ~1680 fills 21:9, ~2560 fills 32:9. The default `npcGroupX = 1100, npcGroupY = 600` matches iWant's bottom-right anchor convention within the standard stage.

### Per-NPC controls (per slot)

- **Clear Slot** — unassign that NPC
- **11 sub-toggles** matching the player's: SLA Arousal/Exposure, Apropos2, FHU Cum/Anal/Vaginal/Oral, MME Milk/Lactacid, SLP, Pregnancy
- **Label X / Y offset** sliders — fine-tune the name label's position relative to the bar

### Default NPC sub-toggles

Optimised to fit in one bar at steady state (~10 icons):

| ON | OFF |
|----|-----|
| SLA Arousal, Apropos2, FHU Cum (total), MME Milk, Pregnancy | SLA Exposure, FHU Anal/Vaginal/Oral, MME Lactacid, SLP |

Enable more per NPC if needed — the secondary bar absorbs overflow.

### Modules that work on NPCs

All except **PAF** (player-only API) and **SLDefeat** (player-only magic effect). The other 6 modules all support per-actor queries.

### Behavior

- Hotkey is blocked while menus are open and while the mod is disabled
- NPC leaves cell / dies / despawns → their icons and label automatically hide; re-appear when they're back in range
- NPC slots persist across save/load — labels and icons are recreated on game load
- Per-slot toggles are **independent** of the player's — you can show milk on the player and on an NPC with arousal off, etc.


## Installation

- Install as any other mod. SE version is ESL-flagged. (LE version's ESP works for SE as well.)
- (Optional) Flexible icon configuration via SLWidgets MCM
- (Optional) Save SLWidget properties via MCM (load for new saves — saved presets now include per-NPC toggles)
- (Optional) Configure icon placement/color/size in iWant Status Bars MCM. You can use multiple bars
- (Optional) Use custom icon packs from the download section. Install as any other mod (DDS icons only)

### Notes on installation

- Maintain the load order **iwidgets → ibars → slwidgets**. SLWidgets relies on the ibars-ready event.
- The LE version of iWant Status Bars / iWant Widgets is included in the FOMOD of the SE version.
- Check the Incompatible mods section below.

## Hard Requirements

- iWant Status Bars
- iWant Widgets
- PapyrusUtil
- SKSE / SkyUI (for MCM)

## Soft Dependencies

- SexLab Aroused SE (any version, including SLAX)
- Apropos2 SE
- Fill Her Up
- Fertility Mode 3
- HentaiPregnancy
- BeeingFemale
- EggFactory
- SexLab-Parasite
- EstrusChaurus
- EstrusSpider
- EstrusDwemer
- PAF (player only)
- MiniNeeds (player only)
- AlivePeeing SE (player only)
- Private Needs - Orgasm (player only)
- MAL (Mammaries And Lactation, player only)
- SGO4 (Soul Gem Oven, supports NPCs)
- Curse of Life (player only)
- SLDefeat (player only)

## Incompatible mods

- Affected indirectly by mods that impact iWant Widgets. Mods significantly altering `hudmenu.gfx` directly or via a `hudmenu.swf` file may prevent image display.
- Tested without issues in different mod lists with multiple UI mods (Tsukiro / D&DDC / Licentia / Nefaram / Masterstroke).
- In heavy script-load mod lists, iBars may misbehave — icons overlapping or stacking. Workaround: disable icons → save and load (or fast travel) → enable icons.

## Troubleshooting

- Make sure you have only one `iWidgets.esp` plugin
- Check console messages
- Check Papyrus logs and SLWidgets user log
- Check MCM Debug page and dependency check
- Try to disable/enable plugin (widgets are reloaded on menu close)
- Check the ibars menu — confirm icons were added
- **NPC labels not appearing?** Confirm the hotkey is bound; check the NPC is loaded (same cell); confirm the mod isn't disabled
- **NPC icons mixed into the player's bar?** Click "Reset NPC bar layout" once in the NPC Tracking page

## Customization

You can use your own icons. Put them into `Interface\exported\widgets\iwant\widgets\library\...` — follow the naming convention already in place.

Supported icon format: **.dds**, **100x100 px**, **BC3 compression**, no mipmaps. GIMP can export this format.
