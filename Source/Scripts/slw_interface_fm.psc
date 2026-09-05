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
	; SpermCount is None until FM's maintenance first resizes it, and FM forks
	; have shipped it with drifted typing (the get then yields None too) -- the
	; raw element read errors on every tick either way. Fail soft to "no sperm".
	float[] counts = (fm as _JSW_BB_Storage).SpermCount
	if !counts || actorIndex < 0 || actorIndex >= counts.Length
		return false
	endif
	return counts[actorIndex] > 0
endFunction