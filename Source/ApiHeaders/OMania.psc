Scriptname OMania Hidden
{Compile-time header only -- NOT shipped. OMania ships its own OMania.pex,
which a copy of this stub would overwrite.

The Papyrus surface of OMania.dll, copied from OMania 4.0.3's
source\scripts\OMania.psc with the members slw_module_pregnancy and
slw_module_mme call. The functions are native, so a header is all a consumer
can compile against anyway; the DLL answers them at run time. Keep the
signatures byte-identical to OMania's own source.}

; Returns the installed OMania.dll version string, e.g. "0.1.0".
string Function GetVersion() global native

bool Function IsPregnant(Actor akActor) global native
bool Function IsLactating(Actor akActor) global native
; Male carrier of a curse (male gestation off + carrier status on): the egg is remembered, no gestation.
bool Function IsCarrier(Actor akActor) global native
; Gestation progress 0.0-1.0; -1.0 if the actor is not tracked.
float Function GetProgress(Actor akActor) global native
; Transient OStim-driven inflation visual still active (independent of gestation)?
bool Function IsInflated(Actor akActor) global native
; Lactation pressure 0.0-1.0 (1.0 = full; can overfull past 1.0); -1.0 if the actor is not tracked.
float Function GetPressure(Actor akActor) global native

; The current gestation item (egg or baby marker); None if not gestating. (A carrier isn't gestating.)
Form Function GetGestationForm(Actor akActor) global native
; True if the current gestation is the special baby gestation (spawns children), not an egg clutch.
bool Function IsGestatingBaby(Actor akActor) global native
