# Supported Mods

SL Widgets auto-detects installed plugins at startup. No configuration is required to enable a mod — just have it installed and SL Widgets will pick it up. You can still individually toggle each icon group in the MCM if you want to hide certain sets.

---

## Stage icons

Stage icons display a continuously-updating 9-state bar (empty → full). They are always visible when enabled.

### SexLab Aroused SE

*Requires:* `SexLabAroused.esm` (any flavour: SLA SE, SLAX, SLAM)

| Icon | Description |
|------|-------------|
| **Arousal** | Face icon, 9 stages tracking the actor's arousal value |
| **Exposure** | Heart icon, 9 stages tracking the actor's exposure/nudity level |

NPC support: **Yes** — both icons work per-actor.

---

### Apropos2 — Wear & Tear

*Requires:* `Apropos2.esp`

| Icon | Description |
|------|-------------|
| **Vaginal W&T** | 9 stages tracking vaginal wear state |
| **Anal W&T** | 9 stages tracking anal wear state |
| **Oral W&T** | 9 stages tracking oral wear state |

NPC support: **Yes** — all three W&T icons work per-actor.

---

### Fill Her Up (Baka)

*Requires:* `sr_FillHerUp.esp`

| Icon | Description |
|------|-------------|
| **Cum total** | 9 stages tracking the combined cum pool |
| **Vaginal pool** | 9 stages tracking vaginal cum only |
| **Anal pool** | 9 stages tracking anal cum only |
| **Oral pool** | 9 stages tracking oral cum only |

NPC support: **Yes** — all four FHU icons work per-actor.

!!! tip
    For NPC slots the default configuration shows **Cum total** only to save bar space. Enable the per-orifice icons in the NPC Tracking page per slot if you want the detail.

---

### Milk — MME / SGO4 / MAL

At least one of the three milk mods must be installed for milk icons to appear.

| Plugin | Notes |
|--------|-------|
| `MilkModNEW.esp` | Milk Mod Economy — NPC support |
| `SGO4IF.esp` | Soul Gem Oven 4 Integration Fork 1.12+ — NPC support |
| `Mammaries And Lactation.esp` | MAL — **player only** (event-based API) |

| Icon | Description |
|------|-------------|
| **Milk** | Breast icon, 9 stages tracking current milk level |
| **Lactacid** | Bottle icon, 9 stages tracking lactacid (MME only) |

NPC support: **Milk icon** — Yes (via MME or SGO4 APIs, not MAL). **Lactacid icon** — Yes (MME only).

---

### Needs — PAF / MiniNeeds / AlivePeeing / Private Needs

Any combination of the supported needs mods can be installed; SL Widgets checks each and uses whichever is present.

| Plugin | Provides |
|--------|----------|
| `PeeAndFart.esp` or `Paf Fixes and Addons.esp` | Pee + poop |
| `MiniNeeds.esp` | Pee + poop |
| `AlivePeeingSE.esp` | Pee only |
| `Private Needs - Orgasm.esp` | Pee + poop |

| Icon | Description |
|------|-------------|
| **Pee** | Bladder icon, 9 stages |
| **Poop** | Bowel icon, 9 stages |

NPC support: **No** — all needs mods use player-only APIs. These icons show only on the player bar.

---

## Toggle icons

Toggle icons appear when a condition is met and disappear when it clears. They do not show a gradual state — they are either visible or hidden.

### SexLab-Parasites

*Requires:* `SexLab-Parasites.esp`

| Icon | Condition |
|------|-----------|
| **Spider Eggs** | Active spider egg infection |
| **Chaurus Worms** | Active chaurus worm infection (vaginal variant) |

NPC support: **Yes**.

---

### Pregnancy

*Requires:* Any one of the mods below.

SL Widgets detects all installed pregnancy mods and shows the relevant icon set for each.

| Plugin | Icons provided |
|--------|----------------|
| `HentaiPregnancy.esm` | Cum inflation, ovulation, trimester 1/2/3, fetus |
| `BeeingFemale.esm` | Pregnancy state variants |
| `EggFactory.esp` | Egg states |
| `EstrusChaurus.esp` | Chaurus egg states |
| `EstrusSpider.esp` | Spider egg states |
| `EstrusDwemer.esp` | Dwemer sphere states |
| `Fertility Mode.esm` | Cycle and pregnancy states |
| `CurseOfLife.esp` | Curse of Life pregnancy states |
| `SGO4IF.esp` | SGO4 soul gem pregnancy states |

NPC support: **Yes** for all pregnancy mods.

!!! note
    Pregnancy can momentarily spike to 5–7 visible icons when multiple mods are installed. NPC slots have a secondary bar (20 extra icon positions) to absorb overflow.

---

### SLDefeat

*Requires:* `SexLabDefeat.esp`

| Icon | Condition |
|------|-----------|
| **Defeat** | Player is in a weakened/raped state |

NPC support: **No** - SLDefeat uses a player-only magic effect.

---

### SLO VE (willpower bar)

*Requires:* `SLOVE.esp` (SLO VE 0.7.2 or newer)

Not a status icon but a **bar**: an iWant Widgets meter with a brain icon beside it, showing the player's [willpower](https://crajjjj.github.io/SLOVE/resistance/) during a scene.

| State | What you see |
|-------|--------------|
| Outside a scene | Nothing: the bar is hidden, whatever willpower is left |
| In a scene, willpower at `100` | Nothing: the bar is hidden |
| In a scene, below `100` | The bar, filled to the current willpower, draining as the scene goes on |
| In a scene, broken (`0`) | The bar flashes and empties, and the icon turns red |

The value is read from the StorageUtil keys SLO VE publishes, with the recovery since the last scene worked out, so the bar starts a scene where SLO VE will. Whether the player is in a scene is asked of SexLab's animating faction. Position, size and the on/off switch are on the **Meters** page of the MCM, right column. The bar is updated on the normal update interval (5 seconds by default), so it comes and goes up to that long after the scene does.

NPC support: **No** - the bar is for the player.

---

## Meter stack

*Requires:* any of SexLab Aroused, Fill Her Up, Apropos2

The same values as some of the stage icons above, also shown as **bars**: one iWant Widgets meter per value, stacked at the right edge of the screen, half way down. Beside each meter sits that value's status icon, at the same stage it shows in the status bar (so a custom icon pack changes it too).

| Meter | Mod | Value |
|-------|-----|-------|
| **Arousal** | SexLab Aroused | Arousal, 0-100 |
| **FHU Total** | Fill Her Up | The combined cum pool, in percent of the max inflation |
| **FHU Vaginal / Anal / Oral Pool** | Fill Her Up | How full that pool is |
| **Vaginal / Anal / Oral W&T** | Apropos2 | The wear and tear stage. Apropos2 only shares the stage (0-8), so these bars move in eighths |

How they show is one switch on the MCM's **Meters** page:

| Mode | What you see |
|------|--------------|
| Fade after a change (default) | A meter fades in when its value changes and fades out again after the hold time (10 seconds by default) |
| Always show | Every meter stays on screen |

Values are read on the normal update interval (5 seconds by default), so a meter can appear and fade up to that long after the change. Only meters that are switched on and whose mod is installed get a row, and a row keeps its place while its meter is faded out. Each meter has its own switch; position, size, the display mode and the hold time are on the same page.

NPC support: **No** - the meters are for the player. NPCs keep their status icons.

---

## Summary table

| Mod | Stage icons | Toggle icons | NPC support |
|-----|:-----------:|:------------:|:-----------:|
| SexLab Aroused (SLA/SLAX/SLAM) | 2 | — | Yes |
| Apropos2 | 3 | — | Yes |
| Fill Her Up (Baka) | 4 | — | Yes |
| Milk Mod Economy (MME) | 2 | — | Yes |
| Soul Gem Oven 4 (SGO4) | 1 | — | Yes |
| Mammaries and Lactation (MAL) | 1 | — | Player only |
| PAF / MiniNeeds / AlivePeeing / Private Needs | 1–2 | — | Player only |
| SexLab-Parasites | — | 2 | Yes |
| HentaiPregnancy | — | Up to 5 | Yes |
| BeeingFemale | — | Varies | Yes |
| EggFactory | — | Varies | Yes |
| EstrusChaurus / EstrusSpider / EstrusDwemer | — | Varies | Yes |
| Fertility Mode 3 | — | Varies | Yes |
| Curse of Life | — | Varies | Yes |
| SGO4 (pregnancy) | — | Varies | Yes |
| SLDefeat | - | 1 | Player only |
| SLO VE | a willpower bar, not an icon | - | Player only |

SexLab Aroused (arousal), Fill Her Up and Apropos2 also have bars in the [meter stack](#meter-stack), player only.
