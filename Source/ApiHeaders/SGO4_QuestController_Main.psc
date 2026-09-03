ScriptName SGO4_QuestController_Main extends Quest
{Compile-time header only -- NOT shipped.

Declares just enough of SGO4IF 1.12+ for slw_interface_sgo4 to bind against.
Compiling the mod's real source instead drags in SGO4_QuestUtil_Main, which
calls SexLabFramework.GetSex and so demands a SexLab P+ tree; every other
SexLab-dependent import here (SexLab Separate Orgasm above all) is built
against 1.63, and mixing the two breaks unrelated scripts. Papyrus resolves
calls by name at runtime, so the real .pex answers these at load time.

Keep the signatures below byte-identical to SGO4IF's own source.}

SGO4_QuestDatabase_Main Property Data Auto

SGO4_QuestController_Main Function Get() Global
	Return Game.GetFormFromFile(0x821,"SGO4IF.esp") As SGO4_QuestController_Main
EndFunction
