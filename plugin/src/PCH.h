#pragma once

#include <RE/Skyrim.h>
#include <SKSE/SKSE.h>

// CommonLib v7 (REX) pulls real <Windows.h> into the include chain; scrub the
// macro collisions we actually hit (min/max are handled by NOMINMAX in xmake.lua)
#undef GetObject

#include <algorithm>
#include <array>
#include <atomic>
#include <charconv>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <filesystem>
#include <format>
#include <mutex>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

using namespace std::literals;

namespace logger = SKSE::log;
