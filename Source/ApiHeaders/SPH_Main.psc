Scriptname SPH_Main extends Quest
{SL Widgets compile stub for SPH's main quest script (SPH - Skyrim Pubic
Hair.esp, quest SPH_MainQuest 0x800). Only the members slw_interface_sph
reads, declared as in SPH 2.0, 2.1 and 2.1.1. The cast and the calls resolve
by name at runtime; never shipped (SPH ships the real script).}

bool property ArmpitsOn = true auto hidden
int property ArmpitStage = 2 auto hidden       ; 0..6

; longest hair on the pubis (natural regrowth or the style shape), 0..5
int Function PubicLength()
	Return 0
EndFunction
