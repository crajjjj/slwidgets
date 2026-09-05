Scriptname slw_util Hidden

Import Debug

String Function slwGetModName() Global
	return "SLWidgets"
EndFunction

;SemVer support
Int Function GetVersion() Global
    Return 20204
    ; 1.0.0   -> 10000
    ; 1.1.0   -> 10100
    ; 1.1.1  -> 10101
    ; 1.61  -> 16100
    ; 10.61.20 -> 106120
EndFunction

String Function GetVersionString() Global
    Return "2.2.4"
EndFunction

String Function StringIfElse(Bool isTrue, String returnTrue, String returnFalse = "") Global
    If isTrue
        Return returnTrue
    Else
        Return returnFalse
    EndIf
EndFunction

; Icons are authored as .dds, but the PrismaUI renderer also decodes .png and
; .gif (animated GIF included). If an icon pack drops an alternate format next
; to the .dds, prefer it. We probe ONCE per icon (the first .dds state) and
; apply the winning extension to every state, matching how packs ship a single
; uniform format -- so a partial pack (mixed formats within one icon) is not
; supported; ship all of an icon's states in the same format. With no alternate
; present, or on the (Flash) original renderer where only .dds resolves, the
; paths are returned unchanged, so this is safe on either backend.
;
; files[] holds paths relative to Interface/exported/ (the loadWidget root);
; MiscUtil.FileExists wants a Skyrim-root path, hence the "Data/Interface/
; exported/" prefix. Mutates and returns the passed array (built fresh per call
; by the module, so no aliasing).
String[] Function resolveIconFiles(String[] files) Global
    If !files || files.Length == 0
        Return files
    EndIf

    ; Find the first non-empty .dds entry to probe.
    String probe = ""
    Int i = 0
    While i < files.Length && probe == ""
        String f = files[i]
        If f != "" && StringUtil.Find(f, ".dds") != -1
            probe = f
        EndIf
        i += 1
    EndWhile
    If probe == ""
        Return files
    EndIf

    Int dot = StringUtil.Find(probe, ".dds")
    If dot == -1 || dot != StringUtil.GetLength(probe) - 4
        Return files
    EndIf
    String base = StringUtil.Substring(probe, 0, dot)

    String prefix = "Data/Interface/exported/"
    String chosenExt = ""
    If MiscUtil.FileExists(prefix + base + ".gif")
        chosenExt = ".gif"
    ElseIf MiscUtil.FileExists(prefix + base + ".png")
        chosenExt = ".png"
    EndIf
    If chosenExt == ""
        Return files
    EndIf

    ; Swap the trailing .dds of every state to the chosen extension.
    i = 0
    While i < files.Length
        String cur = files[i]
        If cur != ""
            Int d = StringUtil.Find(cur, ".dds")
            If d != -1 && d == StringUtil.GetLength(cur) - 4
                files[i] = StringUtil.Substring(cur, 0, d) + chosenExt
            EndIf
        EndIf
        i += 1
    EndWhile
    Return files
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