# Troubleshooting

---

## Where to look first

- **Papyrus log** — `Documents/My Games/Skyrim Special Edition/Logs/Script/Papyrus.0.log`
- **SL Widgets user log** — `Documents/My Games/Skyrim Special Edition/Logs/Script/User/slwidgets.0.log`
- **MCM Debug page** — shows exactly which of SL Widgets' dependencies were found and whether iWant Status Bars is ready

---

## Icons not appearing at all

=== "Check 1: mod enabled"
    MCM → **General** → **Enable/Disable Mod** must be toggled **on**.

=== "Check 2: iWant ready"
    MCM → **Debug** → Dependency Check should show iWant Status Bars as **OK**. If not, confirm iWant Status Bars and iWant Widgets are installed and active, and that load order is `iwidgets → ibars → slwidgets`.

=== "Check 3: only one iWidgets ESP"
    If you have both the LE and SE versions of iWant Widgets installed you will have two `iWidgets.esp` files. Keep only one. SL Widgets will not initialise correctly with duplicates.

=== "Check 4: dependency detected"
    MCM → **Debug** → check the mod whose icons you expect. If it shows **Not Found**, the plugin is not loaded or its filename doesn't match. Check that the ESP/ESM is enabled in your load order.

---

## Icons overlapping or in the wrong bar

This happens on heavy script-load mod lists where iWant Bar events fire out of order.

**Fix:** Disable the mod (MCM → General), save, reload (or fast-travel and back), re-enable.

If **NPC icons are appearing in the player bar**, press **Reset NPC bar layout** on the NPC Tracking page. This forces a reconciliation pass that moves NPC icons to their dedicated bars.

---

## NPC labels not appearing

1. Confirm the Pick Hotkey is bound (MCM → NPC Tracking → Pick Hotkey shows a key name, not blank).
2. Confirm the NPC is loaded — they must be in the same cell and have 3D geometry (alive, not deleted, within load radius).
3. Confirm the mod is not disabled.
4. After a game load, labels are recreated automatically when iWant Status Bars fires its ready event. Wait a few seconds on the first load.

---

## NPC slot not assigning

The hotkey is silently blocked when:

- Any menu is open (MCM, inventory, dialogue, map, loading screen)
- The crosshair is not targeting an actor
- The crosshair is targeting the player
- All three NPC slots are already full
- The mod is globally disabled

If you press the hotkey and nothing happens, check each of these conditions.

---

## A mod I have installed isn't being detected

1. MCM → **Debug** → check the dependency list. If it shows Not Found:
   - Verify the ESP/ESM filename exactly matches what SL Widgets expects (see [Supported Mods](supported-mods.md) for the exact filenames).
   - Confirm the plugin is enabled in your load order.
2. If you installed the mod during the current session, press **Reset Modules** on the Debug page to recheck all dependencies without restarting the game.

---

## Icons are there but never change

- Confirm the dependent mod is actually running (not just installed). For example, SLA won't report values until SexLab itself is initialised.
- Check the **Update Interval** (MCM → General). At 60 seconds, an icon update takes up to a minute to reflect.
- For MAL (Mammaries and Lactation), values are one tick behind by design — this is normal.

---

## Settings preset won't save / load

- PapyrusUtil must be installed and working. Check your Papyrus log for PapyrusUtil errors.
- Preset files are written to `Data/SKSE/Plugins/SlWidgets/SettingsPresets/`. Confirm the folder exists and is writable (mod manager virtual filesystem sometimes blocks writes to this path — try running via MO2 rather than Vortex if this occurs, or configure Vortex to allow writes to SKSE plugin data).

---

## Still stuck?

Collect the following before reporting an issue:

- Your Papyrus log (`Papyrus.0.log`)
- The SL Widgets user log (`slwidgets.0.log`)
- A screenshot of MCM → Debug showing the dependency check results
- Your load order (use a tool like LOOT or the SSEEdit plugin list)
