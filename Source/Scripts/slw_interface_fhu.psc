Scriptname slw_interface_fhu Hidden

Import Debug
import slw_util


;FHU
;--------------------------------------

Int Function GetCumAmount(Actor akTarget, Quest FhuInflateQuest) Global
	int percentage =(FhuInflateQuest as sr_inflateQuest).GetInflationPercentage(akTarget) as int
	return percentToState9(percentage)
EndFunction

Int Function GetCumAmountAnal(Actor akTarget, Quest FhuInflateQuest) Global
	float percentage =(FhuInflateQuest as sr_inflateQuest).GetAnalPercentage(akTarget) * 100.0 
	return percentToState9(percentage as int)
EndFunction

Int Function GetCumAmountVag(Actor akTarget, Quest FhuInflateQuest) Global
	float percentage =(FhuInflateQuest as sr_inflateQuest).GetVaginalPercentage(akTarget) * 100.0 
	return percentToState9(percentage as int)
EndFunction

Int Function GetCumAmountOral(Actor akTarget, Quest FhuInflateQuest) Global
	float percentage =(FhuInflateQuest as sr_inflateQuest).GetOralPercentage(akTarget) * 100.0 
	return percentToState9(percentage as int)
EndFunction
