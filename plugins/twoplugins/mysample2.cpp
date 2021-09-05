#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>

static plugmod_t *idaapi init(void)
{
  msg("Plugin2 initialized!\n");
  return PLUGIN_OK;
}

static void idaapi term(void)
{
  msg("Plugin2 term()\n");
}

static bool idaapi run(size_t arg)
{
  msg("Plugin2 run()\n");
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
  "Sample plugin2",
  ""
};
