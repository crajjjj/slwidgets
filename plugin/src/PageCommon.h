#pragma once

// What every page draws with, and the read cycle the pages share. Inside a
// framework callback only (see Ui.h), under the page's own lock.

#include "Bridge.h"
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

	// ImGui pushes popped on every way out of a scope, an exception included: a
	// push left open breaks the framework's whole window at its End()
	class IdScope
	{
	public:
		explicit IdScope(int a_id) { Ui::PushID(a_id); }
		~IdScope() { Ui::PopID(); }
		IdScope(const IdScope&) = delete;
		IdScope& operator=(const IdScope&) = delete;
	};

	class DisabledScope
	{
	public:
		explicit DisabledScope(bool a_disabled) :
			_disabled(a_disabled)
		{
			if (_disabled) {
				Ui::BeginDisabled(true);
			}
		}
		~DisabledScope()
		{
			if (_disabled) {
				Ui::EndDisabled();
			}
		}
		DisabledScope(const DisabledScope&) = delete;
		DisabledScope& operator=(const DisabledScope&) = delete;

	private:
		bool _disabled;
	};

	class IndentScope
	{
	public:
		IndentScope() { Ui::Indent(0.0f); }
		~IndentScope() { Ui::Unindent(0.0f); }
		IndentScope(const IndentScope&) = delete;
		IndentScope& operator=(const IndentScope&) = delete;
	};

	// One page's read cycle: a read when the page comes up or comes back, a read
	// some time after a write, Refresh, and the status line.
	class PageState
	{
	public:
		PageState(Bridge::Query a_query, const char* a_what, const char* a_notRunning) :
			_query(a_query), _what(a_what), _notRunning(a_notRunning) {}

		// First thing in a frame. True when the page has just come up (no frame for
		// a while: it was left, or the menu closed); a read is then asked for.
		bool BeginFrame(double a_now)
		{
			const bool reopened = a_now - _lastFrame > kReopenGap;
			_lastFrame = a_now;
			if (reopened) {
				Request(a_now, true, true);
			}
			return reopened;
		}

		// Ask for a read now; a_announce says so in the status line (the user asked).
		// A read still out is not doubled; this one is then asked again shortly,
		// and LastRequestAt stays where it was: the answer coming predates now.
		void Request(double a_now, bool a_force, bool a_announce)
		{
			if (a_announce) {
				SetStatus(std::format("Reading the {}...", _what), false);
			}
			if (Bridge::Request(_query, a_force)) {
				_lastRequestAt = a_now;
			} else {
				_confirmAt = a_now + kRetryAfter;
			}
		}

		// The newest answer: true with a usable one in a_text. A timeout, an error
		// or a "not running" answer goes to the status line instead.
		bool Take(std::string& a_text)
		{
			std::string error;
			if (!Bridge::Take(_query, a_text, error)) {
				if (Bridge::Pending(_query) && Bridge::PendingSeconds(_query) > kAnswerTimeout) {
					SetStatus(std::format("SL Widgets has not answered for {:.0f} s. Is the mod enabled, with a game loaded? Refresh asks again.",
								  Bridge::PendingSeconds(_query)),
						true);
				}
				return false;
			}
			if (!error.empty()) {
				SetStatus(error, true);
				return false;
			}
			if (a_text.empty()) {
				SetStatus(_notRunning, true);
				return false;
			}
			return true;
		}

		// When the newest read was asked for: an answer is no newer than that
		double LastRequestAt() const { return _lastRequestAt; }

		void ConfirmAt(double a_at) { _confirmAt = a_at; }

		// Sends the read owed after a write once due, unless a_hold (then it waits)
		void ServeConfirm(double a_now, bool a_hold)
		{
			if (_confirmAt > 0.0 && a_now >= _confirmAt && !a_hold) {
				_confirmAt = 0.0;
				Request(a_now, false, false);
			}
		}

		void DrawStatusLine(double a_now)
		{
			Colored(_statusIsError ? kWarn : kOk, _status.c_str());
			Ui::SameLine(0.0f, -1.0f);
			if (Ui::SmallButton("Refresh")) {
				Request(a_now, true, true);
			}
		}

		void SetStatus(std::string a_text, bool a_error)
		{
			_status = std::move(a_text);
			_statusIsError = a_error;
		}

		// The next frame counts as the page coming up again
		void ForgetFrame() { _lastFrame = 0.0; }

		// A game is being loaded or started
		void Reset()
		{
			_status.clear();
			_statusIsError = false;
			_lastFrame = 0.0;
			_confirmAt = 0.0;
			_lastRequestAt = 0.0;
		}

	private:
		static constexpr double kReopenGap = 1.0;  // seconds without a frame: the page was left and came back
		static constexpr float  kAnswerTimeout = 6.0f;
		static constexpr double kRetryAfter = 1.0;  // seconds before a read that found one still out is asked again

		Bridge::Query _query;
		const char*   _what;
		const char*   _notRunning;
		std::string   _status;
		bool          _statusIsError = false;
		double        _lastFrame = 0.0;
		double        _confirmAt = 0.0;  // read again at this time; 0 = nothing owed
		double        _lastRequestAt = 0.0;
	};
}
