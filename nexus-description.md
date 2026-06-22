A plugin for [b]iWant Status Bars[/b] that adds adult-mod status widgets — arousal, pregnancy, milk, cum, wear & tear, needs and more — to Skyrim's HUD, for the player [b]and up to 3 NPCs[/b].

113+ icons included. Fully configurable in-game through the MCM.

[url=https://crajjjj.github.io/slwidgets/]📖 SLWidgets Wiki — full docs with icon previews[/url]

[size=5][b]✨ Features[/b][/size]
[list]
[*][b]Two icon mechanics[/b] — 9-stage gauges that fill with a mod's value (arousal, milk, cum, wear & tear, needs) and condition toggles that pop in/out (pregnancy, parasites, defeat). [url=https://crajjjj.github.io/slwidgets/icons/]See every icon →[/url]
[*][b]NPC tracking[/b] — watch up to 3 NPCs alongside the player: aim at an NPC, press a hotkey, and they get their own icon set and a floating name label. [url=https://crajjjj.github.io/slwidgets/npc-tracking/]How it works →[/url]
[*][b]Broad mod support[/b] — SexLab Aroused, Apropos2, Fill Her Up, MME / SGO4 / MAL, the major pregnancy frameworks, and more. [url=https://crajjjj.github.io/slwidgets/supported-mods/]Full list →[/url]
[*][b]Custom icon packs[/b] — restyle any icon set; grab one from the download section. [url=https://crajjjj.github.io/slwidgets/custom-packs/]Preview packs →[/url]
[*][b]Settings presets[/b] — save and load your toggle setup, handy for new saves
[/list]

[size=5][b]⚙️ Installation[/b][/size]
[list]
[*]Install with any mod manager. The SE build is ESPFE (ESL-flagged); the LE build's ESP also works on SE.
[*][b]Load order:[/b] iWant Widgets → iWant Status Bars → SLWidgets
[*](Optional) Choose which widgets are shown in the SLWidgets MCM
[*](Optional) Save / load your SLWidgets settings in the MCM — useful for new saves
[*](Optional) Set icon placement, colour and size in the iWant Status Bars MCM (multiple bars supported)
[*](Optional) Install custom icon packs from the download section (DDS textures only)
[/list]
[i]Step-by-step guide: [url=https://crajjjj.github.io/slwidgets/getting-started/]Getting Started →[/url][/i]

[b]Notes:[/b]
[list]
[*]Do not install both the ESL and ESP versions of iWant Widgets at once — they overlap and conflict
[*]LE users: the LE build of iWant Status Bars / iWant Widgets is included in the SE FOMOD
[/list]

[size=5][b]🖱️ MCM Setup[/b][/size] [i](thanks Herowynne)[/i]

[b]Step 1 — Enable the mod[/b]
Open the SLWidgets MCM → General page → toggle [b]Disable/Enable mod[/b]. The label shows the action, not the current state:
[list]
[*][b]ENABLE[/b] shown = mod is currently OFF (press to turn it on)
[*][b]DISABLE[/b] shown = mod is currently ON
[/list]
Back out and re-open the MCM to confirm.

[b]Step 2 — Configure iWant Status Bars[/b]
Open the iWant Status Bars MCM → Bars page → assign a hotkey under [b]Press to Toggle[/b], exit the MCM, and press the hotkey in-game. Adjust Type, X Position and Y Position as needed. After any change in the iWant Status Bars MCM, press the hotkey twice to refresh the display.

[i]Every menu setting explained: [url=https://crajjjj.github.io/slwidgets/mcm-reference/]MCM Reference →[/url][/i]

[size=5][b]📦 Requirements[/b][/size]

[b]Hard requirements[/b]
[list]
[*]iWant Status Bars
[*]iWant Widgets
[*]PapyrusUtil
[*]SKSE & SkyUI (for the MCM)
[/list]

[b]Soft dependencies[/b] — install only the ones you use
[list]
[*]SexLab Aroused SE (any version, including SLAX)
[*]Apropos2 SE (ESL/ESP)
[*]Fill Her Up — Baka Edition 1.90+
[*]Milk Mod Economy
[*]Mammaries And Lactation (MAL)
[*]SGO4 IF (1.10 hotfix)
[*]SexLab Parasites
[*]Fertility Mode v3 Fixes and Tweaks / FM Reloaded
[*]HentaiPregnancy
[*]BeeingFemale
[*]Egg Factory 3.0+
[*]EstrusChaurus / EstrusSpider / EstrusDwemer
[*]PAF
[*]MiniNeeds
[*]Alive Peeing SSE
[*]Private Needs - Orgasm
[*]SLDefeat
[*]Curse of Life (1.13.2+)
[/list]
[i]Which icons each mod adds: [url=https://crajjjj.github.io/slwidgets/supported-mods/]Supported Mods →[/url][/i]

[size=5][b]🔧 Troubleshooting[/b][/size]
[list]
[*]Check console messages and Papyrus logs
[*]Make sure only one iWidgets.esp is loaded
[*]Check the MCM Debug page for dependency status
[*]Toggle the mod off / on — widgets reload when the MCM closes
[*]Open the iWant Status Bars MCM to confirm icons were registered
[*][b]NPC labels missing?[/b] Confirm the pick hotkey is bound, the NPC is loaded (same cell), and the mod is enabled
[*][b]NPC icons in the player's bar?[/b] Press [b]Reset NPC bar layout[/b] once on the NPC Tracking page
[/list]
[i]More fixes and log locations: [url=https://crajjjj.github.io/slwidgets/troubleshooting/]Troubleshooting →[/url][/i]

[size=5][b]🎨 Custom Icons[/b][/size]

Want ready-made styles? Grab a pack from the download section — [url=https://crajjjj.github.io/slwidgets/custom-packs/]preview them on the wiki[/url]. To make your own, place icons in [font=Courier New]\Interface\exported\widgets\iwant\widgets\library[/font] following the existing naming convention. Format: [b].dds[/b], 100×100 px, BC3 compression, no mipmaps (GIMP can export this). [url=https://crajjjj.github.io/slwidgets/customization/]Full guide →[/url]

[i]Thanks to all contributors.[/i]
