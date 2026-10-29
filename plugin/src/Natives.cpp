#include "Natives.h"

namespace Natives
{
	namespace
	{
		constexpr auto kScript = "slw_bridge"sv;
		constexpr auto kIWantScript = "iWant_Status_Bars";
		constexpr auto kStepVariable = "BAR_SPACING_PERCENTAGE";
		constexpr auto kStateVariable = "iconActiveStatus";

		// one flag per cause, so the first cause logged cannot hide another
		std::atomic<bool> g_warnedNoScript{ false };
		std::atomic<bool> g_warnedNoVariable{ false };
		std::atomic<bool> g_warnedNoStates{ false };

		void WarnOnce(std::atomic<bool>& a_flag, std::string_view a_why)
		{
			if (!a_flag.exchange(true)) {
				logger::warn("iWant Status Bars is out of reach: {}", a_why);
			}
		}

		// The named variable of the iWant_Status_Bars script on a_bars, or null. The
		// object pointer keeps the script object alive while the variable is used.
		RE::BSScript::Variable* IWantVariable(RE::TESQuest* a_bars, std::string_view a_name, RE::BSTSmartPointer<RE::BSScript::Object>& a_object)
		{
			if (!a_bars) {
				return nullptr;
			}
			auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
			auto* policy = vm ? vm->GetObjectHandlePolicy() : nullptr;
			if (!policy) {
				return nullptr;
			}
			const auto handle = policy->GetHandleForObject(a_bars->GetFormType(), a_bars);
			if (handle == policy->EmptyHandle() || !vm->FindBoundObject(handle, kIWantScript, a_object) || !a_object) {
				WarnOnce(g_warnedNoScript, "no iWant_Status_Bars script on the quest");
				return nullptr;
			}
			return a_object->GetVariable(RE::BSFixedString{ a_name });
		}

		RE::BSScript::Variable* StepVariable(RE::TESQuest* a_bars, RE::BSTSmartPointer<RE::BSScript::Object>& a_object)
		{
			auto* variable = IWantVariable(a_bars, kStepVariable, a_object);
			if (a_object && (!variable || !variable->IsFloat())) {
				// another iWant build: the slider then says it cannot set the spacing
				WarnOnce(g_warnedNoVariable, "iWant_Status_Bars has no Float BAR_SPACING_PERCENTAGE");
				return nullptr;
			}
			return variable;
		}

		// The step, or 0.0 when it cannot be read
		float GetIWantIconStep(RE::StaticFunctionTag*, RE::TESQuest* a_bars)
		{
			RE::BSTSmartPointer<RE::BSScript::Object> object;
			const auto*                               variable = StepVariable(a_bars, object);
			return variable ? variable->GetFloat() : 0.0f;
		}

		// Writes the step; iWant uses it from its next draw. A plain store of a Float
		// iWant only reads: a draw running at that moment sees the old step or the new.
		bool SetIWantIconStep(RE::StaticFunctionTag*, RE::TESQuest* a_bars, float a_step)
		{
			if (!(a_step >= kMinIconStep && a_step <= kMaxIconStep)) {  // NaN fails too
				return false;
			}
			RE::BSTSmartPointer<RE::BSScript::Object> object;
			auto*                                     variable = StepVariable(a_bars, object);
			if (!variable) {
				return false;
			}
			variable->SetFloat(a_step);
			return true;
		}

		// The stage iWant shows for an icon, or -1 when it cannot be read. A read of
		// an Int iWant writes on its own thread: the answer is the stage before a
		// change running at that moment or the one after.
		std::int32_t GetIWantIconState(RE::StaticFunctionTag*, RE::TESQuest* a_bars, std::int32_t a_icon)
		{
			if (a_icon < 0) {
				return -1;
			}
			RE::BSTSmartPointer<RE::BSScript::Object> object;
			const auto*                               variable = IWantVariable(a_bars, kStateVariable, object);
			if (!object) {
				return -1;
			}
			RE::BSTSmartPointer<RE::BSScript::Array> states;
			if (variable && variable->IsArray()) {
				states = variable->GetArray();
			}
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
	}

	bool Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		if (!a_vm) {
			return false;
		}
		a_vm->RegisterFunction("GetIWantIconStep"sv, kScript, GetIWantIconStep);
		a_vm->RegisterFunction("SetIWantIconStep"sv, kScript, SetIWantIconStep);
		a_vm->RegisterFunction("GetIWantIconState"sv, kScript, GetIWantIconState);
		return true;
	}
}
