#pragma once

// The SL Widgets layout as slw_widget_controller.editorLayout() reports it, and the
// geometry of what iWant draws from it. No game, no ImGui: the maths mirrors
// iwant_status_bars._drawBar and slw_widget_controller._buildMeters, in stage
// units, iWant's fixed 1280x720 Flash stage (positions are widget centers).

namespace Layout
{
	constexpr int kVersion = 1;  // slw_widget_controller.editorLayout's "v="
	constexpr int kBars = 10;    // iWant TOTAL_STATUS_BARS
	constexpr int kPlayerBars = 4;  // bars 0-3 hold the player's icons and belong to iWant; 4-9 are the NPC slots'
	constexpr int kNpcSlots = 3;
	constexpr int kStageW = 1280;
	constexpr int kStageH = 720;
	constexpr int kNpcBarGap = 40;  // slw_widget_controller NPC_BAR_VSPACING: the overflow bar sits this far under the primary
	constexpr int kNpcIconSize = 18;  // NPC_DEFAULT_ICON_SIZE, fixed by _layoutNpcBars

	// What the mod accepts (iWant's locked slider range and the SL Widgets MCM)
	constexpr int kMinX = -1280, kMaxX = 2559;
	constexpr int kMinY = -720, kMaxY = 1439;
	constexpr int kMinBarSize = 8, kMaxBarSize = 100;
	constexpr int kMinMetersScale = 20, kMaxMetersScale = 200;

	struct Rect
	{
		float x0 = 0, y0 = 0, x1 = 0, y1 = 0;

		bool Contains(float a_x, float a_y) const { return a_x >= x0 && a_x <= x1 && a_y >= y0 && a_y <= y1; }
		void Include(const Rect& a_other);
	};

	struct Bar
	{
		int                      x = 640;
		int                      y = 360;
		int                      type = 0;  // 0 left, 1 right, 2 up, 3 down, 4 circle, 5 orbit, 6-9 half circles (lower, upper, left, right)
		int                      size = 25;
		bool                     visible = true;
		std::vector<std::string> files;  // the icons' state-0 art, Interface\exported relative, in bar order
	};

	struct Npc
	{
		int                                 x = 1100;  // slot 1's primary bar anchor; slots 2-3 stack upward by stride
		int                                 y = 600;
		int                                 stride = 105;
		std::array<std::string, kNpcSlots>  names;  // the actor in each slot, "" when empty
	};

	struct Meters
	{
		int  x = 1150;  // the stack's center
		int  y = 360;
		int  scale = 60;  // percent
		int  rows = 0;    // meters switched on whose mod is loaded
		bool always = false;
	};

	struct Model
	{
		std::array<Bar, kBars> bars;
		Npc                    npc;
		Meters                 meters;
	};

	// Parses editorLayout's string. False, with a_error, on a version the parser
	// does not know or a value that does not read; what parsed before that stays.
	bool Parse(std::string_view a_text, Model& a_out, std::string& a_error);

	struct IconSlot
	{
		float cx, cy, size;
	};

	// Where a bar's icons sit; at least one slot, so an empty bar still has a footprint
	std::vector<IconSlot> IconSlots(const Bar& a_bar);
	Rect                  Footprint(const Bar& a_bar);

	struct MeterRow
	{
		float cx, cy, w, h;  // the bar
		float iconCx, iconSize;  // the icon to its left
	};

	// The stack's rows, top first; at least one, so a stack with nothing switched on still has a footprint
	std::vector<MeterRow> MeterRows(const Meters& a_m);
	Rect                  MetersFootprint(const Meters& a_m);

	// NPC slot n (1-3) owns bars 2n+2 (primary) and 2n+3 (overflow)
	int PrimaryBar(int a_slot);
	int SecondaryBar(int a_slot);
	int SlotOfBar(int a_bar);  // 0 for a player bar

	// Puts the NPC bars where _layoutNpcBars would from the anchor, for a preview
	void ApplyNpcAnchor(Model& a_model);

	int Clamp(int a_v, int a_min, int a_max);
}
