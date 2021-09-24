
Scriptname slw_interface_slax extends Quest  
import slw_log
import slw_util
Quest SlaConfigQuest
slaFrameworkScr sla
Actor Property playerRef Auto


Function initInterface()
	If isInterfaceActive()
		Return 
	EndIf
	If isSLAReady()
			slw_log.WriteLog("SexLabAroused.esm found")
			sla = Game.GetFormFromFile(0x4290F, "SexLabAroused.esm") As slaFrameworkScr
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
		slw_log.WriteLog("SexLabAroused.esm ready")		
	EndEvent

	Int Function getArousalLevel()
	
		Int arousal = sla.GetActorArousal(playerRef)
	
		If arousal < 10
			return 0
		ElseIf arousal < 20
			return 1
		ElseIf arousal < 30
			return 2
		ElseIf arousal < 40
			return 3
		ElseIf arousal < 60
			return 4
		ElseIf arousal < 80
			return 5
		ElseIf arousal < 90
			return 6
		ElseIf arousal < 100
			return 7
		Else
			return 8
		EndIf
	EndFunction

	Int Function getExposureLevel()
	
		Int exposure = sla.GetActorExposure(playerRef)
		If exposure < 10
			return 0
		ElseIf exposure < 20
			return 1
		ElseIf exposure < 30
			return 2
		ElseIf exposure < 40
			return 3
		ElseIf exposure < 60
			return 4
		ElseIf exposure < 80
			return 5
		ElseIf exposure < 90
			return 6
		ElseIf exposure < 100
			return 7
		Else
			return 8
		EndIf
	EndFunction
EndState

Int Function getExposureLevel()
	Return 0
EndFunction

Int Function getArousalLevel()
	Return 0
EndFunction
	

