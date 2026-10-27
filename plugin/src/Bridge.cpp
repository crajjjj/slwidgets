#include "Bridge.h"

namespace Bridge
{
	namespace
	{
		using Clock = std::chrono::steady_clock;

		constexpr auto kScript = "slw_bridge"sv;
		constexpr auto kQueries = static_cast<std::size_t>(Query::kCount);
		constexpr std::array<std::string_view, kQueries> kQueryFunctions{ "GetLayout"sv, "GetToggles"sv, "GetPresets"sv, "GetGeneral"sv, "GetMeters"sv, "GetNpc"sv, "GetBarIcons"sv };

		struct Slot
		{
			std::string               text;          // the newest answer
			std::string               error;         // why there is none
			bool                      fresh = false;  // an answer waits to be taken
			std::atomic<bool>         inFlight{ false };
			std::atomic<std::int64_t> sentAt{ 0 };  // Clock ticks of the last request
		};

		std::mutex                     g_lock;  // text, error and fresh of every slot
		std::array<Slot, kQueries>     g_slots;
		std::atomic<std::uint32_t>     g_generation{ 0 };  // bumped when the VM resets

		std::int64_t Now()
		{
			return Clock::now().time_since_epoch().count();
		}

		Slot& SlotOf(Query a_query)
		{
			return g_slots[static_cast<std::size_t>(a_query)];
		}

		void Deliver(Query a_query, std::string a_text, std::string a_error)
		{
			std::scoped_lock lock{ g_lock };
			auto&            slot = SlotOf(a_query);
			slot.text = std::move(a_text);
			slot.error = std::move(a_error);
			slot.fresh = true;
			slot.inFlight.store(false);
		}

		// The answer of a query. Runs on a VM thread, so it hands the string over
		// under the lock and touches nothing else.
		class StringResult : public RE::BSScript::IStackCallbackFunctor
		{
		public:
			StringResult(Query a_query, std::uint32_t a_generation) :
				_query(a_query), _generation(a_generation) {}

			void operator()(RE::BSScript::Variable a_result) override
			{
				if (_generation != g_generation.load()) {
					return;  // from before a load: not about the VM that is running now
				}
				if (a_result.IsString()) {
					Deliver(_query, std::string{ a_result.GetString() }, {});
				} else {
					Deliver(_query, {}, "SL Widgets answered with no data");
				}
			}

			void SetObject(const RE::BSTSmartPointer<RE::BSScript::Object>&) override {}

		private:
			Query         _query;
			std::uint32_t _generation;
		};

		// What a C++ argument becomes for the VM
		std::int32_t      Arg(int a_value) { return a_value; }
		bool              Arg(bool a_value) { return a_value; }
		RE::BSFixedString Arg(const std::string& a_value) { return RE::BSFixedString{ a_value }; }

		// Queues one static call of slw_bridge on the game thread. With a_query,
		// its answer is delivered to that query, a failure as its error. The
		// argument object is never deleted here: who owns it after the call is not
		// documented, and a few bytes per call is the only safe side of that.
		template <class... Args>
		void Call(std::string_view a_function, std::optional<Query> a_query, Args... a_args)
		{
			const auto* tasks = SKSE::GetTaskInterface();
			if (!tasks) {
				if (a_query) {
					Deliver(*a_query, {}, "no SKSE task interface");
				}
				return;
			}
			const auto generation = g_generation.load();
			tasks->AddTask([=]() {
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				if (!vm) {
					if (a_query) {
						Deliver(*a_query, {}, "no Papyrus VM");
					}
					return;
				}
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback;
				if (a_query) {
					callback.reset(new StringResult(*a_query, generation));
				}
				auto* args = RE::MakeFunctionArguments(Arg(a_args)...);
				if (vm->DispatchStaticCall(RE::BSFixedString{ kScript }, RE::BSFixedString{ a_function }, args, callback)) {
					return;
				}
				logger::warn("slw_bridge.{} was refused by the VM: slw_bridge.pex missing, or from another SL Widgets build", a_function);
				if (a_query) {
					Deliver(*a_query, {}, "slw_bridge.pex did not answer: install the SL Widgets scripts of the same release as the DLL");
				}
			});
		}
	}

	bool Request(Query a_query, bool a_force)
	{
		auto& slot = SlotOf(a_query);
		if (!a_force && slot.inFlight.exchange(true)) {
			return false;
		}
		slot.inFlight.store(true);
		slot.sentAt.store(Now());
		Call(kQueryFunctions[static_cast<std::size_t>(a_query)], a_query);
		return true;
	}

	bool Take(Query a_query, std::string& a_text, std::string& a_error)
	{
		std::scoped_lock lock{ g_lock };
		auto&            slot = SlotOf(a_query);
		if (!slot.fresh) {
			return false;
		}
		slot.fresh = false;
		a_text = slot.text;
		a_error = slot.error;
		return true;
	}

	bool Pending(Query a_query)
	{
		return SlotOf(a_query).inFlight.load();
	}

	float PendingSeconds(Query a_query)
	{
		const auto& slot = SlotOf(a_query);
		if (!slot.inFlight.load()) {
			return 0.0f;
		}
		return std::chrono::duration<float>(Clock::duration{ Now() - slot.sentAt.load() }).count();
	}

	void OnVmReset()
	{
		++g_generation;
		std::scoped_lock lock{ g_lock };
		for (auto& slot : g_slots) {
			slot.fresh = false;
			slot.text.clear();
			slot.error.clear();
			slot.inFlight.store(false);
		}
	}

	void SetBarPos(int a_bar, int a_x, int a_y)
	{
		Call("SetBarPos"sv, std::nullopt, a_bar, a_x, a_y);
	}

	void SetBarSize(int a_bar, int a_size)
	{
		Call("SetBarSize"sv, std::nullopt, a_bar, a_size);
	}

	void SetBarType(int a_bar, int a_type)
	{
		Call("SetBarType"sv, std::nullopt, a_bar, a_type);
	}

	void MoveIconInBar(int a_bar, int a_seat, int a_icon, int a_dir)
	{
		Call("MoveIconInBar"sv, std::nullopt, a_bar, a_seat, a_icon, a_dir);
	}

	void MoveIconToBar(int a_bar, int a_seat, int a_icon, int a_target)
	{
		Call("MoveIconToBar"sv, std::nullopt, a_bar, a_seat, a_icon, a_target);
	}

	void SetNpcGroup(int a_x, int a_y)
	{
		Call("SetNpcGroup"sv, std::nullopt, a_x, a_y);
	}

	void SetNpcSpacing(int a_spacing)
	{
		Call("SetNpcSpacing"sv, std::nullopt, a_spacing);
	}

	void SetMeters(int a_x, int a_y, int a_scale)
	{
		Call("SetMeters"sv, std::nullopt, a_x, a_y, a_scale);
	}

	void ResetNpcLayout()
	{
		Call("ResetNpcLayout"sv, std::nullopt);
	}

	void SetToggle(const std::string& a_key, bool a_value)
	{
		Call("SetToggle"sv, std::nullopt, a_key, a_value);
	}

	void LoadPreset(const std::string& a_name)
	{
		Call("LoadPreset"sv, std::nullopt, a_name);
	}

	void SavePreset(const std::string& a_name)
	{
		Call("SavePreset"sv, std::nullopt, a_name);
	}

	void SetSetting(const std::string& a_key, const std::string& a_value)
	{
		Call("SetSetting"sv, std::nullopt, a_key, a_value);
	}

	void ReportMenu(int a_report)
	{
		Call("SetMenuReport"sv, std::nullopt, a_report);
	}
}
