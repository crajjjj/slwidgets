Scriptname slw_module_stress extends slw_base_module
{Stress and Fear: the player's stress (the mod's 0-100 global) and fear.
The mod has no fear number: fear is the phobias the player carries, one
spell per creature type, picked up when badly hurt by that type and shed by
conquering it. The fear icon counts them, stage 8 for eight or more.
Player only, like the mod.}
import slw_log
import slw_util

Bool Property Module_Ready = false auto hidden

slw_config Property config Auto
Actor Property PlayerRef Auto

GlobalVariable _stressTotal
Spell[] _phobias

String STRESS_STATE = "Stress"
String FEAR_STATE = "Fear"
string iconbasepath = "widgets/iwant/widgets/library/stress/"
int EMPTY = -1
int _stress_prv = -1
int _fear_prv = -1
; the phobia count is 24 spell checks; phobias come and go with fights, so
; the count is reused for PHOBIA_RECHECK seconds
Int _phobiaCached = 0
Float _phobiaCheckedAt = -1.0
Float PHOBIA_RECHECK = 15.0

;override
Bool Function isInterfaceActive()
	Return Module_Ready
EndFunction

;override
Function resetInterface()
	Module_Ready = false
	_stress_prv = EMPTY
	_fear_prv = EMPTY
	_phobiaCheckedAt = -1.0
EndFunction

;override
Function initInterface()
	If Module_Ready || !isStressFearReady()
		Return
	EndIf
	WriteLog("ModuleStress: Stress and Fear.esp found")
	String plugin = "Stress and Fear.esp"
	_stressTotal = Game.GetFormFromFile(0x000801, plugin) as GlobalVariable
	; the 24 phobia spells of Stress and Fear 2.07 (Stress_PhobiaSpell_*)
	Int[] ids = new Int[24]
	ids[0] = 0x000817
	ids[1] = 0x000824
	ids[2] = 0x00082F
	ids[3] = 0x000833
	ids[4] = 0x000839
	ids[5] = 0x00083E
	ids[6] = 0x000843
	ids[7] = 0x000848
	ids[8] = 0x00084D
	ids[9] = 0x000852
	ids[10] = 0x000857
	ids[11] = 0x00085C
	ids[12] = 0x000861
	ids[13] = 0x000866
	ids[14] = 0x00086B
	ids[15] = 0x000870
	ids[16] = 0x000878
	ids[17] = 0x00087E
	ids[18] = 0x000883
	ids[19] = 0x000888
	ids[20] = 0x00088D
	ids[21] = 0x000892
	ids[22] = 0x000897
	ids[23] = 0x000898
	Spell[] found = new Spell[24]
	Int n = 0
	Int i = 0
	While i < ids.Length
		Spell sp = Game.GetFormFromFile(ids[i], plugin) as Spell
		If sp
			found[n] = sp
			n += 1
		EndIf
		i += 1
	EndWhile
	_phobias = found
	If _stressTotal
		Module_Ready = true
		WriteLog("ModuleStress: " + n + " phobia spells resolved")
	Else
		WriteLog("ModuleStress: Stress_Total not found", 2)
	EndIf
EndFunction

;override
Event onWidgetReload(iWant_Status_Bars iBars, Actor target, Int slot)
	_stress_prv = EMPTY
	_fear_prv = EMPTY
	_phobiaCheckedAt = -1.0
	iBars.releaseIcon(slwGetModName(), STRESS_STATE)
	iBars.releaseIcon(slwGetModName(), FEAR_STATE)
	If !target || !isInterfaceActive()
		Return
	EndIf
	If config.isOn(config.module_saf_stress)
		_loadStressIcon(iBars)
	EndIf
	If config.isOn(config.module_saf_fear)
		_loadFearIcon(iBars)
	EndIf
EndEvent

;override
Event onWidgetToggleUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	Bool ready = target && isInterfaceActive()
	If ready && config.isOn(config.module_saf_stress)
		_loadStressIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), STRESS_STATE)
		_stress_prv = EMPTY
	EndIf
	If ready && config.isOn(config.module_saf_fear)
		_loadFearIcon(iBars)
	Else
		iBars.releaseIcon(slwGetModName(), FEAR_STATE)
		_fear_prv = EMPTY
	EndIf
EndEvent

;override
Event onWidgetStatusUpdate(iWant_Status_Bars iBars, Actor target, Int slot)
	If !target || !isInterfaceActive()
		Return
	EndIf
	If config.isOn(config.module_saf_stress)
		Int stressCurr = percentToState9NotStrict(getStressPercent())
		If _stress_prv == EMPTY || _stress_prv != stressCurr
			iBars.setIconStatus(slwGetModName(), STRESS_STATE, stressCurr)
			_stress_prv = stressCurr
		EndIf
	EndIf
	If config.isOn(config.module_saf_fear)
		Int fearCurr = clampInt(_cachedPhobiaCount(target), 0, 8)
		If _fear_prv == EMPTY || _fear_prv != fearCurr
			iBars.setIconStatus(slwGetModName(), FEAR_STATE, fearCurr)
			_fear_prv = fearCurr
		EndIf
	EndIf
EndEvent

Int Function getStressPercent()
	If !_stressTotal
		Return 0
	EndIf
	Return clampInt(_stressTotal.GetValue() as Int, 0, 100)
EndFunction

; real time restarts at every game launch: a stamp from before a load is stale
Int Function _cachedPhobiaCount(Actor target)
	Float now = Utility.GetCurrentRealTime()
	If _phobiaCheckedAt < 0.0 || now < _phobiaCheckedAt || now - _phobiaCheckedAt >= PHOBIA_RECHECK
		_phobiaCached = getPhobiaCount(target)
		_phobiaCheckedAt = now
	EndIf
	Return _phobiaCached
EndFunction

Int Function getPhobiaCount(Actor target)
	Int count = 0
	Int i = 0
	While i < _phobias.Length
		If _phobias[i] && target.HasSpell(_phobias[i])
			count += 1
		EndIf
		i += 1
	EndWhile
	Return count
EndFunction

Function _loadStressIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("Calm,Relaxed,Uneasy,Tense,Stressed,Very Stressed,Anxious,Overwhelmed,Breaking", ",")
	loadStageIcon(config, iBars, STRESS_STATE, 0, iconbasepath + "stress/stress", d)
EndFunction

Function _loadFearIcon(iWant_Status_Bars iBars)
	String[] d = StringUtil.Split("No Phobia,1 Phobia,2 Phobias,3 Phobias,4 Phobias,5 Phobias,6 Phobias,7 Phobias,8+ Phobias", ",")
	loadStageIcon(config, iBars, FEAR_STATE, 0, iconbasepath + "fear/fear", d)
EndFunction
