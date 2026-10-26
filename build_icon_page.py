"""One-off generator: converts SL Widgets DDS icons to PNG and writes docs/icons.md.

Safe to re-run. Not part of the mod build; lives at repo root for convenience.
"""
import os
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
LIB = os.path.join(ROOT, "Interface", "exported", "widgets", "iwant", "widgets", "library")
OUT_IMG = os.path.join(ROOT, "docs", "assets", "icons")
OUT_MD = os.path.join(ROOT, "docs", "icons.md")

os.makedirs(OUT_IMG, exist_ok=True)
# Clear stale PNGs from previous runs so unreferenced samples don't linger in the site.
for _f in os.listdir(OUT_IMG):
    if _f.endswith(".png"):
        os.remove(os.path.join(OUT_IMG, _f))


def sample_indices(n, k=4):
    """Pick up to k evenly-spaced indices across 0..n-1 (always includes first and last)."""
    if n <= k:
        return list(range(n))
    return sorted({round(i * (n - 1) / (k - 1)) for i in range(k)})


def convert(rel_dds, out_name):
    """rel_dds is relative to LIB. Writes OUT_IMG/out_name.png, returns out_name.png."""
    src = os.path.join(LIB, rel_dds.replace("/", os.sep))
    dst = os.path.join(OUT_IMG, out_name + ".png")
    Image.open(src).convert("RGBA").save(dst, "PNG")
    return out_name + ".png"


md = []


def h(level, text):
    md.append(f"\n{'#' * level} {text}\n")


def para(text):
    md.append(text + "\n")


def stage_row(key, folder, prefix, n, label, desc=None):
    """Row of n stage icons (0..n-1) with numeric captions."""
    if label:
        h(4, label)
    if desc:
        para(desc)
    md.append('<div class="icon-grid" markdown>\n')
    for i in sample_indices(n):
        fn = convert(f"{folder}/{prefix}{i}.dds", f"{key}_{i}")
        md.append(
            f'<figure class="icon-cell">'
            f'<img src="../assets/icons/{fn}" alt="{key} stage {i}">'
            f'<figcaption>{i}</figcaption></figure>'
        )
    md.append("\n</div>\n")


def toggle_grid(items, keyprefix):
    """items: list of (rel_dds, caption). Single icons with text captions."""
    md.append('<div class="icon-grid" markdown>\n')
    for rel, caption in items:
        safe = keyprefix + "_" + os.path.splitext(os.path.basename(rel))[0].replace(" ", "_")
        fn = convert(rel, safe)
        md.append(
            f'<figure class="icon-cell icon-cell--wide">'
            f'<img src="../assets/icons/{fn}" alt="{caption}">'
            f'<figcaption>{caption}</figcaption></figure>'
        )
    md.append("\n</div>\n")


# ---- Page header ----
para("# Icon Gallery\n")
para(
    "The icons SL Widgets can display, grouped by source mod. "
    "**Stage icons** fill through their steps (most have 9: 0 = empty, 8 = full) as a value rises; "
    "only a few representative steps are shown here. "
    "**Toggle icons** simply appear when their condition is active and vanish when it clears. "
    "Since 3.0.0 the whole set is drawn in one ring style; the classic icons are an optional download.\n"
)
para(
    "!!! note\n"
    "    Icons are shown on a checkerboard so transparency is visible. In-game they render "
    "    over the HUD at whatever size, position, and colour you set in the iWant Status Bars MCM. "
    "    Colours here are the defaults — see [Customization](customization.md) for colour presets and custom packs.\n"
)

# ---- Stage icons ----
h(2, "Stage icons")

h(3, "SexLab Aroused")
para("*Requires SexLabAroused.esm (SLA SE / SLAX / SLAM).*")
stage_row("sla_arousal", "sla/arousal", "aroused", 9, "Arousal", "Heart icon that fills as arousal rises.")
stage_row("sla_exposure", "sla/exposure", "exp", 9, "Exposure", "Eye icon that fills as exposure / nudity rises.")

h(3, "Apropos2 — Wear & Tear")
para("*Requires Apropos2.esp.*")
stage_row("apr_vag", "apropos2/vaginal", "vag", 9, "Vaginal")
stage_row("apr_anal", "apropos2/anal", "ass", 9, "Anal")
stage_row("apr_oral", "apropos2/oral", "oral", 9, "Oral")

h(3, "Fill Her Up (Baka)")
para("*Requires sr_FillHerUp.esp.*")
stage_row("fhu_total", "fhu/total", "cum", 9, "Cum — total pool")
stage_row("fhu_vag", "fhu/vaginal", "cum", 9, "Cum — vaginal pool")
stage_row("fhu_anal", "fhu/anal", "cum", 9, "Cum — anal pool")
stage_row("fhu_oral", "fhu/oral", "cum", 9, "Cum — oral pool")

h(3, "Milk — MME / SGO4 / MAL")
para("*Requires MilkModNEW.esp, dse-soulgem-oven.esp, or Mammaries And Lactation.esp.*")
stage_row("mme_milk", "mme/milk", "milk", 9, "Milk")
stage_row("mme_lact", "mme/lactacid", "lact", 9, "Lactacid", "MME only.")

h(3, "Needs — PAF / MiniNeeds / AlivePeeing / Private Needs")
para("*Player only. These icons use 5 stages, not 9.*")
stage_row("paf_pee", "paf/pee", "pee", 5, "Pee (bladder)")
stage_row("paf_poop", "paf/poop", "poop", 5, "Poop (bowel)")

h(3, "Survival, hygiene and health (3.0.0)")
para("*New in 3.0.0. Player only unless noted.*")
stage_row("sh_food", "sunhelm/food", "food", 9, "Food (SunHelm)")
stage_row("sh_thirst", "sunhelm/thirst", "thirst", 9, "Thirst (SunHelm)")
stage_row("sh_cold", "sunhelm/cold", "cold", 9, "Cold (SunHelm)", "A sun while warm, a snowflake from Chilly on.")
stage_row("sh_fatigue", "sunhelm/fatigue", "fatigue", 9, "Fatigue (SunHelm)")
stage_row("dirt", "hygiene/dirt", "dirt", 9, "Dirtiness (Bathing in Skyrim Renewed)", "Also per NPC slot.")
stage_row("wet", "hygiene/wet", "wet", 9, "Wetness (WetFunction NG / Wet Function Redux)", "Also per NPC slot.")
stage_row("sph_pubic", "sph/pubic", "pubic", 6, "Pubic hair (SPH)", "SPH's six stages.")
stage_row("sph_armpit", "sph/armpit", "armpit", 7, "Armpit hair (SPH)", "SPH's seven stages.")
stage_row("baby", "bf/babyhealth", "baby", 9, "Baby health (BeeingFemale)", "Only while pregnant; also per NPC slot. Full health is stage 0.")
stage_row("stress", "stress/stress", "stress", 9, "Stress (Stress and Fear)")
stage_row("fear", "stress/fear", "fear", 9, "Fear (Stress and Fear)", "One stage per phobia held.")
stage_row("injury", "health/injury", "injury", 4, "Injuries (Blade and Blunt)", "Unhurt, Minor, Major, Critical.")
stage_row("disease", "health/disease", "disease", 4, "Diseases", "Shown only while a disease is held: Infected, Worsening, Severe (stages 2 and 3 need SunHelm Diseases).")

# ---- Toggle icons ----
h(2, "Toggle icons")

h(3, "SexLab-Parasites")
para("*Requires SexLab-Parasites.esp. Each appears only while that infection is active.*")
toggle_grid(
    [
        ("slp/parasite0.dds", "Spider eggs"),
        ("slp/parasite2.dds", "Chaurus worm"),
        ("slp/parasite1.dds", "Chaurus worm (vaginal)"),
    ],
    "slp",
)

h(3, "Pregnancy")
para(
    "*Requires any supported pregnancy mod. SL Widgets shows whichever icon matches the "
    "current state reported by HentaiPregnancy, BeeingFemale, EggFactory, the Estrus mods, "
    "Fertility Mode 3, Curse of Life, or SGO4.*"
)
toggle_grid(
    [
        ("pregnancymod/cum.dds", "Cum inflation"),
        ("pregnancymod/cum1.dds", "Cum inflation (alt)"),
        ("pregnancymod/ovulation.dds", "Ovulation"),
        ("pregnancymod/basic.dds", "Pregnant (basic)"),
        ("pregnancymod/preg1.dds", "Trimester 1"),
        ("pregnancymod/preg2.dds", "Trimester 2"),
        ("pregnancymod/preg3.dds", "Trimester 3"),
        ("pregnancymod/fetus.dds", "Fetus"),
        ("pregnancymod/eggs.dds", "Eggs (EggFactory)"),
        ("pregnancymod/chaurusEggs.dds", "Chaurus eggs (Estrus)"),
        ("pregnancymod/spiderEggs.dds", "Spider eggs (Estrus)"),
        ("pregnancymod/spheres.dds", "Dwemer spheres (Estrus)"),
    ],
    "preg",
)

h(4, "Soul gems (SGO4)")
para("Progression as soul gems mature.")
gem_files = ["gems.dds", "gems2.dds", "gems3.dds", "gems4.dds", "gems5.dds", "gems6.dds"]
md.append('<div class="icon-grid" markdown>\n')
for idx in sample_indices(len(gem_files)):
    fn = convert(f"pregnancymod/{gem_files[idx]}", f"preg_gems_{idx}")
    md.append(
        f'<figure class="icon-cell">'
        f'<img src="../assets/icons/{fn}" alt="soul gems stage {idx}">'
        f'<figcaption>{idx + 1}</figcaption></figure>'
    )
md.append("\n</div>\n")

h(3, "SLDefeat")
para("*Requires SexLabDefeat.esp. Player only.*")
toggle_grid([("defeatmod/raped.dds", "Weakened / raped")], "defeat")

h(2, "The whole set")
para(
    "Since 3.0.0 every icon is drawn in one style: a progress ring around a glyph, tinted white to red "
    "as the value worsens (milk and lactacid keep one colour). The icons from before 3.0.0 are an optional "
    "download. See [Icon styles](customization.md#icon-styles)."
)
md.append("![The ring icon set](assets/ring-style.png)\n")

with open(OUT_MD, "w", encoding="utf-8") as f:
    f.write("\n".join(md))

print("Wrote", OUT_MD)
print("PNG count:", len([n for n in os.listdir(OUT_IMG) if n.endswith('.png')]))
