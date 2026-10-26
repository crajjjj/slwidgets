Scriptname _SHColdSystem extends Quest
{SL Widgets compile stub for SunHelm's cold quest script (SunHelmSurvival.esp,
quest _SHColdQuest 0x6A13C2). Only the members SL Widgets reads. The cold
system has no percent function: SL Widgets divides the level by the last
stage threshold itself.}

GlobalVariable Property _SHCurrentColdLevel auto
int Property _SHColdStage5 auto
; 0 warm .. 5 freezing, -1 before the first update
int Property CurrentColdStage auto
