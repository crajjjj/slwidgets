#pragma once

// The SL Widgets layout as slw_widget_controller.editorLayout() reports it, in
// stage units (iWant's fixed 1280x720 Flash stage; positions are widget centers).

namespace Layout
{
	constexpr int kVersion = 1;  // slw_widget_controller.editorLayout's "v="
	constexpr int kBars = 10;    // iWant TOTAL_STATUS_BARS
	constexpr int kPlayerBars = 4;  // bars 0-3 hold the player's icons and belong to iWant; 4-9 are the NPC slots', laid out from the cluster anchor
	constexpr int kNpcSlots = 3;
	constexpr int kOrientations = 10;  // iWant bar types: 0 left, 1 right, 2 up, 3 down, 4 circle, 5 orbit, 6-9 half circles

	// What the mod accepts: iWant's locked slider range and the SL Widgets MCM's
	constexpr int kMinX = -1280, kMaxX = 2559;
	constexpr int kMinY = -720, kMaxY = 1439;
	constexpr int kMinBarSize = 8, kMaxBarSize = 100;
	constexpr int kMinNpcSpacing = 50, kMaxNpcSpacing = 200;
	constexpr int kMaxMetersY = 719;  // the MCM's slider must still be able to show the value
	constexpr int kMinMetersScale = 20, kMaxMetersScale = 200;

	struct Bar
	{
		int  x = 640;
		int  y = 360;
		int  type = 0;
		int  size = 25;
		bool visible = true;  // iWant's own show/hide; a hidden bar takes a move all the same
	};

	struct Npc
	{
		int                                x = 1100;  // slot 1's primary bar anchor; slots 2-3 stack upward by stride
		int                                y = 600;
		int                                stride = 105;
		std::array<std::string, kNpcSlots> names;  // the actor in each slot, "" when empty
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

	int Clamp(int a_v, int a_min, int a_max);
}
