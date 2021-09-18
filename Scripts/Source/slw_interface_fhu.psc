Scriptname slw_interface_fhu extends Quest  

Quest FhuInflateQuest
Actor Property playerRef Auto


Function initInterface()
	If isInterfaceActive()
		Return 
	EndIf
	If Game.GetModByName("sr_FillHerUp.esp") != 255
			slw_log.WriteLog("sr_FillHerUp.esp found")
			FhuInflateQuest = Game.GetFormFromFile(0x000D63,"sr_FillHerUp.esp") as Quest
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

State Installed
	Event OnBeginState()
		slw_log.WriteLog("sr_FillHerUp.esp ready")		
	EndEvent

	Int Function GetCumAmount()
		int rank =(FhuInflateQuest as sr_inflateQuest).GetInflationPercentage(playerRef) as int
		if rank < 0
			rank = 0
		elseif rank > 101
			rank = 101
		endIf
	
		If rank < 10
			return 0
		ElseIf rank < 20
			return 1
		ElseIf rank < 30
			return 2
		ElseIf rank < 40
			return 3
		ElseIf rank < 60
			return 4
		ElseIf rank < 80
			return 5
		ElseIf rank < 90
			return 6
		ElseIf rank < 100
			return 7
		Else
			return 8
		EndIf
	EndFunction


EndState

Int Function GetCumAmount()
	Return 0
EndFunction
	

