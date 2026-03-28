// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) Elias Bachaalany

/**
 * @file plugin.h
 * @brief Plugin header - declarations and constants.
 *
 * Note: Most includes come from pch.h (precompiled header).
 * This file only contains plugin-specific declarations.
 */
#pragma once

// ============================================================================
// Fallback includes when PCH is disabled
// ============================================================================

#ifndef PLUGIN_PCH_INCLUDED
#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>
#endif

// ============================================================================
// Plugin Constants
// ============================================================================

#define PLUGIN_NAME    "MyPlugin"
#define PLUGIN_HOTKEY  "Ctrl-Shift-P"
