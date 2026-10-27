Scriptname slw_util Hidden

Import Debug

String Function slwGetModName() Global
	return "SLWidgets"
EndFunction

;SemVer support
Int Function GetVersion() Global
    Return 30200
    ; 1.0.0   -> 10000
    ; 1.1.0   -> 10100
    ; 1.1.1  -> 10101
    ; 1.61  -> 16100
    ; 10.61.20 -> 106120
EndFunction

String Function GetVersionString() Global
    Return "3.2.0"
EndFunction

String Function StringIfElse(Bool isTrue, String returnTrue, String returnFalse = "") Global
    If isTrue
        Return returnTrue
    Else
        Return returnFalse
    EndIf
EndFunction


; Slot model: index 0 is the player, indices 1..N_NPC_SLOTS are tracked NPCs.
Int Function getSlotCount() Global
    Return 4
EndFunction

Int Function getNpcSlotCount() Global
    Return 3
EndFunction

; Returns the icon name to use for a given slot. Slot 0 (player) keeps the
; original unsuffixed name for save-compat with existing widgets; NPC slots
; get a "_NPCn" suffix so iWant Status Bars treats them as distinct icons.
String Function getIconNameForSlot(String baseName, Int slot) Global
    If slot <= 0
        Return baseName
    EndIf
    Return baseName + "_NPC" + slot
EndFunction

Bool Function isFHUReady() Global
	Return isDependencyReady("sr_FillHerUp.esp")
EndFunction

Bool Function isMMEReady() Global
	Return isDependencyReady("MilkModNEW.esp") 
EndFunction

Bool Function isSLAReady() Global
	Return  isDependencyReady("SexLabAroused.esm")
EndFunction

Bool Function isSLPReady() Global
	Return  isDependencyReady("SexLab-Parasites.esp") 
EndFunction

Bool Function isAprReady() Global
	Return isDependencyReady("Apropos2.esp") 
EndFunction

Bool Function isECReady() Global
	Return isDependencyReady("EstrusChaurus.esp")
EndFunction

Bool Function isESReady() Global
	Return isDependencyReady("EstrusSpider.esp") 
EndFunction

Bool Function isEDReady() Global
	Return isDependencyReady("EstrusDwemer.esp")
EndFunction

Bool Function isBFReady() Global
	Return isDependencyReady("BeeingFemale.esm") 
EndFunction

Bool Function isHPReady() Global
	Return isDependencyReady("HentaiPregnancy.esm")
EndFunction

Bool Function isFM3Ready() Global
	Return isDependencyReady("Fertility Mode.esm")
EndFunction

Bool Function isFM3TweaksReady() Global
	Return isDependencyReady("Fertility Mode 3 Fixes and Updates.esp")
EndFunction

Bool Function isFMReloadedReady() Global
	; Fertility Mode Reloaded ships as "Fertility Mode.esm" -- the SAME filename
	; as vanilla FM3 -- so filename detection cannot tell them apart. The
	; ImmersiveEffectsFaction record exists only in the Reloaded fork.
	If !isDependencyReady("Fertility Mode.esm")
		Return false
	EndIf
	Return (Game.GetFormFromFile(0x02666B, "Fertility Mode.esm") as Faction) != None
EndFunction

Bool Function isEFReady() Global
	Return isDependencyReady("EggFactory.esp")
EndFunction

Bool Function isPAFReady() Global
	Return  isPAFLegacyReady() || isPAFAIOReady()
EndFunction

Bool Function isPAFLegacyReady() Global
	Return  isDependencyReady("PeeAndFart.esp")
EndFunction

Bool Function isPAFAIOReady() Global
	Return  isDependencyReady("Paf Fixes and Addons.esp")
EndFunction


Bool Function isMiniNeedsReady() Global
	Return  isDependencyReady("MiniNeeds.esp")
EndFunction

Bool Function isAlivePeeingReady() Global
	Return  isDependencyReady("AlivePeeingSE.esp")
EndFunction

Bool Function isPNOReady() Global
	Return  isDependencyReady("Private Needs - Orgasm.esp")
EndFunction

Bool Function isSLDefeatReady() Global
	Return  isDependencyReady("SexLabDefeat.esp")
EndFunction

; SGO4IF 1.12 merged the base mod into its own plugin, so dse-soulgem-oven.esp
; is absent on a supported install. Pre-1.12 SGO4IF also ships SGO4IF.esp, but
; as a patch over the base mod with the old dse_sgo_* scripts -- ruling out the
; base plugin is what distinguishes the merged fork from that layout.
Bool Function isSGO4Ready() Global
	Return !isDependencyReady("dse-soulgem-oven.esp") && isDependencyReady("SGO4IF.esp")
EndFunction

Bool Function isMALReady() Global
	Return  isDependencyReady("Mammaries And Lactation.esp")
EndFunction

Bool Function isCurseOfLifeReady() Global
	Return isDependencyReady("CurseOfLife.esp")
EndFunction

Bool Function isSloveReady() Global
	Return isDependencyReady("SLOVE.esp")
EndFunction

; --- 3.0.0 sources ---

Bool Function isSunHelmReady() Global
	Return isDependencyReady("SunHelmSurvival.esp")
EndFunction

Bool Function isSunHelmDiseasesReady() Global
	Return isDependencyReady("SunHelmDiseases.esp")
EndFunction

; Bathing in Skyrim Renewed keeps the original plugin name. The percentage
; global (0xDA8) exists only in Renewed; the 2018 original tracked dirt as
; spell tiers and is not supported.
Bool Function isBathingReady() Global
	If !isDependencyReady("Bathing in Skyrim.esp")
		Return false
	EndIf
	Return (Game.GetFormFromFile(0x000DA8, "Bathing in Skyrim.esp") as GlobalVariable) != None
EndFunction

; Wet Function Redux (Papyrus, keeps wetness in StorageUtil)
Bool Function isWetFunctionReady() Global
	Return isDependencyReady("WetFunction.esp")
EndFunction

; WetFunction NG (SKSE port, keeps wetness in its DLL behind WetFunctionNG.*)
Bool Function isWetFunctionNGReady() Global
	Return isDependencyReady("WetFunctionNG.esp")
EndFunction

Bool Function isSPHReady() Global
	Return isDependencyReady("SPH - Skyrim Pubic Hair.esp")
EndFunction

Bool Function isStressFearReady() Global
	Return isDependencyReady("Stress and Fear.esp")
EndFunction

Bool Function isBladeBluntReady() Global
	Return isDependencyReady("BladeAndBlunt.esp")
EndFunction

; The colours a stage icon starts with: the fine-to-worst ramp the ring icon
; set is drawn for, white -> gold -> orange -> red, with the stock alphas
; (stage 0 faint, stage 1 half). Any length of arrays: the ramp's nine stops
; are sampled across them. A colour preset overrides it per icon afterwards.
Function fillStageColors(Int[] r, Int[] g, Int[] b, Int[] a) Global
	Int n = r.Length
	Int i = 0
	While i < n
		Int stop = 8
		If n > 1
			stop = ((i * 8 * 2 + (n - 1)) / (2 * (n - 1)))
		EndIf
		r[i] = 255
		If stop == 0
			g[i] = 255
			b[i] = 255
		ElseIf stop == 1
			g[i] = 240
			b[i] = 200
		ElseIf stop == 2
			g[i] = 226
			b[i] = 150
		ElseIf stop == 3
			g[i] = 206
			b[i] = 100
		ElseIf stop == 4
			g[i] = 180
			b[i] = 66
		ElseIf stop == 5
			g[i] = 140
			b[i] = 44
		ElseIf stop == 6
			g[i] = 100
			b[i] = 36
		ElseIf stop == 7
			g[i] = 66
			b[i] = 40
		Else
			g[i] = 36
			b[i] = 36
		EndIf
		If i == 0
			a[i] = 33
		ElseIf i == 1
			a[i] = 75
		Else
			a[i] = 100
		EndIf
		i += 1
	EndWhile
EndFunction

; Registers a stage icon with iWant for a slot: one file per stage, basepath
; + stage + ".dds" (basepath is the widgets/... path up to the stage number),
; the captions as the stage names, the default colours above, then the active
; colour preset. Presets are keyed by the base name (no _NPCn suffix), like the
; older modules do it; config.loadIconForSlot puts an NPC slot's icon straight
; into that slot's bar. Loading an icon that is already loaded does nothing.
Function loadStageIcon(slw_config cfg, iWant_Status_Bars iBars, String baseName, Int slot, String basepath, String[] captions) Global
	Int n = captions.Length
	String[] s = Utility.CreateStringArray(n)
	Int[] r = Utility.CreateIntArray(n)
	Int[] g = Utility.CreateIntArray(n)
	Int[] b = Utility.CreateIntArray(n)
	Int[] a = Utility.CreateIntArray(n)
	Int i = 0
	While i < n
		s[i] = basepath + i + ".dds"
		i += 1
	EndWhile
	fillStageColors(r, g, b, a)
	cfg.ApplyIconColors(baseName, r, g, b, a)
	cfg.loadIconForSlot(iBars, getIconNameForSlot(baseName, slot), captions, s, r, g, b, a, slot)
EndFunction

Int Function clampInt(Int value, Int low, Int high) Global
	If value < low
		Return low
	ElseIf value > high
		Return high
	EndIf
	Return value
EndFunction

Bool Function isDependencyReady(String modname) Global
	; ESL-flagged plugins are invisible to GetModByName (returns 255), so the
	; light index must be checked too. GetLightModByName's not-found sentinel
	; is 0xFFFF -- 255 is a valid light index.
	int index = Game.GetModByName(modname)
	if index != 255 && index != -1
		return true
	endif
	return Game.GetLightModByName(modname) != 65535
EndFunction

Int Function percentToState9(int percent) Global
	if percent < 0
		percent = 0
	elseif percent > 100
		percent = 100
	endIf

	If percent == 0
		return 0
	ElseIf percent < 10
		return 1
	ElseIf percent < 25
		return 2
	ElseIf percent < 40
		return 3
	ElseIf percent < 55
		return 4
	ElseIf percent < 70
		return 5
	ElseIf percent < 85
		return 6
	ElseIf percent < 100
		return 7
	Else
		return 8
	EndIf
EndFunction

Int Function percentToState9NotStrict(int percent) Global
	if percent < 0
		percent = 0
	elseif percent > 100
		percent = 100
	endIf

	If percent < 5
		return 0
	ElseIf percent < 10
		return 1
	ElseIf percent < 25
		return 2
	ElseIf percent < 40
		return 3
	ElseIf percent < 55
		return 4
	ElseIf percent < 70
		return 5
	ElseIf percent < 85
		return 6
	ElseIf percent < 100
		return 7
	Else
		return 8
	EndIf
EndFunction	

Int Function percentToState5(int percent) Global
    If percent < 0
		percent = 0
	elseif percent > 100
		percent = 100
	endIf

	If percent < 10
		return 0
	ElseIf percent < 25
		return 1
	ElseIf percent < 50
		return 2
	ElseIf percent < 75
		return 3
	Else
		return 4
	EndIf
EndFunction