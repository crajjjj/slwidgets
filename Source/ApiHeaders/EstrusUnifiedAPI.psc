Scriptname EstrusUnifiedAPI Hidden
{Compile-time header only -- NOT shipped.

The public API of Estrus Unified (EstrusUnified.dll), copied from its
Scripts\Source\EstrusUnifiedAPI.psc (release 1.1, API version 1) with the
members slw_module_pregnancy calls. The functions are native, so a header is
all a consumer can compile against anyway; the DLL answers them at run time.
Keep the signatures byte-identical to Estrus Unified's own source.}

; Stable API version, independent of the mod's release version.
Int Function GetAPIVersion() Global Native
Bool Function IsReady() Global Native

; 0 = none, 1 = Chaurus, 2 = Spider, 3 = Dwemer. Values will not be renumbered.
Int Function GetPregnancyType(Actor target) Global Native
; Percent 0..100. Returns -1 only when pregnant but timing is unavailable.
Float Function GetPregnancyProgress(Actor target) Global Native

; Quest/form receivers implement OnEstrusUnifiedPregnancyChanged(Actor target, Int pregnancyType).
; Type is zero after completion, cancellation or a pregnancy reset.
Bool Function RegisterForPregnancyEvents(Form receiver) Global Native
Bool Function UnregisterForPregnancyEvents(Form receiver) Global Native
