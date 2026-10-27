#include "Bridge.h"

namespace Bridge
{
	namespace
	{
		using Clock = std::chrono::steady_clock;

		constexpr auto kScript = "slw_bridge"sv;

		std::mutex                 g_lock;
		std::string                g_layout;  // the newest answer
		std::string                g_error;   // why there is none
		bool                       g_fresh = false;  // an answer waits to be taken
		std::atomic<bool>          g_inFlight{ false };
		std::atomic<std::uint32_t> g_generation{ 0 };  // bumped when the VM resets
		std::atomic<std::int64_t>  g_sentAt{ 0 };      // Clock ticks of the last request

		std::int64_t Now()
		{
			return Clock::now().time_since_epoch().count();
		}

		void Deliver(std::string a_layout, std::string a_error)
		{
			std::scoped_lock lock{ g_lock };
			g_layout = std::move(a_layout);
			g_error = std::move(a_error);
			g_fresh = true;
			g_inFlight.store(false);
		}

		// The answer of GetLayout. Runs on a VM thread, so it hands the string over
		// under the lock and touches nothing else.
		class LayoutResult : public RE::BSScript::IStackCallbackFunctor
		{
		public:
			explicit LayoutResult(std::uint32_t a_generation) :
				_generation(a_generation) {}

			void operator()(RE::BSScript::Variable a_result) override
			{
				if (_generation != g_generation.load()) {
					return;  // from before a load: not about the VM that is running now
				}
				if (a_result.IsString()) {
					Deliver(std::string{ a_result.GetString() }, {});
				} else {
					Deliver({}, "SL Widgets answered without a layout");
				}
			}

			void SetObject(const RE::BSTSmartPointer<RE::BSScript::Object>&) override {}

		private:
			std::uint32_t _generation;
		};

		// Queues one static call of slw_bridge on the game thread. Integer arguments
		// only, copied into the task. The argument object is never deleted here: who
		// owns it after the call is not documented, and a few bytes per call is the
		// only safe side of that.
		template <class... Args>
		void Call(std::string_view a_function, RE::BSScript::IStackCallbackFunctor* a_callback, Args... a_args)
		{
			const auto* tasks = SKSE::GetTaskInterface();
			if (!tasks) {
				if (a_callback) {
					delete a_callback;
					Deliver({}, "no SKSE task interface");
				}
				return;
			}
			tasks->AddTask([=]() {
				RE::BSTSmartPointer<RE::BSScript::IStackCallbackFunctor> callback{ a_callback };
				auto* vm = RE::BSScript::Internal::VirtualMachine::GetSingleton();
				if (!vm) {
					if (a_callback) {
						Deliver({}, "no Papyrus VM");
					}
					return;
				}
				auto* args = RE::MakeFunctionArguments(static_cast<std::int32_t>(a_args)...);
				if (vm->DispatchStaticCall(RE::BSFixedString{ kScript }, RE::BSFixedString{ a_function }, args, callback)) {
					return;
				}
				logger::warn("slw_bridge.{} was refused by the VM: slw_bridge.pex missing, or from another SL Widgets build", a_function);
				if (a_callback) {
					Deliver({}, "slw_bridge.pex did not answer: install the SL Widgets scripts of the same release as the DLL");
				}
			});
		}
	}

	void RequestLayout(bool a_force)
	{
		if (!a_force && g_inFlight.exchange(true)) {
			return;
		}
		g_inFlight.store(true);
		g_sentAt.store(Now());
		Call("GetLayout"sv, new LayoutResult(g_generation.load()));
	}

	bool Take(std::string& a_layout, std::string& a_error)
	{
		std::scoped_lock lock{ g_lock };
		if (!g_fresh) {
			return false;
		}
		g_fresh = false;
		a_layout = g_layout;
		a_error = g_error;
		return true;
	}

	bool Pending()
	{
		return g_inFlight.load();
	}

	float PendingSeconds()
	{
		if (!g_inFlight.load()) {
			return 0.0f;
		}
		return std::chrono::duration<float>(Clock::duration{ Now() - g_sentAt.load() }).count();
	}

	void OnVmReset()
	{
		++g_generation;
		std::scoped_lock lock{ g_lock };
		g_fresh = false;
		g_layout.clear();
		g_error.clear();
		g_inFlight.store(false);
	}

	void SetBarPos(int a_bar, int a_x, int a_y)
	{
		Call("SetBarPos"sv, nullptr, a_bar, a_x, a_y);
	}

	void SetBarSize(int a_bar, int a_size)
	{
		Call("SetBarSize"sv, nullptr, a_bar, a_size);
	}

	void SetBarType(int a_bar, int a_type)
	{
		Call("SetBarType"sv, nullptr, a_bar, a_type);
	}

	void SetNpcGroup(int a_x, int a_y)
	{
		Call("SetNpcGroup"sv, nullptr, a_x, a_y);
	}

	void SetNpcSpacing(int a_spacing)
	{
		Call("SetNpcSpacing"sv, nullptr, a_spacing);
	}

	void SetMeters(int a_x, int a_y, int a_scale)
	{
		Call("SetMeters"sv, nullptr, a_x, a_y, a_scale);
	}

	void ResetNpcLayout()
	{
		Call("ResetNpcLayout"sv, nullptr);
	}
}
