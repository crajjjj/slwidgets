set_xmakever("3.0.0")  -- the commonlibsse-ng submodule requires 3.0

-- SLWidgetsMenu.dll: the SL Widgets in-game position editor, a window on SKSE Menu
-- Framework. Build from this folder:
--
--   xmake f -m release
--   xmake
--
-- VS 2022 (v143, C++23) and the CommonLibSSE-NG submodule (git submodule update
-- --init --recursive). The DLL lands in ..\SKSE\Plugins, where skyrimse.ppj's zip
-- picks it up with the rest of the SKSE folder, so a release build runs this first.

PROJECT_NAME = "SLWidgetsMenu"
PROJECT_AUTHOR = "crajjjj"

set_languages("cxx23")
set_license("gplv3")
set_warnings("allextra")

includes("lib/commonlibsse-ng")
set_project(PROJECT_NAME)  -- after the include: the library names the project too, and the last one wins

set_policy("package.requires_lock", true)

add_rules("mode.debug", "mode.release")

if is_mode("debug") then
    add_defines("DEBUG")
    set_optimize("none")
    set_runtimes("MTd")
elseif is_mode("release") then
    add_defines("NDEBUG")
    set_optimize("fastest")
    set_symbols("debug")
    set_runtimes("MT")
end

add_defines("_SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING")  -- SKSEMenuFramework.h uses <codecvt>
add_defines("NOMINMAX")  -- CommonLib v7 headers pull in Windows.h

target(PROJECT_NAME)
    set_kind("shared")
    add_deps("commonlibsse-ng")
    add_rules("commonlibsse-ng.plugin", {
        name = PROJECT_NAME,
        author = PROJECT_AUTHOR,
        description = "SL Widgets in-game position editor (SKSE Menu Framework)."
    })
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src", "extern/SKSEMenuFramework")
    set_pcxxheader("src/PCH.h")

    add_cxxflags(
        "cl::/diagnostics:caret",
        "cl::/wd4200",
        "cl::/wd4201",
        "cl::/Zc:preprocessor",
        "cl::/utf-8"
    )
    if is_mode("debug") then
        add_cxxflags("cl::/bigobj")
    end

    -- The mod has ONE version, slw_util.GetVersionString(); build_release.py reads
    -- the same line. Read here, on load, because the description scope cannot read
    -- files, and before the commonlib plugin rule stamps target:version() into the
    -- DLL's version resource (its on_config).
    on_load(function (target)
        local src = io.readfile(path.join(os.projectdir(), "..", "Source", "Scripts", "slw_util.psc"))
        local v = src and src:match('GetVersionString%(%)%s+Global%s+Return%s+"([^"]+)"')
        if not v then
            raise("slw_util.GetVersionString() not found: the DLL would carry no version")
        end
        target:set("version", v)
    end)

    -- NEVER install. The commonlib plugin rule runs `xmake install` after every
    -- build and, with XSE_TES5_MODS_PATH set, aims it at <mods>\<target name>: a
    -- stray "SLWidgetsMenu" folder in the live Mod Organizer mods directory.
    on_config(function (target)        -- runs after the rule's on_config
        target:set("installdir", path.join(os.projectdir(), "build", "install"))
    end)
    on_install(function (target) end)  -- a target-level on_install replaces the rule's

    after_build(function (target)
        -- the DLL only: a pdb under SKSE would ship in the zip
        local out = path.join(os.projectdir(), "..", "SKSE", "Plugins")
        if not os.isdir(out) then
            os.mkdir(out)
        end
        os.cp(target:targetfile(), out)
    end)
target_end()
