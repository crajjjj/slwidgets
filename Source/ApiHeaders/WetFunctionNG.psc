Scriptname WetFunctionNG Hidden
{SL Widgets compile stub for WetFunction NG's global script (WetFunctionNG.esp
+ WetFunctionNG.dll). Only the two natives SL Widgets calls. Global calls
resolve at call time, so the real script is used in game and nothing breaks
without NG as long as the calls stay behind isWetFunctionNGReady().}

; the actor's wetness, 0 .. GetWetnessCap()
Float Function GetWetness(Actor akActor) Global Native
; the ini's [Wetness] fWetnessCap (10 by default)
Float Function GetWetnessCap() Global Native
