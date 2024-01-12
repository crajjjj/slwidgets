Scriptname slw_interface_mnd Hidden

Import Debug
import slw_util

Int Function getPoopLevelMND(Quest mnd) Global
	if !(mnd as mndController).enablePoop
		return 0
	endif
	int p = getMNDPercent("Poop", mnd)
	return percentToState5(p)
EndFunction

Int Function getPeeLevelMND(Quest mnd) Global
	if !(mnd as mndController).enablePiss
		return 0
	endif

	int p = getMNDPercent("Piss", mnd)
	return percentToState5(p)
EndFunction

;fixed function from mnd
int function getMNDPercent(string need, Quest mnd) Global
	mndController mndContr = mnd as mndController
	float now = Utility.GetCurrentGameTime()
	float tsv = 20.0/mndContr.TimeScale.getValue()
	float perc = -1.0
	
	If need=="Piss"
		perc = tsv * 24.0*(now - mndContr.lastTimePiss)/mndContr.timePiss
	elseIf need=="Poop"
		perc = tsv * 24.0*(now - mndContr.lastTimePoop)/mndContr.timePoop
	endIf
	return (perc * 100) as int
endFunction