
Scriptname slw_interface_apropos_two extends Quest  

Int Property aproposVersion = -1 Auto Hidden

Quest ActorsQuest
Actor Property PlayerRef Auto

 Function initInterface()
	If isInterfaceActive()
		Return 
	EndIf
	
	If Game.GetModByName("Apropos2.esp") != 255
		slw_log.WriteLog("Apropos2.esp found")
		ActorsQuest = Game.GetFormFromFile(0x02902C, "Apropos2.esp") as Quest
		if GetAproposAlias(PlayerRef, ActorsQuest) == None
			String akActorName = playerRef.GetLeveledActorBase().GetName()
			slw_log.WriteLog("Actor "+ akActorName + " is not yet registered in Apropos2")
		EndIf
		GoToState("Installed")
	ElseIf GetState() != ""
		GoToState("")
	EndIf

EndFunction


Bool Function isInterfaceActive()
	If GetState() == "Installed"
		Return true
	EndIf
	Return false
EndFunction

ReferenceAlias Function GetAproposAlias(Actor akTarget, Quest apropos2Quest )
	; Search Apropos2 actor aliases as the player alias is not set in stone
	ReferenceAlias AproposTwoAlias = None
	Int i = 0
	ReferenceAlias AliasSelect
	While i < apropos2Quest.GetNumAliases() 
		AliasSelect = ActorsQuest.GetNthAlias(i) as ReferenceAlias
		If AliasSelect.GetReference() as Actor == akTarget
			AproposTwoAlias = AliasSelect
		EndIf
		Return AproposTwoAlias
		i += 1
	EndWhile
	Return AproposTwoAlias
EndFunction

;  Installed ====================================
State Installed
	Event OnBeginState()
		slw_log.WriteLog("Apropos2 ready")
	EndEvent
	
	
Int Function GetWearStateAnal() 
	ReferenceAlias AproposTwoAlias = GetAproposAlias(PlayerRef, ActorsQuest)
	if GetAproposAlias(PlayerRef, ActorsQuest) != None
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

Int Function GetWearStateVaginal() 
	ReferenceAlias AproposTwoAlias = GetAproposAlias(PlayerRef, ActorsQuest)
	if GetAproposAlias(PlayerRef, ActorsQuest) != None
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

Int Function GetWearStateOral() 
	ReferenceAlias AproposTwoAlias = GetAproposAlias(PlayerRef, ActorsQuest)
	if GetAproposAlias(PlayerRef, ActorsQuest) != None
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


	
EndState

; Not Installed ====================================


Int Function GetWearStateAnal() 
	Return 0
EndFunction

Int Function GetWearStateVaginal() 
	Return 0
EndFunction

Int Function GetWearStateOral() 
	Return 0
EndFunction




