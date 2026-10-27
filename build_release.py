"""Package the release: one FOMOD archive with the icon style as its choice.

    python build_release.py

Run it after the plugin build (plugin\\, the DLL the zip packs), the Papyrus
build (Pyro writes Build/SLWidgets.zip, the whole mod as a flat tree) and
build_icons.py. The version comes from slw_util.GetVersionString(). It writes

  Build/SLWidgets <version>.zip
    fomod/             info.xml (version stamped), ModuleConfig.xml, the preview images
    00 Core/           Pyro's zip minus the icon library and the two colour presets
                       an icon style owns (Default, HideEmpty); keeps misc/placeholder
    01 Ring Icons/     the ring library and the ring Default / HideEmpty presets
    02 Classic Icons/  art/classic: the hand-drawn classic art, the sets
                       build_icons.py draws in the classic look, the classic presets

Either option installs a COMPLETE library (nothing is overlaid any more), so
the classic library must hold exactly the ring library's files; the packager
refuses otherwise. Until 3.3.0 the classic icons were a separate overlay zip.
"""
import os
import re
import xml.etree.ElementTree as ET
import zipfile

import savedds

ROOT = os.path.dirname(os.path.abspath(__file__))
LIB_REL = "Interface/exported/widgets/iwant/widgets/library"
PRESETS_REL = "SKSE/Plugins/SlWidgets/IconPresets"
STYLE_PRESETS = ("Default.json", "HideEmpty.json")  # the presets an icon style owns
CLASSIC = os.path.join(ROOT, "art", "classic")
FOMOD = os.path.join(ROOT, "fomod")


def version():
    src = open(os.path.join(ROOT, "Source", "Scripts", "slw_util.psc"), encoding="utf-8").read()
    m = re.search(r'GetVersionString\(\) Global\s+Return "([^"]+)"', src)
    if not m:
        raise SystemExit("version not found in slw_util.psc")
    return m.group(1)


def walk(folder):
    for dp, _, fns in os.walk(folder):
        for fn in fns:
            yield os.path.join(dp, fn)


def check_fresh(pyro_zip, ver):
    """Refuse to package an old Pyro zip under the current version.

    The compiled slw_util.pex inside must carry the version string, and no
    file Pyro packs may be newer than the zip (Pyro writes the zip last)."""
    with zipfile.ZipFile(pyro_zip) as z:
        try:
            pex = z.read("Scripts/slw_util.pex")
        except KeyError:
            raise SystemExit(f"{pyro_zip} has no Scripts/slw_util.pex: rerun Pyro")
    if ver.encode() not in pex:
        raise SystemExit(f"{pyro_zip} was built for another version than {ver}: rerun Pyro")
    # The SKSE menu DLL ships in the same zip (plugin\\ builds it into
    # SKSE\\Plugins); its version resource holds the version string in UTF-16.
    with zipfile.ZipFile(pyro_zip) as z:
        try:
            dll = z.read("SKSE/Plugins/SLWidgetsMenu.dll")
        except KeyError:
            raise SystemExit(f"{pyro_zip} has no SKSE/Plugins/SLWidgetsMenu.dll: build plugin\\ "
                             "(xmake f -m release && xmake), then rerun Pyro")
    if ver.encode("utf-16-le") not in dll:
        raise SystemExit(f"the SLWidgetsMenu.dll in {pyro_zip} is not version {ver}: rebuild plugin\\, then rerun Pyro")
    zip_time = os.path.getmtime(pyro_zip)
    sources = [os.path.join(ROOT, "SLWidgets.esp")]
    for folder in ("Scripts", os.path.join("Source", "Scripts"), "Interface", "SKSE", "Seq"):
        sources.extend(walk(os.path.join(ROOT, folder)))
    newer = [p for p in sources if os.path.getmtime(p) > zip_time + 1]
    if newer:
        raise SystemExit(f"{len(newer)} files are newer than {pyro_zip} (e.g. "
                         f"{os.path.relpath(newer[0], ROOT)}): rerun Pyro")


def check_dds_headers():
    """Every shipped texture must carry a spec header (savedds.py says which
    fields and why): the 3.0.0 / 3.0.1 icons did not and drew as streaks in
    the Flash iWant Widgets."""
    bad = savedds.off_spec([os.path.join(ROOT, LIB_REL.replace("/", os.sep)),
                            os.path.join(CLASSIC, "library")])
    if bad:
        raise SystemExit(f"{len(bad)} .dds files have an off-spec header (e.g. "
                         f"{os.path.relpath(bad[0], ROOT)}): python savedds.py --fix <folder>")


def check_translations():
    """Every MCM translation file must be UTF-16LE with a BOM, CRLF-only, one
    '$key<TAB>value' per non-empty line. A bare CR inside one line hid two
    Debug-page labels in all ten files from 2.2.2 to 3.2.0: the engine showed
    both keys untranslated."""
    bad = []
    for p in walk(os.path.join(ROOT, "Interface", "Translations")):
        if not p.lower().endswith(".txt"):
            continue
        rel = os.path.relpath(p, ROOT)
        raw = open(p, "rb").read()
        if raw[:2] != b"\xff\xfe":
            bad.append(f"{rel}: no UTF-16LE BOM")
            continue
        text = raw[2:].decode("utf-16-le", errors="replace")
        if re.search(r"\r(?!\n)|(?<!\r)\n", text):
            bad.append(f"{rel}: a line end that is not CRLF")
        for n, line in enumerate(text.split("\r\n"), 1):
            if line and (not line.startswith("$") or line.count("\t") != 1):
                bad.append(f"{rel}:{n}: not '$key<TAB>value'")
    if bad:
        raise SystemExit("translation files:\n  " + "\n  ".join(bad[:10]))


def library_files(root):
    """Relative paths of the .dds files under an icon library, minus misc/."""
    out = set()
    for p in walk(root):
        rel = os.path.relpath(p, root).replace(os.sep, "/")
        if rel.lower().endswith(".dds") and not rel.startswith("misc/"):
            out.add(rel)
    return out


def check_classic_complete():
    """The installer's Classic option replaces the ring library outright, so the
    classic library must hold the same files: a missing one would be a missing
    icon, not a fallback to the ring art (build_icons.py draws the generated sets)."""
    ring = library_files(os.path.join(ROOT, LIB_REL.replace("/", os.sep)))
    classic = library_files(os.path.join(CLASSIC, "library"))
    missing, extra = sorted(ring - classic), sorted(classic - ring)
    if missing or extra:
        raise SystemExit(f"classic library: {len(missing)} files missing (e.g. {missing[:3]}), "
                         f"{len(extra)} not in the ring library (e.g. {extra[:3]}): run build_icons.py")


def stamped_info_xml(ver):
    """fomod/info.xml with the version slw_util holds; the tracked file is
    brought in step as well, so the two never disagree."""
    path = os.path.join(FOMOD, "info.xml")
    text = open(path, encoding="utf-8").read()
    new, n = re.subn(r'<Version MachineVersion="[^"]*">[^<]*</Version>',
                     f'<Version MachineVersion="{ver}">{ver}</Version>', text)
    if n != 1:
        raise SystemExit("fomod/info.xml has no <Version MachineVersion=...> element")
    if new != text:
        open(path, "w", encoding="utf-8", newline="").write(new)
        print("stamped fomod/info.xml with", ver)
    return new


def write_fomod(pyro_zip, ver, out):
    lib_prefix = LIB_REL + "/"
    style_presets = {f"{PRESETS_REL}/{n}" for n in STYLE_PRESETS}
    with zipfile.ZipFile(pyro_zip) as src, zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        for info in src.infolist():
            if info.is_dir():
                continue
            name = info.filename.replace("\\", "/")
            style = (name.startswith(lib_prefix) and not name.startswith(lib_prefix + "misc/")) or name in style_presets
            z.writestr(("01 Ring Icons/" if style else "00 Core/") + name, src.read(info))
        lib = os.path.join(CLASSIC, "library")
        for p in walk(lib):
            z.write(p, "02 Classic Icons/" + LIB_REL + "/" + os.path.relpath(p, lib).replace(os.sep, "/"))
        for n in STYLE_PRESETS:
            z.write(os.path.join(CLASSIC, "presets", n), f"02 Classic Icons/{PRESETS_REL}/{n}")
        z.writestr("fomod/info.xml", stamped_info_xml(ver))
        for fn in sorted(os.listdir(FOMOD)):
            if fn != "info.xml":
                z.write(os.path.join(FOMOD, fn), "fomod/" + fn)
    check_fomod(out)


def check_fomod(path):
    """Every folder and image ModuleConfig.xml names is in the archive, Core
    holds no icon textures, and the two style folders hold the same file set."""
    with zipfile.ZipFile(path) as z:
        names = [n.replace("\\", "/") for n in z.namelist()]
        root = ET.fromstring(z.read("fomod/ModuleConfig.xml"))
    tops = {n.split("/")[0] for n in names}
    for el in root.iter("folder"):
        if el.get("source") not in tops:
            raise SystemExit(f"ModuleConfig.xml names folder '{el.get('source')}', not in the archive")
    for el in root.iter("image"):
        if el.get("path").replace("\\", "/") not in names:
            raise SystemExit(f"ModuleConfig.xml names image '{el.get('path')}', not in the archive")
    core = [n for n in names if n.startswith("00 Core/")]
    if any(n.startswith("00 Core/" + LIB_REL + "/") and "/misc/" not in n for n in core):
        raise SystemExit("00 Core holds icon textures; the style folders should")
    ring = {n.split("/", 1)[1] for n in names if n.startswith("01 Ring Icons/") and n.endswith(".dds")}
    classic = {n.split("/", 1)[1] for n in names if n.startswith("02 Classic Icons/") and n.endswith(".dds")}
    if ring != classic:
        raise SystemExit("the two icon style folders hold different texture sets")
    print(f"fomod ok: {len(core)} core files, {len(ring)} textures per style")


def main():
    ver = version()
    check_dds_headers()
    check_translations()
    check_classic_complete()
    out_dir = os.path.join(ROOT, "Build")
    os.makedirs(out_dir, exist_ok=True)
    pyro_zip = os.path.join(out_dir, "SLWidgets.zip")
    if not os.path.exists(pyro_zip):
        raise SystemExit("no Build/SLWidgets.zip: run the Papyrus build (Pyro) first")
    check_fresh(pyro_zip, ver)
    named = os.path.join(out_dir, f"SLWidgets {ver}.zip")
    write_fomod(pyro_zip, ver, named)
    print("wrote", named, os.path.getsize(named) // 1024, "KB")


if __name__ == "__main__":
    main()
