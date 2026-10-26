"""Draw the brain icon of the SLO VE willpower bar.

    python build_willpower_icon.py            # writes the .dds the mod ships
    python build_willpower_icon.py --png X    # also a PNG preview at path X

A top view of a brain in the style of the other SL Widgets icons: white on
transparent, 100x100, DXT5. The outline is not traced from anything: each
hemisphere is a ring of overlapping lobes (circles), and the stroke is that
shape minus the same shape with every lobe drawn a stroke width smaller, which
is what puts the little inward notch between two lobes.

Needs Pillow 11.2 or newer (the first with a DXT5 writer).
"""
import argparse
import math
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw

# the classic brain; the shipped one is drawn by build_icons.py (ring style)
OUT = Path(__file__).parent / "art/classic/library/slove/willpower.dds"

S = 800        # work size; the result is this scaled down to 100
STROKE = 44    # line width at work size (5.5 px in the icon)
CX = S // 2

# One hemisphere (the left): its lobes, as (center x, center y, radius), walked
# from the front (top) round the outside to the back (bottom).
LOBES = [
    (318, 150, 86),
    (232, 196, 92),
    (166, 286, 96),
    (140, 400, 100),
    (160, 514, 96),
    (226, 604, 92),
    (316, 652, 84),
]
# what fills the middle of the hemisphere behind the lobes
BODY = (150, 110, 420, 690)
# and the strip along the inner face, between the first and the last lobe
INNER = (318, 128, CX, 674)

# The folds inside: arcs as (bounding box, start angle, end angle), PIL angles
# (0 = east, clockwise).
FOLDS = [
    ((226, 196, 346, 316), 200, 40),
    ((186, 330, 326, 470), 250, 100),
    ((226, 484, 346, 604), 150, 350),
]


def hemisphere(shrink):
    """The left hemisphere as a mask, every edge pulled in by `shrink`."""
    mask = Image.new("L", (S, S), 0)
    draw = ImageDraw.Draw(mask)
    x0, y0, x1, y1 = BODY
    draw.ellipse((x0 + shrink, y0 + shrink, x1 - shrink, y1 - shrink), fill=255)
    for x, y, r in LOBES:
        r -= shrink
        draw.ellipse((x - r, y - r, x + r, y + r), fill=255)
    # the same at every shrink: it carries the inside up to the inner face, so
    # the line between the hemispheres comes out one even width
    draw.rectangle(INNER, fill=255)
    # the flat inner face: half a stroke each, so the two hemispheres share one line
    draw.rectangle((CX - shrink // 2, 0, S, S), fill=0)
    return mask


def left_half():
    line = ImageChops.subtract(hemisphere(0), hemisphere(STROKE))
    draw = ImageDraw.Draw(line)
    for box, start, end in FOLDS:
        draw.arc(box, start, end, fill=255, width=STROKE - 8)
        # round ends: PIL's arcs are cut square
        x0, y0, x1, y1 = box
        r = (x1 - x0) / 2
        mid = r - (STROKE - 8) / 2
        for angle in (start, end):
            ex = (x0 + x1) / 2 + mid * math.cos(math.radians(angle))
            ey = (y0 + y1) / 2 + mid * math.sin(math.radians(angle))
            cap = (STROKE - 8) / 2
            draw.ellipse((ex - cap, ey - cap, ex + cap, ey + cap), fill=255)
    # folds must not spill over the inner face
    draw.rectangle((CX, 0, S, S), fill=0)
    return line


def build():
    half = left_half()
    alpha = ImageChops.lighter(half, half.transpose(Image.FLIP_LEFT_RIGHT))
    alpha = alpha.resize((100, 100), Image.LANCZOS)
    icon = Image.new("RGBA", (100, 100), (255, 255, 255, 0))
    icon.putalpha(alpha)
    return icon


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--png", help="also write a PNG preview here")
    args = parser.parse_args()
    icon = build()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    icon.save(OUT, pixel_format="DXT5")
    print("wrote", OUT, OUT.stat().st_size, "bytes")
    if args.png:
        # on a dark ground, enlarged: white on transparent shows nothing in a viewer
        # and beside it at about the size the bar shows it, which is what counts
        ground = Image.new("RGBA", (100, 100), (40, 40, 48, 255))
        ground.alpha_composite(icon)
        preview = Image.new("RGBA", (460, 400), (40, 40, 48, 255))
        preview.paste(ground.resize((400, 400), Image.LANCZOS), (0, 0))
        preview.paste(ground.resize((29, 29), Image.LANCZOS), (416, 185))
        preview.save(args.png)
        print("wrote", args.png)


if __name__ == "__main__":
    main()
