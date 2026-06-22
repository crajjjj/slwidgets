"""One-off generator for the Custom Packs page.

Reads the SLW custom-pack zips from the Downloads folder, converts representative
icons to PNG (docs/assets/packs/), and writes docs/custom-packs.md. Each alternative
is shown as its own subsection titled with the exact file to download, followed by a
single row of preview icons.

Local tool only (not part of the mod build). The generated PNGs + markdown are what
get committed; this script needs the zips present to re-run.
"""
import os
import glob
import io
import zipfile
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
DOWNLOADS = os.path.join(os.path.expanduser("~"), "Downloads")
LIB = os.path.join(ROOT, "Interface", "exported", "widgets", "iwant", "widgets", "library")
OUT_IMG = os.path.join(ROOT, "docs", "assets", "packs")
OUT_MD = os.path.join(ROOT, "docs", "custom-packs.md")

os.makedirs(OUT_IMG, exist_ok=True)
for _f in os.listdir(OUT_IMG):
    if _f.endswith(".png"):
        os.remove(os.path.join(OUT_IMG, _f))


def sample_indices(n, k=4):
    if n <= k:
        return list(range(n))
    return sorted({round(i * (n - 1) / (k - 1)) for i in range(k)})


def find_zip(fragment):
    hits = glob.glob(os.path.join(DOWNLOADS, fragment))
    if not hits:
        raise FileNotFoundError(fragment)
    return hits[0]


def zip_bytes(zip_path, suffix):
    suffix = suffix.lower()
    with zipfile.ZipFile(zip_path) as z:
        for name in z.namelist():
            if name.lower().replace("\\", "/").endswith(suffix):
                return z.read(name)
    raise KeyError(f"{suffix} not in {os.path.basename(zip_path)}")


def save_png(img, out_name):
    img.convert("RGBA").save(os.path.join(OUT_IMG, out_name + ".png"), "PNG")
    return out_name + ".png"


def stock_img(rel):
    return Image.open(os.path.join(LIB, rel.replace("/", os.sep)))


def pack_img(zip_path, suffix):
    return Image.open(io.BytesIO(zip_bytes(zip_path, suffix)))


md = []


def w(s=""):
    md.append(s)


def icon_row(cells):
    w('<div class="icon-grid" markdown>')
    for c in cells:
        w(c)
    w("</div>\n")


def fig(fn, alt, caption):
    return (f'<figure class="icon-cell"><img src="assets/packs/{fn}" alt="{alt}">'
            f'<figcaption>{caption}</figcaption></figure>')


def variant_heading(v):
    if v.get("file"):
        w(f"### {v['label']} — `{v['file']}`\n")
    else:
        w(f"### {v['label']} — built in (default)\n")
    bits = []
    if v.get("by"):
        bits.append(f"By {v['by']}.")
    if v.get("desc"):
        bits.append(v["desc"])
    if bits:
        w("*" + " ".join(bits) + "*\n")


def stage_group(gkey, heading, intro, lib_prefix, n, variants):
    w(f"\n## {heading}\n")
    w(intro)
    w("\n!!! warning \"Pick one\"\n"
      "    These packs all replace the same texture files. Install **only one** of the "
      "options below for this icon — a second pack would overwrite the first.\n")
    cols = sample_indices(n)
    for v in variants:
        variant_heading(v)
        cells = []
        for i in cols:
            img = stock_img(f"{lib_prefix}{i}.dds") if v["src"] == "stock" \
                else pack_img(v["zip"], f"{v['suffix']}{i}.dds")
            fn = save_png(img, f"{gkey}_{v['key']}_{i}")
            cells.append(fig(fn, f"{v['label']} stage {i}", i))
        icon_row(cells)


def toggle_group(gkey, heading, intro, columns, variants):
    w(f"\n## {heading}\n")
    w(intro)
    w("\n!!! warning \"Pick one\"\n"
      "    Install **only one** option below — packs replace the same texture files.\n")
    for v in variants:
        variant_heading(v)
        cells = []
        for name, cap in columns:
            img = stock_img(f"pregnancymod/{name}.dds") if v["src"] == "stock" \
                else pack_img(v["zip"], f"pregnancymod/{name}.dds")
            fn = save_png(img, f"{gkey}_{v['key']}_{name}")
            cells.append(fig(fn, f"{v['label']} {cap}", cap))
        icon_row(cells)


# ---------------------------------------------------------------- page header
w("# Custom Icon Packs\n")
w(
    "Community-made alternative icons for SL Widgets. Each pack restyles one icon set "
    "while leaving everything else stock. Below, every option is titled with the **exact "
    "file to download** so you know which one gives which look.\n"
)
w(
    "!!! info \"Where to get them\"\n"
    "    All packs are **Optional Files** on the "
    "[SL Widgets Nexus page](https://www.nexusmods.com/skyrimspecialedition/mods/164162?tab=files). "
    "Download the file named in each heading below.\n"
)
w(
    "!!! note \"Installing a pack\"\n"
    "    Install the downloaded archive with your mod manager and let it **overwrite SL "
    "    Widgets'** files (or drop its `Interface/...` folder into `Data/`). Packs only "
    "    replace `.dds` textures — no plugin, no new requirements. To revert, reinstall SL "
    "    Widgets or remove the pack.\n"
)

# ---------------------------------------------------------------- arousal
stage_group(
    "arousal",
    "Arousal (SexLab Aroused)",
    "*Replaces the arousal icon. Requires SexLabAroused.esm in-game.*\n",
    "sla/arousal/aroused",
    9,
    [
        {"key": "stock", "label": "Stock heart", "src": "stock",
         "desc": "The default arousal icon. The same heart is also offered as a standalone "
                 "download (file SLW_Custom_Pack_Alternative_arousalHeart) so you can restore "
                 "it after trying another pack."},
        {"key": "face", "label": "Face", "src": "zip",
         "file": "SLW_Custom_Pack_Arousal_face",
         "zip": find_zip("SLW_Custom_Pack_Arousal_face*.zip"), "suffix": "sla/arousal/aroused"},
        {"key": "caiena", "label": "Caiena style", "src": "zip", "by": "Caiena",
         "file": "SLW_Custom_Pack_SLA_Arousal_by_Caiena",
         "zip": find_zip("SLW_Custom_Pack_SLA_Arousal_by_Caiena*.zip"), "suffix": "sla/arousal/aroused"},
    ],
)

# ---------------------------------------------------------------- FHU total
stage_group(
    "fhu",
    "Fill Her Up — total cum",
    "*Replaces the FHU total-pool icon. Requires sr_FillHerUp.esp in-game.*\n",
    "fhu/total/cum",
    9,
    [
        {"key": "stock", "label": "Stock", "src": "stock"},
        {"key": "alt", "label": "Alternative", "src": "zip",
         "file": "SLW_Custom_Pack_Alternative_FHU_total",
         "desc": "Also bundles an alternative cum-inflation (pregnancy) icon.",
         "zip": find_zip("SLW_Custom_Pack_Alternative_FHU_total*.zip"), "suffix": "fhu/total/cum"},
        {"key": "memati", "label": "memati style", "src": "zip", "by": "memati",
         "file": "SLW_Custom_Pack_FHU_by_memati",
         "zip": find_zip("SLW_Custom_Pack_FHU_by_memati*.zip"), "suffix": "fhu/total/cum"},
    ],
)

# ---------------------------------------------------------------- pregnancy
toggle_group(
    "preg",
    "Pregnancy",
    "*Replaces several pregnancy condition icons. Requires a supported pregnancy mod in-game.*\n",
    [
        ("cum", "Cum inflation"),
        ("ovulation", "Ovulation"),
        ("fetus", "Fetus"),
        ("chaurusEggs", "Chaurus eggs"),
        ("spiderEggs", "Spider eggs"),
    ],
    [
        {"key": "stock", "label": "Stock", "src": "stock"},
        {"key": "alt", "label": "Alternative", "src": "zip",
         "file": "SLWidgets_Alternative_Pregnancy_Widgets",
         "zip": find_zip("SLWidgets_Alternative_Pregnancy_Widgets*.zip")},
    ],
)

with open(OUT_MD, "w", encoding="utf-8") as f:
    f.write("\n".join(md))

print("Wrote", OUT_MD)
print("PNG count:", len([n for n in os.listdir(OUT_IMG) if n.endswith(".png")]))
