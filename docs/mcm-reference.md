# MCM Reference

SL Widgets adds a four-page MCM menu accessible from SkyUI. Since 3.2 the icon switches, the positions and a second home for the settings presets are in the [SKSE Menu](position-editor.md).

---

## General

Core enable/disable control, update timing, and preset management.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| **Enable/Disable Mod** | Toggle | Off | Master switch. Disabling unloads all modules and hides all icons. Enabling reloads and starts the update loop. |
| **Update Interval** | Slider 1-60 | 5 | Seconds between status checks. Lower values are more responsive but add script overhead. Changes that SLA, Fill Her Up or Apropos2 SE 1.0020+ report (see [Supported Mods](supported-mods.md)) are checked within a second or two whatever the interval. |
| **Settings Preset** | Menu | Default | Load a saved settings preset (switches, per-NPC state, meters, layout). Presets are `.json` files in `SKSE/Plugins/SlWidgets/SettingsPresets/`. |
| **Save Settings Preset** | Button | - | Save the current state (update interval, color preset, all player switches, all per-NPC switches, everything on the Meters page, and the layout of the player bars, the NPC cluster and the meter stack) to the active preset. Prompts before overwriting. |
| **Color Preset** | Menu | Default | Load an icon color scheme. Presets are `.json` files in `SKSE/Plugins/SlWidgets/IconPresets/`. |
| **Switches, positions, presets: SKSE menu** | Text | - | Where the settings that left the MCM in 3.2 are: see [SKSE Menu](position-editor.md) |

---

## Toggles (moved)

Since 3.2 the player icon switches are on the SKSE menu's [Toggles](position-editor.md#toggles) page, which lists them all with the mods they need.

---

## Meters

Bars rather than status icons: one stack of iWant Widgets meters with one place and one size, for the player only. Each meter has an icon to its left: the brain for willpower, otherwise that value's status icon. See [Supported Mods](supported-mods.md#meter-stack).

### Stack settings

Left column.

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| **Always Show Meters** | Toggle | Off | On: every meter stays on screen. Off: a meter appears when its value moves by 5 points or more, or its icon changes stage, and fades out again after the time below. The willpower meter keeps its own rule either way: up during a scene, while willpower is below 100 |
| **Fade Out After** | Slider 2-120 s | 10 | How long a meter stays up after a change. Greyed out while meters are always shown |

The stack's position and size are on the SKSE menu's [Positions](position-editor.md#positions) page (the MCM's sliders before 3.2): at the right edge, half way down, 60% by default.

### Meter switches

Right column, grouped by mod, in the order the meters stack from the top. A switch is greyed out when its mod is not installed.

| Setting | Requires | Description |
|---------|----------|-------------|
| **Willpower Meter Enabled** | `SLOVE.esp` | SLO VE willpower, during a scene: see [Supported Mods](supported-mods.md#slo-ve-willpower-bar) |
| **Arousal Meter Enabled** | `SexLabAroused.esm` | SexLab Aroused arousal |
| **FHU Total / Vaginal Pool / Anal Pool / Oral Pool Meter Enabled** | `sr_FillHerUp.esp` | Fill Her Up pools |
| **Vaginal / Anal / Oral W&T Meter Enabled** | `Apropos2.esp` | Apropos2 wear and tear |

All off by default: switch on the meters you want. A change to the switches takes effect when the menu closes, and then the whole stack, willpower included, is shown for half a minute so you can see where it sits.

---

## NPC Tracking

Configure the NPC bar cluster and per-slot settings.

### Global NPC settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| **Pick Hotkey** | Key bind | Unset | In-game key for assigning/clearing NPC slots via crosshair |

The cluster's position and spacing, and the reset to its default corner, are on the SKSE menu's [Positions](position-editor.md#positions) page (the MCM's sliders before 3.2).

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
| **Dependency Check: Defeat** | Shows OK / Not Found for SLDefeat and SLO VE |
| **Add Icon Placeholder** | Loads a transparent placeholder icon into an iWant bar slot. Useful for reserving space when manually arranging your bar layout. |
