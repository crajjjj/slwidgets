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

Function trace(String msg, Int aiPriority = 0) Global 
	;WriteLog(msg,aiPriority)
EndFunction

Function WriteLogAndPrintConsole(String asMessage, Int aiPriority = 0) Global
	WriteLog(asMessage,aiPriority)
	PrintConsole(asMessage)
EndFunction

Function Notification(String msg) Global
    Debug.Notification("[SLWidgets] " + msg)
EndFunction

Function PrintConsole(String msg) Global
    MiscUtil.PrintConsole("[SLWidgets] " + msg)
EndFunction
