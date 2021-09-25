Scriptname slw_interface_pregnancy extends Quest  
;DEPRECATED
Actor Property playerRef Auto

Bool Property Plugin_EstrusChaurus = false auto hidden
Bool Property Plugin_EstrusSpider = false auto hidden
Bool Property Plugin_EstrusDwemer = false auto hidden
Bool Property Plugin_EggFactory = false auto hidden
Bool Property Plugin_BeeingFemale = false auto hidden
Bool Property Plugin_FertilityMode3 = false auto hidden
Bool Property Plugin_HentaiPregnancy = false auto hidden
;Deprecated
Bool Property Plugin_SLP = false auto hidden

Spell _BFStatePregnant 
Faction _HentaiPregnantFaction
Faction _EggFactoryPregnantFaction

Spell _ChaurusBreederSpell
Keyword _zzEstrusParasiteKeyword

Spell _SpiderBreederSpell
Keyword _zzEstrusSpiderParasiteKWD

Spell _DwemerBreederSpell
Keyword _zzEstrusDwemerParasiteKWD

Function initInterface()
	slw_log.WriteLog("slw_interface_pregnancy init interface deprecated", 2)
EndFunction


Bool Function isInterfaceActive()
	Return false
EndFunction
		
Int Function getPregnancyCode()
	slw_log.WriteLog("slw_interface_pregnancy getPregnancyCode deprecated", 2)
	Return 0
EndFunction

	