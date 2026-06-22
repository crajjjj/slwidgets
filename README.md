SL Widgets SSE
==============

A plugin for **iWant Status Bars** that shows SexLab-related status icons for the player **and up to three NPCs** — arousal, milk, wear & tear, cum, pregnancy, parasites, needs and more. 113+ icons, all configurable in the MCM.

📖 **Full documentation:** https://crajjjj.github.io/slwidgets/

## Features

- **9-stage gauges** (arousal, milk, cum, wear & tear, needs…) and **condition toggles** (pregnancy, parasites, defeat). Browse them all in the [Icon Gallery](https://crajjjj.github.io/slwidgets/icons/).
- **Track up to 3 NPCs** alongside the player, each with its own icon set and floating name label — see [NPC Tracking](https://crajjjj.github.io/slwidgets/npc-tracking/).
- **Broad mod support** (SexLab Aroused, Apropos2, Fill Her Up, MME/SGO4/MAL, the major pregnancy frameworks, and more) — see [Supported Mods](https://crajjjj.github.io/slwidgets/supported-mods/).
- **Custom icon packs** to restyle the look — see [Custom Icon Packs](https://crajjjj.github.io/slwidgets/custom-packs/).
- Position, colour, size and toggles tuned in the **MCM** — see the [MCM Reference](https://crajjjj.github.io/slwidgets/mcm-reference/).

## Requirements

- iWant Status Bars
- iWant Widgets
- PapyrusUtil
- SKSE / SkyUI

Load order: **iWidgets → iBars → SL Widgets** (SL Widgets relies on the iBars-ready event).

Every SexLab / pregnancy / needs integration is **optional** — install only the ones you use. Full list with per-mod notes: [Supported Mods](https://crajjjj.github.io/slwidgets/supported-mods/).

## Installation

Install with any mod manager (the SE build is ESL-flagged; the LE plugin also works on SE), keep the load order above, then configure in the SL Widgets MCM. Step-by-step instructions: [Getting Started](https://crajjjj.github.io/slwidgets/getting-started/).

Custom icon packs (optional `.dds`-only downloads) install the same way — see [Custom Icon Packs](https://crajjjj.github.io/slwidgets/custom-packs/).

## Compatibility

Works alongside common UI overhauls. Mods that heavily alter `hudmenu.gfx`/`hudmenu.swf` can stop the icons from drawing. In very heavy script loads icons may overlap — disable, save/load, then re-enable. More fixes on the [Troubleshooting](https://crajjjj.github.io/slwidgets/troubleshooting/) page.

## Documentation

| Page | What's there |
|------|--------------|
| [Getting Started](https://crajjjj.github.io/slwidgets/getting-started/) | Install & first-time setup |
| [Supported Mods](https://crajjjj.github.io/slwidgets/supported-mods/) | Every integration + requirements |
| [Icon Gallery](https://crajjjj.github.io/slwidgets/icons/) | Preview of every icon |
| [Custom Icon Packs](https://crajjjj.github.io/slwidgets/custom-packs/) | Alternative icon styles |
| [NPC Tracking](https://crajjjj.github.io/slwidgets/npc-tracking/) | Tracking up to 3 NPCs |
| [MCM Reference](https://crajjjj.github.io/slwidgets/mcm-reference/) | Every menu setting |
| [Customization](https://crajjjj.github.io/slwidgets/customization/) | Make your own icons |
| [Troubleshooting](https://crajjjj.github.io/slwidgets/troubleshooting/) | Logs, fixes, common issues |
