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
