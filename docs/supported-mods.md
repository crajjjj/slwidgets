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
| `dse-soulgem-oven.esp` | Soul Gem Oven 4 — NPC support |
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
| `dse-soulgem-oven.esp` | SGO4 soul gem pregnancy states |

NPC support: **Yes** for all pregnancy mods.

!!! note
    Pregnancy can momentarily spike to 5–7 visible icons when multiple mods are installed. NPC slots have a secondary bar (20 extra icon positions) to absorb overflow.

---

### SLDefeat

*Requires:* `SexLabDefeat.esp`

| Icon | Condition |
|------|-----------|
| **Defeat** | Player is in a weakened/raped state |

NPC support: **No** — SLDefeat uses a player-only magic effect.

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
| SLDefeat | — | 1 | Player only |
