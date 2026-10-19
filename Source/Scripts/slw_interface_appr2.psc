Scriptname slw_interface_appr2 Hidden

Import Debug
import slw_util


;Appropos
;--------------------------------------

ReferenceAlias Function GetAproposAlias(Actor akTarget, Quest apropos2Quest ) Global
	; Search Apropos2 actor aliases as the player alias is not set in stone
	ReferenceAlias aproposTwoAlias = None
	Int i = 0
	ReferenceAlias AliasSelect
	Int aliasesInt = apropos2Quest.GetNumAliases() 
	;slw_log.WriteLog("Apropos2 actor count" + aliasesInt)
	While i < aliasesInt 
		AliasSelect = apropos2Quest.GetNthAlias(i) as ReferenceAlias
		If AliasSelect.GetReference() as Actor == akTarget
			;slw_log.WriteLog("Apropos2 player found")
			aproposTwoAlias = AliasSelect
			Return aproposTwoAlias
		EndIf
		i += 1
	EndWhile

	;if aproposTwoAlias == None
		;String akActorName = akTarget.GetLeveledActorBase().GetName()
		;slw_log.WriteLog("Actor "+ akActorName + " is not yet registered in Apropos2")
	;EndIf
	Return aproposTwoAlias
EndFunction
	
Int Function GetWearStateAnal(Actor akTarget, Quest apropos2Quest) Global
	Int[] states = GetWearStates(akTarget, apropos2Quest)
	return states[1]
EndFunction

Int Function GetWearStateVaginal(Actor akTarget, Quest apropos2Quest) Global
	Int[] states = GetWearStates(akTarget, apropos2Quest)
	return states[0]
EndFunction

; All three stages (0-8) from one alias search: [0] vaginal, [1] anal,
; [2] oral. The search walks every alias of the Apropos2 actors quest, so a
; caller that wants more than one body part should use this.
Int[] Function GetWearStates(Actor akTarget, Quest apropos2Quest) Global
	Int[] states = new Int[3]
	ReferenceAlias aproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if aproposTwoAlias != None
		Apropos2ActorAlias a = aproposTwoAlias as Apropos2ActorAlias
		states[0] = ClampWearState(a.VaginalWearTearState)
		states[1] = ClampWearState(a.AnalWearTearState)
		states[2] = ClampWearState(a.OralWearTearState)
	endif
	return states
EndFunction

; Apropos2 stages run 1-9 once an actor has any (0 before), the icons 0-8.
Int Function ClampWearState(Int wearTearState) Global
	Int damage = wearTearState - 1
	If damage < 0
		return 0
	Elseif damage > 8
		return 8
	EndIf
	return damage
EndFunction

Int Function GetWearStateOral(Actor akTarget, Quest apropos2Quest) Global
	Int[] states = GetWearStates(akTarget, apropos2Quest)
	return states[2]
EndFunction