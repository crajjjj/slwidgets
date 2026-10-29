#include "Natives.h"

namespace Natives
{
	namespace
	{
		constexpr auto kScript = "slw_bridge"sv;
		constexpr auto kIWantScript = "iWant_Status_Bars";
		constexpr auto kStepVariable = "BAR_SPACING_PERCENTAGE";

		// one flag per cause, so the first cause logged cannot hide another
		std::atomic<bool> g_warnedNoScript{ false };
		std::atomic<bool> g_warnedNoVariable{ false };
		std::atomic<bool> g_warnedNoStates{ false };
		std::atomic<bool> g_warnedNoLayout{ false };

		void WarnOnce(std::atomic<bool>& a_flag, std::string_view a_why)
		{
			if (!a_flag.exchange(true)) {
				logger::warn("iWant Status Bars is out of reach: {}", a_why);
			}
		}

		// The iWant_Status_Bars script object on a_bars, or null
		RE::BSTSmartPointer<RE::BSScript::Object> IWantObject(RE::TESQuest* a_bars)
		{
			RE::BSTSmartPointer<RE::BSScript::Object> object;
			if (!a_bars) {
				return object;
			}
			auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
			auto* policy = vm ? vm->GetObjectHandlePolicy() : nullptr;
			if (!policy) {
				return object;
			}
			const auto handle = policy->GetHandleForObject(a_bars->GetFormType(), a_bars);
			if (handle == policy->EmptyHandle() || !vm->FindBoundObject(handle, kIWantScript, object) || !object) {
				WarnOnce(g_warnedNoScript, "no iWant_Status_Bars script on the quest");
				object.reset();
			}
			return object;
		}

		// The step variable on a_object (which keeps it alive while it is used), or null
		RE::BSScript::Variable* StepVariable(const RE::BSTSmartPointer<RE::BSScript::Object>& a_object)
		{
			if (!a_object) {
				return nullptr;
			}
			auto* variable = a_object->GetVariable(RE::BSFixedString{ kStepVariable });
			if (!variable || !variable->IsFloat()) {
				// another iWant build: the slider then says it cannot set the spacing
				WarnOnce(g_warnedNoVariable, "iWant_Status_Bars has no Float BAR_SPACING_PERCENTAGE");
				return nullptr;
			}
			return variable;
		}

		// An Int[] or Bool[] script variable as ints; empty when it is missing or of
		// another type. Each element is a plain read of a value iWant writes on its
		// own thread: a change running at that moment is read before or after.
		std::vector<std::int32_t> ReadInts(const RE::BSTSmartPointer<RE::BSScript::Object>& a_object, std::string_view a_name)
		{
			std::vector<std::int32_t> values;
			const auto* variable = a_object ? a_object->GetVariable(RE::BSFixedString{ a_name }) : nullptr;
			if (!variable || !variable->IsArray()) {
				return values;
			}
			const auto array = variable->GetArray();
			if (!array) {
				return values;
			}
			values.reserve(array->size());
			for (std::uint32_t i = 0; i < array->size(); ++i) {
				const auto& element = (*array)[i];
				if (element.IsInt()) {
					values.push_back(element.GetSInt());
				} else if (element.IsBool()) {
					values.push_back(element.GetBool() ? 1 : 0);
				} else {
					return {};
				}
			}
			return values;
		}

		// The step, or 0.0 when it cannot be read
		float GetIWantIconStep(RE::StaticFunctionTag*, RE::TESQuest* a_bars)
		{
			const auto  object = IWantObject(a_bars);
			const auto* variable = StepVariable(object);
			return variable ? variable->GetFloat() : 0.0f;
		}

		// Writes the step; iWant uses it from its next draw. A plain store of a Float
		// iWant only reads: a draw running at that moment sees the old step or the new.
		bool SetIWantIconStep(RE::StaticFunctionTag*, RE::TESQuest* a_bars, float a_step)
		{
			if (!(a_step >= kMinIconStep && a_step <= kMaxIconStep)) {  // NaN fails too
				return false;
			}
			const auto object = IWantObject(a_bars);
			auto*      variable = StepVariable(object);
			if (!variable) {
				return false;
			}
			variable->SetFloat(a_step);
			return true;
		}

		// The stage iWant shows for an icon, or -1 when it cannot be read. -1 for a
		// negative icon too, which is how the scripts tell this native is bound: an
		// unbound one answers 0.
		std::int32_t GetIWantIconState(RE::StaticFunctionTag*, RE::TESQuest* a_bars, std::int32_t a_icon)
		{
			if (a_icon < 0) {
				return -1;
			}
			const auto object = IWantObject(a_bars);
			if (!object) {
				return -1;
			}
			const auto* variable = object->GetVariable(RE::BSFixedString{ "iconActiveStatus" });
			const auto  states = variable && variable->IsArray() ? variable->GetArray() : RE::BSTSmartPointer<RE::BSScript::Array>{};
			if (!states) {
				WarnOnce(g_warnedNoStates, "iWant_Status_Bars has no Int[] iconActiveStatus");
				return -1;
			}
			if (static_cast<std::uint32_t>(a_icon) >= states->size()) {
				return -1;
			}
			const auto& state = (*states)[static_cast<std::uint32_t>(a_icon)];
			return state.IsInt() ? state.GetSInt() : -1;
		}

		void Mix(std::uint32_t& a_hash, std::int32_t a_value)
		{
			auto v = static_cast<std::uint32_t>(a_value);
			for (int i = 0; i < 4; ++i) {
				a_hash ^= v & 0xFFu;
				a_hash *= 16777619u;  // FNV-1a
				v >>= 8;
			}
		}

		// One number per bar that changes whenever an idle stage of its icons would
		// stand at the wrong place: X, Y, shape, icon size, Skip Hidden Icons, the
		// icons in its seats and, for a line, the icon step. Empty when any of them
		// cannot be read.
		std::vector<std::int32_t> GetIWantBarSignatures(RE::StaticFunctionTag*, RE::TESQuest* a_bars)
		{
			const auto object = IWantObject(a_bars);
			if (!object) {
				return {};
			}
			const auto x = ReadInts(object, "statusBarX");
			const auto y = ReadInts(object, "statusBarY");
			const auto type = ReadInts(object, "statusBarTypeIndex");
			const auto size = ReadInts(object, "statusBarIconSize");
			const auto skip = ReadInts(object, "statusBarHideOnAlpha0");
			const auto seats = ReadInts(object, "statusBarIcon");
			const auto* step = StepVariable(object);
			const auto  bars = x.size();
			if (bars == 0 || y.size() != bars || type.size() != bars || size.size() != bars || skip.size() != bars ||
				!step || seats.empty() || seats.size() % bars != 0) {
				WarnOnce(g_warnedNoLayout, "a bar array of iWant_Status_Bars is missing or of another size");
				return {};
			}
			const auto perBar = seats.size() / bars;
			// the step as iWant applies it, to the pixel: (size * step) As Int
			const auto stepValue = step->GetFloat();

			std::vector<std::int32_t> signatures(bars);
			for (std::size_t b = 0; b < bars; ++b) {
				std::uint32_t hash = 2166136261u;
				Mix(hash, x[b]);
				Mix(hash, y[b]);
				Mix(hash, type[b]);
				Mix(hash, size[b]);
				Mix(hash, skip[b]);
				Mix(hash, type[b] < 4 ? static_cast<std::int32_t>(static_cast<float>(size[b]) * stepValue) : 0);
				for (std::size_t s = 0; s < perBar; ++s) {
					Mix(hash, seats[b * perBar + s]);
				}
				signatures[b] = static_cast<std::int32_t>(hash);
			}
			return signatures;
		}
	}

	bool Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		if (!a_vm) {
			return false;
		}
		// The readers only read script variables, so they run on the calling VM
		// thread instead of waiting a frame for the main thread each call.
		a_vm->RegisterFunction("GetIWantIconStep"sv, kScript, GetIWantIconStep, true);
		a_vm->RegisterFunction("SetIWantIconStep"sv, kScript, SetIWantIconStep);
		a_vm->RegisterFunction("GetIWantIconState"sv, kScript, GetIWantIconState, true);
		a_vm->RegisterFunction("GetIWantBarSignatures"sv, kScript, GetIWantBarSignatures, true);
		return true;
	}
}
