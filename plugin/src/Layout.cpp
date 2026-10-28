#include "Layout.h"

#include "Text.h"

namespace Layout
{
	namespace
	{
		// "x,y,type,size,visible"
		bool ParseBar(std::string_view a_value, Bar& a_bar, std::string& a_error)
		{
			const auto fields = Text::Split(a_value, ',');
			if (fields.size() < 5) {
				a_error = "a bar has fewer than five fields";
				return false;
			}
			int visible = 1;
			if (!Text::ToInt(fields[0], a_bar.x) || !Text::ToInt(fields[1], a_bar.y) || !Text::ToInt(fields[2], a_bar.type) ||
				!Text::ToInt(fields[3], a_bar.size) || !Text::ToInt(fields[4], visible)) {
				a_error = "a bar field is not a number";
				return false;
			}
			a_bar.visible = visible != 0;
			return true;
		}
	}

	bool ParseIcons(std::string_view a_text, Model& a_out, std::string& a_error)
	{
		a_error.clear();
		for (auto& bar : a_out.bars) {
			bar.icons.clear();  // the answer lists them all again
		}
		bool sawVersion = false;
		for (const auto item : Text::Split(a_text, '|')) {
			const auto eq = item.find('=');
			if (eq == std::string_view::npos) {
				continue;
			}
			const auto key = item.substr(0, eq);
			const auto value = item.substr(eq + 1);
			if (key == "v"sv) {
				int version = 0;
				if (!Text::ToInt(value, version) || version != kIconsVersion) {
					a_error = std::format("the scripts report icon list version {} but the DLL reads {}: install both from the same release", std::string{ value }, kIconsVersion);
					return false;
				}
				sawVersion = true;
			} else if (key == "ic"sv) {
				// bar,seat,id,label: the label is the rest and may hold commas
				const auto f = Text::Fields(value, 4);
				int        bar = -1;
				Icon       icon;
				if (f.size() != 4 || !Text::ToInt(f[0], bar) || !Text::ToInt(f[1], icon.seat) || !Text::ToInt(f[2], icon.id)) {
					a_error = "an icon entry does not read";
					return false;
				}
				if (bar >= 0 && bar < kPlayerBars) {
					icon.label = std::string{ f[3] };
					a_out.bars[static_cast<std::size_t>(bar)].icons.push_back(std::move(icon));
				}
			}
		}
		if (!sawVersion) {
			a_error = "no icon list version in the answer";
			return false;
		}
		return true;
	}

	int Clamp(int a_v, int a_min, int a_max)
	{
		return std::max(a_min, std::min(a_max, a_v));
	}

	bool Parse(std::string_view a_text, Model& a_out, std::string& a_error)
	{
		a_error.clear();
		a_out.iconSpacing = -1;  // only an answer that carries it shows the slider
		bool sawVersion = false;
		for (const auto item : Text::Split(a_text, '|')) {
			const auto eq = item.find('=');
			if (eq == std::string_view::npos) {
				continue;
			}
			const auto key = item.substr(0, eq);
			const auto value = item.substr(eq + 1);
			if (key == "v"sv) {
				int version = 0;
				if (!Text::ToInt(value, version) || version != kVersion) {
					a_error = std::format("the scripts report layout version {} but the DLL reads {}: install both from the same release", std::string{ value }, kVersion);
					return false;
				}
				sawVersion = true;
			} else if (key.size() >= 2 && key[0] == 'b') {
				int bar = -1;
				if (Text::ToInt(key.substr(1), bar) && bar >= 0 && bar < kBars) {
					if (!ParseBar(value, a_out.bars[static_cast<std::size_t>(bar)], a_error)) {
						return false;
					}
				}
			} else if (key == "npc"sv) {
				const auto f = Text::Split(value, ',');
				if (f.size() < 3 || !Text::ToInt(f[0], a_out.npc.x) || !Text::ToInt(f[1], a_out.npc.y) || !Text::ToInt(f[2], a_out.npc.stride)) {
					a_error = "the npc entry does not read";
					return false;
				}
			} else if (key.size() == 2 && key[0] == 'n' && key[1] >= '1' && key[1] <= '3') {
				a_out.npc.names[static_cast<std::size_t>(key[1] - '1')] = std::string{ value };
			} else if (key == "meters"sv) {
				const auto f = Text::Split(value, ',');
				int        always = 0;
				if (f.size() < 5 || !Text::ToInt(f[0], a_out.meters.x) || !Text::ToInt(f[1], a_out.meters.y) || !Text::ToInt(f[2], a_out.meters.scale) ||
					!Text::ToInt(f[3], a_out.meters.rows) || !Text::ToInt(f[4], always)) {
					a_error = "the meters entry does not read";
					return false;
				}
				a_out.meters.always = always != 0;
			} else if (key == "sp"sv) {
				// added in 3.4.1 without a version bump: an older DLL skips the key
				if (!Text::ToInt(value, a_out.iconSpacing)) {
					a_error = "the icon spacing entry does not read";
					return false;
				}
			}
		}
		if (!sawVersion) {
			a_error = "no layout version in the answer";
			return false;
		}
		return true;
	}
}
