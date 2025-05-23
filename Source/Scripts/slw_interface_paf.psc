Scriptname slw_interface_paf Hidden

Import Debug
import slw_util

;PAF/MiniNeeds/ALP
;--------------------------------------
Int Function getPoopLevelPAF( Quest paf) Global
	int pafstate = (paf as PAF_MainQuestScript).PoopState
	;slw_log.WriteLog("ModulePAF: PAF_MainQuestScript.GetAPI().PoopState" + pafstate )
	if pafstate >= 4
		return  4
	Else
		return pafstate
	endif 
EndFunction

Int Function getPeeLevelPAF(Quest paf) Global
	int pafstate = (paf as PAF_MainQuestScript).PeeState
	;slw_log.WriteLog("ModulePAF: PAF_MainQuestScript.GetAPI().PeeState" + pafstate )
	if pafstate >= 4
		return  4
	Else
		return pafstate
	endif 
EndFunction