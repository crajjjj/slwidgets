# Getting Started

## Hard requirements

These must be installed and working before SL Widgets will function at all.

| Mod | Notes |
|-----|-------|
| **iWant Status Bars** | The HUD bar framework SL Widgets displays into |
| **iWant Widgets** | Flash widget layer used for NPC name labels |
| **PapyrusUtil** | Used for preset save/load (JSON) |
| **SKSE** | Required by all of the above |
| **SkyUI** | Required for the MCM menu |

!!! note "Load order"
    Maintain `iwidgets.esp → ibars.esp → slwidgets.esp`. SL Widgets listens for the iBars-ready event and will not initialise without it.

!!! note "LE users"
    The FOMOD of the SE version of iWant Status Bars / iWant Widgets ships the LE version as well. The SL Widgets LE ESP also works on SE.

---

## Installation

1. Install all hard requirements first and confirm iWant Status Bars is displaying correctly.
2. Install SL Widgets via your mod manager as a normal mod.
3. The ESP is **ESL-flagged** — it will not consume a load order slot on SE.
4. Launch the game, open the MCM, and find **SL Widgets** in the list.

That's it. SL Widgets auto-detects which of your installed mods are present and activates only the relevant icon sets.

---

## First-time setup

### 1. Confirm mod detection

Open MCM → **SL Widgets** → **Debug** page. The dependency checklist shows every supported plugin and whether it was found. If an expected mod shows "Not Found", verify its ESP/ESM name matches what SL Widgets expects (see [Supported Mods](supported-mods.md)).

### 2. Configure icon placement

SL Widgets places icons into iWant Status Bars. To reposition, resize, or recolour them, use the **iWant Status Bars MCM**. You can spread icons across multiple bars if desired.

### 3. Enable the mod

On the MCM **General** page the mod starts disabled. Flip the **Enable/Disable Mod** toggle. Icons appear after the next update tick (default: 5 seconds).

### 4. Set up NPC tracking (optional)

If you want to track NPCs, go to MCM → **NPC Tracking**, bind a **Pick Hotkey**, then aim at any NPC in-game and press it. See [NPC Tracking](npc-tracking.md) for the full guide.

---

## Soft dependencies

None of these are required. SL Widgets detects them at runtime and silently skips any that are absent.

- SexLab Aroused SE (any version including SLAX / SLAM)
- Apropos2 SE
- Fill Her Up (Baka)
- Milk Mod Economy (MME)
- Soul Gem Oven 4 (SGO4)
- Mammaries and Lactation (MAL)
- HentaiPregnancy
- BeeingFemale
- EggFactory
- EstrusChaurus / EstrusSpider / EstrusDwemer
- Fertility Mode 3
- Curse of Life
- SexLab-Parasites
- PAF / MiniNeeds / AlivePeeing SE / Private Needs - Orgasm
- SLDefeat

See [Supported Mods](supported-mods.md) for exactly what each one contributes.

---

## Incompatible mods

- Mods that replace `hudmenu.gfx` / `hudmenu.swf` directly (without a merge) can prevent iWant Widgets images from rendering. If your icons disappear entirely after installing another UI mod, check for `hudmenu.swf` conflicts.
- Tested compatible with Tsukiro, D&DDC, Licentia, Nefaram, Masterstroke, and similar curated lists.
