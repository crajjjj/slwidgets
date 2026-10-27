#include "Layout.h"

#include <numbers>

namespace Layout
{
	namespace
	{
		constexpr float kPi = std::numbers::pi_v<float>;

		// iwant_status_bars constants
		constexpr float kBarSpacing = 1.5f;  // BAR_SPACING_PERCENTAGE: icon pitch on a line, in icon sizes
		// slw_widget_controller meter constants, at 100%
		constexpr int kMeterW = 334;
		constexpr int kMeterH = 30;
		constexpr int kMeterIcon = 48;
		constexpr int kMeterIconGap = 6;
		constexpr int kMeterPitch = 56;

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

		// "x,y,type,size,visible,file;file" - the files are last and may be absent
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
			a_bar.files.clear();
			if (fields.size() > 5) {
				for (const auto file : Split(fields[5], ';')) {
					if (!file.empty()) {
						a_bar.files.emplace_back(file);
					}
				}
			}
			return true;
		}

		Rect SquareAround(float a_cx, float a_cy, float a_size)
		{
			const float h = a_size * 0.5f;
			return { a_cx - h, a_cy - h, a_cx + h, a_cy + h };
		}
	}

	void Rect::Include(const Rect& a_other)
	{
		x0 = std::min(x0, a_other.x0);
		y0 = std::min(y0, a_other.y0);
		x1 = std::max(x1, a_other.x1);
		y1 = std::max(y1, a_other.y1);
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
					a_error = std::format("slw_widget_controller reports layout version {} but the DLL reads {}: update both from the same release", std::string{ value }, kVersion);
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

	std::vector<IconSlot> IconSlots(const Bar& a_bar)
	{
		const auto  n = std::max<std::size_t>(1, a_bar.files.size());
		const float size = static_cast<float>(std::max(1, a_bar.size));
		const float x = static_cast<float>(a_bar.x);
		const float y = static_cast<float>(a_bar.y);
		std::vector<IconSlot> out;
		out.reserve(n);
		if (a_bar.type <= 3) {
			// a line: the first icon on the anchor, the rest `change` apart in the bar's direction
			const float change = static_cast<float>(static_cast<int>(size * kBarSpacing));
			const float dx = a_bar.type == 0 ? -change : a_bar.type == 1 ? change : 0.0f;
			const float dy = a_bar.type == 2 ? -change : a_bar.type == 3 ? change : 0.0f;
			for (std::size_t i = 0; i < n; ++i) {
				out.push_back({ x + dx * i, y + dy * i, size });
			}
			return out;
		}
		// rings: iWant's drawShapeCircle spreads the icons over the arc; the angle
		// origin and direction are a reading of the type names, not of its code,
		// so the ring's extent is right and an icon's exact seat is approximate
		float       radius = size * 2.0f;
		float       start = 0.0f;
		float       sweep = 2.0f * kPi;
		std::size_t first = 0;
		if (a_bar.type == 5) {
			// orbit: the first icon sits in the middle at twice the size
			out.push_back({ x, y, size * 2.0f });
			first = 1;
		} else if (a_bar.type >= 6) {
			radius = size * 3.0f;
			sweep = kPi;
			start = a_bar.type == 7 ? kPi : a_bar.type == 8 ? kPi * 0.5f : a_bar.type == 9 ? kPi * 1.5f : 0.0f;
		}
		const std::size_t onRing = n - first;
		for (std::size_t i = 0; i < onRing; ++i) {
			const float step = sweep >= 2.0f * kPi ? sweep / static_cast<float>(onRing) : sweep / static_cast<float>(std::max<std::size_t>(1, onRing - 1));
			const float a = start + step * static_cast<float>(i);
			out.push_back({ x + radius * std::cos(a), y + radius * std::sin(a), size });
		}
		return out;
	}

	Rect Footprint(const Bar& a_bar)
	{
		const auto slots = IconSlots(a_bar);
		Rect       r = SquareAround(slots[0].cx, slots[0].cy, slots[0].size);
		for (const auto& s : slots) {
			r.Include(SquareAround(s.cx, s.cy, s.size));
		}
		return r;
	}

	std::vector<MeterRow> MeterRows(const Meters& a_m)
	{
		// _buildMeters, integer maths as the script does it
		const int   rows = std::max(1, a_m.rows);
		const int   pitch = kMeterPitch * a_m.scale / 100;
		const int   iconSize = kMeterIcon * a_m.scale / 100;
		const int   width = kMeterW * a_m.scale / 100;
		const int   height = kMeterH * a_m.scale / 100;
		const int   iconX = a_m.x - width / 2 - iconSize / 2 - kMeterIconGap;
		const int   y0 = a_m.y - (rows - 1) * pitch / 2;
		std::vector<MeterRow> out;
		out.reserve(static_cast<std::size_t>(rows));
		for (int i = 0; i < rows; ++i) {
			out.push_back({ static_cast<float>(a_m.x), static_cast<float>(y0 + i * pitch), static_cast<float>(width), static_cast<float>(height),
				static_cast<float>(iconX), static_cast<float>(iconSize) });
		}
		return out;
	}

	Rect MetersFootprint(const Meters& a_m)
	{
		const auto rows = MeterRows(a_m);
		Rect       r = SquareAround(rows[0].iconCx, rows[0].cy, rows[0].iconSize);
		for (const auto& row : rows) {
			r.Include(SquareAround(row.iconCx, row.cy, row.iconSize));
			r.Include({ row.cx - row.w * 0.5f, row.cy - row.h * 0.5f, row.cx + row.w * 0.5f, row.cy + row.h * 0.5f });
		}
		return r;
	}

	int PrimaryBar(int a_slot)
	{
		return a_slot * 2 + 2;
	}

	int SecondaryBar(int a_slot)
	{
		return PrimaryBar(a_slot) + 1;
	}

	int SlotOfBar(int a_bar)
	{
		return a_bar < kPlayerBars ? 0 : (a_bar - 2) / 2;
	}

	void ApplyNpcAnchor(Model& a_model)
	{
		for (int slot = 1; slot <= kNpcSlots; ++slot) {
			auto& primary = a_model.bars[static_cast<std::size_t>(PrimaryBar(slot))];
			auto& secondary = a_model.bars[static_cast<std::size_t>(SecondaryBar(slot))];
			const int baseY = a_model.npc.y - (slot - 1) * a_model.npc.stride;
			primary.x = a_model.npc.x;
			primary.y = baseY;
			secondary.x = a_model.npc.x;
			secondary.y = baseY + kNpcBarGap;
		}
	}
}
