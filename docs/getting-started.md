# Getting Started

## Hard requirements

These must be installed and working before SL Widgets will function at all.

| Mod | Notes |
|-----|-------|
| **iWant Status Bars** | The HUD bar framework SL Widgets displays into. **2.10 or newer** is required for NPC tracking, and recommended for everyone: it carries bar-lookup and init-timeout fixes that affect player icons too |
| **iWant Widgets** | Widget layer that draws the icons and NPC name labels. Optionally replaceable by the [Prisma renderer](prisma.md) |
| **PapyrusUtil** | Used for preset save/load (JSON) |
| **SKSE** | Required by all of the above |
| **SkyUI** | Required for the MCM, which shows the state and the dependency check |
| **SKSE Menu Framework** | 3.8 or newer. Every setting is in its menu, enabling the mod included: see [SKSE Menu](position-editor.md) |

!!! note "Load order"
    Maintain `iwidgets.esp → ibars.esp → slwidgets.esp`. SL Widgets listens for the iBars-ready event and will not initialise without it.

!!! note "LE users"
    The FOMOD of the SE version of iWant Status Bars / iWant Widgets ships the LE version as well. The SL Widgets LE ESP also works on SE.

---

## Installation

1. Install all hard requirements first and confirm iWant Status Bars is displaying correctly.
2. Install SL Widgets via your mod manager as a normal mod. Prefer the icons from before 3.0.0? Add the optional **SLWidgets Classic Icons** download on top (see [Icon styles](customization.md#icon-styles)).
3. The ESP is **ESL-flagged** — it will not consume a load order slot on SE.
4. Launch the game, open the SKSE Menu Framework menu with its hotkey, and pick the **SL Widgets** section.

That's it. SL Widgets auto-detects which of your installed mods are present and activates only the relevant icon sets.

---

## First-time setup

### 1. Confirm mod detection

Open MCM → **SL Widgets** → **Maintenance** page. The dependency checklist shows every supported plugin and whether it was found. If an expected mod shows "Not Found", verify its ESP/ESM name matches what SL Widgets expects (see [Supported Mods](supported-mods.md)).

### 2. Configure icon placement

SL Widgets places icons into iWant Status Bars. Move and resize the bars, reorder their icons or move an icon to another bar on the SKSE menu's [Positions](position-editor.md#positions) page; iWant Status Bars' own MCM does the same and more.

### 3. Enable the mod

A new game starts with the mod disabled. On the SKSE menu's [General](position-editor.md#general) page switch on **Mod enabled**. Icons appear after the next update tick (default: 5 seconds); the MCM's General page shows **Enabled** from then on.

### 4. Set up NPC tracking (optional)

If you want to track NPCs, set a **Pick Hotkey** on the SKSE menu's [NPC Tracking](position-editor.md#npc-tracking) page, then aim at any NPC in-game and press it. See [NPC Tracking](npc-tracking.md) for the full guide.

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
- EstrusChaurus / EstrusSpider / EstrusDwemer, or Estrus Unified
- Fertility Mode 3
- Curse of Life
- SexLab-Parasites
- PAF / MiniNeeds / AlivePeeing SE / Private Needs - Orgasm
- SLDefeat
- SLO VE (a willpower bar)
- SunHelm Survival and SunHelm Diseases
- Bathing in Skyrim Renewed 2.7+
- Wet Function Redux or WetFunction NG
- SPH - Skyrim Pubic Hair 2.0+
- Stress and Fear
- Blade and Blunt 4.0+

See [Supported Mods](supported-mods.md) for exactly what each one contributes.

---

## Incompatible mods

- Mods that replace `hudmenu.gfx` / `hudmenu.swf` directly (without a merge) can prevent iWant Widgets images from rendering. If your icons disappear entirely after installing another UI mod, check for `hudmenu.swf` conflicts. The [Prisma renderer](prisma.md) sidesteps this class of conflict entirely, since it does not draw through Flash.
- Tested compatible with Tsukiro, D&DDC, Licentia, Nefaram, Masterstroke, and similar curated lists.
