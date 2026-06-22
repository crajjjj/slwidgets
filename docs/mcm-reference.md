# MCM Reference

SL Widgets adds a four-page MCM menu accessible from SkyUI.

---

## General

Core enable/disable control, update timing, and preset management.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| **Enable/Disable Mod** | Toggle | Off | Master switch. Disabling unloads all modules and hides all icons. Enabling reloads and starts the update loop. |
| **Update Interval** | Slider 1–60 | 5 | Seconds between status checks. Lower values are more responsive but add script overhead. |
| **Settings Preset** | Menu | Default | Load a saved settings preset (toggles + per-NPC state). Presets are `.json` files in `SKSE/Plugins/SlWidgets/SettingsPresets/`. |
| **Save Settings Preset** | Button | — | Save the current state (update interval, color preset, all player toggles, all per-NPC toggles) to the active preset. Prompts before overwriting. |
| **Color Preset** | Menu | Default | Load an icon color scheme. Presets are `.json` files in `SKSE/Plugins/SlWidgets/IconPresets/`. |

---

## Toggles

Enable or disable individual icon groups. Settings are organised by mod.

### Stage icon groups

| Setting | Requires | Description |
|---------|----------|-------------|
| **Arousal Icon Enabled** | `SexLabAroused.esm` | Face icon tracking arousal (9 stages) |
| **Exposure Icon Enabled** | `SexLabAroused.esm` | Heart icon tracking exposure/nudity (9 stages) |
| **W&T Icon Enabled** | `Apropos2.esp` | Three icons for vaginal, anal, and oral wear & tear (9 stages each) |
| **FHU Total Icon Enabled** | `sr_FillHerUp.esp` | Combined cum pool (9 stages) |
| **FHU Vaginal Pool Icon Enabled** | `sr_FillHerUp.esp` | Vaginal cum pool (9 stages) |
| **FHU Anal Pool Icon Enabled** | `sr_FillHerUp.esp` | Anal cum pool (9 stages) |
| **FHU Oral Pool Icon Enabled** | `sr_FillHerUp.esp` | Oral cum pool (9 stages) |
| **MME/SGO Milk Icon Enabled** | MME, SGO4, or MAL | Milk level (9 stages) |
| **MME Lactacid Icon Enabled** | `MilkModNEW.esp` | Lactacid level (9 stages) |
| **Pee Icon Enabled** | PAF, MiniNeeds, AlivePeeing, or Private Needs | Bladder fill (9 stages) |
| **Poop Icon Enabled** | PAF, MiniNeeds, or Private Needs | Bowel fill (9 stages) |

### Toggle icon groups

| Setting | Requires | Description |
|---------|----------|-------------|
| **Parasites Icons Enabled** | `SexLab-Parasites.esp` | Spider egg and chaurus worm infection indicators |
| **Pregnancy Icons Enabled** | Any pregnancy mod | Full set of pregnancy state icons for all detected pregnancy mods |
| **Defeat Icon Enabled** | `SexLabDefeat.esp` | Weakened/raped state indicator (player only) |

---

## NPC Tracking

Configure the NPC bar cluster and per-slot settings.

### Global NPC settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| **Pick Hotkey** | Key bind | Unset | In-game key for assigning/clearing NPC slots via crosshair |
| **NPC Group X** | Slider 0–2560 | 1100 | Horizontal position of the NPC1 anchor (standard stage: 0–1279) |
| **NPC Group Y** | Slider 0–719 | 600 | Vertical position of the NPC1 anchor |
| **NPC Vertical Spacing** | Slider 50–200 | 105 | Distance between each stacked NPC bar pair |
| **Reset NPC bar layout** | Button | — | Resets group X/Y to (1100, 600), spacing to 105, and clears per-slot label offsets |

### Label style (global)

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| **Font** | Menu | `$EverywhereFont` | Flash font key used for all NPC name labels. Changing it recreates all labels. |
| **Label Size** | Slider 10–60 | 24 | Text height. Changing it recreates all labels. |
| **Label Color** | Color picker | White | RGB colour applied to all three NPC name labels |

### Per-slot settings (NPC Slot 1 / 2 / 3)

Each slot has the same set of controls:

| Setting | Type | Description |
|---------|------|-------------|
| **Clear Slot** | Button | Unassign the NPC and remove their icons and label |
| **Arousal Icon Enabled** | Toggle | Per-slot SLA arousal |
| **Exposure Icon Enabled** | Toggle | Per-slot SLA exposure |
| **W&T Icon Enabled** | Toggle | Per-slot Apropos2 wear & tear |
| **FHU Total Icon Enabled** | Toggle | Per-slot FHU total cum |
| **FHU Vaginal Pool Icon Enabled** | Toggle | Per-slot FHU vaginal |
| **FHU Anal Pool Icon Enabled** | Toggle | Per-slot FHU anal |
| **FHU Oral Pool Icon Enabled** | Toggle | Per-slot FHU oral |
| **MME/SGO Milk Icon Enabled** | Toggle | Per-slot milk |
| **MME Lactacid Icon Enabled** | Toggle | Per-slot lactacid |
| **Parasites Icons Enabled** | Toggle | Per-slot parasite indicators |
| **Pregnancy Icons Enabled** | Toggle | Per-slot pregnancy indicators |
| **Label X Offset** | Slider −200 – +200 | Fine-tune the label's horizontal position relative to the bar |
| **Label Y Offset** | Slider −200 – +200 | Fine-tune the label's vertical position relative to the bar |
| **Custom Label** | Text input | Override the NPC's display name in their label |

---

## Debug

Maintenance utilities and dependency status. Version number is shown in the header.

| Setting | Description |
|---------|-------------|
| **Reset Modules** | Rechecks all mod dependencies and reinitialises modules. Use if you installed or removed a supported mod mid-session. |
| **Dependency Check: Main** | Shows OK / Not Found for: iWant Status Bars, SexLab Aroused, Apropos2, Fill Her Up, MME, MAL, SexLab-Parasites |
| **Dependency Check: Pregnancy** | Shows OK / Not Found for all nine pregnancy plugins |
| **Dependency Check: Needs** | Shows OK / Not Found for PAF, MiniNeeds, AlivePeeing, Private Needs |
| **Dependency Check: Defeat** | Shows OK / Not Found for SLDefeat |
| **Add Icon Placeholder** | Loads a transparent placeholder icon into an iWant bar slot. Useful for reserving space when manually arranging your bar layout. |
