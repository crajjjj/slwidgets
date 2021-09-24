Scriptname slw_interface_fhu extends Quest  
import slw_log
import slw_util
Quest FhuInflateQuest
Actor Property playerRef Auto


Function initInterface()
	If isInterfaceActive()
		Return 
	EndIf
	If isFHUReady()
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
		int percentage =(FhuInflateQuest as sr_inflateQuest).GetInflationPercentage(playerRef) as int
		return _percentToState(percentage)
	EndFunction

	Int Function GetCumAmountAnal()
		float percentage =(FhuInflateQuest as sr_inflateQuest).GetAnalPercentage(playerRef) * 100.0 
		return _percentToState(percentage as int)
	EndFunction

	Int Function GetCumAmountVag()
		float percentage =(FhuInflateQuest as sr_inflateQuest).GetVaginalPercentage(playerRef) * 100.0 
		return _percentToState(percentage as int)
	EndFunction

EndState

Int Function GetCumAmount()
	Return 0
EndFunction
Int Function GetCumAmountAnal()
	Return 0
EndFunction
Int Function GetCumAmountVag()
	Return 0
EndFunction

Int Function _percentToState(int percent)
	if percent < 0
		percent = 0
	elseif percent > 101
		percent = 101
	endIf

	If percent < 10
		return 0
	ElseIf percent < 20
		return 1
	ElseIf percent < 30
		return 2
	ElseIf percent < 40
		return 3
	ElseIf percent < 60
		return 4
	ElseIf percent < 80
		return 5
	ElseIf percent < 90
		return 6
	ElseIf percent < 100
		return 7
	Else
		return 8
	EndIf
EndFunction			

