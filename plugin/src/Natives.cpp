#include "Natives.h"

namespace Natives
{
	namespace
	{
		constexpr auto kScript = "slw_bridge"sv;
		constexpr auto kIWantScript = "iWant_Status_Bars";
		constexpr auto kStepVariable = "BAR_SPACING_PERCENTAGE";

		std::atomic<bool> g_warned{ false };

		void WarnOnce(std::string_view a_why)
		{
			if (!g_warned.exchange(true)) {
				logger::warn("iWant's icon step is out of reach: {}", a_why);
			}
		}

		// The step variable of the iWant_Status_Bars script on a_bars, or null. The
		// object pointer keeps the script object alive while the variable is used.
		RE::BSScript::Variable* StepVariable(RE::TESQuest* a_bars, RE::BSTSmartPointer<RE::BSScript::Object>& a_object)
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
				WarnOnce("no iWant_Status_Bars script on the quest");
				return nullptr;
			}
			auto* variable = a_object->GetVariable(RE::BSFixedString{ kStepVariable });
			if (!variable || !variable->IsFloat()) {
				// another iWant build: the slider then says it cannot set the spacing
				WarnOnce("iWant_Status_Bars has no Float BAR_SPACING_PERCENTAGE");
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
	}

	bool Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		if (!a_vm) {
			return false;
		}
		a_vm->RegisterFunction("GetIWantIconStep"sv, kScript, GetIWantIconStep);
		a_vm->RegisterFunction("SetIWantIconStep"sv, kScript, SetIWantIconStep);
		return true;
	}
}
