Scriptname slw_interface_sla Hidden

Import Debug
import slw_util

;SLA
;--------------------------------------
Int Function getArousalLevel(Faction arousalFaction, Quest sla, Actor act) global
	if !sla || !act
		return 0
	endif
	Int arousal = 0
	int slaVersion = (sla as slaFrameworkScr).GetVersion()
	if slaVersion > 20200000
		arousal = (sla as slaFrameworkScr).GetActorArousal(act)
	else
		arousal = act.GetFactionRank(arousalFaction)
		If (arousal < 0)
			 arousal = (sla as slaFrameworkScr).GetActorArousal(act)
		EndIf
	endif
	return percentToState9NotStrict(arousal)
EndFunction

Int Function getExposureLevel(Faction exposureFaction, Quest sla, Actor akTarget) Global
	Int exposure = akTarget.GetFactionRank(exposureFaction)
	If (exposure < 0)
		exposure = (sla as slaFrameworkScr).GetActorExposure(akTarget)
	EndIf
	return percentToState9NotStrict(exposure)
EndFunction