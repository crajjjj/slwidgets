# Supported Mods

SL Widgets auto-detects installed plugins at startup. No configuration is required to enable a mod: just have it installed and SL Widgets will pick it up. You can still switch each icon group off on the SKSE menu's [Toggles](position-editor.md#toggles) page if you want to hide certain sets.

---

## Stage icons

Stage icons display a continuously-updating 9-state bar (empty → full). They are always visible when enabled.

### SexLab Aroused SE

*Requires:* `SexLabAroused.esm` (any flavour: SLA SE, SLAX, SLAM)

| Icon | Description |
|------|-------------|
| **Arousal** | Heart icon, 9 stages tracking the actor's arousal value |
| **Exposure** | Eye icon, 9 stages tracking the actor's exposure/nudity level |

NPC support: **Yes** — both icons work per-actor.

Updates: on the update interval, and within a couple of seconds of an orgasm or of a change another mod asks SLA for (its exposure and arousal-effect events). With SLA NG also at the end of each SLA scan.

---

### Apropos2 — Wear & Tear

*Requires:* `Apropos2.esp`

| Icon | Description |
|------|-------------|
| **Vaginal W&T** | 9 stages tracking vaginal wear state |
| **Anal W&T** | 9 stages tracking anal wear state |
| **Oral W&T** | 9 stages tracking oral wear state |

NPC support: **Yes** — all three W&T icons work per-actor.

Updates: on the update interval; with **Apropos2 SE 1.0020** or newer also within about a second of every stage change, which that version announces.

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

Updates: on the update interval; for the player also within about a second of every fill, absorption and leak, which FHU announces.

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
| **Milk** | Milk carton icon, 9 stages tracking current milk level |
| **Lactacid** | Potion icon, 9 stages tracking lactacid (MME only) |

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
| **Pee** | Droplet icon, 5 stages |
| **Poop** | Pile icon, 5 stages |

NPC support: **No** — all needs mods use player-only APIs. These icons show only on the player bar.

---

## Survival, hygiene and health (3.0.0)

Stage icons, all of them. They are drawn in the ring style only (the classic set has no art for them), so they look the same with either [icon style](customization.md#icon-styles).

### SunHelm

*Requires:* `SunHelmSurvival.esp`

| Icon | Description |
|------|-------------|
| **Food** | 9 stages from Full to Starved: SunHelm's hunger level over its last stage threshold |
| **Thirst** | 9 stages from Quenched to Dying of Thirst |
| **Cold** | 9 stages from Warm to Hypothermic: a sun for the first three, a snowflake from Chilly on |
| **Fatigue** | 9 stages from Rested to Collapsing |

A need you switch off in SunHelm's own MCM drops its icon. NPC support: **No** - SunHelm tracks the player only.

### Bathing in Skyrim Renewed and Wet Function

*Requires:* `Bathing in Skyrim.esp` (the Renewed version, 2.7 or newer; the 2018 original is not supported) and/or Wet Function: `WetFunctionNG.esp` (WetFunction NG) or `WetFunction.esp` (Wet Function Redux)

| Icon | Description |
|------|-------------|
| **Dirtiness** | 9 stages from Clean to Reeking: Renewed's dirt percentage |
| **Wetness** | 9 stages from Dry to Dripping: Wet Function's wetness above its dry level, as a share of the rest up to its cap (the strength the mod drives the wet look with) |

NPC support: **Yes** for both, off by default per slot. Renewed only writes a value for the actors it tracks; everyone else reads as clean.

### SPH - Skyrim Pubic Hair

*Requires:* `SPH - Skyrim Pubic Hair.esp` (2.0 or newer)

| Icon | Description |
|------|-------------|
| **Pubic hair** | SPH's six stages, Shaved to Untamed (a shaving style counts as its own length) |
| **Armpit hair** | SPH's seven stages, Shaved to Very Long |

NPC support: **No** - SPH grows hair on the player only.

### BeeingFemale baby health

*Requires:* `BeeingFemale.esm`

| Icon | Description |
|------|-------------|
| **Baby health** | 9 stages from Healthy to Miscarrying while pregnant (BeeingFemale's trimesters and labor), hidden otherwise. The scale runs the other way from the rest: full health is the calm end |

NPC support: **Yes**, off by default per slot.

### Stress and Fear

*Requires:* `Stress and Fear.esp`

| Icon | Description |
|------|-------------|
| **Stress** | 9 stages from Calm to Breaking: the mod's stress total |
| **Fear** | The phobias held, one stage each up to 8+, rechecked every 15 seconds. The mod has no fear number: a phobia is a spell it adds when a creature type hurts you badly and removes when you conquer it |

NPC support: **No**.

### Blade and Blunt injuries

*Requires:* `BladeAndBlunt.esp` (4.0 or newer)

| Icon | Description |
|------|-------------|
| **Injuries** | Unhurt, Minor, Major or Critical Injury: the spell Blade and Blunt's DLL applies |

NPC support: **No**.

### Diseases

*Requires:* nothing for vanilla diseases; `SunHelmDiseases.esp` for stages 2 and 3

| Icon | Description |
|------|-------------|
| **Diseases** | Infected, Worsening, Severe: the worst stage of any disease held, shown only while one is held. Vanilla diseases (Sanguinare Vampiris included) are stage 1; SunHelm Diseases turns each into a three-stage chain and adds seven diseases of its own. Rechecked every 20 seconds |

NPC support: **No**.

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

Not a status icon but a **bar**: the top meter of the [meter stack](#meter-stack), with a brain icon beside it, showing the player's [willpower](https://crajjjj.github.io/SLOVE/resistance/) during a scene.

| State | What you see |
|-------|--------------|
| Outside a scene | Nothing: the bar is hidden, whatever willpower is left |
| In a scene, willpower at `100` | Nothing: the bar is hidden |
| In a scene, below `100` | The bar, filled to the current willpower, draining as the scene goes on |
| In a scene, broken (`0`) | The bar flashes and empties, and the icon turns red |

The value is read from the StorageUtil keys SLO VE publishes, with the recovery since the last scene worked out, so the bar starts a scene where SLO VE will. Whether the player is in a scene is asked of SexLab's animating faction. The bar takes the stack's position and size; its switch is on the SKSE menu's **Meters** page with the others. The stack's display mode does not apply to it: it always follows the table above. The bar is updated on the normal update interval (5 seconds by default), so it comes and goes up to that long after the scene does.

NPC support: **No** - the bar is for the player.

---

## Meter stack

*Requires:* any of SLO VE, SexLab Aroused, Fill Her Up, Apropos2

One iWant Widgets meter per value, stacked at the right edge of the screen, half way down, with one position and one size for the whole stack. On top sits the [SLO VE willpower bar](#slo-ve-willpower-bar); below it the same values as some of the stage icons above, each with that value's status icon beside it, at the same stage it shows in the status bar (so a custom icon pack changes it too).

| Meter | Mod | Value |
|-------|-----|-------|
| **Willpower** | SLO VE | Willpower, 0-100, during a scene only (see above) |
| **Arousal** | SexLab Aroused | Arousal, 0-100 |
| **FHU Total** | Fill Her Up | The combined cum pool, in percent of the max inflation |
| **FHU Vaginal / Anal / Oral Pool** | Fill Her Up | How full that pool is |
| **Vaginal / Anal / Oral W&T** | Apropos2 | The wear and tear stage. Apropos2 only shares the stage (0-8), so these bars move in eighths |

How they show is one switch on the SKSE menu's [Meters](position-editor.md#meters) page (willpower keeps its own rule):

| Mode | What you see |
|------|--------------|
| Fade after a change (default) | A meter fades in when its value moves by 5 points or more, or its icon changes stage, and fades out again after the hold time (10 seconds by default). Slow drifts, such as FHU absorbing or arousal wearing off, show again every 5 points instead of keeping the meter up |
| Always show | Every meter stays on screen |

Values are read on the normal update interval (5 seconds by default), and sooner when SLA, FHU or Apropos2 SE 1.0020+ report a change (see each mod above), so a meter appears within a second or two of such a change. Fading out is decided on the next check, so it can come up to an interval late. Only meters that are switched on and whose mod is installed get a row, and a row keeps its place while its meter is faded out. Each meter has its own switch, and all of them start **off**: switch on the ones you want on the SKSE menu's **Meters** page, where the display mode and the hold time are too; position and size are on its **Positions** page, and a settings preset saves all of them.

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

SexLab Aroused (arousal), Fill Her Up and Apropos2 also have bars in the [meter stack](#meter-stack), with the SLO VE willpower bar, player only.
