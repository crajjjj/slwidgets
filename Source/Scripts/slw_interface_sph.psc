Scriptname slw_interface_sph Hidden
{SPH's live hair stages, from its main quest passed as a plain Quest and
cast to SPH_Main (stubbed in Source/ApiHeaders) only inside these global
functions, so nothing that merely holds the quest needs SPH's script to
resolve. SPH's globals SPH_GPubicLength / SPH_GArmpitStage are not the live
state: it writes them only when its shave and growth-cream menus open (they
exist to condition those menus' buttons). Both return -1 when the cast
fails.}

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
