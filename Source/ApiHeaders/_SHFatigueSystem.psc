Scriptname _SHFatigueSystem extends Quest
{SL Widgets compile stub for SunHelm's fatigue quest script (SunHelmSurvival.esp,
quest _SHFatigueQuest 0x01E844). Only the members SL Widgets reads.}

int Property _SHFatigueStage5 auto
; 0 rested .. 5 exhausted
int Property CurrentFatigueStage auto hidden

int Function GetFatiguePercent()
	Return 0
EndFunction
