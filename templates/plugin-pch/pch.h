/**
 * @file pch.h
 * @brief Precompiled header for IDA plugin.
 *
 * This header includes stable IDA SDK headers that rarely change.
 * Using PCH significantly speeds up compilation by pre-parsing these headers.
 *
 * To disable PCH, configure with: cmake -B build -DUSE_PCH=OFF
 */
#pragma once

// Marker to indicate PCH is being used
#define PLUGIN_PCH_INCLUDED

// Standard Library Headers
#include <algorithm>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

// IDA SDK Core Headers
#include <pro.h>
#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>
#include <bytes.hpp>
#include <funcs.hpp>
#include <auto.hpp>
#include <nalt.hpp>
#include <netnode.hpp>
#include <segment.hpp>
#include <name.hpp>
#include <ua.hpp>
#include <xref.hpp>
