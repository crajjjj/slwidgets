#include "Bridge.h"
#include "Env.h"
#include "Menu.h"
#include "PositionsPage.h"
#include "PresetsPage.h"
#include "SettingsPage.h"
#include "TogglesPage.h"

#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>

using namespace SKSE;

// SLWidgetsMenu.dll - the SL Widgets pages in SKSE Menu Framework's menu.
// It is a convenience on top of a mod that runs entirely without it, so nothing
// in here may take the game down: no report_and_fail, and a step that fails only
// disables the page.

namespace
{
	bool InitializeLogging()
	{
		auto path = log::log_directory();
		if (!path) {
			return false;
		}
		*path /= PluginDeclaration::GetSingleton()->GetName();
		*path += L".log";

		std::shared_ptr<spdlog::logger> logger;
		if (IsDebuggerPresent()) {
			logger = std::make_shared<spdlog::logger>(
				"Global", std::make_shared<spdlog::sinks::msvc_sink_mt>());
		} else {
			logger = std::make_shared<spdlog::logger>(
				"Global", std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true));
		}
		logger->set_level(spdlog::level::info);
		logger->flush_on(spdlog::level::info);

		spdlog::set_default_logger(std::move(logger));
		spdlog::set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%l] %v");
		return true;
	}

	void OnMessage(MessagingInterface::Message* a_msg)
	{
		try {
			switch (a_msg->type) {
			case MessagingInterface::kPostPostLoad:
				// every SKSE plugin is loaded by now, and the framework has not started
				// rendering: its registration lists are unlocked, and the loading
				// screen already renders at kDataLoaded
				Env::Detect();
				Menu::Register();
				break;
			case MessagingInterface::kNewGame:
			case MessagingInterface::kPostLoadGame:
				// the MCM's status line: are the pages up, or does the framework lack what they need
				if (::GetModuleHandleW(L"SKSEMenuFramework")) {
					Bridge::ReportMenu(Env::Get().frameworkOk ? 1 : 2);
				}
				[[fallthrough]];
			case MessagingInterface::kPreLoadGame:
				// the VM is reset: an answer on its way is gone, the layout belongs to the old game
				Bridge::OnVmReset();
				Positions::OnVmReset();
				Toggles::OnVmReset();
				Presets::OnVmReset();
				Settings::OnVmReset();
				break;
			default:
				break;
			}
		} catch (...) {
			log::error("message {} failed", a_msg ? a_msg->type : 0);
		}
	}
}

SKSEPluginLoad(const LoadInterface* a_skse)
{
	try {
		InitializeLogging();
	} catch (...) {
		// no log is not a reason to refuse to load
	}

	const auto* plugin = PluginDeclaration::GetSingleton();
	log::info("{} v{} is loading...", plugin->GetName(), plugin->GetVersion());

	// false: SKSE::Init would otherwise set up a logger of its own on top of ours,
	// and that one throws inside a noexcept function when the log cannot be created
	Init(a_skse, false);

	if (const auto* messaging = GetMessagingInterface()) {
		messaging->RegisterListener(OnMessage);
	}

	log::info("{} loaded.", plugin->GetName());
	return true;
}
