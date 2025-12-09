/**
 * @file main.cpp
 * @brief IDA plugin implementation with PCH support.
 */

#include "plugin.h"

// Plugin module class
struct sample_plugin_t : public plugmod_t
{
    virtual bool idaapi run(size_t) override
    {
        msg("Hello from %s!\n", PLUGIN_NAME);
        info("This plugin was built with precompiled header support.");
        return true;
    }
};

// Plugin initialization
static plugmod_t* idaapi init()
{
    msg("%s: initialized\n", PLUGIN_NAME);
    return new sample_plugin_t;
}

// Plugin description
plugin_t PLUGIN =
{
    IDP_INTERFACE_VERSION,
    PLUGIN_MULTI,
    init,
    nullptr,
    nullptr,
    "Sample Plugin with PCH - Demonstrates precompiled header usage.",
    "Sample Plugin with PCH\n"
    "This plugin template uses precompiled headers for faster builds.",
    PLUGIN_NAME,
    PLUGIN_HOTKEY
};
