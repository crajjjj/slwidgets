Scriptname slw_interface_appr2 Hidden

Import Debug
import slw_util


;Appropos
;--------------------------------------

ReferenceAlias Function GetAproposAlias(Actor akTarget, Quest apropos2Quest ) Global
	; Search Apropos2 actor aliases as the player alias is not set in stone
	ReferenceAlias AproposTwoAlias = None
	Int i = 0
	ReferenceAlias AliasSelect
	While i < apropos2Quest.GetNumAliases() 
		AliasSelect = apropos2Quest.GetNthAlias(i) as ReferenceAlias
		If AliasSelect.GetReference() as Actor == akTarget
			AproposTwoAlias = AliasSelect
		EndIf
		Return AproposTwoAlias
		i += 1
	EndWhile
	Return AproposTwoAlias
EndFunction
	
Int Function GetWearStateAnal(Actor akTarget,  Quest apropos2Quest) Global
	ReferenceAlias AproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest) 
	if GetAproposAlias(akTarget, apropos2Quest) != None
		Int damage =  (AproposTwoAlias as Apropos2ActorAlias).AnalWearTearState
		If damage <= 8
			return damage
		Else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

Int Function GetWearStateVaginal(Actor akTarget,  Quest apropos2Quest) Global 
	ReferenceAlias AproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if GetAproposAlias(akTarget, apropos2Quest) != None
		Int damage = (AproposTwoAlias as Apropos2ActorAlias).VaginalWearTearState
		If damage <= 8
			return damage
		Else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction

Int Function GetWearStateOral(Actor akTarget, Quest apropos2Quest) Global
	ReferenceAlias AproposTwoAlias = GetAproposAlias(akTarget, apropos2Quest)
	if GetAproposAlias(akTarget, apropos2Quest) != None
		Int damage = (AproposTwoAlias as Apropos2ActorAlias).OralWearTearState
		If damage <= 8
			return damage
		Else
			return 8
		EndIf
	Else
		return 0
	Endif
EndFunction