Scriptname slw_interface_fm Hidden

Import Debug
import slw_util

;FM+
;--------------------------------------
int function getFMActorIndex( Quest fm, Actor akTarget) Global
	return (fm as _JSW_BB_Storage).TrackedActors.Find(akTarget as form) 
endFunction

bool function isFMPregnant( Quest fm, int actorIndex) Global
	return (fm as _JSW_BB_Storage).LastConception[actorIndex] != 0.0
endFunction

bool function isFMOvulating( Quest fm, int actorIndex) Global
	return (fm as _JSW_BB_Storage).LastOvulation[actorIndex] != 0.0
endFunction

bool function hasFMSperm( Quest fm, int actorIndex) Global
	return (fm as _JSW_BB_Storage).SpermCount[actorIndex] > 0
endFunction