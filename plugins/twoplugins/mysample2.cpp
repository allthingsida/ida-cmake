#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>

int idaapi init(void)
{
  msg("Plugin2 initialized!\n");
  return PLUGIN_OK;
}

void idaapi term(void)
{
  msg("Plugin2 term()\n");
}

bool idaapi run(size_t arg)
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
