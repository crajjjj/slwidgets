"""Hand-drawn SVG glyphs for the icon sets game-icons has nothing usable for.

    python art/ring/draw_custom_glyphs.py     # rewrites the hand-drawn files in art/ring/glyphs

Each file has the shape of a game-icons file (512 viewBox, background square
first, white glyph after) so build_icons.py loads them like any other glyph.
Evenodd fill makes the inner shapes holes. The glyphs: vulva, anus, ovum,
belly (pregnant torso), sperm, sun-simple, snowflake-simple, the hair
stages pubic-0..5 and armpit-0..6, blood (a splatter) and wound (three claw
slashes).
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


# --- hair (3.4.0): one glyph per SPH stage, from the user's references (hip
# brackets around a Y that grows into a filled triangle; a raised arm with the
# hollow filling up; a razor and sparkles when shaved). Strokes at weight B of
# the drafts (x1.4): the thin reference lines vanished at the 40 px bar size.
# build_icons draws these full and lets the ring alone show the stage.
HAIR_K = 1.4


def hstroke(d, w, extra=""):
    return (f'<path fill="none" stroke="#fff" stroke-width="{w * HAIR_K:.0f}" stroke-linecap="round" '
            f'stroke-linejoin="round"{extra} d="{d}"/>')


def hpoly(points, w=20, extra=""):
    d = "M" + " L".join(f"{x:.0f},{y:.0f}" for x, y in points) + " Z"
    return f'<path fill="#fff" stroke="#fff" stroke-width="{w * HAIR_K:.0f}" stroke-linejoin="round"{extra} d="{d}"/>'


def razor(cx, cy, s=1.0):
    """A silhouette: the rounded head with the blade line as a hole, a handle."""
    head_w, head_h, r = 120 * s, 46 * s, 12 * s
    x, y = cx - head_w / 2, cy - head_h
    head = (f"M{x + r:.0f},{y:.0f} h{head_w - 2 * r:.0f} a{r:.0f},{r:.0f} 0 0 1 {r:.0f},{r:.0f} v{head_h - 2 * r:.0f} "
            f"a{r:.0f},{r:.0f} 0 0 1 {-r:.0f},{r:.0f} h{-(head_w - 2 * r):.0f} a{r:.0f},{r:.0f} 0 0 1 {-r:.0f},{-r:.0f} "
            f"v{-(head_h - 2 * r):.0f} a{r:.0f},{r:.0f} 0 0 1 {r:.0f},{-r:.0f} Z ")
    slot = f"M{x + 10 * s:.0f},{cy - head_h / 2 - 4 * s:.0f} h{head_w - 20 * s:.0f} v{8 * s:.0f} h{-(head_w - 20 * s):.0f} Z "
    out = f'<path fill="#fff" fill-rule="evenodd" d="{head}{slot}"/>'
    out += hpoly([(cx - 17 * s, cy), (cx + 17 * s, cy), (cx + 13 * s, cy + 96 * s), (cx - 13 * s, cy + 96 * s)], 8 * s)
    return out


def sparkle(cx, cy, s=1.0):
    return hstroke(f"M{cx - 20 * s:.0f},{cy} L{cx + 20 * s:.0f},{cy} M{cx},{cy - 20 * s:.0f} L{cx},{cy + 20 * s:.0f}", 12 * s)


def hip_brackets():
    out = ""
    for side in (-1, 1):
        x_in = 256 + side * 128
        x_ctl = 256 + side * 214
        out += hstroke(f"M{x_in},62 Q{x_ctl},256 {x_in},450", 34)
    return out


def bush(w, h, y_top, tufts=False):
    """A filled triangle, point down; tufts: three small ones on the top edge."""
    l, r = 256 - w / 2, 256 + w / 2
    apex = (256, y_top + h)
    parts = hpoly([(l, y_top), (r, y_top), apex])
    if tufts:
        for dx in (-76, 0, 76):
            x = 256 + dx
            parts += hpoly([(x - 16, y_top + 4), (x + 16, y_top + 4), (x, y_top - 26)], 10)
    return parts, apex[1]


def cleft_stem(apex_y):
    return hstroke(f"M256,{apex_y:.0f} L256,404", 26)


def cleft_y(w=22):
    return hstroke("M196,232 L256,300 L316,232", w)


PUBIC_STAGES = [
    lambda: cleft_y() + cleft_stem(300) + razor(332, 340, 0.82) + sparkle(184, 350, 0.9),
    lambda: cleft_y(26) + cleft_stem(300) + hpoly([(201, 236), (311, 236), (256, 300)], 0, ' fill-opacity="0.42"'),
    lambda: (lambda p: p[0] + cleft_stem(p[1]))(bush(120, 72, 232)),
    lambda: (lambda p: p[0] + cleft_stem(p[1]))(bush(172, 100, 218)),
    lambda: (lambda p: p[0] + cleft_stem(p[1]))(bush(226, 128, 204)),
    lambda: (lambda p: p[0] + cleft_stem(p[1]))(bush(258, 144, 196, tufts=True)),
]
for i, make in enumerate(PUBIC_STAGES):
    write_raw(f"pubic-{i}", hip_brackets() + make())


def raised_arm():
    # the arm across the top, the torso down the right, the armpit curve between
    return hstroke("M80,64 L360,64 L360,340 L286,340 L250,156 Q244,122 204,122 L80,122 Z", 30)


def strand(x0, y0, length, lean, wave, w=24):
    c1 = (x0 + lean * 0.2 + wave, y0 + length * 0.35)
    c2 = (x0 + lean * 0.8 - wave, y0 + length * 0.7)
    return hstroke(f"M{x0:.0f},{y0:.0f} C{c1[0]:.0f},{c1[1]:.0f} {c2[0]:.0f},{c2[1]:.0f} {x0 + lean:.0f},{y0 + length:.0f}", w)


def strands(n, length, wave, spread, w=24):
    """n strands hanging from the arm's inner edge, fanning out as they lengthen."""
    xs = [128 + i * (92 / max(n - 1, 1)) for i in range(n)]
    out = ""
    for i, x in enumerate(xs):
        lean = (i - (n - 1) / 2) * spread
        out += strand(x, 150, length, lean, wave * (1 if i % 2 else -1), w)
    return out


ARMPIT_STAGES = [
    lambda: razor(148, 236, 0.9) + sparkle(228, 172, 0.9) + sparkle(104, 170, 0.7),
    lambda: '<ellipse fill="#fff" fill-opacity="0.42" cx="176" cy="168" rx="56" ry="26"/>',
    lambda: "".join(f'<circle fill="#fff" cx="{x}" cy="162" r="13"/>' for x in (128, 160, 192, 220)),
    lambda: strands(4, 42, 0, 6),
    lambda: strands(5, 78, 6, 9),
    lambda: strands(5, 118, 14, 12),
    lambda: strands(5, 140, 14, 13, 26),
]
for i, make in enumerate(ARMPIT_STAGES):
    write_raw(f"armpit-{i}", raised_arm() + make())


# --- blood: a splatter, an uneven blot of overlapping discs with tapered spikes
# of uneven length and a few loose drops, so it reads apart from the wetness
# droplets and the pee splash (ball-tipped arms around a disc read as a germ).
# Every shape is its own path: the pieces overlap, and one path of mixed
# windings would punch holes where they do.
def spike(cx, cy, ang_deg, r0, r1, half_w, tip_r=7):
    a = math.radians(ang_deg)
    dx, dy = math.cos(a), math.sin(a)
    nx, ny = -dy, dx
    bx, by = cx + dx * r0, cy + dy * r0
    tx, ty = cx + dx * r1, cy + dy * r1
    tri = (f"M{bx + nx * half_w:.1f},{by + ny * half_w:.1f} L{tx + nx * tip_r:.1f},{ty + ny * tip_r:.1f} "
           f"L{tx - nx * tip_r:.1f},{ty - ny * tip_r:.1f} L{bx - nx * half_w:.1f},{by - ny * half_w:.1f} Z ")
    return [tri, circle(round(tx), round(ty), tip_r)]


def blood():
    cx, cy = 256, 256
    parts = [circle(250, 266, 96), circle(212, 222, 70), circle(300, 300, 78), circle(310, 214, 52),
             circle(196, 314, 50), circle(262, 196, 48)]
    # (angle, tip distance, base half-width)
    for ang, reach, w in [(-112, 196, 30), (-74, 150, 18), (-34, 226, 34), (4, 160, 20), (58, 214, 32),
                          (96, 146, 18), (134, 192, 26), (176, 222, 34), (226, 150, 20)]:
        parts += spike(cx, cy, ang, 70, reach, w)
    # (angle, distance, radius): the loose drops
    for ang, dist, r in [(-92, 222, 14), (-56, 196, 20), (24, 210, 11), (34, 186, 16), (80, 206, 22),
                         (112, 222, 10), (156, 210, 15), (204, 196, 19), (248, 214, 12)]:
        a = math.radians(ang)
        parts.append(circle(round(cx + math.cos(a) * dist), round(cy + math.sin(a) * dist), r))
    return [(d, False) for d in parts]


write("blood", blood())


# --- wound: three claw slashes, upper right to lower left, each a curved
# stroke that tapers to a point at both ends; the middle one is the longest
def slash(cx, cy, length, half_w, angle_deg, bend, n=32):
    a = math.radians(angle_deg)
    dx, dy = math.cos(a), math.sin(a)
    nx, ny = -dy, dx
    x0, y0 = cx - dx * length / 2, cy - dy * length / 2
    x1, y1 = cx + dx * length / 2, cy + dy * length / 2
    qx, qy = cx + nx * bend, cy + ny * bend
    left, right = [], []
    for i in range(n + 1):
        t = i / n
        # quadratic bezier point and its tangent
        px = (1 - t) ** 2 * x0 + 2 * (1 - t) * t * qx + t * t * x1
        py = (1 - t) ** 2 * y0 + 2 * (1 - t) * t * qy + t * t * y1
        tx = 2 * (1 - t) * (qx - x0) + 2 * t * (x1 - qx)
        ty = 2 * (1 - t) * (qy - y0) + 2 * t * (y1 - qy)
        tl = math.hypot(tx, ty) or 1.0
        ox, oy = -ty / tl, tx / tl
        hw = half_w * math.sin(math.pi * t) ** 0.6
        left.append((px + ox * hw, py + oy * hw))
        right.append((px - ox * hw, py - oy * hw))
    pts = left + right[::-1]
    return "M" + " L".join(f"{x:.1f},{y:.1f}" for x, y in pts) + " Z "


WOUND_ANGLE = 115
_perp = math.radians(WOUND_ANGLE + 90)
wound = []
for off, length in [(-112, 330), (0, 410), (112, 330)]:
    wound.append((slash(256 + math.cos(_perp) * off, 256 + math.sin(_perp) * off, length, 36, WOUND_ANGLE, 26), False))
write("wound", wound)
