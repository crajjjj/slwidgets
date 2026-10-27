#pragma once

// Bits every page draws with. Inside a framework callback only (see Ui.h).

#include "Ui.h"

namespace PageCommon
{
	inline const Ui::ImVec4 kWarn{ 1.0f, 0.5f, 0.4f, 1.0f };
	inline const Ui::ImVec4 kHint{ 0.7f, 0.7f, 0.7f, 1.0f };
	inline const Ui::ImVec4 kOk{ 0.6f, 0.9f, 0.6f, 1.0f };

	inline void Colored(const Ui::ImVec4& a_color, const char* a_text)
	{
		Ui::PushStyleColor(Ui::ImGuiCol_Text, a_color);
		Ui::TextUnformatted(a_text);
		Ui::PopStyleColor(1);
	}

	// A wrapped tooltip for the last item, disabled items included
	inline void Tooltip(const std::string& a_text)
	{
		if (a_text.empty() || !Ui::IsItemHovered(Ui::ImGuiHoveredFlags_AllowWhenDisabled)) {
			return;
		}
		if (Ui::BeginTooltip()) {
			Ui::PushTextWrapPos(Ui::GetFontSize() * 28.0f);
			Ui::TextUnformatted(a_text.c_str());
			Ui::PopTextWrapPos();
			Ui::EndTooltip();
		}
	}
}
