Scriptname slw_module_health extends slw_base_module
{Injuries from Blade and Blunt and diseases, for the player.

Blade and Blunt's DLL puts one of three spells on the player (Minor, Major,
Critical Injury): the injury icon is a four-step check of them.

Diseases: every vanilla disease is a spell the actor holds, which is stage 1.
SunHelm Diseases makes each one a three-stage chain by adding stage 2 and 3
spells (a stage spell replaces the one before), and brings seven diseases of
its own with the same three stages. The disease icon shows the worst stage
across all of them, and only while one is held: it needs no other mod, so it
must not take a bar position on every install. The scan is up to 50 spell
checks, so its result is reused for DISEASE_RECHECK seconds; diseases move
in game hours.}
import slw_log
import slw_util

Bool Property Plugin_BladeBlunt = false auto hidden
Bool Property Plugin_SunHelmDiseases = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

Spell[] _injury      ; stage 1..3 = index 0..2
Spell[] _disease1
Spell[] _disease2
Spell[] _disease3

String INJURY_STATE = "Injuries"
String DISEASE_STATE = "Diseases"
string iconbasepath = "widgets/iwant/widgets/library/health/"
int EMPTY = -1
int _injury_prv = -1
int _disease_prv = -1
Bool _diseaseLoaded = false
Int _diseaseCached = 0
Float _diseaseCheckedAt = -1.0
Float DISEASE_RECHECK = 20.0

;override
Bool Function isInterfaceActive()
	; the disease half always has the vanilla diseases to watch
	Return true
EndFunction

;override
Function resetInterface()
	Plugin_BladeBlunt = false
	Plugin_SunHelmDiseases = false
	_injury_prv = EMPTY
	_disease_prv = EMPTY
	_diseaseLoaded = false
	_diseaseCheckedAt = -1.0
	_disease1 = None
EndFunction

;override
Function initInterface()
	If !Plugin_BladeBlunt && isBladeBluntReady()
		WriteLog("ModuleHealth: BladeAndBlunt.esp found")
		_injury = new Spell[3]
		_injury[0] = Game.GetFormFromFile(0x00084A, "BladeAndBlunt.esp") as Spell
		_injury[1] = Game.GetFormFromFile(0x00084B, "BladeAndBlunt.esp") as Spell
		_injury[2] = Game.GetFormFromFile(0x00084D, "BladeAndBlunt.esp") as Spell
		Plugin_BladeBlunt = _injury[0] && _injury[1] && _injury[2]
		If !Plugin_BladeBlunt
			WriteLog("ModuleHealth: the Blade and Blunt injury spells were not found (4.0 or newer is needed)", 2)
		EndIf
	EndIf
	; again when SunHelm Diseases came or went since the lists were built: its
	; stage 2 and 3 replace the vanilla spell, so a list without them loses a
	; disease once it worsens
	If !_disease1 || Plugin_SunHelmDiseases != isSunHelmDiseasesReady()
		_resolveDiseases()
	EndIf
EndFunction

; The disease lists, built on the first load and again whenever SunHelm
; Diseases comes or goes: 15 vanilla spells (7 diseases incl. Sanguinare
; Vampiris, their trap variants, Dragonborn's Droops), then SunHelm Diseases
; when it is loaded. A stage cached from the old lists is dropped.
Function _resolveDiseases()
	Spell[] s1 = new Spell[24]
	Spell[] s2 = new Spell[14]
	Spell[] s3 = new Spell[14]
	Int n1 = 0
	n1 = _add(s1, n1, 0x0B877C, "Skyrim.esm")   ; Ataxia
	n1 = _add(s1, n1, 0x0B877E, "Skyrim.esm")   ; Bone Break Fever
	n1 = _add(s1, n1, 0x0B877F, "Skyrim.esm")   ; Brain Rot
	n1 = _add(s1, n1, 0x0B8781, "Skyrim.esm")   ; Rattles
	n1 = _add(s1, n1, 0x0B8782, "Skyrim.esm")   ; Rockjoint
	n1 = _add(s1, n1, 0x0B8783, "Skyrim.esm")   ; Witbane
	n1 = _add(s1, n1, 0x0B8780, "Skyrim.esm")   ; Sanguinare Vampiris
	n1 = _add(s1, n1, 0x10A24A, "Skyrim.esm")   ; trap variants
	n1 = _add(s1, n1, 0x10A24C, "Skyrim.esm")
	n1 = _add(s1, n1, 0x10A24D, "Skyrim.esm")
	n1 = _add(s1, n1, 0x10A24E, "Skyrim.esm")
	n1 = _add(s1, n1, 0x10A24F, "Skyrim.esm")
	n1 = _add(s1, n1, 0x10A250, "Skyrim.esm")
	n1 = _add(s1, n1, 0x0037E9, "Dawnguard.esm")    ; trap Sanguinare Vampiris
	n1 = _add(s1, n1, 0x0285C1, "Dragonborn.esm")   ; Droops
	Plugin_SunHelmDiseases = isSunHelmDiseasesReady()
	If Plugin_SunHelmDiseases
		WriteLog("ModuleHealth: SunHelmDiseases.esp found")
		String p = "SunHelmDiseases.esp"
		; SunHelm's own diseases, stage 1
		n1 = _add(s1, n1, 0x000837, p)   ; Feeble Limb
		n1 = _add(s1, n1, 0x000838, p)   ; Shakes
		n1 = _add(s1, n1, 0x000839, p)   ; Wither
		n1 = _add(s1, n1, 0x00083A, p)   ; Damp Worm
		n1 = _add(s1, n1, 0x00083D, p)   ; Chills
		n1 = _add(s1, n1, 0x000840, p)   ; Swamp Fever
		n1 = _add(s1, n1, 0x000849, p)   ; Astral Vapors
		; stage 2
		Int n2 = 0
		n2 = _add(s2, n2, 0x00083C, p)
		n2 = _add(s2, n2, 0x00083E, p)
		n2 = _add(s2, n2, 0x000841, p)
		n2 = _add(s2, n2, 0x000843, p)
		n2 = _add(s2, n2, 0x000845, p)
		n2 = _add(s2, n2, 0x000847, p)
		n2 = _add(s2, n2, 0x00084A, p)
		n2 = _add(s2, n2, 0x00084C, p)
		n2 = _add(s2, n2, 0x00084E, p)
		n2 = _add(s2, n2, 0x000850, p)
		n2 = _add(s2, n2, 0x000852, p)
		n2 = _add(s2, n2, 0x000854, p)
		n2 = _add(s2, n2, 0x000856, p)
		n2 = _add(s2, n2, 0x000858, p)
		; stage 3
		Int n3 = 0
		n3 = _add(s3, n3, 0x00083B, p)
		n3 = _add(s3, n3, 0x00083F, p)
		n3 = _add(s3, n3, 0x000842, p)
		n3 = _add(s3, n3, 0x000844, p)
		n3 = _add(s3, n3, 0x000846, p)
		n3 = _add(s3, n3, 0x000848, p)
		n3 = _add(s3, n3, 0x00084B, p)
		n3 = _add(s3, n3, 0x00084D, p)
		n3 = _add(s3, n3, 0x00084F, p)
		n3 = _add(s3, n3, 0x000851, p)
		n3 = _add(s3, n3, 0x000853, p)
		n3 = _add(s3, n3, 0x000855, p)
		n3 = _add(s3, n3, 0x000857, p)
		n3 = _add(s3, n3, 0x000859, p)
	EndIf
	_disease1 = s1
	_disease2 = s2
	_disease3 = s3
	_diseaseCheckedAt = -1.0
	WriteLog("ModuleHealth: " + n1 + " disease spells resolved")
EndFunction

Int Function _add(Spell[] list, Int n, Int formId, String plugin)
	Spell sp = Game.GetFormFromFile(formId, plugin) as Spell
	If sp && n < list.Length
		list[n] = sp
		Return n + 1
	EndIf
	Return n
EndFunction

Bool Function _injuryOn()
	Return Plugin_BladeBlunt && config.isOn(config.module_injuries)
EndFunction

Bool Function _diseaseOn()
	Return config.isOn(config.module_diseases)
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_injury_prv = EMPTY
	iBars.releaseIcon(slwGetModName(), INJURY_STATE)
	_releaseDisease(iBars)
	_diseaseCheckedAt = -1.0
	If !target
		Return
	EndIf
	If _injuryOn()
		_loadInjuryIcon(iBars)
	EndIf
	; the disease icon is loaded by the status update that finds a disease
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	If target && _injuryOn()
		_loadInjuryIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), INJURY_STATE)
		_injury_prv = EMPTY
	EndIf
	If (!target || !_diseaseOn()) && _diseaseLoaded
		_releaseDisease(iBars)
	EndIf
EndEvent

Function _releaseDisease(iWant_Status_Bars iBars)
	_diseaseLoaded = false
	_disease_prv = EMPTY
	iBars.releaseIcon(slwGetModName(), DISEASE_STATE)
EndFunction

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	If !target
		Return
	EndIf
	If _injuryOn()
		Int injuryCurr = getInjuryStage(target)
		If _injury_prv == EMPTY || _injury_prv != injuryCurr
			iBars.setIconStatus(slwGetModName(), INJURY_STATE, injuryCurr)
			_injury_prv = injuryCurr
		EndIf
	EndIf
	If _diseaseOn()
		Int diseaseCurr = _cachedDiseaseStage(target)
		If diseaseCurr == 0
			If _diseaseLoaded
				_releaseDisease(iBars)
			EndIf
		Else
			If !_diseaseLoaded
				; claimed before the external load call, as in slw_module_baby
				_diseaseLoaded = true
				_loadDiseaseIcon(iBars)
			EndIf
			If _disease_prv == EMPTY || _disease_prv != diseaseCurr
				iBars.setIconStatus(slwGetModName(), DISEASE_STATE, diseaseCurr)
				_disease_prv = diseaseCurr
			EndIf
		EndIf
	EndIf
EndEvent

; getDiseaseStage, reused for DISEASE_RECHECK seconds. Real time restarts at
; every game launch, so a stamp from before a load (now < stamp) counts as
; stale too.
Int Function _cachedDiseaseStage(Actor target)
	Float now = Utility.GetCurrentRealTime()
	If _diseaseCheckedAt < 0.0 || now < _diseaseCheckedAt || now - _diseaseCheckedAt >= DISEASE_RECHECK
		_diseaseCached = getDiseaseStage(target)
		_diseaseCheckedAt = now
	EndIf
	Return _diseaseCached
EndFunction

; 0 unhurt, 1 minor, 2 major, 3 critical: the worst injury spell held
Int Function getInjuryStage(Actor target)
	If !Plugin_BladeBlunt
		Return 0
	EndIf
	Int i = 2
	While i >= 0
		If _injury[i] && target.HasSpell(_injury[i])
			Return i + 1
		EndIf
		i -= 1
	EndWhile
	Return 0
EndFunction

; 0 healthy, 1 infected, 2 worsening, 3 severe: the worst stage of any
; disease held. A stage spell replaces the one before it, so no list can be
; skipped; callers go through _cachedDiseaseStage.
Int Function getDiseaseStage(Actor target)
	If !_disease1
		_resolveDiseases()
	EndIf
	If _hasAny(target, _disease3)
		Return 3
	ElseIf _hasAny(target, _disease2)
		Return 2
	ElseIf _hasAny(target, _disease1)
		Return 1
	EndIf
	Return 0
EndFunction

Bool Function _hasAny(Actor target, Spell[] list)
	If !list
		Return false
	EndIf
	Int i = 0
	While i < list.Length
		If list[i]
			If target.HasSpell(list[i])
				Return true
			EndIf
		Else
			; the lists are filled from the front
			Return false
		EndIf
		i += 1
	EndWhile
	Return false
EndFunction

Function _loadInjuryIcon(iWant_Status_Bars iBars)
	; Blade and Blunt's own spell names
	String[] d = StringUtil.Split("Unhurt,Minor Injury,Major Injury,Critical Injury", ",")
	loadStageIcon(config, iBars, INJURY_STATE, 0, iconbasepath + "injury/injury", d)
EndFunction

Function _loadDiseaseIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Healthy,Infected,Worsening,Severe", ",")
	loadStageIcon(config, iBars, DISEASE_STATE, 0, iconbasepath + "disease/disease", d)
EndFunction
