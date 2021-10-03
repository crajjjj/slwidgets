Scriptname slw_system_alias extends ReferenceAlias
import slw_util

slw_config Property config Auto

Event onPlayerLoadGame()
	slw_log.WriteLog("game reload event")
	config.widget_controller.setup()
endEvent
