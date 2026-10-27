"""Write a DXT5 .dds with the header fields the DDS spec gives a compressed texture.

Pillow (11.2 to 12.x) encodes DXT5 but puts (width + 3) * 4 in dwPitchOrLinearSize,
where the spec wants the byte size of the top mip, and the RGBA bit count (32) in
the pixel format's dwRGBBitCount, which a FourCC format leaves at 0. The icons
SL Widgets 3.0.0 and 3.0.1 shipped carried those two values and drew as diagonal
streaks in iWant Widgets' Flash loader (two user reports; the Prisma renderer
decodes through WIC and showed them fine, which is why it went unnoticed). The
classic icons, which load everywhere, carry the spec values, so every icon goes
through save_dxt5: Pillow encodes, then the two fields are set to what the spec
says. Nothing else is touched: a mip count of 0, which Pillow also writes, is in
classic icons that have loaded for years.

    python savedds.py --check <folder>...   list .dds files whose header is off
    python savedds.py --fix <folder>...     rewrite those headers in place
"""
import io
import os
import struct
import sys

DDPF_FOURCC = 0x4
BLOCK_BYTES = {b"DXT1": 8, b"DXT3": 16, b"DXT5": 16}


def linear_size(width, height, block_bytes):
    return max(1, (width + 3) // 4) * max(1, (height + 3) // 4) * block_bytes


def fixed_header(data):
    """The file with its header set per the spec, or None when it is not a
    FourCC-compressed DDS this knows. The pixel data is left alone."""
    if len(data) < 128 or data[:4] != b"DDS ":
        return None
    pfflags = struct.unpack_from("<I", data, 80)[0]
    fourcc = bytes(data[84:88])
    if not pfflags & DDPF_FOURCC or fourcc not in BLOCK_BYTES:
        return None
    height, width = struct.unpack_from("<II", data, 12)
    out = bytearray(data)
    struct.pack_into("<I", out, 20, linear_size(width, height, BLOCK_BYTES[fourcc]))
    struct.pack_into("<I", out, 88, 0)
    return bytes(out)


def save_dxt5(img, path):
    buf = io.BytesIO()
    img.save(buf, format="DDS", pixel_format="DXT5")
    data = fixed_header(buf.getvalue())
    if data is None:
        raise RuntimeError("Pillow did not write a DXT5 file for " + str(path))
    with open(path, "wb") as f:
        f.write(data)


def off_spec(folders):
    """Paths of .dds files under the folders whose header fixed_header would change."""
    bad = []
    for folder in folders:
        for dp, _, fns in os.walk(folder):
            for fn in fns:
                if not fn.lower().endswith(".dds"):
                    continue
                p = os.path.join(dp, fn)
                with open(p, "rb") as f:
                    data = f.read()
                fixed = fixed_header(data)
                if fixed is not None and fixed != data:
                    bad.append(p)
    return bad


def main(argv):
    if len(argv) < 2 or argv[0] not in ("--check", "--fix"):
        print(__doc__)
        return 2
    bad = off_spec(argv[1:])
    for p in bad:
        print(p)
    if argv[0] == "--fix":
        for p in bad:
            with open(p, "rb") as f:
                data = f.read()
            with open(p, "wb") as f:
                f.write(fixed_header(data))
        print("rewrote", len(bad), "headers")
    else:
        print(len(bad), "files off spec")
    return 1 if bad and argv[0] == "--check" else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
