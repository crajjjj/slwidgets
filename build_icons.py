"""Draw the SL Widgets icon set (the "ring" style) and the presets that go with it.

    python build_icons.py            # writes every .dds, plus the colour presets
    python build_icons.py --sheet    # also docs/assets/ring-style.png (the overview)

One icon = a progress ring around a glyph. The ring sweeps clockwise from
12 o'clock as the stage rises and ends in an arrowhead; the glyph is an
outline whose body fills from the bottom; toggle icons (pregnancy states,
parasites, defeat) keep a full ring and a full glyph. Everything is white on
transparent, 100x100 DXT5, like the classic icons were, so iWant's per-stage
tint (the colour presets) does the colouring. The ramp the set is drawn for,
white -> gold -> orange -> red, becomes the shipped Default colour preset.

Where things go:
  art/ring/glyphs/*.svg        the glyphs (game-icons.net + hand-drawn, see CREDITS.md)
  Interface/.../library/...    the icons the mod ships, every set
  SKSE/.../IconPresets/        Default.json and HideEmpty.json are rewritten from the
                               ramp; AllWhite*.json only gain the 3.0.0 icons' keys
  art/classic/presets/         the classic Default / HideEmpty presets (packed by
                               build_release.py with art/classic/library) gain the
                               3.0.0 icons' keys with the classic alphas

The classic art under art/classic/library is not touched by this script.
Needs Pillow 11.2+ (DXT5 writer) and resvg-py:  pip install pillow resvg-py
"""
import argparse
import io
import json
import math
import os
import re

import resvg_py
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.abspath(__file__))
GLYPHS = os.path.join(ROOT, "art", "ring", "glyphs")
LIB = os.path.join(ROOT, "Interface", "exported", "widgets", "iwant", "widgets", "library")
PRESETS = os.path.join(ROOT, "SKSE", "Plugins", "SlWidgets", "IconPresets")
CLASSIC_PRESETS = os.path.join(ROOT, "art", "classic", "presets")
SHEET = os.path.join(ROOT, "docs", "assets", "ring-style.png")

# ---- drawing -----------------------------------------------------------------
S = 800            # work size, scaled down to FINAL with LANCZOS
FINAL = 100
RING_R = 0.44 * S
RING_W = 0.045 * S
GLYPH = 0.56 * S   # glyph box
BADGE = 0.48 * GLYPH
TRACK_A = 70       # alpha of the empty ring track
GHOST_A = 60       # alpha of the unfilled glyph body
OUTLINE_W = 0.030 * S

# the tint the set is drawn for, per stage 0..8: r, g, b, and iWant alpha 0-100
RAMP = [
    (255, 255, 255, 72),
    (255, 240, 200, 85),
    (255, 226, 150, 100),
    (255, 206, 100, 100),
    (255, 180, 66, 100),
    (255, 140, 44, 100),
    (255, 100, 36, 100),
    (255, 66, 40, 100),
    (255, 36, 36, 100),
]
# the stock alphas, used where the classic presets get the new icons
CLASSIC_A = [33, 75] + [100] * 7

_mask_cache = {}


def glyph_mask(name, size):
    key = (name, int(size))
    if key not in _mask_cache:
        svg = open(os.path.join(GLYPHS, name + ".svg"), encoding="utf-8").read()
        # game-icons files start with a black background square
        svg = re.sub(r'<path d="M0 0h512v512H0z"/>', "", svg, count=1)
        png = resvg_py.svg_to_bytes(svg_string=svg, width=int(size), height=int(size))
        _mask_cache[key] = Image.open(io.BytesIO(bytes(png))).convert("RGBA").getchannel("A")
    return _mask_cache[key]


def ring_layer(frac, full_ring):
    lay = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(lay)
    c = S / 2
    box = (c - RING_R, c - RING_R, c + RING_R, c + RING_R)
    if full_ring or frac >= 1.0:
        d.ellipse(box, outline=255, width=int(RING_W))
        return lay
    d.ellipse(box, outline=TRACK_A, width=int(RING_W))
    if frac <= 0:
        return lay
    start, end = -90.0, -90.0 + 360.0 * frac
    d.arc(box, start, end, fill=255, width=int(RING_W))
    for ang, cap in ((start, True), (end, False)):
        ex = c + RING_R * math.cos(math.radians(ang))
        ey = c + RING_R * math.sin(math.radians(ang))
        if cap:
            r = RING_W / 2
            d.ellipse((ex - r, ey - r, ex + r, ey + r), fill=255)
        else:
            t = math.radians(ang)
            tx, ty = -math.sin(t), math.cos(t)     # along the sweep
            nx, ny = math.cos(t), math.sin(t)      # outward
            L, Wd = RING_W * 1.9, RING_W * 1.25
            d.polygon([(ex + tx * L, ey + ty * L), (ex + nx * Wd, ey + ny * Wd),
                       (ex - nx * Wd, ey - ny * Wd)], fill=255)
    return lay


def glyph_layer(mask, frac):
    eroded = mask.filter(ImageFilter.MinFilter(int(OUTLINE_W) | 1))
    outline = ImageChops.subtract(mask, eroded)
    h = mask.height
    fill_from = int(round(h * (1 - frac)))
    body = Image.new("L", mask.size, GHOST_A)
    if frac > 0:
        body.paste(Image.new("L", (mask.width, h - fill_from), 255), (0, fill_from))
    body = ImageChops.multiply(body, eroded)
    return ImageChops.lighter(outline, body)


def build(glyph, frac, badge=None, full_ring=False):
    """One icon as RGBA FINALxFINAL, white on transparent.

    glyph: glyph name. frac: 0..1 ring sweep and glyph fill. badge: a second
    glyph in the bottom-right corner, or "<name" for bottom-left.
    """
    left = bool(badge) and badge.startswith("<")
    if left:
        badge = badge[1:]
    gsize = GLYPH * (0.92 if badge else 1.0)
    g = glyph_layer(glyph_mask(glyph, gsize), frac)
    lay = Image.new("L", (S, S), 0)
    offx = offy = int((S - gsize) / 2)
    if badge:
        offy -= int(GLYPH * 0.06)
        offx += int(GLYPH * 0.06) if left else -int(GLYPH * 0.06)
    lay.paste(g, (offx, offy))
    if badge:
        bm = glyph_mask(badge, BADGE)
        bx = int(S / 2 - GLYPH * 0.16 - BADGE) if left else int(S / 2 + GLYPH * 0.16)
        by = int(S / 2 + GLYPH * 0.16)
        knock = Image.new("L", (S, S), 0)
        knock.paste(bm.filter(ImageFilter.MaxFilter(int(OUTLINE_W * 1.3) | 1)), (bx, by))
        lay = ImageChops.subtract(lay, knock)
        bl = Image.new("L", (S, S), 0)
        bl.paste(bm, (bx, by))
        lay = ImageChops.lighter(lay, bl)
    a = ImageChops.lighter(ring_layer(frac, full_ring), lay).resize((FINAL, FINAL), Image.LANCZOS)
    icon = Image.new("RGBA", (FINAL, FINAL), (255, 255, 255, 0))
    icon.putalpha(a)
    return icon


# ---- the sets ---------------------------------------------------------------
def stages(prefix, n):
    return [f"{prefix}{i}" for i in range(n)]


def fracs(n):
    return [i / (n - 1) for i in range(n)]


COLD = ["sun-simple"] * 3 + ["snowflake-simple"] * 6

# (classic, folder, file stems, glyph or one glyph per file, badge, fills or None)
# classic: whether the set also has classic art (art/classic/library), which is what
# the Classic Icons pack replaces. fills None = a stage set: progress ring, fill
# i/(n-1). A list = toggle icons: full ring, that fill per file.
SETS = [
    # the sets that pre-date 3.0.0
    ("ring", "sla/arousal", stages("aroused", 9), "hearts", None, None),
    ("ring", "sla/exposure", stages("exp", 9), "tired-eye", None, None),
    ("ring", "apropos2/vaginal", stages("vag", 9), "vulva", "bandage-roll", None),
    ("ring", "apropos2/anal", stages("ass", 9), "anus", "bandage-roll", None),
    ("ring", "apropos2/oral", stages("oral", 9), "lips", "bandage-roll", None),
    ("ring", "fhu/total", stages("cum", 9), "dripping-goo", None, None),
    ("ring", "fhu/vaginal", stages("cum", 9), "goo-spurt", "<vulva", None),
    ("ring", "fhu/anal", stages("cum", 9), "goo-spurt", "<anus", None),
    ("ring", "fhu/oral", stages("cum", 9), "goo-spurt", "<lips", None),
    ("ring", "mme/milk", stages("milk", 9), "milk-carton", None, None),
    ("ring", "mme/lactacid", stages("lact", 9), "round-potion", None, None),
    ("ring", "paf/pee", stages("pee", 5), "droplet-splash", None, None),
    ("ring", "paf/poop", stages("poop", 5), "turd", None, None),
    # parasite0 spider eggs, parasite1 chaurus worm (vaginal), parasite2 chaurus worm
    ("ring", "slp", ["parasite0", "parasite1", "parasite2"], ["spider-face", "worms", "worms"], [None, "vulva", None], [1, 1, 1]),
    ("ring", "pregnancymod",
     ["cum", "cum1", "ovulation", "basic", "preg1", "preg2", "preg3", "fetus", "eggs", "chaurusEggs", "spiderEggs", "spheres"],
     ["sperm", "sperm", "ovum", "belly", "belly", "belly", "belly", "fetus", "nest-eggs", "alien-egg", "spider-web", "gears"],
     None, [1, 1, 1, 1, 0.33, 0.66, 1, 1, 1, 1, 1, 1]),
    ("ring", "pregnancymod", ["gems", "gems2", "gems3", "gems4", "gems5", "gems6"], "crystal-growth", None, [i / 5 for i in range(6)]),
    ("ring", "defeatmod", ["raped"], "kneeling", None, [1]),
    ("ring", "slove", ["willpower"], "brain", None, [1]),
    # the sets new in 3.0.0 (ring style only)
    ("lib", "sunhelm/food", stages("food", 9), "meal", None, None),
    ("lib", "sunhelm/thirst", stages("thirst", 9), "waterskin", None, None),
    ("lib", "sunhelm/cold", stages("cold", 9), COLD, None, None),
    ("lib", "sunhelm/fatigue", stages("fatigue", 9), "bed", None, None),
    ("lib", "hygiene/dirt", stages("dirt", 9), "soap", None, None),
    ("lib", "hygiene/wet", stages("wet", 9), "droplets", None, None),
    ("lib", "sph/pubic", stages("pubic", 6), "high-grass", None, None),
    ("lib", "sph/armpit", stages("armpit", 7), "grass", None, None),
    ("lib", "bf/babyhealth", stages("baby", 9), "embryo", None, None),
    ("lib", "stress/stress", stages("stress", 9), "broken-heart", None, None),
    ("lib", "stress/fear", stages("fear", 9), "chained-heart", None, None),
    ("lib", "health/injury", stages("injury", 4), "arm-bandage", None, None),
    ("lib", "health/disease", stages("disease", 4), "medicine-pills", None, None),
]

# ---- the presets --------------------------------------------------------------
# icon name (as registered with iWant, the preset key) -> how it is coloured
#   ("ramp", n)            n stages along RAMP
#   ("const", n, (r,g,b))  one colour, the alpha ramp only
#   ("tone", i)            a toggle icon at RAMP[i]
RING_PRESET = {
    "Arousal": ("ramp", 9), "Exposure": ("ramp", 9),
    "AP2Vaginal": ("ramp", 9), "AP2Anal": ("ramp", 9), "AP2Oral": ("ramp", 9),
    "FHUCum": ("ramp", 9), "FHUCumVaginal": ("ramp", 9), "FHUCumAnal": ("ramp", 9), "FHUCumOral": ("ramp", 9),
    "MMEMilk": ("const", 9, (253, 255, 245)), "MMELactacid": ("const", 9, (236, 244, 255)),
    "PAF_PEE": ("ramp", 5), "PAF_POOP": ("ramp", 5),
    "Parasites_SpiderEggs": ("tone", 5), "Parasites_ChaurusWorm": ("tone", 6), "Parasites_ChaurusWormVag": ("tone", 7),
    "Defeat_Raped": ("tone", 8),
    "Pregnancy_Ovulation": ("tone", 1), "Pregnancy_CumInflation": ("tone", 2), "Pregnancy_Basic": ("tone", 3),
    "Pregnancy_Trimester1": ("tone", 2), "Pregnancy_Trimester2": ("tone", 4), "Pregnancy_Trimester3": ("tone", 6),
    "Pregnancy_Fetus": ("tone", 8), "Pregnancy_Eggs": ("tone", 3), "Pregnancy_Chaurus_Eggs": ("tone", 5),
    "Pregnancy_Spider_Eggs": ("tone", 6), "Pregnancy_Dwemer_Spheres": ("tone", 7),
}
NEW_KEYS = {
    "SH_Food": ("ramp", 9), "SH_Thirst": ("ramp", 9), "SH_Cold": ("ramp", 9), "SH_Fatigue": ("ramp", 9),
    "Dirtiness": ("ramp", 9), "Wetness": ("ramp", 9),
    "SPH_Pubic": ("ramp", 6), "SPH_Armpit": ("ramp", 7),
    "BF_BabyHealth": ("ramp", 9),
    "Stress": ("ramp", 9), "Fear": ("ramp", 9),
    "Injuries": ("ramp", 4), "Diseases": ("ramp", 4),
}
RING_PRESET.update(NEW_KEYS)


def ramp_index(i, n):
    return int(round(i * 8 / (n - 1))) if n > 1 else 8


def colours(spec, alphas=None, white=False):
    """r, g, b, a arrays for one preset entry. alphas: None = the RAMP alphas,
    else a 9-long list sampled like the colours. white: AllWhite variants."""
    kind = spec[0]
    if kind == "tone":
        r, g, b, a = RAMP[spec[1]]
        if white:
            r = g = b = 255
        return {"r": [r], "g": [g], "b": [b], "a": [100]}
    n = spec[1]
    out = {"r": [], "g": [], "b": [], "a": []}
    for i in range(n):
        ri = ramp_index(i, n)
        r, g, b, a = RAMP[ri]
        if kind == "const":
            r, g, b = spec[2]
        if white:
            r = g = b = 255
        if alphas is not None:
            a = alphas[ri]
        out["r"].append(r)
        out["g"].append(g)
        out["b"].append(b)
        out["a"].append(a)
    return out


def dump_preset(d):
    lines = ["{"]
    keys = list(d)
    for k in keys:
        lines.append(f'  "{k}": {{')
        for ch in "rgba":
            arr = ", ".join(f"{x:3d}" for x in d[k][ch])
            lines.append(f'    "{ch}": [{arr}]' + ("," if ch != "a" else ""))
        lines.append("  }" + ("," if k != keys[-1] else ""))
    lines.append("}")
    return "\n".join(lines) + "\n"


def write_presets():
    # the shipped Default and HideEmpty are the ring ramp, in full
    ramp_a = [c[3] for c in RAMP]
    hide_a = [0] + ramp_a[1:]
    ring = {k: colours(v) for k, v in RING_PRESET.items()}
    open(os.path.join(PRESETS, "Default.json"), "w", encoding="utf-8").write(dump_preset(ring))
    ring_hide = {k: colours(v, alphas=hide_a) for k, v in RING_PRESET.items()}
    open(os.path.join(PRESETS, "HideEmpty.json"), "w", encoding="utf-8").write(dump_preset(ring_hide))
    # the white presets and the classic pack's presets keep their colours and
    # only gain the icons new in 3.0.0, with the classic alphas
    classic_hide = [0] + CLASSIC_A[1:]
    variants = {
        os.path.join(PRESETS, "AllWhite.json"): dict(alphas=CLASSIC_A, white=True),
        os.path.join(PRESETS, "AllWhite_HideEmpty.json"): dict(alphas=classic_hide, white=True),
        os.path.join(CLASSIC_PRESETS, "Default.json"): dict(alphas=CLASSIC_A, white=False),
        os.path.join(CLASSIC_PRESETS, "HideEmpty.json"): dict(alphas=classic_hide, white=False),
    }
    for path, kw in variants.items():
        d = json.load(open(path, encoding="utf-8"))
        for k, spec in NEW_KEYS.items():
            d[k] = colours(spec, **kw)
        open(path, "w", encoding="utf-8").write(dump_preset(d))
    print("wrote presets")


# ---- the sheet (docs/assets/ring-style.png) ------------------------------------
CAPTIONS = {
    "sla/arousal": ["Not Aroused", "Slightly", "Moderately", "Highly", "Extremely", "Completely", "Shaking", "Losing Control", "No Control"],
    "sla/exposure": ["Not Exposed", "Slightly", "Moderately", "Highly", "Extremely", "Completely", "Totally", "Super", "Mega"],
    "apropos2/vaginal": ["Normal", "Slightly", "Moderately", "Highly", "Extremely", "Completely", "Totally", "Super", "Mega"],
    "fhu/total": ["Empty", "Slightly", "Moderately", "Highly", "Extremely", "Completely", "Totally", "Super", "Mega"],
    "paf/pee": ["Empty", "Slightly", "Moderately", "Highly", "Extremely"],
    "sunhelm/food": ["Full", "Satisfied", "Content", "Peckish", "Hungry", "Very Hungry", "Famished", "Starving", "Starved"],
    "sunhelm/thirst": ["Quenched", "Refreshed", "Fine", "Slightly Dry", "Thirsty", "Very Thirsty", "Parched", "Dehydrated", "Dying"],
    "sunhelm/cold": ["Warm", "Comfortable", "Cool", "Chilly", "Cold", "Very Cold", "Freezing", "Frostbitten", "Hypothermic"],
    "sunhelm/fatigue": ["Rested", "Fresh", "Fine", "Tired", "Weary", "Very Tired", "Exhausted", "Drained", "Collapsing"],
    "hygiene/dirt": ["Clean", "Fresh", "Dusty", "Slightly Dirty", "Dirty", "Grimy", "Very Dirty", "Filthy", "Reeking"],
    "hygiene/wet": ["Dry", "Damp", "Sweaty", "Moist", "Wet", "Very Wet", "Soaked", "Drenched", "Dripping"],
    "sph/pubic": ["Shaved", "Shadow", "Stubble", "Short", "Long", "Untamed"],
    "sph/armpit": ["Shaved", "Shadow", "Stubble", "Short", "Medium", "Long", "Very Long"],
    "bf/babyhealth": ["Healthy", "Strong", "Stable", "Fine", "Weak", "At Risk", "Critical", "Failing", "Miscarrying"],
    "stress/stress": ["Calm", "Relaxed", "Uneasy", "Tense", "Stressed", "Very Stressed", "Anxious", "Overwhelmed", "Breaking"],
    "stress/fear": ["No Phobia", "1 Phobia", "2 Phobias", "3 Phobias", "4 Phobias", "5 Phobias", "6 Phobias", "7 Phobias", "8+ Phobias"],
    "health/injury": ["Unhurt", "Minor Injury", "Major Injury", "Critical Injury"],
    "health/disease": ["Healthy", "Infected", "Worsening", "Severe"],
}
LABELS = {
    "sla/arousal": "Arousal", "sla/exposure": "Exposure", "apropos2/vaginal": "W&T Vaginal", "apropos2/anal": "W&T Anal",
    "apropos2/oral": "W&T Oral", "fhu/total": "Cum Total", "fhu/vaginal": "Cum Vaginal", "fhu/anal": "Cum Anal",
    "fhu/oral": "Cum Oral", "mme/milk": "Milk", "mme/lactacid": "Lactacid", "paf/pee": "Pee", "paf/poop": "Poop",
    "sunhelm/food": "Food", "sunhelm/thirst": "Thirst", "sunhelm/cold": "Cold", "sunhelm/fatigue": "Fatigue",
    "hygiene/dirt": "Dirtiness", "hygiene/wet": "Wetness", "sph/pubic": "Pubic Hair", "sph/armpit": "Armpit Hair",
    "bf/babyhealth": "Baby Health", "stress/stress": "Stress", "stress/fear": "Fear", "health/injury": "Injuries",
    "health/disease": "Diseases", "slp": "Parasites", "pregnancymod": "Pregnancy", "defeatmod": "Weakened", "slove": "Willpower",
}
CONST_ROWS = {"mme/milk": (253, 255, 245), "mme/lactacid": (236, 244, 255)}


def tinted(icon, rgba):
    r, g, b, a = rgba
    solid = Image.new("RGBA", icon.size, (r, g, b, 255))
    solid.putalpha(icon.getchannel("A").point(lambda v: int(v * a / 100)))
    return solid


def write_sheet(icons):
    """icons: {(folder, stem): PIL image} as built by main()."""
    font = "C:/Windows/Fonts/georgia.ttf"
    f_title = ImageFont.truetype(font, 40)
    f_label = ImageFont.truetype(font, 26)
    f_cap = ImageFont.truetype(font, 13)
    f_foot = ImageFont.truetype(font, 16)
    ICON, CELL, LABEL_W, ROW_H, MARGIN, TITLE_H = 66, 82, 200, 108, 24, 90
    COL_W = LABEL_W + 9 * CELL + 10
    rows = []
    for where, folder, stems, glyph, badge, fills in SETS:
        if folder in ("pregnancymod", "slp", "defeatmod", "slove") and stems[0] == "gems":
            continue
        caps = CAPTIONS.get(folder)
        if caps is None:
            base = folder.split("/")[0]
            for k, v in CAPTIONS.items():
                if k.split("/")[0] == base and len(v) == len(stems):
                    caps = v
        if caps is None:
            caps = stems
        rows.append((LABELS.get(folder, folder), folder, stems, caps))
    left, right = rows[:13], rows[13:]
    H = TITLE_H + max(len(left), len(right)) * ROW_H + MARGIN + 50
    W = MARGIN * 2 + COL_W * 2 + 40
    sheet = Image.new("RGBA", (W, H), (6, 6, 8, 255))
    d = ImageDraw.Draw(sheet)
    title = "SL Widgets 3.0  -  the icon set, fine to worst"
    d.text(((W - d.textlength(title, font=f_title)) / 2, 26), title, font=f_title, fill=(240, 240, 240, 255))

    def draw_rows(rws, x0):
        y = TITLE_H
        for label, folder, stems, caps in rws:
            lw = d.textlength(label, font=f_label)
            d.text((x0 + LABEL_W - 16 - lw, y + ICON / 2 - 16), label, font=f_label, fill=(235, 235, 235, 255))
            n = len(stems)
            for i, stem in enumerate(stems[:9]):
                ri = ramp_index(i, n) if n > 1 else 8
                col = RAMP[ri]
                if folder in CONST_ROWS:
                    col = CONST_ROWS[folder] + (RAMP[ri][3],)
                if folder in ("pregnancymod", "slp", "defeatmod", "slove"):
                    col = RAMP[[1, 2, 3, 2, 4, 6, 8, 3, 5, 6, 7, 5][i % 12]]
                t = tinted(icons[(folder, stem)], col).resize((ICON, ICON), Image.LANCZOS)
                x = x0 + LABEL_W + i * CELL
                sheet.alpha_composite(t, (int(x + (CELL - ICON) / 2), int(y)))
                cap = caps[i] if i < len(caps) else stem
                cw = d.textlength(cap, font=f_cap)
                d.text((x + (CELL - cw) / 2, y + ICON + 4), cap, font=f_cap, fill=(200, 200, 200, 255))
            y += ROW_H

    draw_rows(left, MARGIN)
    draw_rows(right, MARGIN + COL_W + 40)
    foot = ("Stage counts are the mod's real ones. The ring sweeps with the stage, the glyph fills from the bottom, "
            "the colour is the per-stage tint of the Default colour preset; milk and lactacid keep one colour. "
            "Glyphs: game-icons.net (CC BY 3.0) and hand-drawn, see art/ring/glyphs/CREDITS.md.")
    d.text(((W - d.textlength(foot, font=f_foot)) / 2, H - 34), foot, font=f_foot, fill=(150, 150, 150, 255))
    os.makedirs(os.path.dirname(SHEET), exist_ok=True)
    sheet.convert("RGB").save(SHEET)
    print("wrote", SHEET)


# ---- main ---------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--sheet", action="store_true", help="also write docs/assets/ring-style.png")
    args = parser.parse_args()
    icons = {}
    count = 0
    for where, folder, stems, glyph, badge, fills in SETS:
        n = len(stems)
        dest = os.path.join(LIB, folder.replace("/", os.sep))
        os.makedirs(dest, exist_ok=True)
        for i, stem in enumerate(stems):
            g = glyph[i] if isinstance(glyph, list) else glyph
            b = badge[i] if isinstance(badge, list) else badge
            if fills is None:
                icon = build(g, i / (n - 1), badge=b)
            else:
                icon = build(g, fills[i], badge=b, full_ring=True)
            icon.save(os.path.join(dest, stem + ".dds"), pixel_format="DXT5")
            icons[(folder, stem)] = icon
            count += 1
    print("wrote", count, "icons")
    write_presets()
    if args.sheet:
        write_sheet(icons)


if __name__ == "__main__":
    main()
