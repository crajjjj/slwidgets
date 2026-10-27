"""Hand-drawn SVG glyphs for the icon sets game-icons has nothing usable for.

    python art/ring/draw_custom_glyphs.py     # rewrites the hand-drawn files in art/ring/glyphs

Each file has the shape of a game-icons file (512 viewBox, background square
first, white glyph after) so build_icons.py loads them like any other glyph.
Evenodd fill makes the inner shapes holes. The glyphs: vulva, anus, ovum,
belly (pregnant torso), sperm, sun-simple, snowflake-simple.
"""
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
GI = os.path.join(HERE, "glyphs")

HEAD = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M0 0h512v512H0z"/>'
TAIL = "</svg>"


def circle(cx, cy, r):
    return f"M{cx - r},{cy} a{r},{r} 0 1 0 {2 * r},0 a{r},{r} 0 1 0 {-2 * r},0 Z "


def almond(cx, cy, half_h, bulge_r):
    """Vesica piscis: two arcs of radius bulge_r meeting at top and bottom."""
    top, bot = cy - half_h, cy + half_h
    return f"M{cx},{top} A{bulge_r},{bulge_r} 0 0 1 {cx},{bot} A{bulge_r},{bulge_r} 0 0 1 {cx},{top} Z "


def capsule(cx, cy, length, width, angle_deg):
    a = math.radians(angle_deg)
    dx, dy = math.cos(a), math.sin(a)
    nx, ny = -dy, dx
    hl, hw = length / 2, width / 2
    p = [
        (cx - dx * hl + nx * hw, cy - dy * hl + ny * hw),
        (cx + dx * hl + nx * hw, cy + dy * hl + ny * hw),
        (cx + dx * hl - nx * hw, cy + dy * hl - ny * hw),
        (cx - dx * hl - nx * hw, cy - dy * hl - ny * hw),
    ]
    rect = "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in p) + " Z "
    return rect + circle(cx - dx * hl, cy - dy * hl, hw) + circle(cx + dx * hl, cy + dy * hl, hw)


def drop(cx, cy, r):
    return (f"M{cx},{cy - 2.2 * r} C{cx + 0.1 * r},{cy - 1.4 * r} {cx + r},{cy - 0.9 * r} {cx + r},{cy} "
            f"a{r},{r} 0 1 1 {-2 * r},0 C{cx - r},{cy - 0.9 * r} {cx - 0.1 * r},{cy - 1.4 * r} {cx},{cy - 2.2 * r} Z ")


def svg(paths):
    """paths: list of (d, evenodd)"""
    body = "".join(f'<path fill="#fff"{" fill-rule=\"evenodd\"" if eo else ""} d="{d}"/>' for d, eo in paths)
    return HEAD + body + TAIL


def write(name, paths):
    with open(os.path.join(GI, name + ".svg"), "w", encoding="utf-8") as f:
        f.write(svg(paths))
    print("wrote", name)


# --- vulva: a wide almond (outer labia), a narrower almond hole (inner labia /
# slit) and a round hole at the top (clitoris); a second thin almond hole
# inside the slit keeps a visible line once the glyph is filled
outer = almond(256, 262, 222, 260)
inner = almond(256, 290, 150, 420)
inner_line = almond(256, 300, 110, 2600)
clit = circle(256, 128, 22)
write("vulva", [(outer + inner + clit, True), (inner_line, False)])

# --- anus: a ring nearly filling the box, an asterisk of four lines through its
# center (the user's reference, 2026-10-27: inner ring + asterisk inside the
# icon's own progress ring; the asterisk spans about 0.58 of the hole, the
# strokes match the progress ring's weight at bar size)
ring_out, ring_w = 250, 46
ring = circle(256, 256, ring_out) + circle(256, 256, ring_out - ring_w)
arm = int((ring_out - ring_w) * 0.58)
star = "".join(capsule(256, 256, 2 * arm, int(ring_w * 0.9), i * 45) for i in range(4))
write("anus", [(ring, True), (star, False)])

# --- ovum: a cell with a nucleus hole and a corona of dots
cell = circle(256, 256, 118) + circle(256, 256, 40)
corona = ""
for i in range(14):
    ang = i * (360 / 14)
    corona += circle(256 + 182 * math.cos(math.radians(ang)), 256 + 182 * math.sin(math.radians(ang)), 20)
write("ovum", [(cell, True), (corona, False)])

# --- belly: side profile of a female torso, neck to thigh, with a round swollen
# belly and a navel hole; three drops under the belly for "inflation"
torso = ("M150,16 L222,16 "
         "C222,60 236,86 262,96 "          # neck into the chest
         "C318,100 336,150 300,172 "       # breast
         "C372,186 452,246 448,330 "       # belly, out and down
         "C444,406 390,452 316,452 "       # under the belly
         "L316,496 L150,496 Z ")           # thigh / hip down the back
navel = circle(416, 326, 15)
drops = drop(360, 490, 13) + drop(410, 478, 11) + drop(452, 462, 9)
write("belly", [(torso + navel, True), (drops, False)])


# --- sperm cells: an oval head and a wavy tail (stroked, round caps). A stroke
# is fine here: the glyph pipeline only reads the rendered alpha.
def sperm(cx, cy, scale, angle_deg, tail_w=40):
    """One cell, head at (cx, cy), swimming toward angle_deg (0 = right)."""
    hx, hy = 78 * scale, 56 * scale
    tail = (f"M{-hx * 0.8:.0f},0 C{-hx * 2.2:.0f},{-hy * 1.8:.0f} {-hx * 3.0:.0f},{hy * 1.8:.0f} "
            f"{-hx * 4.3:.0f},{-hy * 0.6:.0f} S{-hx * 6.0:.0f},{hy * 1.2:.0f} {-hx * 6.6:.0f},{hy * 0.2:.0f}")
    return (f'<g transform="translate({cx},{cy}) rotate({angle_deg})">'
            f'<ellipse fill="#fff" cx="0" cy="0" rx="{hx:.0f}" ry="{hy:.0f}"/>'
            f'<path fill="none" stroke="#fff" stroke-width="{tail_w * scale:.0f}" stroke-linecap="round" d="{tail}"/>'
            f'</g>')


def write_raw(name, inner):
    with open(os.path.join(GI, name + ".svg"), "w", encoding="utf-8") as f:
        f.write(HEAD + inner + TAIL)
    print("wrote", name)


# one big cell, diagonal, for "inflation"
write_raw("sperm", sperm(372, 160, 1.0, -35))

# --- sun: a disc with twelve rays, long and short alternating
sun_parts = circle(256, 256, 96)
for i in range(12):
    ang = i * 30
    long = (i % 2 == 0)
    r_mid = 190 if long else 172
    length = 90 if long else 54
    sun_parts += capsule(256 + r_mid * math.cos(math.radians(ang)), 256 + r_mid * math.sin(math.radians(ang)), length, 30, ang)
write("sun-simple", [(sun_parts, False)])

# --- snowflake: six arms, each with a pair of branches and a tip dot
flake = circle(256, 256, 30)
for i in range(6):
    ang = i * 60
    a = math.radians(ang)
    flake += capsule(256 + 118 * math.cos(a), 256 + 118 * math.sin(a), 236, 28, ang)
    for side in (-1, 1):
        bang = ang + side * 55
        bx = 256 + 150 * math.cos(a) + 42 * math.cos(math.radians(bang))
        by = 256 + 150 * math.sin(a) + 42 * math.sin(math.radians(bang))
        flake += capsule(bx, by, 84, 24, bang)
    flake += circle(256 + 236 * math.cos(a), 256 + 236 * math.sin(a), 20)
write("snowflake-simple", [(flake, False)])
