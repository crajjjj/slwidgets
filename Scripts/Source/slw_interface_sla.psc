Scriptname slw_interface_sla Hidden

Import Debug
import slw_util

;SLA
;--------------------------------------
Int Function getArousalLevel(Faction arousalFaction, Quest sla, Actor akTarget) Global
	Int arousal = akTarget.GetFactionRank(arousalFaction)
	If (arousal < 0)
		arousal = (sla as slaFrameworkScr).GetActorArousal(akTarget)
	EndIf
	return percentToState9(arousal)
EndFunction

Int Function getExposureLevel(Faction exposureFaction, Quest sla, Actor akTarget) Global
	Int exposure = akTarget.GetFactionRank(exposureFaction)
	If (exposure < 0)
		exposure = (sla as slaFrameworkScr).GetActorExposure(akTarget)
	EndIf
	return percentToState9(exposure)
EndFunction