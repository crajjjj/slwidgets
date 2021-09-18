Scriptname slw_player extends ReferenceAlias

slw_widget property widget auto
Actor Property playerRef Auto


Event onPlayerLoadGame()
	slw_log.WriteLog("loading interfaces ...")
	widget.loadSetup()
endEvent
