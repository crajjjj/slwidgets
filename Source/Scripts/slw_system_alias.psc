Scriptname slw_system_alias extends ReferenceAlias
import slw_util

slw_config Property config Auto

Event onPlayerLoadGame()
	slw_log.trace("System_alias: Game reload event")
	config.moduleSetup()
	config.widget_controller.startUpdates()
endEvent
