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

## 2. MCM Menu

| # | P | Scenario | Expected | Scripts |
|---|---|----------|----------|---------|
| 2.1 | P0 | All 3 MCM pages render | General, Toggles, Debug pages load without script errors | slw_menu |
| 2.2 | P0 | Enable/Disable mod toggle | Enable: `moduleReset` + `moduleSetup` + `reloadWidgets` + `startUpdates`. Disable: `stopUpdates` + `moduleReset` + `reloadWidgets` | slw_menu |
| 2.3 | P1 | Toggle grayed when dependency missing | Each toggle's flag uses `isInterfaceActive()` — disabled when mod not found | slw_menu |
| 2.4 | P1 | Update interval slider | Range 1–60, value persists in `config.updateInterval`, affects `RegisterForSingleUpdate` delay | slw_menu, slw_widget_controller |
| 2.5 | P1 | Recheck dependencies button | `moduleReset()` + `moduleSetup()` re-detects newly installed mods, page refreshes | slw_menu |
| 2.6 | P1 | Debug page dependency list | All `isXxxReady()` checks display OK/Not Found correctly for installed mods | slw_menu |
| 2.7 | P2 | OnConfigClose reloads widgets | `widget_controller.reloadWidgets()` fires, icons refresh | slw_menu |

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
| 8.13 | P2 | Multiple pregnancy mods | FM3/HP/BF are mutually exclusive (`elseif` chain), Estrus/EggFactory/SGO4/COF are additive | slw_module_pregnancy |

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

---

*Last updated: 2026-05-03*
