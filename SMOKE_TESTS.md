# SL Widgets — Smoke Tests

Pre-release checklist. Each scenario should be verified in-game or by code inspection before tagging a release.

**Priority key:** P0 = blocker, P1 = high, P2 = medium

---

## 1. Game Load & Initialization

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 1.1 | P0 | Fresh install — new save | `slw_system_alias.onPlayerLoadGame()` fires, `moduleSetup()` runs all 8 modules, `startUpdates()` begins polling | slw_system_alias, slw_config |
| 1.2 | P0 | Existing save — reload | `onPlayerLoadGame` re-runs `moduleSetup()` + `startUpdates()`, all previously detected plugins re-detected | slw_system_alias |
| 1.3 | P0 | iWant Status Bars ready event | `OniWantStatusBarsReady` captures `iBars` reference, `isLoaded()` returns true | slw_widget_controller |
| 1.4 | P1 | iWant Status Bars not installed | `iBars` remains None, `isLoaded()` returns false, no script errors | slw_widget_controller |
| 1.5 | P1 | iWant Status Bars loads after SLW | `RegisterForModEvent` persists, late `iWantStatusBarsReady` event still captured | slw_widget_controller |

## 2. MCM (read-only since 3.3.0) and the SKSE menu's General page

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 2.1 | P0 | MCM renders | Two pages, General and Maintenance; no option can be changed; an old save shows the same two | slw_menu |
| 2.2 | P0 | MCM General | **SL Widgets: Enabled / Disabled** matches the mod; **SKSE menu: OK**, or names SKSE Menu Framework / SLWidgetsMenu.dll as missing | slw_menu._skseMenuState |
| 2.3 | P0 | SKSE menu > General > Mod enabled on, then off | On: modules set up, icons load, the update loop starts. Off: loop stops, icons go. The MCM's General follows | slw_config._editorSetEnabled |
| 2.4 | P1 | Update interval slider | Range 1-60, applied on release, persists in `config.updateInterval` | slw_config.editorSet |
| 2.5 | P1 | Reset modules (mod enabled) | Served by the next update pass: `moduleReset` + `moduleSetup`; a newly installed mod is detected | requestModuleRecheck |
| 2.6 | P1 | MCM Maintenance dependency list | All `isXxxReady()` checks display OK/Not Found correctly for installed mods | slw_menu |
| 2.7 | P1 | Color Preset choice | Colours change after the next update pass reloads the icons | requestReload |
| 2.8 | P1 | Add icon placeholder | A transparent placeholder icon takes an iWant bar seat | LoadEmptyIcon |

## 3. User Settings Persistence

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 3.1 | P1 | Save user settings | All 15 toggle/interval values written to `SlWidgets/UserSettings.json` via jsonutil | slw_config |
| 3.2 | P1 | Load user settings | JSON values override current config, `moduleReset` + `moduleSetup` + `reloadWidgets` + `startUpdates` | slw_config, slw_menu |
| 3.3 | P2 | Load with missing/corrupt JSON | `jsonutil.IsGood()` returns false, error logged, load returns false | slw_config |
| 3.4 | P2 | Save overwrite confirmation | MCM shows overwrite dialog when file already exists | slw_menu |

## 4. Module: SexLab Aroused (SLA)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 4.1 | P0 | SLA detected | `pArousalFaction`, `pExposureFaction`, `sla` quest all resolved from Form IDs, `Module_Ready = true` | slw_module_sla |
| 4.2 | P0 | Arousal icon updates | `getArousalLevel()` returns state 0–8, `setIconStatus` called only when state changes (`arousal_state_prv != curr`) | slw_module_sla |
| 4.3 | P0 | Exposure icon updates | Same change-detection pattern as arousal | slw_module_sla |
| 4.4 | P1 | Toggle off releases icon | Disabling arousal/exposure in MCM releases the icon via `iBars.releaseIcon()` | slw_module_sla |
| 4.5 | P1 | SLA not installed | `Module_Ready` stays false, no icons loaded, no errors | slw_module_sla |

## 5. Module: Apropos 2

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 5.1 | P0 | Apropos2 detected | `Quest.GetQuest("Apropos2Actors")` resolves, `Module_Ready = true` | slw_module_apropos_two |
| 5.2 | P0 | Wear & tear icons update | Oral/Anal/Vaginal states 0–8, change-detection pattern works | slw_module_apropos_two |
| 5.3 | P1 | Player not registered in Apropos2 | `GetAproposAlias` returns None, warning logged, no crash | slw_module_apropos_two |
| 5.4 | P1 | Apropos2 not yet initialized | `ActorsQuest` is None, `Module_Ready` stays false, retries on next `moduleSetup` | slw_module_apropos_two |

## 6. Module: Fill Her Up (FHU)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 6.1 | P0 | FHU detected | `FhuInflateQuest` resolved from Form ID, `Module_Ready = true` | slw_module_fhu |
| 6.2 | P0 | All 4 cum icons update | Total/Anal/Vaginal/Oral each track state independently with change detection | slw_module_fhu |
| 6.3 | P1 | Individual toggles | Each of the 4 cum icons can be independently enabled/disabled | slw_module_fhu |
| 6.4 | P1 | FHU quest not found | Form ID mismatch logs error, `Module_Ready` stays false | slw_module_fhu |

## 7. Module: Milk (MME + SGO4 + MAL)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 7.1 | P0 | MME detected | `Plugin_MME = true`, milk icon loaded | slw_module_mme |
| 7.2 | P0 | Milk icon state updates | `getMilkLevel()` combines all active sources, `percentToState9NotStrict` maps to 0–8 | slw_module_mme |
| 7.3 | P0 | MME + MAL combined | Both milk values summed in `getMilkLevel()`, single icon reflects total | slw_module_mme |
| 7.4 | P1 | MAL event registration | `MAL_ReturnPlayerStoredMilk` and `MAL_ReturnPlayerMilkLimit` events registered | slw_module_mme |
| 7.5 | P1 | MAL values one tick behind | First tick after reload shows 0 (cache cleared in `onWidgetReload`), correct values on second tick | slw_module_mme |
| 7.6 | P1 | Lactacid icon (MME only) | Lactacid toggle only active when `Plugin_MME` is true (not SGO4/MAL) | slw_module_mme |
| 7.7 | P1 | SGO4 milk | `getMilkCur`/`getMilkMax` via interface, summed with other sources | slw_module_mme |
| 7.8 | P2 | Division by zero guard | `milkMax <= 0` sets `milkMax = 1`, same for lactacid | slw_module_mme |
| 7.9 | P1 | OMania milk | While `OMania.IsLactating`, `GetPressure` x 100 drives the milk icon (past 1.0 = the top stage), player and NPC slots; beside MME/SGO4/MAL the fuller of the two shows, never a sum; lactacid stays MME-only | slw_module_mme |
| 7.10 | P1 | MAL after a reload | Save, reload: the MAL return events are registered again in `initInterface` (SKSE drops mod event registrations on load), so the player's milk icon follows MAL instead of sitting at Empty | slw_module_mme |

## 8. Module: Pregnancy

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 8.1 | P0 | All 9 pregnancy mods detected | Each `isXxxReady()` + Form ID resolution works, plugin flags set correctly | slw_module_pregnancy |
| 8.2 | P0 | Fertility Mode 3 — trimester icons | `handleFertilityMode3`: HasSpell checks for Ovulation/Tri1/Tri2/Tri3, icons load/release correctly | slw_module_pregnancy |
| 8.3 | P0 | FM3 actor index -1 | All 6 FM icons released, function returns early without error | slw_module_pregnancy |
| 8.4 | P0 | Hentai Pregnancy — faction rank icons | Rank 1=cum, 2=cum+ovulation, 3=fetus; other ranks release all | slw_module_pregnancy |
| 8.5 | P0 | BeeingFemale — state-based icons | States 0–21 mapped to correct icon combinations (ovulation/cum/trimester/chaurus) | slw_module_pregnancy |
| 8.6 | P1 | SGO4 gems icon | Gem count > 0 loads gems icon with color gradient based on `GemTotalPercent` | slw_module_pregnancy |
| 8.7 | P1 | SGO4 gems change detection | Icon only reloads when `gems_state_curr` or `GemPercent` changes | slw_module_pregnancy |
| 8.8 | P1 | Estrus Chaurus/Spider/Dwemer | HasSpell OR WornHasKeyword triggers parasite pregnancy icon | slw_module_pregnancy |
| 8.9 | P1 | EggFactory | `isEggFactPregnant()` quest check shows/hides eggs icon | slw_module_pregnancy |
| 8.10 | P1 | Curse of Life | StorageUtil float checks for Chaurus/Spider/Dragon/Blessing sizes | slw_module_pregnancy |
| 8.11 | P1 | FM3 SpermCount type mismatch | Tweaks mod changes SpermCount to int — verify no crash (known issue, logged) | slw_module_pregnancy |
| 8.12 | P2 | Pregnancy toggle off | `module_pregnancy_enabled = false` releases all pregnancy icons | slw_module_pregnancy |
| 8.13 | P2 | Multiple pregnancy mods | FM3/HP/BF are mutually exclusive (`elseif` chain), Estrus/EggFactory/SGO4/COF/OMania are additive; an icon two of them drive (BF + Estrus Unified chaurus eggs, EggFactory + COF eggs) shows while either wants it and is not dropped and reloaded every pass (`_want` + `_applySharedIcons`) | slw_module_pregnancy |
| 8.14 | P1 | Estrus Unified | `EstrusUnifiedAPI.GetPregnancyType` 1/2/3 shows chaurus eggs / spider eggs / spheres and 0 releases them, player and NPC slots; the legacy Estrus blocks stay off; `OnEstrusUnifiedPregnancyChanged` pulls the next pass forward; the Debug page lists it | slw_module_pregnancy, slw_menu |
| 8.15 | P1 | OMania | Detected only with `OMania.dll` (`GetVersion` not empty, once per load into `slw_config.OManiaReady`; plugin without DLL = Not found on the Debug page, one unbound-native line per load, none per pass); a baby shows trimester 1/2/3 at progress thirds, a chaurus / spider / dwarven-oil clutch its own icon, any other clutch eggs, `IsInflated` cum inflation; nothing before implantation or for a male carrier; player and NPC slots | slw_module_pregnancy, slw_config, slw_menu |
| 8.16 | P1 | Save from 3.4.2 with a pregnancy icon up | First pass releases every shared icon no mod wants (`_shared_shown` starts at 255), then only what a pass left loaded; uninstalling one of two pregnancy mods drops its icons on the next pass | slw_module_pregnancy |

## 9. Module: SexLab Parasites (SLP)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 9.1 | P0 | SLP detected | Quest resolved from Form ID, `Module_Ready = true` | slw_module_slp |
| 9.2 | P0 | Parasite icons show/hide | SpiderEgg/ChaurusWorm/ChaurusWormVag checked via `isInfectedBySLP()` | slw_module_slp |
| 9.3 | P1 | Toggle off releases all | `_releaseParasiteIcons` clears all 3 icons | slw_module_slp |

## 10. Module: Pee & Fart / Needs (PAF + MiniNeeds + AlivePeeing + PNO)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 10.1 | P0 | PAF detected (legacy or AIO) | Tries `PeeAndFart.esp` first, then `Paf Fixes and Addons.esp` | slw_module_paf |
| 10.2 | P0 | Pee/Poop icons update | States 0–4 via `percentToState5`, change detection works | slw_module_paf |
| 10.3 | P1 | MiniNeeds fallback | If PAF not found, tries MiniNeeds for pee/poop values | slw_module_paf |
| 10.4 | P1 | AlivePeeing fallback | If PAF/MiniNeeds not found, tries AlivePeeing globals for pee only | slw_module_paf |
| 10.5 | P1 | Private Needs Orgasm fallback | If none above found, tries PNO quest | slw_module_paf |
| 10.6 | P2 | Priority order | PAF > PNO > MiniNeeds > AlivePeeing (first detected wins) | slw_module_paf |

## 11. Module: SL Defeat

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 11.1 | P0 | SL Defeat detected | `_defeatWeakened` MagicEffect resolved, `Module_Ready = true` | slw_module_sldefeat |
| 11.2 | P0 | Raped icon shows when effect active | `PlayerRef.HasMagicEffect(_defeatWeakened)` triggers icon | slw_module_sldefeat |
| 11.3 | P1 | Icon released when effect removed | Effect wears off, next update tick releases icon | slw_module_sldefeat |

## 11a. 3.0.0 modules (SunHelm, hygiene, SPH, baby health, stress, health)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 11a.1 | P0 | Fresh game, all six modules | `moduleSetup()` runs 14 modules, each logs its plugin detection; no "property not found" errors (ESP carries the six script entries and `slw_config` properties) | slw_config, SLWidgets.esp |
| 11a.2 | P0 | Existing 2.3.0 save | MCM traces "Updating script to version 30000", the 13 new toggles default on, the log shows "icons registered by an older build, reloading them once" on the first load: the new icons appear and the old ones take the Default preset's full alpha without opening the MCM; the next load does not reload again | slw_menu, slw_config |
| 11a.3 | P1 | SunHelm installed | Food/Thirst/Cold/Fatigue toggles enabled; food icon follows `GetHungerPercent()` (eat: stage drops), cold shows the sun at stages 0-2 and the snowflake from 3 | slw_module_sunhelm |
| 11a.4 | P1 | SunHelm absent | The four toggles greyed, no errors (the casts are never made) | slw_module_sunhelm |
| 11a.5 | P0 | Bathing in Skyrim Renewed | Dirtiness icon follows the global (Renewed's 0-1 shown x 100, so half dirty = stage 4, never stuck at Clean); bathing drops it; an NPC in a tracked slot with the NPC toggle on shows its own value (`BiS_Dirtiness`) | slw_module_hygiene |
| 11a.6 | P1 | WetFunction NG or Redux | Wetness rises in rain / water and reaches Dripping only near the cap; a dry actor (wetness at or below 1) shows Dry; off for NPC slots by default | slw_module_hygiene |
| 11a.7 | P1 | SPH 2.0 | Pubic icon has 6 stages, armpit 7; shaving drops them, growth cream raises one step | slw_module_sph |
| 11a.8 | P1 | BeeingFemale pregnancy | Baby health icon appears in the trimesters and labor and is gone in Replenish after birth / miscarriage; 100 health = stage 0 ("Healthy") | slw_module_baby |
| 11a.9 | P1 | Stress and Fear | Stress follows `Stress_Total`; fear counts held phobia spells (0..8+) | slw_module_stress |
| 11a.10 | P1 | Blade and Blunt | Injury icon steps Unhurt / Minor / Major / Critical with the spells the DLL applies | slw_module_health |
| 11a.11 | P1 | Diseases | No icon while healthy; a vanilla disease (also Sanguinare) shows stage 1 within 20 s; SunHelm Diseases stages 2 / 3 raise it; a cure removes the icon | slw_module_health |
| 11a.14 | P1 | SunHelm need switched off in SunHelm's MCM | That need's icon disappears; switched back on, it returns | slw_module_sunhelm |
| 11a.15 | P0 | No SunHelm installed | No link errors for slw_module_sunhelm in the Papyrus log; the four toggles greyed | slw_module_sunhelm, slw_interface_sunhelm |
| 11a.16 | P1 | NPC page | All three slots show every option (slots 2 and 3 in the right column) | slw_menu |
| 11a.17 | P1 | NPC slot with Dirtiness on, NPC not loaded | The NPC's icon goes to that slot's bar, not the player's, and takes preset colours | slw_util.loadStageIcon |
| 11a.12 | P2 | Settings preset round trip | The 13 new keys and `npc.N.dirt/wet/baby` save and load | slw_config |
| 11a.13 | P1 | Archive | One FOMOD. The Ring option shows every icon in the ring style with the ramp Default preset; the Classic option the old art for the pre-3.0.0 sets and the generated classic look for the 13 newer ones, with the classic Default / HideEmpty presets (empty stages faint). Both options install the same file set (`build_release.py` refuses otherwise); reinstalling with the other option swaps every texture. The MCM colour preset list shows the four shipped presets either way | build_release.py, fomod/ |

## 11b. 3.4.1 sources (Survival Mode, Just Blood, Combat Wound)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 11b.1 | P1 | Survival Mode on, no SunHelm | Food, Cold and Fatigue toggles enabled, Thirst greyed; the three icons show and follow hunger, cold and exhaustion (eat: food drops; stand in snow: cold climbs; sleep: fatigue drops); the worst stage of the mode lands near stage 8 | slw_module_sunhelm |
| 11b.2 | P1 | Survival Mode installed but off (`Survival_ModeEnabled` 0) | No food / cold / fatigue icons; switching the mode on brings them on the next tick | slw_module_sunhelm |
| 11b.3 | P1 | Survival Mode Improved, one need disabled (`SMI_ColdShouldBeEnabled` 0) | That icon goes away, the other two stay | slw_module_sunhelm |
| 11b.4 | P2 | SunHelm and Survival Mode both running | The icons show SunHelm's values; stopping a SunHelm need hands that icon to Survival Mode | slw_module_sunhelm |
| 11b.5 | P1 | Just Blood | Blood icon Clean at full health, steps up at 75 / 50 / 40 / 25 % health and back down as health returns; matches the stains on the body; Clean while swimming if the stains go away | slw_module_hygiene |
| 11b.6 | P1 | Combat Wound | A power attack that wounds adds one stage per wound (4 or more = last); the stage drops as Fade Tattoos removes them; a follower in an NPC slot with Wounds on shows its own | slw_module_hygiene |
| 11b.9 | P1 | Dirt and Blood, player | Dirtiness steps 0 / 2 / 4 / 6 / 8 with Clean and Dirt 1-4, Blood with Blood 1-4 (dirtiness stays at that level); a swim or a wash drops both; with Bathing in Skyrim also running, Dirtiness shows the dirtier | slw_module_hygiene |
| 11b.10 | P1 | Dirt and Blood, NPC slot with Blood on | Rises as the NPC loses health (85 / 65 / 45 / 25 %); a follower shows blood for about five minutes after dropping below 60 %; Dirtiness never shows for an NPC with Dirt and Blood alone | slw_module_hygiene |
| 11b.11 | P1 | Existing 3.4.0 save with Just Blood, Dirt and Blood or Combat Wound | On the first load the log shows the one-time icon reload and the Blood / Wounds icons appear without opening any menu; the MCM traces "Updating script to version 30401" | slw_widget_controller, slw_menu |
| 11b.12 | P1 | 3.4.1 scripts with a 3.4.0 SLWidgetsMenu.dll | No unbound-native errors for GetIWantIconStep in the Papyrus log; the spacing row says it cannot reach the value | slw_bridge.hasNatives |
| 11b.13 | P2 | Survival Mode plugin present, mode off | Food / Cold / Fatigue switches greyed on the Toggles page; switching the mode on and reopening the page enables them | slw_module_sunhelm.canShowNeed |
| 11b.7 | P1 | NPC Tracking page | Each slot lists Blood and Wounds, off by default; a settings preset round-trips `module_blood`, `module_wounds` and `npc.N.blood` / `npc.N.wounds` | slw_config |
| 11b.8 | P2 | Maintenance page | Rows for Survival Mode, Survival Mode Improved, Dirt and Blood, Just Blood and Combat Wound | slw_menu |

## 12. Widget Controller Update Loop

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 12.1 | P0 | Update loop runs | `OnUpdate` calls `moduleWidgetStateUpdate(iBars)` then re-registers with `updateInterval` delay | slw_widget_controller |
| 12.2 | P0 | Stopped state halts updates | `config.slw_stopped = true` causes `OnUpdate` to return immediately | slw_widget_controller |
| 12.3 | P1 | Module ordering | All 8 modules updated sequentially in fixed order (SLA, Apropos, FHU, MME, SLP, Pregnancy, PAF, Defeat) | slw_config |
| 12.4 | P1 | Widget reload | `reloadWidgets()` calls each module's `onWidgetReload(iBars)` — resets `_prv` state, reloads icons | slw_widget_controller |
| 12.5 | P2 | Empty icon utility | `loadEmptyIcon()` creates placeholder icons for bar alignment, increments index, returns -1 when full | slw_widget_controller |

## 13. State Change Detection Pattern

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 13.1 | P0 | EMPTY sentinel (-1) | After reload, `_prv = EMPTY` forces first update to always call `setIconStatus` | All modules |
| 13.2 | P0 | No-change optimization | When `prv == curr`, `setIconStatus` is NOT called (reduces iWant Bars API calls) | All modules |
| 13.3 | P1 | Widget reload resets state | All `_prv` variables reset to `EMPTY` in `onWidgetReload`, ensuring fresh state on next tick | All modules |

## 14. Dependency Detection

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 14.1 | P0 | `isDependencyReady` works | `Game.GetModByName()` returns valid index (!= 255, != -1) for installed mods | slw_util |
| 14.2 | P1 | Form ID resolution failure | When `Game.GetFormFromFile()` returns None, plugin flag set to false, error logged | All modules |
| 14.3 | P1 | Multiple init calls safe | `If (!Plugin_Xxx && isXxxReady())` guard prevents double-init | All modules |
| 14.4 | P2 | Module reset + re-init | `resetInterface()` clears all flags, `initInterface()` re-detects from scratch | All modules |

## 15. Translation Files

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 15.1 | P1 | All 10 language files present | Each `SLWidgets_*.txt` exists with matching key sets | Interface/Translations/ |
| 15.2 | P1 | UTF-16LE BOM encoding | Files open correctly in-game, no garbled text | Interface/Translations/ |
| 15.3 | P2 | All MCM keys translated | Every `$SLW_*` key referenced in `slw_menu.psc` has an entry in translation files | slw_menu, translations |

---

## 16. Known Issues & Fragile Areas

| # | P | Issue | Location | Impact |
|---|---|-------|----------|--------|
| 16.1 | P1 | **FM3 SpermCount type mismatch** — FM Tweaks mod changes `SpermCount` array from float to int, `hasFMSperm()` may fail silently | slw_interface_fm, slw_module_pregnancy:402 | Cum inflation icon may not show with FM Tweaks |
| 16.2 | P2 | **MAL cache zero on reload** — `onWidgetReload` zeros `_mal_milk_cur`/`_mal_milk_max`, milk shows empty for one tick | slw_module_mme:78-79 | Brief visual glitch on widget reload |
| 16.3 | P2 | **Lactacid only with MME** — Lactacid toggle requires `Plugin_MME`, not `isInterfaceActive()` — SGO4/MAL users can't see lactacid even if MME is also present (intentional — only MME has lactacid) | slw_module_mme:86 | By design |
| 16.4 | P2 | **Pregnancy mod priority** — FM3/HP/BF are in an `elseif` chain — only first detected handles icons | slw_module_pregnancy:242-248 | Users with multiple pregnancy mods only see first one's icons |
| 16.5 | P2 | **SGO4 gems color uniform** — All 6 gem icon slots get same color based on total percent, not per-gem | slw_module_pregnancy:729-772 | Visual only — all gem stages same color |

## 17. SLO VE willpower bar

Added in 2.2.6, never run in game when written. `slovetest willpower <n>` is SLO VE's console command (ConsoleUtil Extended); it writes the player's real willpower.

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 17.1 | P0 | SLO VE detected | Toggles page, right column: the SLO VE block is enabled; Maintenance page shows `SLO VE (SLOVE.esp)` OK | slw_util, slw_menu |
| 17.2 | P0 | In a scene: `slovetest willpower 40` | Within one update interval a bar filled to 40% appears with the brain icon to its left | slw_widget_controller, slw_interface_slove |
| 17.3 | P0 | In a scene: `slovetest willpower 100` | The bar and the icon disappear within one update interval | slw_widget_controller |
| 17.4 | P1 | In a scene: `slovetest willpower 0` from above 0 | Bar empties and flashes, the icon turns red | slw_widget_controller |
| 17.5 | P0 | The scene ends with willpower below 100 | The bar and the icon disappear within one update interval; outside a scene `slovetest willpower 40` draws nothing | slw_widget_controller, slw_interface_slove (`isInScene`) |
| 17.6 | P1 | A real SLO VE scene | The bar follows the drain; it does NOT climb during the scene, however long it runs | slw_interface_slove |
| 17.6b | P1 | Second scene some game hours after one that drained willpower | The bar comes up at the RECOVERED value (SLO VE's `pcrecoverperhour` per game hour), not at the value the first scene ended on | slw_widget_controller (`_willpowerPrv`), slw_interface_slove |
| 17.7 | P1 | Change X, Y or size in the MCM outside a scene | The bar is shown at the new place for half a minute, then hides; no second bar is left at the old place | slw_menu, slw_widget_controller |
| 17.8 | P1 | Save with the bar up, load | Exactly one bar after the load, no leftover widget, no other mod's widget moved or hidden | slw_widget_controller (`_forgetWillpowerBar`) |
| 17.9 | P1 | Toggle off, close the MCM; disable the mod | The bar is gone at once in both cases; back on = back within one interval | slw_menu, slw_widget_controller |
| 17.10 | P2 | SLO VE not installed | Block greyed out, nothing drawn, no Papyrus errors | slw_util |
| 17.11 | P2 | Prisma renderer and the Flash renderer | Same size and place in both (the meter is 334x30 at 100% in each) | iWant Widgets |

Since 2.3.0 the willpower bar is the top meter of the meter stack (section 18): its switch is on the **Meters** page, and it takes the stack's X / Y / size, so 17.1 reads "Meters page" for "Toggles page", 17.7 is 18.7 (the preview shows willpower too), and 17.8 is 18.8 (`_forgetMeters`).

## 18. Meter stack (willpower, arousal, FHU, W&T)

Added in 2.3.0, never run in game when written. Player only. Values are read once per update interval, so "at once" below means within one interval of the MCM closing.

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 18.1 | P0 | SLA, FHU and Apropos2 installed, existing save updated to 2.3.0 | Meters page lists all 9 meter switches enabled (willpower greyed out without SLO VE); within one interval the arousal, FHU and W&T meters appear stacked at the right edge, half way down, each with its icon to the left, then fade out after ~10 s (fade mode, first read counts as a change). Willpower's row stays empty outside a scene | slw_menu, slw_widget_controller |
| 18.2 | P0 | Fade mode: `slainc` or a SexLab scene raising arousal | The arousal meter fades in at the new value, the heart icon at the matching stage, and fades out ~10 s later (up to one interval more) | slw_widget_controller, slw_module_sla |
| 18.3 | P0 | Fade mode: an orgasm with FHU inflation | The FHU meters that changed fade in; the unchanged ones stay hidden in their own rows | slw_widget_controller, slw_module_fhu |
| 18.4 | P1 | Apropos2 W&T rises one stage | That W&T meter fades in one eighth further, its icon one stage up | slw_module_apropos_two, slw_interface_appr2 |
| 18.5 | P0 | Always Show Meters on, close the MCM | Every meter stays up; nothing fades | slw_menu, slw_widget_controller |
| 18.6 | P1 | Switch one meter off, close the MCM | That row is gone, the rest re-stack around Y and all show for 30 s | slw_menu, slw_widget_controller (`requestMetersRebuild`) |
| 18.7 | P1 | Change X, Y or size, close the MCM | The stack is drawn at the new place for 30 s, no second stack at the old place | slw_widget_controller (`setMetersLayout`) |
| 18.8 | P1 | Save with meters up, load | Exactly one stack after the load, nothing fades in just because of the load (fade mode), no other mod's widget moved or hidden | slw_widget_controller (`_forgetMeters`, `_meterSeen`) |
| 18.9 | P1 | Disable the mod on the General page | The whole stack is gone at once; enable = back | slw_widget_controller (`stopUpdates`) |
| 18.10 | P2 | Only SLA installed | One row (arousal), FHU and W&T switches greyed out, no Papyrus errors | slw_menu, slw_widget_controller |
| 18.11 | P1 | Save a settings preset, change meter switches, the mode, X, Y and size, load the preset | Switches, mode, place and size all come back; the stack is redrawn at the saved place and shown for 30 s; exactly one stack on screen | slw_config (`_loadMeterSettings`) |
| 18.11b | P2 | Load a preset saved before 2.3.0 (no meter keys) | Nothing on the Meters page changes except the willpower switch, which presets carried before | slw_config |
| 18.12 | P2 | Status icons switched off, meters on | Meters still update (they read the mods themselves, not the icons) | slw_widget_controller |
| 18.13 | P2 | Three NPCs tracked at the default anchors | Check overlap of NPC slot 3 (y 390) with the stack (y ~230-490 with all nine rows); move either if they collide | layout |
| 18.14 | P0 | In a scene: `slovetest willpower 40`, fade mode, nothing else changing | Willpower row (top) comes up at 40% with the brain and STAYS up for the whole scene; other rows fade as usual | slw_widget_controller (meter 0) |
| 18.15 | P1 | Always Show Meters on, outside a scene | Every row up except willpower, which stays hidden until a scene | slw_widget_controller |
| 18.16 | P1 | Fade mode, FHU absorbing or arousal slowly wearing off | The meter shows again only every 5 points (or on an icon stage change), not continuously | `_drawMeters` (`METER_CHANGE_MIN`) |
| 18.17 | P1 | Disable the mod on the General page right after closing the MCM with a layout change (stack being built) | No meter or icon left on screen | `_stopMeters`, `_metersGen` |
| 18.18 | P1 | Quicksave right after a load while the stack builds (3 s after load), then load that save | Every row comes back | `_forgetMeters`, `_metersGen` |
| 18.19 | P1 | Load a settings preset with a different stack position, stay in the MCM more than 30 s, then close it | The stack is shown at the new place for 30 s after closing | `_updateMeters` (preview outside menu mode) |

## 19. Event-driven refresh

Added in 2.3.0, never run in game when written. Set the update interval to 60 s on the General page first, so a change that shows within a couple of seconds can only have come from an event.

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 19.1 | P0 | FHU: a scene that inflates the player | FHU icons and meters move within about a second of the inflation finishing | slw_widget_controller (`OnFhuPlayerCumUpdate`) |
| 19.2 | P1 | FHU: let the player leak | The FHU meters follow the leak about once a second, not faster; no Papyrus log spam | `_refreshSoon` (`REFRESH_MIN_GAP`) |
| 19.3 | P0 | Apropos2 SE 1.0020: a scene that raises a W&T stage, or a stage set in its Wear And Tear Actors page | The W&T icon and meter move within about a second | `OnApropos2WearTearChanged` |
| 19.4 | P2 | Stock Apropos2 (or 1.0019) | W&T still updates, on the 60 s interval; no errors | polling |
| 19.5 | P0 | SLA: an orgasm in a scene | Arousal icon and meter drop within about 2 s | `OnSexLabOrgasm` |
| 19.6 | P1 | SLA NG: wait for a scan (120 s default) | Arousal follows at the scan's end | `OnSlaUpdateComplete` |
| 19.7 | P1 | Track an NPC; Apropos2 W&T changes for that NPC | That NPC slot's W&T icons move within about a second; an untracked NPC's change does not trigger a pass | `_isShown` |
| 19.8 | P1 | Save, load, trigger 19.1 | Still within a second after the load (events re-registered on load) | `startUpdates` |
| 19.9 | P1 | Disable the mod, trigger 19.1 | Nothing drawn, no pass runs | `stopUpdates`, `_refreshSoon` |
| 19.10 | P2 | Papyrus log after a scene with all three mods | No "incorrect number of arguments" or handler errors for these events | handler signatures |
| 19.11 | P1 | Three NPCs tracked (long passes); trigger 19.1 repeatedly | Every change still shows within about 2 s; the controller is idle at least a second between passes | `_scheduleNextTick` (owed refresh), `_lastPassEnd` |
| 19.12 | P1 | A SexLab orgasm right as a normal tick starts | The arousal drop still shows within about 2 s, not on the next 60 s tick | `OnUpdate` (later owed refresh kept) |

---

*Last updated: 2026-10-08*

## 20. Positions page (SLWidgetsMenu.dll, 3.1.0)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 20.1 | P0 | Framework absent | `SLWidgetsMenu.log` says the page is disabled; the mod and its MCM behave as before | plugin/Env.cpp, Menu.cpp |
| 20.2 | P0 | Open the page with a game loaded | The sliders show the values iWant's MCM and the SL Widgets MCM hold; status "Layout read." | slw_bridge, slw_widget_controller.editorLayout |
| 20.3 | P0 | Drag X of bar 0 | The bar's icons follow during the drag (every 150 ms) and land where the slider stops; iWant's MCM shows the new X | editorSetBarPos |
| 20.4 | P0 | Size and orientation of a bar | Applied on release / on pick; icons resize, the bar takes the shape; an orbit's center icon is double | editorSetBarSize, editorSetBarType |
| 20.5 | P0 | NPC cluster X, Y, spacing | Applied on release; all six NPC bars and the name labels follow; the NPC Tracking sliders show the new values | editorSetNpcGroup, editorSetNpcSpacing |
| 20.6 | P1 | Meter stack X, Y, scale | Applied on release; the stack rebuilds within a second and shows its 30 s preview at the new place | editorSetMeters |
| 20.7 | P1 | Close the menu mid-drag (Esc) | The last value is written anyway | Page::OnMenuClosed |
| 20.8 | P1 | Change a bar in iWant's MCM, then Refresh | The page shows the new value | Bridge::RequestLayout |
| 20.9 | P1 | Open at the main menu (no game) | The page says SL Widgets is not running; nothing is written | slw_bridge.GetLayout |
| 20.10 | P1 | Old slw_bridge.pex under a new DLL | The page names the mismatch; no crash | Bridge.cpp |
| 20.11 | P2 | Load a game with the page left open | The layout is dropped and read again when the page comes up | main.cpp OnVmReset |
| 20.12 | P0 | Bar 0 > Icons: ^ / v on an icon (3.3.0) | The icon swaps places with its neighbour on the HUD; the list shows the new order after a read | editorMoveIconInBar |
| 20.13 | P0 | Bar 0 > Icons: to 1 | The icon leaves bar 0 and appears at the end of bar 1, sized to bar 1 | editorMoveIconToBar |
| 20.14 | P1 | A target bar with ten icons | Its to N button is greyed; the script refuses a move there anyway | _nextFreeBarPosition |
| 20.15 | P2 | Move an SL Widgets icon, switch it off and on | It returns to the first free place (expected: moves do not stick) | iWant loadIcon |
| 20.16 | P0 | Icon spacing: slider to 100 and release (3.4.1) | Every line bar closes up to icons edge to edge (player bars, NPC bars, other mods' bars); circles unchanged; the slider reads 100 after the read-back | editorSetIconSpacing, slw_bridge.SetIWantIconStep |
| 20.17 | P0 | Save, load that save | The spacing is still 100 (iWant saved it); **iWant default** puts 150 back and greys itself | iWant's BAR_SPACING_PERCENTAGE |
| 20.18 | P1 | Save a preset at 120, set 150, load the preset | The spacing returns to 120; a preset saved before 3.4.1 leaves the spacing alone | _saveLayoutSettings, _loadLayoutSettings (`bars.spacing`) |
| 20.19 | P2 | Papyrus log after opening the page | No "unbound native" line for GetIWantIconStep / SetIWantIconStep | Natives.cpp, slw_bridge.hasNatives |
| 20.20 | P0 | Dirty with Bathing in Skyrim (icon past stage 0); set bar 0 to Line extending up, close the menu, bathe (3.4.2) | The dirt icon fades to Clean in its place in the up line, never at the bar's old left-line spot | _placeAfterLayoutChanges, _placeIdleStages |
| 20.21 | P1 | Same with X / Y of the bar, a circle bar, an icon moved to another bar, the spacing slider, a switch turned off ahead of the icon, and the same edit in iWant's own MCM | A stage that comes up after the change appears at the icon's place | slw_bridge.GetIWantBarSignatures |
| 20.22 | P1 | Same in an auto-hide bar (Show on change), waiting until the bar has faded before the edit | The icon's next change shows it at the new place | _barFadedOut |
| 20.23 | P2 | Scripts 3.4.2 under a 3.4.1 DLL | Nothing placed, no "unbound native" line for the layout natives; the old behaviour | slw_bridge.hasLayoutNatives |

## 21. Icon textures

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 21.1 | P0 | Icons in the stock Flash iWant Widgets (Prisma renderer disabled) | Ring icons draw as icons, not as diagonal strokes; 3.0.0 / 3.0.1 shipped DDS headers Flash did not accept, and Prisma hid it | savedds.py |
| 21.2 | P0 | `python savedds.py --check` on both libraries before packaging | 0 files off spec (`build_release.py` refuses otherwise) | savedds.py, build_release.py |

## 22. Toggles page (SLWidgetsMenu.dll, 3.2.0)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 22.1 | P0 | Open SKSE menu > SL Widgets > Toggles with a game loaded | Every player switch grouped as the old MCM page was, values as in the save, labels in the game's language | slw_config.editorToggles, plugin/Translations.cpp |
| 22.2 | P0 | Switch an installed icon off and on | The icon goes and comes back within about a second, the menu still open | setToggleByKey, requestTogglePass, _updatePass |
| 22.3 | P1 | Click five switches quickly | One toggle pass at a time (no overlap in the log), every icon ends as clicked | _togglePassOwed |
| 22.4 | P1 | Mod disabled in the MCM, flip a switch | The property changes, nothing is drawn; enabling the mod shows the new state | _refreshSoon (stopped) |
| 22.5 | P2 | Hover a switch | Its help text from the translation files | PageCommon::Tooltip |

## 23. Presets page and layout in presets (3.2.0)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 23.1 | P0 | Presets page lists the files | Every `SettingsPresets/*.json`, the active one marked | slw_config.editorPresets |
| 23.2 | P0 | Save as new "Test", move bar 0 and the NPC cluster, load "Test" | Status Saved, then Loaded; bar 0 and the cluster return; the icons reload once | SavePreset, requestPresetLoad, applySettingsPreset, _loadLayoutSettings |
| 23.3 | P0 | Load a preset saved before 3.2.0 (no layout keys), with bar 0 at size 120 set in iWant's MCM | Switches applied; bars and cluster stay exactly where and as they are | _presetInt |
| 23.4 | P1 | MCM General > Settings Preset load | Same result as the SKSE menu load (both call applySettingsPreset) | slw_menu, slw_config |
| 23.5 | P1 | Save as new with a name holding `\` or `..` | Refused on the page; the bridge refuses it too | PresetsPage ValidName, slw_bridge._isPresetName |
| 23.6 | P1 | Load a preset while the mod is disabled | Values stored at once, modules stay off; enabling the mod shows the preset | requestPresetLoad, applySettingsPreset |
| 23.7 | P2 | Hand-edited preset with `bars.0.size` 500 | Clamped to 150, iWant's maximum | _presetInt |
| 23.8 | P1 | Load then Save over another preset within a second | The save holds the loaded preset's settings (served after the load) | _updatePass owed requests |
| 23.9 | P2 | Save as new, then switch pages and back at once | Status stays Saving... until a later read shows the file, then Saved | PresetsPage Judge |

## 24. Meters and NPC Tracking pages (3.3.0)

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 24.1 | P0 | Meters: switch a meter on | The stack rebuilds with it within a second or two | editorSet meter.N, requestMetersRebuild |
| 24.2 | P1 | Always Show Meters on | Fade Out After greys out; every switched-on meter stays up | editorSet meters.always |
| 24.3 | P0 | NPC Tracking: Pick Hotkey > Set, press K | The row shows K; aiming at an NPC and pressing K tracks it | SettingsPage OnInput, setHotkey |
| 24.4 | P1 | Pick Hotkey > Set, press Escape | The menu closes; the hotkey is unchanged | OnInput (Escape left alone) |
| 24.5 | P1 | Label colour picked | Labels change colour while picking, at most every 0.25 s | DrawColor, setNpcLabelColorPacked |
| 24.6 | P1 | Slot 1: switch Milk on, Clear Slot | Milk icon appears for that NPC; Clear removes icons and label | _editorSetNpc |
| 24.7 | P1 | Custom label typed, Enter | The label shows the text; empty returns the name | setNpcCustomLabel, refreshNpcLabel |
| 24.8 | P2 | A row with a value changed in another page, then Refresh | The page shows the new value | Bridge::Request |
| 24.9 | P0 | Mod enabled off and on again within a second | One flow at a time; the mod ends enabled with its icons (the last switch wins) | _editorRequestEnabled |
| 24.10 | P0 | Right after a load, before iWant is up | Mod enabled is greyed out; once iWant is up it can be switched on and the icons load | editorGeneral canSwitch |
| 24.11 | P1 | Clear Slot while that NPC's icons update | Icons and label go once; no stray label stays | requestNpcRelease, _updatePass |
| 24.12 | P1 | Pick Hotkey > Set, then the Presets page, type a name | The name keeps every letter; the hotkey is unchanged | kCaptureGraceMs |
| 24.13 | P1 | Type a custom label, close the menu without Enter | The label is written anyway | FlushText |
| 24.14 | P2 | Framework older than 3.8 | No pages; the MCM's General says the framework is too old | SetMenuReport, _skseMenuState |
| 24.15 | P2 | Positions page with every Icons list closed | No icon read is asked for (only the layout) | ServeIcons |
