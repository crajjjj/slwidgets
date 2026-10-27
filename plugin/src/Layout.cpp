#include "Layout.h"

namespace Layout
{
	namespace
	{
		std::vector<std::string_view> Split(std::string_view a_text, char a_sep)
		{
			std::vector<std::string_view> out;
			std::size_t                   start = 0;
			while (start <= a_text.size()) {
				const auto end = a_text.find(a_sep, start);
				if (end == std::string_view::npos) {
					out.push_back(a_text.substr(start));
					break;
				}
				out.push_back(a_text.substr(start, end - start));
				start = end + 1;
			}
			return out;
		}

		bool ToInt(std::string_view a_text, int& a_out)
		{
			const auto* begin = a_text.data();
			const auto* end = begin + a_text.size();
			const auto [ptr, ec] = std::from_chars(begin, end, a_out);
			return ec == std::errc{} && ptr == end;
		}

		// "x,y,type,size,visible"
		bool ParseBar(std::string_view a_value, Bar& a_bar, std::string& a_error)
		{
			const auto fields = Split(a_value, ',');
			if (fields.size() < 5) {
				a_error = "a bar has fewer than five fields";
				return false;
			}
			int visible = 1;
			if (!ToInt(fields[0], a_bar.x) || !ToInt(fields[1], a_bar.y) || !ToInt(fields[2], a_bar.type) ||
				!ToInt(fields[3], a_bar.size) || !ToInt(fields[4], visible)) {
				a_error = "a bar field is not a number";
				return false;
			}
			a_bar.visible = visible != 0;
			return true;
		}
	}

	int Clamp(int a_v, int a_min, int a_max)
	{
		return std::max(a_min, std::min(a_max, a_v));
	}

	bool Parse(std::string_view a_text, Model& a_out, std::string& a_error)
	{
		a_error.clear();
		bool sawVersion = false;
		for (const auto item : Split(a_text, '|')) {
			const auto eq = item.find('=');
			if (eq == std::string_view::npos) {
				continue;
			}
			const auto key = item.substr(0, eq);
			const auto value = item.substr(eq + 1);
			if (key == "v"sv) {
				int version = 0;
				if (!ToInt(value, version) || version != kVersion) {
					a_error = std::format("the scripts report layout version {} but the DLL reads {}: install both from the same release", std::string{ value }, kVersion);
					return false;
				}
				sawVersion = true;
			} else if (key.size() >= 2 && key[0] == 'b') {
				int bar = -1;
				if (ToInt(key.substr(1), bar) && bar >= 0 && bar < kBars) {
					if (!ParseBar(value, a_out.bars[static_cast<std::size_t>(bar)], a_error)) {
						return false;
					}
				}
			} else if (key == "npc"sv) {
				const auto f = Split(value, ',');
				if (f.size() < 3 || !ToInt(f[0], a_out.npc.x) || !ToInt(f[1], a_out.npc.y) || !ToInt(f[2], a_out.npc.stride)) {
					a_error = "the npc entry does not read";
					return false;
				}
			} else if (key.size() == 2 && key[0] == 'n' && key[1] >= '1' && key[1] <= '3') {
				a_out.npc.names[static_cast<std::size_t>(key[1] - '1')] = std::string{ value };
			} else if (key == "meters"sv) {
				const auto f = Split(value, ',');
				int        always = 0;
				if (f.size() < 5 || !ToInt(f[0], a_out.meters.x) || !ToInt(f[1], a_out.meters.y) || !ToInt(f[2], a_out.meters.scale) ||
					!ToInt(f[3], a_out.meters.rows) || !ToInt(f[4], always)) {
					a_error = "the meters entry does not read";
					return false;
				}
				a_out.meters.always = always != 0;
			}
		}
		if (!sawVersion) {
			a_error = "no layout version in the answer";
			return false;
		}
		return true;
	}
}
