#pragma once

// Small string helpers for the strings the scripts send.

namespace Text
{
	inline std::vector<std::string_view> Split(std::string_view a_text, char a_sep)
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

	// a_text split at commas into a_count fields, the last taking the rest (free
	// text may hold commas); fewer when the text has fewer commas
	inline std::vector<std::string_view> Fields(std::string_view a_text, std::size_t a_count)
	{
		std::vector<std::string_view> out;
		std::size_t                   start = 0;
		while (out.size() + 1 < a_count) {
			const auto comma = a_text.find(',', start);
			if (comma == std::string_view::npos) {
				break;
			}
			out.push_back(a_text.substr(start, comma - start));
			start = comma + 1;
		}
		out.push_back(a_text.substr(std::min(start, a_text.size())));
		return out;
	}

	inline bool ToInt(std::string_view a_text, int& a_out)
	{
		const auto* begin = a_text.data();
		const auto* end = begin + a_text.size();
		const auto [ptr, ec] = std::from_chars(begin, end, a_out);
		return ec == std::errc{} && ptr == end;
	}

	inline std::string Lower(std::string_view a_text)
	{
		std::string out{ a_text };
		std::transform(out.begin(), out.end(), out.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
		return out;
	}
}
