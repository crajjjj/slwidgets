Download on Nexus: https://www.nexusmods.com/skyrimspecialedition/mods/164162

A plugin for iWant Status Bars that adds adult-mod status widgets — arousal, pregnancy, milk, cum, wear & tear, needs and more — to Skyrim's HUD, for the player and up to 3 NPCs.

210+ icons. Configured in game through the SKSE Menu Framework menu; the MCM shows the state.

Full docs, icon previews, custom packs and guides: https://crajjjj.github.io/slwidgets/


✨ Features

- Two icon mechanics: 9-stage gauges that fill with a mod's value (arousal, milk, cum, wear & tear, needs) and condition toggles that pop in/out (pregnancy, parasites, defeat)
- NPC tracking: watch up to 3 NPCs alongside the player: aim at an NPC, press a hotkey, and they get their own icon set and a floating name label
- Broad mod support: SexLab Aroused, Apropos2, Fill Her Up, MME / SGO4 / MAL, the major pregnancy frameworks, and more
- Meters: SLO VE willpower, arousal, the Fill Her Up pools and Apropos2 wear & tear as one stack of bars at the right edge of the screen, each with its icon beside it, always shown or fading in when a value changes; each meter is switched on in the SKSE menu
- Survival and body status (3.0): SunHelm food, thirst, cold and fatigue, or Survival Mode hunger, cold and exhaustion (stock or Survival Mode Improved, 3.5); Bathing in Skyrim Renewed dirtiness and Wet Function (Redux or NG) wetness; Dirt and Blood dirt and blood or Just Blood bloodstains (3.5); SPH pubic and armpit hair; BeeingFemale baby health; Stress and Fear; Blade and Blunt injuries; Combat Wound wounds (3.5); diseases (SunHelm Diseases stages)
- One drawn icon set (3.0): every icon in the same style, white to red as a value worsens. Prefer the old icons? The installer offers them as the Classic icons option, now for every set
- Custom icon packs: restyle any icon set; grab one from the download section
- SKSE menu (3.1, 3.2): icon switches, positions and presets in the SKSE Menu Framework menu; icons move on the HUD as you change them
- Settings presets: save and load your switches and layout, handy for new saves


⚙️ Installation

- Install with any mod manager. The SE build is ESPFE (ESL-flagged); the LE build's ESP also works on SE.
- Load order: iWant Widgets → iWant Status Bars → SLWidgets
- (Optional) Choose which icons are shown, and where, in the SKSE Menu Framework menu, section SL Widgets
- (Optional) Save / load your SLWidgets settings on its Presets page, useful for new saves
- (Optional) Set icon placement, colour and size in the iWant Status Bars MCM (multiple bars supported)
- (Optional) Pick the Classic icons in the installer (the icons from before 3.0, now for every set), or install a custom icon pack from the download section (DDS textures only)

Notes:
- Do not install both the ESL and ESP versions of iWant Widgets at once — they overlap and conflict
- LE users: the LE build of iWant Status Bars / iWant Widgets is included in the SE FOMOD


🖱️ Setup

Step 1: enable the mod
Open the SKSE Menu Framework menu (its hotkey) → section SL Widgets → General → switch on Mod enabled. A new game starts with the mod off. The SLWidgets MCM's General page shows Enabled from then on, and says so if SKSE Menu Framework is missing.

Step 2: place the icons
The Positions page moves and resizes iWant's bars, reorders their icons and moves icons between bars while you watch the HUD; iWant Status Bars' own MCM does the same and more.


📦 Requirements

Hard requirements
- iWant Status Bars (2.10 or newer for NPC tracking)
- iWant Widgets
- PapyrusUtil
- SKSE & SkyUI
- SKSE Menu Framework 3.8+ (every setting is in its menu)

Soft dependencies — install only the ones you use
- SexLab Aroused SE (any version, including SLAX)
- Apropos2 SE (ESL/ESP)
- Fill Her Up — Baka Edition 1.90+
- Milk Mod Economy
- Mammaries And Lactation (MAL)
- SGO4 IF 1.12+ (merged builds only — the old base-mod layout is not supported)
- SexLab Parasites
- Fertility Mode v3 Fixes and Tweaks / FM Reloaded
- HentaiPregnancy
- BeeingFemale
- Egg Factory 3.0+
- EstrusChaurus / EstrusSpider / EstrusDwemer / Estrus Unified
- PAF
- MiniNeeds
- Alive Peeing SSE
- Private Needs - Orgasm
- SLDefeat
- Curse of Life (1.13.2+)
- SLO VE 0.7.2+ (willpower shown as a bar with a brain icon, player only)
- SunHelm Survival and SunHelm Diseases
- Survival Mode (Creation Club), stock or Survival Mode Improved
- Bathing in Skyrim Renewed 2.7+
- Dirt and Blood - Dynamic Visual Effects 2.2+
- Wet Function Redux or WetFunction NG
- SPH - Skyrim Pubic Hair 2.0+
- Stress and Fear
- Blade and Blunt 4.0+
- Just Blood - Dirt and Blood Lite
- Combat Wound (with SlaveTats and Fade Tattoos)


🔧 Troubleshooting

- Check console messages and Papyrus logs
- Make sure only one iWidgets.esp is loaded
- Check the MCM Maintenance page for dependency status
- Toggle the mod off / on on the SKSE menu's General page
- Open the iWant Status Bars MCM to confirm icons were registered
- NPC labels missing? Confirm the pick hotkey is bound, the NPC is loaded (same cell), and the mod is enabled
- NPC icons in the player's bar? Press Reset NPC bar layout once on the NPC Tracking page

Incompatible mods
- Affected indirectly by mods that impact iWant Widgets. Mods significantly altering hudmenu.gfx directly or via a hudmenu.swf file may prevent image display.
- Tested without issues in several mod lists with multiple UI mods (Tsukiro / D&DDC / Licentia / Nefaram / Masterstroke).


🎨 Custom Icons

Want ready-made styles? Grab a pack from the download section. To make your own, place icons in \Interface\exported\widgets\iwant\widgets\library following the existing naming convention. Format: .dds, 100×100 px, BC3 compression, no mipmaps (GIMP can export this).


🔗 Links

- Changelog: https://github.com/crajjjj/slwidgets/releases
- GitHub: https://github.com/crajjjj/slwidgets


Thanks to:

- randomuser123two — aroused icons
- markdf — the idea
- Saber2th — custom FHU icons
- coreoveride — fetus icon
- dragonlord217 — colon icons
