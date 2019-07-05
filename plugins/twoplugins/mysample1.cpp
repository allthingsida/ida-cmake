#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <kernwin.hpp>

int idaapi init(void)
{
  msg("Plugin1 initialized!\n");
  return PLUGIN_OK;
}

void idaapi term(void)
{
  msg("Plugin1 term()\n");
}

bool idaapi run(size_t arg)
{
  msg("Plugin1 run()\n");
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
  "Sample plugin1",
  ""
};
