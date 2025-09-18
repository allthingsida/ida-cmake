#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>

// Plugin module class
struct sample_plugin_t : public plugmod_t
{
    virtual bool idaapi run(size_t) override
    {
        msg("Hello from MyPlugin!\n");
        info("This is a sample IDA plugin built with ida-cmake.");
        return true;
    }
};

// Plugin initialization
static plugmod_t* idaapi init()
{
    msg("MyPlugin: initialized\n");
    return new sample_plugin_t;
}

// Plugin description
plugin_t PLUGIN =
{
    IDP_INTERFACE_VERSION,
    PLUGIN_MULTI,         // Plugin flags
    init,                 // Initialize
    nullptr,              // Terminate (not used for PLUGIN_MULTI)
    nullptr,              // Run (not used for PLUGIN_MULTI)
    "Sample Plugin - This is a sample plugin template.",  // Comment
    "Sample Plugin\n"     // Help text
    "This is a sample plugin built with ida-cmake.",
    "Sample Plugin",      // Plugin name in menu
    "Ctrl-Shift-P"       // Plugin hotkey
};