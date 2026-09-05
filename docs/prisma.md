# Prisma Renderer

**Optional.** SL Widgets works fully on the standard Flash renderer — nothing on this page is required.

[iWant Widgets — Prisma Edition](https://github.com/crajjjj/iwantprismwidgets) is a drop-in replacement for the *rendering layer* underneath iWant Status Bars. It draws the icons through [PrismaUI](https://www.nexusmods.com/skyrimspecialedition/mods/148718) (an HTML/Ultralight overlay) instead of Scaleform/Flash.

It replaces only the part that paints pixels. **iWant Status Bars, its MCM, SL Widgets, and existing `.dds` icon packs all run unchanged** — same script API, same coordinates, same settings.

---

## What it changes

| | Flash (default) | Prisma Edition |
|---|---|---|
| Icon sharpness | 1280 × 720 stage upscaled by the game | Rendered at your monitor's native resolution |
| Save loads | Widgets die with the HUD menu and are rebuilt every load | The overlay survives loads; icons are rebuilt once per session |
| `hudmenu.swf` conflicts | UI overhauls that replace it can stop icons drawing entirely | Unaffected — no Flash involved |
| Icon formats | `.dds` only | `.dds`, `.png`, `.jpg`, animated `.gif` |
| Ultrawide margins | Unreachable without an extended-stage HUD mod | Reachable via negative X |
| VR | Works | **Not supported** |

---

## Requirements and installation

| Requirement | Notes |
|-------------|-------|
| **SKSE** + Address Library | Standard SKSE plugin requirements |
| **PrismaUI** | Plus its own requirements |
| **iWant Widgets** (the original) | Must stay **installed and enabled** — see below |
| **iWant Status Bars** | Unchanged, untouched |

!!! warning "Keep the original iWant Widgets enabled"
    The Prisma Edition ships **no icon textures** and deliberately uses the *same* plugin and script filenames as the original. Install it at **higher priority** so it overrides the original's plugin and scripts, while the original keeps supplying the `.dds` icon library and its load-order slot.

    Disabling or uninstalling the original will leave you with missing icons.

Install it like any mod, above the original iWant Widgets in your mod manager's priority order. Nothing needs configuring afterwards.

!!! note "Switching mid-playthrough"
    Safe in both directions — the widget scripts hold no meaningful save state. Expect a few one-time Papyrus log warnings about the original's orphaned quest on the first load after switching.

---

## Animated and alternate-format icons

With the Prisma renderer, SL Widgets automatically prefers a `.gif` and then a `.png` sibling of each icon's `.dds`, applied uniformly across all of that icon's states. To animate the arousal heart, drop `aroused0.gif` … `aroused8.gif` beside the existing `.dds` files — no configuration.

| Format | Result |
|--------|--------|
| `.dds` | Static (the default; BC3/DXT5, 100 × 100) |
| `.png` / `.jpg` | Static, no DDS conversion needed |
| `.gif` | **Animated**, per-frame delays honoured |

!!! warning "Alternate-format packs are Prisma-only"
    Ship all states of one icon in the same format. A pack containing both `.dds` and `.png` will pick the `.png` on the **Flash** renderer too, which cannot decode it — so the icon renders as nothing. Label such packs as requiring the Prisma renderer.

Icon paths and naming are otherwise identical to [Customization](customization.md#custom-icon-packs).

---

## Ultrawide positioning

The Prisma renderer centres the fixed 1280 × 720 stage rather than letting the game stretch it, so on ultrawide monitors the usable **left** margin sits at *negative* X — roughly −200 on 21:9 and −640 on 32:9. The right margin extends past 1279 as before.

Both the iWant Status Bars MCM and the SL Widgets NPC group sliders accept **−1280 … 2560** for X and **−720 … 719** for Y with position lock on (unlocking still opens ±10000). Because coordinates are icon *centres*, small negative values also let a bar tuck flush against the screen edge on any monitor.

See [Screen coordinates](customization.md#screen-coordinates) for the standard-stage ranges.

---

## Known differences

- **Transitions snap** to their final value instead of animating. Fades end exactly where the Flash original ended them, and autohide delays are still honoured — only the intermediate frames are gone.
- **`.swf` custom widgets cannot render** (they need Scaleform). They are logged and skipped.
- **Meters** are a close stylistic approximation of SkyUI's meter rather than a pixel match.
- **VR is not supported** — PrismaUI limitation. VR users stay on the Flash renderer.

---

## Troubleshooting

If icons disappear entirely after switching, check in this order:

1. The original iWant Widgets is still **installed and enabled** (it provides the textures).
2. The Prisma Edition sits at **higher priority** than the original.
3. PrismaUI is installed and its own requirements are met.
4. Check `Documents/My Games/Skyrim Special Edition/SKSE/iWantWidgetsPrisma.log` — it names any icon file it could not read or decode.

Everything else on the [Troubleshooting](troubleshooting.md) page applies unchanged.
