"""Assemble the SL Widgets release archive, a FOMOD with two icon styles.

    python build_release.py            # -> Build/SLWidgets <version>.zip

Run it after the Papyrus build (Scripts/*.pex must be current) and after
build_icons.py. The version comes from slw_util.GetVersionString().

Archive layout (what the installer sees):
  fomod/info.xml, fomod/ModuleConfig.xml
  00 Core/            plugin, scripts and sources, translations, SEQ, the
                      settings and colour presets except Default.json, the
                      new 3.0.0 icon sets (both styles share them)
  10 Classic Icons/   the classic art of the sets that pre-date 3.0.0, and
                      the classic Default.json colour preset
  20 Ring Icons/      the same sets drawn in the ring style (art/ring/library)
                      and the ring Default.json (the fine-to-worst ramp)
The two icon folders are one "pick exactly one" group. Pyro's own zip step
cannot nest option folders, which is why this exists; Pyro's flat
Build/SLWidgets.zip is left alone.
"""
import os
import re
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
LIB_REL = "Interface/exported/widgets/iwant/widgets/library"
RING_LIB = os.path.join(ROOT, "art", "ring", "library")
RING_PRESET = os.path.join(ROOT, "art", "ring", "presets", "Default.json")
PRESET_REL = "SKSE/Plugins/SlWidgets/IconPresets/Default.json"


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


def rel(path, base=ROOT):
    return os.path.relpath(path, base).replace(os.sep, "/")


def ring_set_folders():
    """The library folders art/ring/library restyles (relative to the library root)."""
    return {rel(os.path.dirname(p), RING_LIB) for p in walk(RING_LIB)}


def module_config(ver):
    return f"""<?xml version="1.0" encoding="UTF-16"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>SL Widgets {ver}</moduleName>
  <requiredInstallFiles>
    <folder source="00 Core" destination="" priority="0" />
  </requiredInstallFiles>
  <installSteps order="Explicit">
    <installStep name="Icon style">
      <optionalFileGroups order="Explicit">
        <group name="Icon style" type="SelectExactlyOne">
          <plugins order="Explicit">
            <plugin name="Ring icons (new in 3.0)">
              <description>Every icon drawn in one style: a progress ring around a glyph, coloured white to gold to orange to red as the value worsens (milk and lactacid keep one colour). The default colour preset is the ring ramp. Pick this for a uniform HUD.</description>
              <files>
                <folder source="20 Ring Icons" destination="" priority="1" />
              </files>
              <typeDescriptor><type name="Recommended" /></typeDescriptor>
            </plugin>
            <plugin name="Classic icons">
              <description>The icons SL Widgets shipped before 3.0 (hearts, bottles, drawings) with their colour preset. The sets new in 3.0 (food, thirst, cold, fatigue, dirtiness, wetness, hair, baby health, stress, fear, injuries, diseases) only exist in the ring style and are installed either way.</description>
              <files>
                <folder source="10 Classic Icons" destination="" priority="1" />
              </files>
              <typeDescriptor><type name="Optional" /></typeDescriptor>
            </plugin>
          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
  </installSteps>
</config>
"""


def info_xml(ver):
    return f"""<?xml version="1.0" encoding="UTF-16"?>
<fomod>
  <Name>SL Widgets</Name>
  <Author>crajjjj</Author>
  <Version>{ver}</Version>
  <Website>https://www.nexusmods.com/skyrimspecialedition/mods/164162</Website>
  <Description>iWant Status Bars plugin: SexLab, survival and body status icons for the player and up to three NPCs.</Description>
  <Groups><element>User Interface</element></Groups>
</fomod>
"""


def main():
    ver = version()
    out_dir = os.path.join(ROOT, "Build")
    os.makedirs(out_dir, exist_ok=True)
    out = os.path.join(out_dir, f"SLWidgets {ver}.zip")
    pex = [p for p in walk(os.path.join(ROOT, "Scripts")) if p.endswith(".pex")]
    if not pex:
        raise SystemExit("no Scripts/*.pex: run the Papyrus build first")
    restyled = ring_set_folders()
    lib_abs = os.path.join(ROOT, *LIB_REL.split("/"))

    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("fomod/info.xml", info_xml(ver).encode("utf-16"))
        z.writestr("fomod/ModuleConfig.xml", module_config(ver).encode("utf-16"))
        # core
        for p in [os.path.join(ROOT, "SLWidgets.esp"), os.path.join(ROOT, "LICENSE"), os.path.join(ROOT, "README.md")]:
            z.write(p, "00 Core/" + os.path.basename(p))
        for p in pex:
            z.write(p, "00 Core/" + rel(p))
        for p in walk(os.path.join(ROOT, "Source", "Scripts")):
            if p.endswith(".psc"):
                z.write(p, "00 Core/" + rel(p))
        for p in walk(os.path.join(ROOT, "Seq")):
            z.write(p, "00 Core/" + rel(p))
        for p in walk(os.path.join(ROOT, "Interface", "Translations")):
            if p.endswith(".txt"):
                z.write(p, "00 Core/" + rel(p))
        for p in walk(os.path.join(ROOT, "SKSE")):
            if rel(p) != PRESET_REL:
                z.write(p, "00 Core/" + rel(p))
        # the library: sets with a ring counterpart go to the two options,
        # the rest (the 3.0.0 sets, the placeholder) to core
        for p in walk(lib_abs):
            folder = rel(os.path.dirname(p), lib_abs)
            if folder in restyled:
                z.write(p, "10 Classic Icons/" + rel(p))
            else:
                z.write(p, "00 Core/" + rel(p))
        z.write(os.path.join(ROOT, *PRESET_REL.split("/")), "10 Classic Icons/" + PRESET_REL)
        for p in walk(RING_LIB):
            z.write(p, "20 Ring Icons/" + LIB_REL + "/" + rel(p, RING_LIB))
        z.write(RING_PRESET, "20 Ring Icons/" + PRESET_REL)
    print("wrote", out, os.path.getsize(out) // 1024, "KB")


if __name__ == "__main__":
    main()
