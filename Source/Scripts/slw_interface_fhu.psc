Scriptname slw_interface_fhu Hidden

Import Debug
import slw_util


;FHU
;--------------------------------------

Int Function GetCumAmount(Actor akTarget, Quest FhuInflateQuest) Global
	return percentToState9(GetCumPercent(akTarget, FhuInflateQuest))
EndFunction

Int Function GetCumAmountAnal(Actor akTarget, Quest FhuInflateQuest) Global
	return percentToState9(GetCumPercentAnal(akTarget, FhuInflateQuest))
EndFunction

Int Function GetCumAmountVag(Actor akTarget, Quest FhuInflateQuest) Global
	return percentToState9(GetCumPercentVag(akTarget, FhuInflateQuest))
EndFunction

Int Function GetCumAmountOral(Actor akTarget, Quest FhuInflateQuest) Global
	return percentToState9(GetCumPercentOral(akTarget, FhuInflateQuest))
EndFunction

; The percentages behind the icon stages. FHU gives the total as 0-100 of its
; max inflation and the pools as a 0-1 fraction of the pool size.
Int Function GetCumPercent(Actor akTarget, Quest FhuInflateQuest) Global
	return (FhuInflateQuest as sr_inflateQuest).GetInflationPercentage(akTarget) as int
EndFunction

Int Function GetCumPercentAnal(Actor akTarget, Quest FhuInflateQuest) Global
	return ((FhuInflateQuest as sr_inflateQuest).GetAnalPercentage(akTarget) * 100.0) as int
EndFunction

Int Function GetCumPercentVag(Actor akTarget, Quest FhuInflateQuest) Global
	return ((FhuInflateQuest as sr_inflateQuest).GetVaginalPercentage(akTarget) * 100.0) as int
EndFunction

Int Function GetCumPercentOral(Actor akTarget, Quest FhuInflateQuest) Global
	return ((FhuInflateQuest as sr_inflateQuest).GetOralPercentage(akTarget) * 100.0) as int
EndFunction
