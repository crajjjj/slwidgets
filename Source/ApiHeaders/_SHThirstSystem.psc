Scriptname _SHThirstSystem extends Quest
{SL Widgets compile stub for SunHelm's thirst quest script (SunHelmSurvival.esp,
quest _SHThirstQuest 0x05C470). Only the members SL Widgets reads.}

int Property _SHThirstStage5 auto
; 0 quenched .. 5 parched
int Property CurrentThirstStage auto hidden

int Function GetThirstPercent()
	Return 0
EndFunction
