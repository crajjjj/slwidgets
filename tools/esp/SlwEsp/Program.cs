// Registers SL Widgets module scripts in SLWidgets.esp.
//
// A module is a script on the SLWidgetsModules quest (0x801) with two
// properties, config -> the SLWidgetsConfig quest (0x800) and PlayerRef ->
// the player, and a matching object property on slw_config (on 0x800) that
// points back at the modules quest. The Creation Kit did this for the 2.x
// modules; this does the same for the names below, skipping any already
// present, and rewrites the plugin in place (a .bak copy is kept beside it).
//
//   dotnet run --project tools/esp/SlwEsp -- SLWidgets.esp
//
// Mutagen re-saves are not byte-faithful (header counts, subrecord order),
// which is fine for a two-record plugin; check the result with xEdit or
// houseCARL before shipping.
using Mutagen.Bethesda;
using Mutagen.Bethesda.Plugins;
using Mutagen.Bethesda.Plugins.Records;
using Mutagen.Bethesda.Skyrim;

var modules = new[]
{
    ("slw_module_sunhelm", "module_sunhelm"),
    ("slw_module_hygiene", "module_hygiene"),
    ("slw_module_sph", "module_sph"),
    ("slw_module_baby", "module_baby"),
    ("slw_module_stress", "module_stress"),
    ("slw_module_health", "module_health"),
};

if (args.Length < 1)
{
    Console.Error.WriteLine("usage: SlwEsp <path to SLWidgets.esp>");
    return 2;
}
var path = Path.GetFullPath(args[0]);
var modKey = ModKey.FromFileName(Path.GetFileName(path));
var mod = SkyrimMod.CreateFromBinary(new ModPath(modKey, path), SkyrimRelease.SkyrimSE);

var configQuest = mod.Quests.First(q => q.FormKey.ID == 0x800);
var modulesQuest = mod.Quests.First(q => q.FormKey.ID == 0x801);
var player = new FormLink<ISkyrimMajorRecordGetter>(FormKey.Factory("000014:Skyrim.esm"));

var modulesVmad = modulesQuest.VirtualMachineAdapter ?? throw new Exception("SLWidgetsModules has no scripts");
var configVmad = configQuest.VirtualMachineAdapter ?? throw new Exception("SLWidgetsConfig has no scripts");
var configScript = configVmad.Scripts.First(s => s.Name == "slw_config");

int added = 0;
foreach (var (scriptName, propertyName) in modules)
{
    if (!modulesVmad.Scripts.Any(s => s.Name == scriptName))
    {
        var entry = new ScriptEntry { Name = scriptName, Flags = ScriptEntry.Flag.Local };
        entry.Properties.Add(new ScriptObjectProperty
        {
            Name = "config", Flags = ScriptProperty.Flag.Edited, Alias = -1,
            Object = configQuest.ToLink<ISkyrimMajorRecordGetter>(),
        });
        entry.Properties.Add(new ScriptObjectProperty
        {
            Name = "PlayerRef", Flags = ScriptProperty.Flag.Edited, Alias = -1, Object = player,
        });
        modulesVmad.Scripts.Add(entry);
        Console.WriteLine($"added script {scriptName} to SLWidgetsModules");
        added++;
    }
    if (!configScript.Properties.Any(p => p.Name == propertyName))
    {
        configScript.Properties.Add(new ScriptObjectProperty
        {
            Name = propertyName, Flags = ScriptProperty.Flag.Edited, Alias = -1,
            Object = modulesQuest.ToLink<ISkyrimMajorRecordGetter>(),
        });
        Console.WriteLine($"added property slw_config.{propertyName}");
        added++;
    }
}
if (added == 0)
{
    Console.WriteLine("nothing to do");
    return 0;
}

File.Copy(path, path + ".bak", overwrite: true);
var tmpDir = Path.Combine(Path.GetTempPath(), "SlwEsp_" + Guid.NewGuid().ToString("N"));
Directory.CreateDirectory(tmpDir);
var tmp = Path.Combine(tmpDir, modKey.FileName);
mod.BeginWrite
    .ToPath(tmp)
    .WithNoLoadOrder()
    .Write();
File.Copy(tmp, path, overwrite: true);
Directory.Delete(tmpDir, recursive: true);
Console.WriteLine($"wrote {path} ({added} additions), backup at {path}.bak");
return 0;
