#pragma once

// SL Widgets' own MCM strings, Interface\Translations\SLWidgets_<LANGUAGE>.txt,
// so the SKSE menu says what the MCM says in every language the mod ships.

namespace Translations
{
	// The text of a "$SLW_..." key in the game's language (sLanguage), with the
	// English file filling keys that file lacks. Text that is not a key, or a key
	// no file has, comes back without its '$'. The files are read on first use.
	std::string Get(std::string_view a_key);
}
