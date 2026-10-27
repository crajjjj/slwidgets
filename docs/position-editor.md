# Position Editor

*Since 3.1.* An in-game editor that lets you **drag** the status bars, the NPC slot cluster and the meter stack into place on the HUD, instead of reading coordinates off sliders.

---

## Requirements

- [SKSE Menu Framework](https://www.nexusmods.com/skyrimspecialedition/mods/120352) 3.8 or newer. Without it SL Widgets works exactly as before; the editor is simply absent and the MCM sliders remain.
- The editor itself, `SLWidgetsMenu.dll`, ships in the SL Widgets archive under `SKSE/Plugins`. It never changes anything on its own: it only reads and writes the same positions the MCMs hold.

---

## Opening it

1. Load a game and let iWant Status Bars come up (the icons are showing).
2. Open the SKSE Menu Framework menu with its hotkey.
3. Pick the **SL Widgets** section, then **Position editor**, then **Open the position editor**.

The game freezes while the editor is open, but the widgets keep updating, so a move shows on the real icons a moment after you release it.

---

## What you see

| Box | Colour | What it is |
|-----|--------|------------|
| Bar 0 to Bar 3 | blue | iWant's player bars, each with its icons. A bar iWant has hidden is drawn dimmer and labelled *(hidden)* |
| NPC 1 to NPC 3 | green | the NPC slot cluster, one row per slot with the tracked actor's name, moved as one |
| Meters | orange | the meter stack, one row per meter switched on |

A faint rectangle marks iWant's 1280 × 720 stage, which matters on an ultrawide screen (see [Screen coordinates](customization.md#screen-coordinates)).

The toolbar shows the link's status, the selected box's coordinates, and the buttons below.

---

## Controls

| Action | Effect |
|--------|--------|
| Drag a box | moves it; the position is written when you release |
| Click a box, then arrow keys | nudges by 1, with ++shift++ by 10 |
| ++plus++ / ++minus++ | icon size of a bar; scale of the meter stack |
| **Snap to 10** | positions land on a 10-unit grid |
| **Refresh** | reads the layout again, after a change in iWant's MCM or a loaded preset |
| **Reset NPC layout** | the cluster back to its default corner (1100, 600) |
| **Done** or ++esc++ | closes the editor |

---

## What a move changes

- **Bars 0 to 3** are iWant's shared bars: a move writes iWant's X and Y, the same values its MCM sliders hold, so every mod's icons in that bar move with it.
- **The NPC cluster** writes the *NPC group X / Y* of the [NPC Tracking](npc-tracking.md) page; the slots keep their spacing.
- **The meter stack** writes *Meters X / Y / Scale* of the Meters page. The stack rebuilds a moment after a move and then shows its 30-second preview, so you can see it outside a scene.

All of it lives in the save like the MCM's settings, and goes into settings presets the same way.

---

## Notes

- The icons in the editor are their first-stage art, drawn white: a preview of where they sit. The real icons keep their stage and colour.
- A custom icon pack in a BSA shows as empty boxes in the preview; the editor reads loose files. The boxes move all the same.
- On SKSE Menu Framework 3.8 the framework's own panel stays open behind the editor; drag it aside. Newer framework builds let the editor hide it.
- The editor and the scripts must come from the same SL Widgets release: an older `slw_bridge.pex` under a newer DLL shows a message in the toolbar instead of a layout.
