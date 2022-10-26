Scriptname slw_interface_eggfact36 Hidden

Import Debug
import slw_util

;EggFact
;--------------------------------------
bool function isEggFactPregnant( Quest q, Actor act) Global
	return (q as EggFactoryMasterTimer).GetPregCount(act) > 0
endFunction