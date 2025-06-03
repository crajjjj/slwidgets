Scriptname slw_interface_pno Hidden

Import Debug
import slw_util

;PAF/MiniNeeds/ALP
;--------------------------------------
Int Function getPoopLevelPNO( Quest pno) Global
	int pnoState = (pno as PNO_QF_MainQuest).bowel_lastlevel - 1
	if pnoState < 0
		return  0
	Elseif pnoState >= 4
		return  4
	Else
		return pnoState
	endif 
EndFunction

Int Function getPeeLevelPNO(Quest pno) Global
	int pnoState = (pno as PNO_QF_MainQuest).bladder_lastlevel - 1
	if pnoState < 0
		return  0
	Elseif pnoState >= 4
		return  4
	Else
		return pnoState
	endif 
EndFunction