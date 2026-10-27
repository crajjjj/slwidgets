#include "Translations.h"

#include "Text.h"

#include <fstream>

namespace Translations
{
	namespace
	{
		std::mutex                                   g_lock;
		bool                                         g_loaded = false;
		std::unordered_map<std::string, std::string> g_strings;  // lowercased key, '$' included -> UTF-8 text

		void AppendUtf8(std::string& a_out, std::uint32_t a_cp)
		{
			if (a_cp < 0x80) {
				a_out += static_cast<char>(a_cp);
			} else if (a_cp < 0x800) {
				a_out += static_cast<char>(0xC0 | (a_cp >> 6));
				a_out += static_cast<char>(0x80 | (a_cp & 0x3F));
			} else if (a_cp < 0x10000) {
				a_out += static_cast<char>(0xE0 | (a_cp >> 12));
				a_out += static_cast<char>(0x80 | ((a_cp >> 6) & 0x3F));
				a_out += static_cast<char>(0x80 | (a_cp & 0x3F));
			} else {
				a_out += static_cast<char>(0xF0 | (a_cp >> 18));
				a_out += static_cast<char>(0x80 | ((a_cp >> 12) & 0x3F));
				a_out += static_cast<char>(0x80 | ((a_cp >> 6) & 0x3F));
				a_out += static_cast<char>(0x80 | (a_cp & 0x3F));
			}
		}

		// The file as UTF-8. SkyUI translation files are UTF-16 LE with a BOM
		std::optional<std::string> ReadUtf16File(const std::filesystem::path& a_path)
		{
			std::ifstream file{ a_path, std::ios::binary };
			if (!file) {
				return std::nullopt;
			}
			const std::string bytes{ std::istreambuf_iterator<char>{ file }, std::istreambuf_iterator<char>{} };
			std::size_t       i = 0;
			if (bytes.size() >= 2 && static_cast<unsigned char>(bytes[0]) == 0xFF && static_cast<unsigned char>(bytes[1]) == 0xFE) {
				i = 2;
			}
			std::string out;
			out.reserve(bytes.size() / 2);
			while (i + 1 < bytes.size()) {
				std::uint32_t unit = static_cast<unsigned char>(bytes[i]) | (static_cast<unsigned char>(bytes[i + 1]) << 8);
				i += 2;
				if (unit >= 0xD800 && unit < 0xDC00 && i + 1 < bytes.size()) {
					const std::uint32_t low = static_cast<unsigned char>(bytes[i]) | (static_cast<unsigned char>(bytes[i + 1]) << 8);
					if (low >= 0xDC00 && low < 0xE000) {
						i += 2;
						unit = 0x10000 + ((unit - 0xD800) << 10) + (low - 0xDC00);
					}
				}
				AppendUtf8(out, unit);
			}
			return out;
		}

		// "$KEY<tab>Text" per line; a later file overwrites an earlier one's keys
		std::size_t LoadFile(const std::string& a_language)
		{
			const auto path = std::filesystem::path{ "Data" } / "Interface" / "Translations" / ("SLWidgets_" + a_language + ".txt");
			const auto text = ReadUtf16File(path);
			if (!text) {
				return 0;
			}
			std::size_t count = 0;
			for (auto line : Text::Split(*text, '\n')) {
				if (!line.empty() && line.back() == '\r') {
					line.remove_suffix(1);
				}
				const auto tab = line.find('\t');
				if (tab == std::string_view::npos || line.empty() || line[0] != '$') {
					continue;
				}
				g_strings[Text::Lower(line.substr(0, tab))] = std::string{ line.substr(tab + 1) };
				++count;
			}
			return count;
		}

		std::string GameLanguage()
		{
			const char* value = nullptr;
			if (auto* collection = RE::INISettingCollection::GetSingleton()) {
				if (auto* setting = collection->GetSetting("sLanguage:General")) {
					value = setting->GetString();
				}
			}
			std::string language{ value && *value ? value : "ENGLISH" };
			std::transform(language.begin(), language.end(), language.begin(), [](unsigned char c) { return static_cast<char>(std::toupper(c)); });
			return language;
		}

		void Load()
		{
			const auto language = GameLanguage();
			const auto english = LoadFile("ENGLISH");
			const auto own = language == "ENGLISH" ? english : LoadFile(language);
			logger::info("Translations: {} strings ({}: {}, ENGLISH: {})", g_strings.size(), language, own, english);
		}
	}

	std::string Get(std::string_view a_key)
	{
		if (a_key.empty() || a_key[0] != '$') {
			return std::string{ a_key };
		}
		std::scoped_lock lock{ g_lock };
		if (!g_loaded) {
			g_loaded = true;
			try {
				Load();
			} catch (...) {
				logger::warn("Translations: the files could not be read; the menu shows the keys");
			}
		}
		const auto found = g_strings.find(Text::Lower(a_key));
		return found != g_strings.end() ? found->second : std::string{ a_key.substr(1) };
	}
}
