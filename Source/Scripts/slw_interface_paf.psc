Scriptname slw_interface_paf Hidden

Import Debug
import slw_util

;PAF/MiniNeeds/ALP
;--------------------------------------
Int Function getPoopLevelPAF( Quest paf) Global
	int pafstate = PAF_MainQuestScript.GetAPI().PoopState
	
	if pafstate >= 4
		return  4
	Else
		return pafstate
	endif 
EndFunction

Int Function getPeeLevelPAF(Quest paf) Global
	int pafstate = PAF_MainQuestScript.GetAPI().PeeState
	
	if pafstate >= 4
		return  4
	Else
		return pafstate
	endif 
EndFunction