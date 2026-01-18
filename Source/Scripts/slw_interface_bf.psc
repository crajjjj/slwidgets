Scriptname slw_interface_bf Hidden

Import Debug
import slw_util

;SLP
;--------------------------------------
bool function HasRelevantSperm(Quest fwControllerQuest, Actor akTarget) Global
	return (fwControllerQuest as FWController).HasRelevantSperm(akTarget)
endFunction