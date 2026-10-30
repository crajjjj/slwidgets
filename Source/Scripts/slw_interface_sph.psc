Scriptname slw_interface_sph Hidden
{SPH reads. slw_module_sph keeps SPH's main quest as a plain Quest, and only
these global functions cast it to SPH_Main (stubbed in Source/ApiHeaders),
the same pattern as slw_interface_sunhelm. SPH's globals are not the live
state: it writes them only when its shave and growth-cream menus open (they
exist to condition those menus' buttons), so natural growth and a finished
shave never reach them. Both return -1 when the cast fails, and the caller
then falls back to the global.}

Int Function getPubicLength(Quest q) Global
	SPH_Main sph = q as SPH_Main
	If !sph
		Return -1
	EndIf
	Return sph.PubicLength()
EndFunction

; 0 while SPH's armpit hair is switched off, as its own globals do
Int Function getArmpitStage(Quest q) Global
	SPH_Main sph = q as SPH_Main
	If !sph
		Return -1
	EndIf
	If !sph.ArmpitsOn
		Return 0
	EndIf
	Return sph.ArmpitStage
EndFunction
