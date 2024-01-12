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
	
Int Function GetWearStateAnal(Actor akTarget,  Quest apropos2Quest) Global
	ReferenceAlias aproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest) 
	if aproposTwoAlias != None
		Int damage =  (aproposTwoAlias as Apropos2ActorAlias).AnalWearTearState - 1
		If damage < 0
			return 0
		Elseif  damage <= 8
			return damage
		else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

Int Function GetWearStateVaginal(Actor akTarget,  Quest apropos2Quest) Global 
	ReferenceAlias aproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if aproposTwoAlias != None
		Int damage = (aproposTwoAlias as Apropos2ActorAlias).VaginalWearTearState - 1
		If damage < 0
			return 0
		Elseif  damage <= 8
			return damage
		else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

Int Function GetWearStateOral(Actor akTarget, Quest apropos2Quest) Global
	ReferenceAlias aproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if aproposTwoAlias != None
		Int damage = (aproposTwoAlias as Apropos2ActorAlias).OralWearTearState - 1
		If damage < 0
			return 0
		Elseif  damage <= 8
			return damage
		else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction