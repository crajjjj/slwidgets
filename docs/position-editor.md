# Position Editor

*Since 3.1.* A **Positions** page in the SKSE Menu Framework menu: X, Y, size and orientation of the status bars, the NPC slot cluster and the meter stack as sliders, with the icons moving on the HUD as you change them, the menu still open.

---

## Requirements

- [SKSE Menu Framework](https://www.nexusmods.com/skyrimspecialedition/mods/120352) 3.8 or newer. Without it SL Widgets works exactly as before; the page is simply absent and the MCM sliders remain.
- The page itself, `SLWidgetsMenu.dll`, ships in the SL Widgets archive under `SKSE/Plugins`. It reads and writes the same positions the MCMs hold, nothing else.

---

## Opening it

1. Load a game and let iWant Status Bars come up (the icons are showing).
2. Open the SKSE Menu Framework menu with its hotkey.
3. Pick the **SL Widgets** section, then **Positions**.

The game freezes while the menu is open, but the widgets keep updating, so a change shows on the real icons at once. Move the framework's panel aside if it covers the bar you are placing.

---

## What is on the page

| Group | Sliders | Applies |
|-------|---------|---------|
| Bar 0 to Bar 3 | X, Y, Size, Orientation (iWant's ten shapes) | X and Y follow the slider as you drag; size and orientation when you release it |
| NPC slots | X, Y, Spacing | when you release the slider; the three rows and their name labels move as one cluster |
| Meter stack | X, Y, Scale | when you release the slider; the stack rebuilds a moment later and shows itself for 30 seconds |

Above the sliders a status line says whether the layout was read, with **Refresh** to read it again (after a change in iWant's MCM, or a loaded preset). **Reset NPC layout** puts the cluster back in its default corner (1100, 600).

---

## What a change writes

- **Bars 0 to 3** are iWant's shared bars: the page writes iWant's own X, Y, size and type, the same values its MCM sliders hold, so every mod's icons in that bar move with it.
- **The NPC cluster** writes the *NPC group X / Y* and *spacing* of the [NPC Tracking](npc-tracking.md) page.
- **The meter stack** writes *Meters X / Y / Scale* of the Meters page.

All of it lives in the save like the MCM's settings, and goes into settings presets the same way. Values are iWant's 1280 × 720 stage units (see [Screen coordinates](customization.md#screen-coordinates)).

---

## Notes

- A bar iWant has hidden is marked *(hidden by iWant right now)*; it takes a move all the same.
- The page and the scripts must come from the same SL Widgets release: an older `slw_bridge.pex` under a newer DLL shows a message on the page instead of the sliders.
- On the title screen, with no game loaded, the page says SL Widgets is not running.
