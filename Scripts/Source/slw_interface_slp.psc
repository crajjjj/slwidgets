Scriptname slw_interface_slp Hidden

Import Debug
import slw_util

;SLP
;--------------------------------------
bool function isInfectedBySLP( Quest slp, Actor akTarget, string parasite) Global
	return (slp as SLP_fcts_parasites).isInfectedByString(akTarget, parasite)
endFunction