#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>

//--------------------------------------------------------------------------
struct plugin_ctx_t : public plugmod_t
{
    bool idaapi run(size_t) override
    {
        msg("Hello, world! xxx(cpp)\n");
        return true;
    }
};

//--------------------------------------------------------------------------
plugin_t PLUGIN =
{
    IDP_INTERFACE_VERSION,
    PLUGIN_UNL | PLUGIN_MULTI,
    []()->plugmod_t* {return new plugin_ctx_t; }, // initialize
    nullptr,
    nullptr,
    nullptr,              // long comment about the plugin
    nullptr,              // multiline help about the plugin
    "Hello, world",       // the preferred short name of the plugin
    nullptr,              // the preferred hotkey to run the plugin
};
