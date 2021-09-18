Scriptname slw_interface_pregnancy extends Quest  

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
	slw_log.WriteLog("Pregnancy dlc recheck")
	
	If (!Plugin_EstrusChaurus && Game.GetModbyName("EstrusChaurus.esp") != 255)
		slw_log.WriteLog("EstrusChaurus.esp found")
		Plugin_EstrusChaurus = true
		_ChaurusBreederSpell = Game.GetFormFromFile(0x19121, "EstrusChaurus.esp") as Spell
		if !_ChaurusBreederSpell
			slw_log.WriteLog("EstrusChaurus: _ChaurusBreederSpell not found", 2)
		endif
		_zzEstrusParasiteKeyword = Game.GetFormFromFile(0x160A8, "EstrusChaurus.esp") as Keyword
		if !_zzEstrusParasiteKeyword
			slw_log.WriteLog("EstrusChaurus: _zzEstrusParasiteKeyword not found", 2)
		endif
	endif
	
	If (!Plugin_EstrusSpider && Game.GetModbyName("EstrusSpider.esp") != 255)
		slw_log.WriteLog("EstrusSpider.esp found")
		Plugin_EstrusSpider = true
		_SpiderBreederSpell = Game.GetFormFromFile(0x4e255, "EstrusSpider.esp") as Spell
		if !_SpiderBreederSpell
			slw_log.WriteLog("EstrusSpider: _SpiderBreederSpell not found", 2)
		endif
		_zzEstrusSpiderParasiteKWD = Game.GetFormFromFile(0x4F2A3, "EstrusSpider.esp") as Keyword
		if !_SpiderBreederSpell
			slw_log.WriteLog("EstrusSpider: _zzEstrusSpiderParasiteKWD not found", 2)
		endif
	endif
	
	If (!Plugin_EstrusDwemer && Game.GetModbyName("EstrusDwemer.esp") != 255)
		slw_log.WriteLog("EstrusDwemer.esp found")
		Plugin_EstrusDwemer = true
		_DwemerBreederSpell = Game.GetFormFromFile(0x4e255, "EstrusDwemer.esp") as Spell 
		if !_DwemerBreederSpell
			slw_log.WriteLog("EstrusDwemer: _DwemerBreederSpell not found", 2)
		endif
		_zzEstrusDwemerParasiteKWD = Game.GetFormFromFile(0x4F2A3, "EstrusDwemer.esp") as Keyword
		if !_zzEstrusDwemerParasiteKWD
			slw_log.WriteLog("EstrusDwemer: _zzEstrusDwemerParasiteKWD not found", 2)
		endif
	endif
	
	If (!Plugin_BeeingFemale && Game.GetModbyName("BeeingFemale.esm") != 255)
		slw_log.WriteLog("BeeingFemale.esm found")
		Plugin_BeeingFemale = true
		_BFStatePregnant = Game.GetFormFromFile(0x28a0, "BeeingFemale.esm") as Spell
		if !_BFStatePregnant
			slw_log.WriteLog("BeeingFemale: _BFStatePregnant not found", 2)
		endif
	endif
	
	If (!Plugin_HentaiPregnancy && Game.GetModbyName("HentaiPregnancy.esm") != 255)
		slw_log.WriteLog("HentaiPregnancy.esm found")
		Plugin_HentaiPregnancy = true
		_HentaiPregnantFaction = ( Game.GetFormFromFile(0x12085, "HentaiPregnancy.esm") as Faction )
		if !_HentaiPregnantFaction
			slw_log.WriteLog("HentaiPregnancy: _HentaiPregnantFaction not found", 2)
		endif
	endif

	If (!Plugin_EggFactory && Game.GetModbyName("EggFactory.esp") != 255)
		slw_log.WriteLog("EggFactory found")
		Plugin_EggFactory = true
		_EggFactoryPregnantFaction = Game.GetFormFromFile(0x2943C, "EggFactory.esp") as Faction 
		if !_EggFactoryPregnantFaction
			slw_log.WriteLog("EggFactory: _EggFactoryPregnantFaction not found", 2)
		endif
	endif
EndFunction


Bool Function isInterfaceActive()
	Return (Plugin_EstrusSpider || Plugin_EstrusChaurus || Plugin_EstrusDwemer || Plugin_BeeingFemale || Plugin_HentaiPregnancy || Plugin_EggFactory)
EndFunction
		
	Int Function getPregnancyCode()
		String akActorName = playerRef.GetLeveledActorBase().GetName()
		;Hentai pregnancy LE/SE
		;You can check pregnancy through "HentaiPregnantFaction" its ranks are: 1- actor is cuminflated 2- actor is cuminflated and will be pregnant 3- actor is pregnant
		if (Plugin_HentaiPregnancy)
			int _HentaiPregnantFactionRank = playerRef.GetFactionRank(_HentaiPregnantFaction)
			if _HentaiPregnantFactionRank == 2 || _HentaiPregnantFactionRank == 3
				;slw_log.WriteLog("SLHP Pregnancy: " + akActorName)
				Return 1
			endif
		endif

		;BeeingFemale
		if Plugin_BeeingFemale
			if playerRef.HasSpell(_BFStatePregnant) ;_BFStatePregnant spell
				;slw_log.WriteLog("BF Pregnancy: " + akActorName)
				Return 2
			endif
		endif

		;EggFactory
		If Plugin_EggFactory
			if playerRef.isInFaction(_EggFactoryPregnantFaction ) ;EggFactoryPregCheck Faction
			;	slw_log.WriteLog("EggFactory Pregnancy: " + akActorName)
				Return 3
			endif
		endif

		;Estrus Chaurus+
		if Plugin_EstrusChaurus
			if playerRef.HasSpell(_ChaurusBreederSpell) ;ChaurusBreeder spell
				;slw_log.WriteLog("EC Pregnancy: " + akActorName)
				Return 4
			endif
			if playerRef.WornHasKeyword(_zzEstrusParasiteKeyword) ;zzEstrusParasite Keyword
			;	slw_log.WriteLog("EC Pregnancy: " + akActorName)
				Return 4
			endif
		endif
		
		;Estrus Spider+
		if Plugin_EstrusSpider
			if playerRef.HasSpell( _SpiderBreederSpell) ;SpiderBreeder spell
			;	slw_log.WriteLog("ES Pregnancy: " + akActorName)
				Return 5
			endif
			if playerRef.WornHasKeyword(_zzEstrusParasiteKeyword) ;zzEstrusSpiderParasiteKWD Keyword
				;slw_log.WriteLog("EC Pregnancy: " + akActorName)
				Return 5
			endif
		endif
		
		;Estrus Dwemer+
		if Plugin_EstrusDwemer
			if playerRef.HasSpell(_DwemerBreederSpell) ;DwemerBreeder spell
			;	slw_log.WriteLog("ED Pregnancy: " + akActorName)
				Return 6
			endif
			if playerRef.WornHasKeyword(_zzEstrusDwemerParasiteKWD) ;zzEstrusDwemerParasiteKWD Keyword
			;	slw_log.WriteLog("ED Pregnancy: " + akActorName)
				Return 6
			endif
		endif
		
		Return 0
	EndFunction

	