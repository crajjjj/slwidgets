"""Package the optional "Classic Icons" download and name the release zip.

    python build_release.py

Run it after the Papyrus build (Pyro also writes Build/SLWidgets.zip, the
mod itself) and after build_icons.py. The version comes from
slw_util.GetVersionString(). It writes:

  Build/SLWidgets <version>.zip                 Pyro's Build/SLWidgets.zip, renamed
                                                (the mod, with the ring icons)
  Build/SLWidgets Classic Icons <version>.zip   an optional download: the art the
                                                sets that pre-date 3.0.0 shipped
                                                before, plus the matching Default
                                                and HideEmpty colour presets; it
                                                installs over the mod like the
                                                custom icon packs do

The classic pack is built from art/classic. The sets new in 3.0.0 only exist
in the ring style, so the pack leaves them alone.
"""
import os
import re
import shutil
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
LIB_REL = "Interface/exported/widgets/iwant/widgets/library"
PRESETS_REL = "SKSE/Plugins/SlWidgets/IconPresets"
CLASSIC = os.path.join(ROOT, "art", "classic")


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
    """Refuse to name an old Pyro zip with the current version.

    The compiled slw_util.pex inside must carry the version string, and no
    file Pyro packs may be newer than the zip (Pyro writes the zip last)."""
    with zipfile.ZipFile(pyro_zip) as z:
        try:
            pex = z.read("Scripts/slw_util.pex")
        except KeyError:
            raise SystemExit(f"{pyro_zip} has no Scripts/slw_util.pex: rerun Pyro")
    if ver.encode() not in pex:
        raise SystemExit(f"{pyro_zip} was built for another version than {ver}: rerun Pyro")
    # The position editor ships in the same zip (plugin\ builds it into
    # SKSE\Plugins); its version resource holds the version string in UTF-16.
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


def main():
    ver = version()
    out_dir = os.path.join(ROOT, "Build")
    os.makedirs(out_dir, exist_ok=True)

    pyro_zip = os.path.join(out_dir, "SLWidgets.zip")
    if os.path.exists(pyro_zip):
        check_fresh(pyro_zip, ver)
        named = os.path.join(out_dir, f"SLWidgets {ver}.zip")
        shutil.copyfile(pyro_zip, named)
        print("wrote", named, os.path.getsize(named) // 1024, "KB")
    else:
        print("no Build/SLWidgets.zip: run the Papyrus build (Pyro) for the mod archive")

    pack = os.path.join(out_dir, f"SLWidgets Classic Icons {ver}.zip")
    lib = os.path.join(CLASSIC, "library")
    presets = os.path.join(CLASSIC, "presets")
    with zipfile.ZipFile(pack, "w", zipfile.ZIP_DEFLATED) as z:
        for p in walk(lib):
            z.write(p, LIB_REL + "/" + os.path.relpath(p, lib).replace(os.sep, "/"))
        for p in walk(presets):
            z.write(p, PRESETS_REL + "/" + os.path.basename(p))
        z.writestr("SLWidgets Classic Icons - readme.txt",
                   f"SL Widgets {ver} - Classic Icons\n\n"
                   "The icons SL Widgets shipped before 3.0.0, for people who prefer them to the ring set.\n"
                   "Install after SL Widgets and let it overwrite: it replaces the textures of the sets that\n"
                   "existed before 3.0.0 and the Default and HideEmpty colour presets. The sets new in 3.0.0\n"
                   "(food, thirst, cold, fatigue, dirtiness, wetness, hair, baby health, stress, fear,\n"
                   "injuries, diseases) keep the ring style; there is no other art for them.\n"
                   "To go back to the ring icons, reinstall SL Widgets.\n")
    print("wrote", pack, os.path.getsize(pack) // 1024, "KB")


if __name__ == "__main__":
    main()
