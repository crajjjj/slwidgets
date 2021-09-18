Scriptname slw_interface_mme extends Quest  

Actor Property playerRef Auto

Function initInterface()
	If isInterfaceActive()
		Return 
	EndIf

	If Game.GetModByName("MilkModNEW.esp") != 255
			slw_log.WriteLog("MilkModNEW.esp found")
			
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
		slw_log.WriteLog("MilkModNEW.esm ready")		
	EndEvent

	Int Function getMilkLevel()
		float milkCur = MME_Storage.getMilkCurrent(playerRef)
		float milkMax = MME_Storage.getMilkMaximum(playerRef)
		if milkMax <= 0
			milkMax = 1
		endif
		Int milkLevel = ((milkCur / milkMax) * 100) as Int
		
		If milkLevel < 10
			return 0
		ElseIf milkLevel < 20
			return 1
		ElseIf milkLevel < 30
			return 2
		ElseIf milkLevel < 40
			return 3
		ElseIf milkLevel < 60
			return 4
		ElseIf milkLevel < 80
			return 5
		ElseIf milkLevel < 90
			return 6
		ElseIf milkLevel < 100
			return 7
		Else
			return 8
		EndIf
	EndFunction

	Int Function getLactacidLevel()
		float lactCur = MME_Storage.getLactacidCurrent(playerRef)
		float lactMax = MME_Storage.getLactacidMaximum(playerRef)
		if lactMax <= 0
			lactMax = 1
		endif
		Int lactaciLevel = ((lactCur / lactMax) * 100) as Int
		If lactaciLevel < 10
			return 0
		ElseIf lactaciLevel < 20
			return 1
		ElseIf lactaciLevel < 30
			return 2
		ElseIf lactaciLevel < 40
			return 3
		ElseIf lactaciLevel < 60
			return 4
		ElseIf lactaciLevel < 80
			return 5
		ElseIf lactaciLevel < 90
			return 6
		ElseIf lactaciLevel < 100
			return 7
		Else
			return 8
		EndIf
	EndFunction
EndState

Int Function getMilkLevel()
	Return 0
EndFunction

Int Function getLactacidLevel()
	Return 0
EndFunction
	

