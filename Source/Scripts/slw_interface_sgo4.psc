Scriptname slw_interface_sgo4 Hidden

Import Debug
import slw_util

;SGO4
;--------------------------------------

; Targets SGO4IF 1.12+, which merged the base mod into SGO4IF.esp and renamed
; the whole script family dse_sgo_* -> SGO4_*. 1.13 then compacted the FormIDs,
; so the database is reached through the fork's own controller accessor rather
; than a hardcoded FormID that the next compaction would break again.
Quest Function getSGO4Database() Global
	; Guarded because SGO4_QuestController_Main only exists as a loadable script
	; type when SGO4IF is installed -- the global call below would error without it.
	if !isSGO4Ready()
		return none
	endif
	SGO4_QuestController_Main main = SGO4_QuestController_Main.Get()
	if !main
		return none
	endif
	return main.Data as Quest
EndFunction

Int function gotGems( Quest sgo, Actor akTarget) Global
	return (sgo as SGO4_QuestDatabase_Main).ActorGemCount(akTarget)
endFunction

Float Function gotGemTotalPercent( Quest sgo, Actor akTarget) Global
	return (sgo as SGO4_QuestDatabase_Main).ActorGemTotalPercent(akTarget,TRUE)
endFunction

Float Function getMilkMax( Quest sgo, Actor akTarget) Global
	return (sgo as SGO4_QuestDatabase_Main).ActorMilkMax(akTarget)
endFunction

Float Function getMilkCur( Quest sgo, Actor akTarget) Global
	return (sgo as SGO4_QuestDatabase_Main).ActorMilkAmount(akTarget)
endFunction
