Download on Nexus: https://www.nexusmods.com/skyrimspecialedition/mods/164162

A plugin for iWant Status Bars that adds adult-mod status widgets — arousal, pregnancy, milk, cum, wear & tear, needs and more — to Skyrim's HUD, for the player and up to 3 NPCs.

113+ icons included. Fully configurable in-game through the MCM.

Full docs, icon previews, custom packs and guides: https://crajjjj.github.io/slwidgets/


✨ Features

- Two icon mechanics — 9-stage gauges that fill with a mod's value (arousal, milk, cum, wear & tear, needs) and condition toggles that pop in/out (pregnancy, parasites, defeat)
- NPC tracking — watch up to 3 NPCs alongside the player: aim at an NPC, press a hotkey, and they get their own icon set and a floating name label
- Broad mod support — SexLab Aroused, Apropos2, Fill Her Up, MME / SGO4 / MAL, the major pregnancy frameworks, and more
- Custom icon packs — restyle any icon set; grab one from the download section
- Settings presets — save and load your toggle setup, handy for new saves


⚙️ Installation

- Install with any mod manager. The SE build is ESPFE (ESL-flagged); the LE build's ESP also works on SE.
- Load order: iWant Widgets → iWant Status Bars → SLWidgets
- (Optional) Choose which widgets are shown in the SLWidgets MCM
- (Optional) Save / load your SLWidgets settings in the MCM — useful for new saves
- (Optional) Set icon placement, colour and size in the iWant Status Bars MCM (multiple bars supported)
- (Optional) Install custom icon packs from the download section (DDS textures only)

Notes:
- Do not install both the ESL and ESP versions of iWant Widgets at once — they overlap and conflict
- LE users: the LE build of iWant Status Bars / iWant Widgets is included in the SE FOMOD


🖱️ MCM Setup (thanks Herowynne)

Step 1 — Enable the mod
Open the SLWidgets MCM → General page → toggle Disable/Enable mod. The label shows the action, not the current state:
- ENABLE shown = mod is currently OFF (press to turn it on)
- DISABLE shown = mod is currently ON
Back out and re-open the MCM to confirm.

Step 2 — Configure iWant Status Bars
Open the iWant Status Bars MCM → Bars page → assign a hotkey under Press to Toggle, exit the MCM, and press the hotkey in-game. Adjust Type, X Position and Y Position as needed. After any change in the iWant Status Bars MCM, press the hotkey twice to refresh the display.


📦 Requirements

Hard requirements
- iWant Status Bars
- iWant Widgets
- PapyrusUtil
- SKSE & SkyUI (for the MCM)

Soft dependencies — install only the ones you use
- SexLab Aroused SE (any version, including SLAX)
- Apropos2 SE (ESL/ESP)
- Fill Her Up — Baka Edition 1.90+
- Milk Mod Economy
- Mammaries And Lactation (MAL)
- SGO4 IF (1.10 hotfix)
- SexLab Parasites
- Fertility Mode v3 Fixes and Tweaks / FM Reloaded
- HentaiPregnancy
- BeeingFemale
- Egg Factory 3.0+
- EstrusChaurus / EstrusSpider / EstrusDwemer
- PAF
- MiniNeeds
- Alive Peeing SSE
- Private Needs - Orgasm
- SLDefeat
- Curse of Life (1.13.2+)


🔧 Troubleshooting

- Check console messages and Papyrus logs
- Make sure only one iWidgets.esp is loaded
- Check the MCM Debug page for dependency status
- Toggle the mod off / on — widgets reload when the MCM closes
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
