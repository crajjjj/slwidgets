Scriptname _SHHungerSystem extends Quest
{SL Widgets compile stub for SunHelm's hunger quest script (SunHelmSurvival.esp,
quest _SHHungerQuest 0x008EE8). Only the members SL Widgets reads. The real
script extends _SHSystemBase; the cast and the calls resolve by name at runtime.}

int Property _SHHungerStage5 auto
; 0 fed .. 5 starving
int Property CurrentHungerStage auto hidden

; current level over the last stage threshold, 0-100
int Function GetHungerPercent()
	Return 0
EndFunction
