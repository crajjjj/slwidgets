Scriptname slw_interface_sla Hidden

Import Debug
import slw_util

;SLA
;--------------------------------------
Int Function getArousalLevel(Quest sla, Actor akTarget) Global
	Int arousal = (sla as slaFrameworkScr).GetActorArousal(akTarget)
	return percentToState9(arousal)
EndFunction

Int Function getExposureLevel(Quest sla, Actor akTarget) Global
	Int exposure = (sla as slaFrameworkScr).GetActorExposure(akTarget)
	return percentToState9(exposure)
EndFunction