# Customization

---

## Icon placement and sizing

SL Widgets displays icons through iWant Status Bars. All placement, sizing, and recolouring of individual icons is done in the **iWant Status Bars MCM**, not in the SL Widgets MCM. Refer to iWant's documentation for how to:

- Move bars to different screen positions
- Change icon size
- Adjust bar orientation (horizontal / vertical)
- Show or hide specific bars

SL Widgets picks up layout changes on the next update tick — no reload required.

---

## Screen coordinates

iWant Status Bars (and SL Widgets through it) uses Skyrim's **fixed 1280 × 720 Flash stage**. Skyrim scales this stage to fit any monitor. The same X/Y coordinate produces the same visual position on every resolution — 1080p, 1440p, 4K, and ultrawide all use the same values.

| Area | X range | Y range |
|------|---------|---------|
| Standard 16:9 stage | 0–1279 | 0–719 |
| 21:9 ultrawide (extended stage) | up to ~1680 | 0–719 |
| 32:9 super-ultrawide (extended stage) | up to ~2560 | 0–719 |

!!! warning
    Going past X = 1279 on a standard stage clips icons. Extended-stage coordinates only work with a HUD mod that widens the Flash stage (SkyHUD, True Directional Movement, etc.).

The NPC cluster sliders on the NPC Tracking page default to `npcGroupX = 1100, npcGroupY = 600` to match iWant's own bottom-right anchor convention within the standard stage.

---

## Color presets

Color presets replace the default icon RGB values with custom ones without changing the icon graphics.

**Preset files:** `Data/SKSE/Plugins/SlWidgets/IconPresets/*.json`

Load a preset in MCM → **General** → **Color Preset**.

### File format

```json
{
  ".IconName": {
    "r": [200, 150, 100, ...],
    "g": [50, 80, 120, ...],
    "b": [255, 240, 200, ...],
    "a": [255, 255, 255, ...]
  }
}
```

Each key is an icon base name prefixed with `.`. The arrays contain one value per state (0–8 for 9-stage icons). The `Default` preset is always available as a fallback.

---

## Settings presets

Settings presets save and restore all MCM toggle state in one step — useful for switching between characters or playstyles.

**Preset files:** `Data/SKSE/Plugins/SlWidgets/SettingsPresets/*.json`

A saved preset includes:

- Update interval
- Active color preset
- All 14 player-level icon toggles
- All per-NPC sub-toggles for slots 1–3

**To save:** MCM → General → **Save Settings Preset** (enter a name, confirm).  
**To load:** MCM → General → **Settings Preset** menu → select and confirm.

---

## Custom icon packs

Prefer ready-made alternatives? See the [Custom Icon Packs](custom-packs.md) page for community packs that restyle the arousal, Fill Her Up, and pregnancy icons — install one and let it overwrite the stock textures.

To make your own, you can replace or add icons by dropping `.dds` files into the appropriate iWant library folder.

**Path:** `Data/Interface/exported/widgets/iwant/widgets/library/...`

Follow the naming convention already used by SL Widgets (visible in the installed files).

**Icon format requirements:**

| Property | Value |
|----------|-------|
| Format | DDS |
| Compression | BC3 (DXT5) |
| Size | 100 × 100 px |
| Mipmaps | None |

GIMP can export DDS in BC3 without mipmaps. Photoshop requires the Intel Texture Works plugin or similar.

!!! tip
    Swapping a `.dds` file replaces the icon for every character and NPC using that icon name. Icon names include the slot suffix for NPC variants (`Arousal_NPC1.dds`, `Arousal_NPC2.dds`, `Arousal_NPC3.dds`).
