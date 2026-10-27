# MCM Reference

Since 3.3 the SL Widgets MCM only shows: whether the mod is enabled, whether its settings can be reached, and which supported mods were found. Every setting is in the [SKSE Menu](position-editor.md), section **SL Widgets**.

---

## General

| Line | Shows |
|------|-------|
| **SL Widgets** | **Enabled** or **Disabled**. A new game starts disabled: switch the mod on with **Mod enabled** on the SKSE menu's [General](position-editor.md#general) page |
| **SKSE menu** | **OK** when SKSE Menu Framework and `SLWidgetsMenu.dll` are both loaded; otherwise which one is missing. Without them nothing in SL Widgets can be changed in game |
| **Settings: SKSE menu, section SL Widgets** | Where the settings are |

---

## Maintenance

The version number heads the page, then the dependency check: **OK** or **Not Found** for every plugin SL Widgets looks for, grouped as on the [Supported Mods](supported-mods.md) page.

| Group | Plugins |
|-------|---------|
| Main | iWant Status Bars, iWant Status Bars 2.10+, SexLab Aroused, Apropos2, Fill Her Up, MME, MAL, SexLab Parasites |
| Pregnancy | the nine pregnancy mods |
| Needs | PAF, MiniNeeds, AlivePeeing, Private Needs |
| Defeat | SexLab Defeat, SLO VE |
| Survival | SunHelm, SunHelm Diseases, Bathing in Skyrim, Wet Function Redux, WetFunction NG, SPH, Stress and Fear, Blade and Blunt |

The **Reset modules** and **Add icon placeholder** buttons moved to the SKSE menu's [General](position-editor.md#general) page in 3.3.
