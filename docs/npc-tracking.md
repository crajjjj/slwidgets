# NPC Tracking

SL Widgets can track **up to three NPCs** simultaneously alongside the player. Each tracked NPC gets their own pair of iWant bars and a floating name label on-screen.

---

## Setting up the hotkey

1. Open MCM → **SL Widgets** → **NPC Tracking**.
2. Click **Pick Hotkey** and press the key you want to use.
3. Close the MCM — the hotkey is now active in-game.

---

## Assigning and clearing NPCs

Aim your crosshair directly at an NPC and press the hotkey:

| Situation | Result |
|-----------|--------|
| NPC is not tracked and a slot is free | NPC is assigned to the next available slot; bar and label appear immediately |
| NPC is already tracked | That slot is cleared; bar and label are removed |
| All 3 slots are full | Notification: "All NPC slots full — clear one in MCM" |

To clear a slot from the MCM without using the hotkey, go to **NPC Tracking** → the relevant slot → **Clear Slot**.

!!! note "Hotkey guards"
    The hotkey does nothing while any menu is open (MCM, inventory, dialogue, loading screen) or while the mod is globally disabled.

---

## Bar layout

Each NPC gets two iWant bars: a **primary** and a **secondary**. The secondary bar provides overflow space for mods like pregnancy that can produce many icons at once.

The three NPC bar pairs are stacked in a cluster:

```
NPC 3  ↑ topmost
NPC 2
NPC 1  ← anchor point (npcGroupX, npcGroupY)
```

NPC1 sits at the anchor. NPC2 and NPC3 stack upward so that when fewer slots are in use there is no dead space at the bottom of the cluster.

**Moving the cluster:** Use the **NPC Group X** and **NPC Group Y** sliders on the NPC Tracking page. Both bars for each NPC move together — you do not need to position them individually.

**Vertical spacing:** The **NPC Vertical Spacing** slider controls the gap between bar pairs (default 105 units).

**Reset layout:** The **Reset NPC bar layout** button snaps group X/Y to the default bottom-right anchor (1100, 600), resets spacing to 105, and clears all per-slot label offsets. Press it once the first time you set up NPC tracking to get the standard cluster position.

---

## Name labels

Each assigned NPC gets a floating text label above their bar showing their display name.

- The label uses the NPC's in-game display name by default.
- Set a **Custom Label** in the slot section of the NPC Tracking page to override it.
- When the NPC is in a different cell the label appends `(away)` automatically.

### Label style

The following settings apply globally to all three labels:

| Setting | Default | Description |
|---------|---------|-------------|
| Font | `$EverywhereFont` | Flash font key; 7 options available |
| Label Size | 24 | Text height in HUD units |
| Label Color | White (255, 255, 255) | Colour picker |

!!! note
    Font and size are baked in when the label is first created. Changing them destroys and recreates the label. Colour changes apply immediately without recreation.

### Per-slot fine-tuning

Each slot has individual **Label X Offset** and **Label Y Offset** sliders (±200 units) to nudge the label relative to its bar's auto-position. Use these after adjusting the global group position.

---

## Per-NPC icon configuration

Each NPC slot has 11 independent sub-toggles matching the player's options:

| Toggle | Default (NPC) |
|--------|:-------------:|
| SLA Arousal | On |
| SLA Exposure | Off |
| Apropos2 W&T | On |
| FHU Cum total | On |
| FHU Vaginal pool | Off |
| FHU Anal pool | Off |
| FHU Oral pool | Off |
| MME/SGO Milk | On |
| MME Lactacid | Off |
| SLP Parasites | Off |
| Pregnancy | On |

The defaults are tuned so that a typical NPC stays within the primary bar (~10 icons at steady state). Enable more if the secondary bar gives you room.

!!! tip "Per-slot independence"
    NPC sub-toggles are **completely independent** of the player's settings. You can show milk on an NPC while having it off for the player, or vice versa.

---

## What happens when an NPC leaves

- NPC leaves the cell or is unloaded → icons and label hide automatically.
- NPC re-enters the cell → icons and label reappear on the next update tick.
- NPC dies or is deleted → slot behaves as if the NPC is away. You can clear it manually in the MCM.

---

## Save and load behaviour

NPC slot assignments (which actor is in which slot) persist across saves. On game load:

- Widget IDs are invalid (Flash widgets don't survive saves) — SL Widgets recreates all labels and icons automatically when iWant Status Bars fires its ready event.
- Per-slot toggle settings persist.
- Custom labels persist.
- Icons appear at their neutral state briefly until the first update tick reads new values.

---

## Module support per actor type

| Module | Player | NPC |
|--------|:------:|:---:|
| SLA Arousal | Yes | Yes |
| SLA Exposure | Yes | Yes |
| Apropos2 W&T | Yes | Yes |
| FHU Cum | Yes | Yes |
| MME/SGO4 Milk | Yes | Yes |
| MAL Milk | Yes | No |
| Needs (PAF/MiniNeeds/AlivePeeing/Private Needs) | Yes | No |
| SexLab-Parasites | Yes | Yes |
| Pregnancy (all mods) | Yes | Yes |
| SLDefeat | Yes | No |

PAF, needs mods, and SLDefeat use player-only APIs or magic effects and cannot query NPC state.
