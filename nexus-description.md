A plugin for [b]iWant Status Bars[/b] that adds adult-mod status widgets — arousal, pregnancy, milk, cum, wear & tear, needs and more — to Skyrim's HUD, for the player [b]and up to 3 NPCs[/b].

210+ icons. Configured in game through the SKSE Menu Framework menu; the MCM shows the state.

[url=https://crajjjj.github.io/slwidgets/]📖 SLWidgets Wiki — full docs with icon previews[/url]

[size=5][b]✨ Features[/b][/size]
[list]
[*][b]Two icon mechanics[/b]: 9-stage gauges that fill with a mod's value (arousal, milk, cum, wear & tear, needs) and condition toggles that pop in/out (pregnancy, parasites, defeat). [url=https://crajjjj.github.io/slwidgets/icons/]See every icon →[/url]
[*][b]NPC tracking[/b]: watch up to 3 NPCs alongside the player: aim at an NPC, press a hotkey, and they get their own icon set and a floating name label. [url=https://crajjjj.github.io/slwidgets/npc-tracking/]How it works →[/url]
[*][b]Broad mod support[/b]: SexLab Aroused, Apropos2, Fill Her Up, MME / SGO4 / MAL, the major pregnancy frameworks, and more. [url=https://crajjjj.github.io/slwidgets/supported-mods/]Full list →[/url]
[*][b]Meters[/b]: SLO VE willpower, arousal, the Fill Her Up pools and Apropos2 wear & tear as one stack of bars at the right edge of the screen, each with its icon beside it, always shown or fading in when a value changes; each meter is switched on in the SKSE menu. [url=https://crajjjj.github.io/slwidgets/supported-mods/#meter-stack]How they work →[/url]
[*][b]Survival and body status[/b] (3.0): SunHelm food, thirst, cold and fatigue; Bathing in Skyrim Renewed dirtiness and Wet Function (Redux or NG) wetness; SPH pubic and armpit hair; BeeingFemale baby health; Stress and Fear; Blade and Blunt injuries; diseases (SunHelm Diseases stages). [url=https://crajjjj.github.io/slwidgets/supported-mods/#survival-hygiene-and-health-300]Details →[/url]
[*][b]One drawn icon set[/b] (3.0): every icon in the same style, white to red as a value worsens. Prefer the old icons? The [b]Classic Icons[/b] optional file puts them back. [url=https://crajjjj.github.io/slwidgets/customization/#icon-styles]See the set →[/url]
[*][b]Custom icon packs[/b]: restyle any icon set; grab one from the download section. [url=https://crajjjj.github.io/slwidgets/custom-packs/]Preview packs →[/url]
[*][b]SKSE menu[/b] (3.1, 3.2): icon switches, positions and presets in the SKSE Menu Framework menu; icons move on the HUD as you change them. [url=https://crajjjj.github.io/slwidgets/position-editor/]How it works →[/url]
[*][b]Settings presets[/b]: save and load your switches and layout, handy for new saves
[/list]

[size=5][b]⚙️ Installation[/b][/size]
[list]
[*]Install with any mod manager. The SE build is ESPFE (ESL-flagged); the LE build's ESP also works on SE.
[*][b]Load order:[/b] iWant Widgets → iWant Status Bars → SLWidgets
[*](Optional) Choose which icons are shown, and where, in the SKSE Menu Framework menu, section SL Widgets
[*](Optional) Save / load your SLWidgets settings on its Presets page, useful for new saves
[*](Optional) Set icon placement, colour and size in the iWant Status Bars MCM (multiple bars supported)
[*](Optional) Install the Classic Icons file (the icons from before 3.0) or a custom icon pack from the download section (DDS textures only)
[/list]
[i]Step-by-step guide: [url=https://crajjjj.github.io/slwidgets/getting-started/]Getting Started →[/url][/i]

[b]Notes:[/b]
[list]
[*]Do not install both the ESL and ESP versions of iWant Widgets at once — they overlap and conflict
[*]LE users: the LE build of iWant Status Bars / iWant Widgets is included in the SE FOMOD
[/list]

[size=5][b]🖱️ Setup[/b][/size]

[b]Step 1: enable the mod[/b]
Open the SKSE Menu Framework menu (its hotkey) → section [b]SL Widgets[/b] → [b]General[/b] → switch on [b]Mod enabled[/b]. A new game starts with the mod off. The SLWidgets MCM's General page shows [b]Enabled[/b] from then on, and says so if SKSE Menu Framework is missing.

[b]Step 2: place the icons[/b]
The [b]Positions[/b] page moves and resizes iWant's bars, reorders their icons and moves icons between bars while you watch the HUD; iWant Status Bars' own MCM does the same and more.

[i]Every setting explained: [url=https://crajjjj.github.io/slwidgets/position-editor/]SKSE Menu →[/url][/i]

[size=5][b]📦 Requirements[/b][/size]

[b]Hard requirements[/b]
[list]
[*]iWant Status Bars (2.10 or newer for NPC tracking)
[*]iWant Widgets
[*]PapyrusUtil
[*]SKSE & SkyUI
[*]SKSE Menu Framework 3.8+ (every setting is in its menu)
[/list]

[b]Soft dependencies[/b] — install only the ones you use
[list]
[*]SexLab Aroused SE (any version, including SLAX)
[*]Apropos2 SE (ESL/ESP)
[*]Fill Her Up — Baka Edition 1.90+
[*]Milk Mod Economy
[*]Mammaries And Lactation (MAL)
[*]SGO4 IF 1.12+ (merged builds only — the old base-mod layout is not supported)
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
[*]SLO VE 0.7.2+ (willpower shown as a bar with a brain icon, player only)
[*]SunHelm Survival and SunHelm Diseases
[*]Bathing in Skyrim Renewed 2.7+
[*]Wet Function Redux or WetFunction NG
[*]SPH - Skyrim Pubic Hair 2.0+
[*]Stress and Fear
[*]Blade and Blunt 4.0+
[/list]
[i]Which icons each mod adds: [url=https://crajjjj.github.io/slwidgets/supported-mods/]Supported Mods →[/url][/i]

[size=5][b]🔧 Troubleshooting[/b][/size]
[list]
[*]Check console messages and Papyrus logs
[*]Make sure only one iWidgets.esp is loaded
[*]Check the MCM Maintenance page for dependency status
[*]Toggle the mod off / on on the SKSE menu's General page
[*]Open the iWant Status Bars MCM to confirm icons were registered
[*][b]NPC labels missing?[/b] Confirm the pick hotkey is bound, the NPC is loaded (same cell), and the mod is enabled
[*][b]NPC icons in the player's bar?[/b] Press [b]Reset NPC layout[/b] once on the SKSE menu's Positions page
[/list]
[i]More fixes and log locations: [url=https://crajjjj.github.io/slwidgets/troubleshooting/]Troubleshooting →[/url][/i]

[size=5][b]🎨 Custom Icons[/b][/size]

Want ready-made styles? Grab a pack from the download section — [url=https://crajjjj.github.io/slwidgets/custom-packs/]preview them on the wiki[/url]. To make your own, place icons in [font=Courier New]\Interface\exported\widgets\iwant\widgets\library[/font] following the existing naming convention. Format: [b].dds[/b], 100×100 px, BC3 compression, no mipmaps (GIMP can export this). [url=https://crajjjj.github.io/slwidgets/customization/]Full guide →[/url]

[i]Thanks to all contributors.[/i]
