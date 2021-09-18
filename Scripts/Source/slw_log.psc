Scriptname slw_log Hidden
{Simplified log writer file by Pickysaurus at Nexus Mods. }

Import Debug

Function WriteLog(String asMessage, Int aiPriority = 0) Global
	String asModName = "SLWidgets"
	Utility.SetINIBool("bEnableTrace:Papyrus", true)
	if OpenUserLog(asModName)
		Trace(asModName + " Debugging Started.")
		TraceUser(asModName,"[---"+ asModName +" DEBUG LOG STARTED---]")
	endif
	String sPrefix
	if aiPriority == 2
		sPrefix = "(!ERROR!) "
	elseif aiPriority == 1
		sPrefix = "(!) "
	else
		sPrefix = "(i) "
	endif

	asMessage = sPrefix + asMessage
	
	TraceUser(asModName, asMessage, aiPriority)
EndFunction
