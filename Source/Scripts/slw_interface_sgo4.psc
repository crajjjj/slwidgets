Scriptname slw_interface_sgo4 Hidden

Import Debug
import slw_util

;SGO4
;--------------------------------------
Int function gotGems( Quest sgo, Actor akTarget) Global
	return (sgo as dse_sgo_QuestDatabase_Main).ActorGemCount(akTarget)
endFunction

Float Function gotGemTotalPercent( Quest sgo, Actor akTarget) Global
	return (sgo as dse_sgo_QuestDatabase_Main).ActorGemTotalPercent(akTarget,TRUE)
endFunction

Float Function getMilkMax( Quest sgo, Actor akTarget) Global
	return (sgo as dse_sgo_QuestDatabase_Main).ActorMilkMax(akTarget)
endFunction
Float Function getMilkCur( Quest sgo, Actor akTarget) Global
	return (sgo as dse_sgo_QuestDatabase_Main).ActorMilkAmount(akTarget)
endFunction
