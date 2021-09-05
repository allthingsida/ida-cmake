#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>

static plugmod_t *idaapi init(void)
{
  msg("Plugin initialized!\n");
  return PLUGIN_OK;
}

static void idaapi term(void)
{
  msg("Plugin term()\n");
}

static bool idaapi run(size_t arg)
{
  msg("Plugin run()\n");
  return true;
}

plugin_t PLUGIN =
{
  IDP_INTERFACE_VERSION,
  PLUGIN_UNL,
  init,
  term,
  run,
  "",
  "",
  "Sample plugin",
  ""
};
