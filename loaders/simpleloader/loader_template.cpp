
/*
  L O A D E R  skeleton file
*/

#include <ida.hpp>
#include <fpro.h>
#include <idp.hpp>
#include <loader.hpp>

//--------------------------------------------------------------------------
//
//      check input file format. if recognized, then return 1
//      and fill 'fileformatname'.
//      otherwise return 0
//
static int idaapi accept_file(
    qstring* fileformatname,
    qstring* processor,
    linput_t* li,
    const char* filename)
{
    *fileformatname = "Template loader <edit me>";
    *processor = "metapc";

    return 1;
}

//--------------------------------------------------------------------------
//
//      load file into the database.
//
void idaapi load_file(linput_t* li, ushort neflag, const char* fileformatname)
{
}

//--------------------------------------------------------------------------
//
//  generate binary file.
//
int idaapi save_file(FILE* fp, const char* /*fileformatname*/)
{
    return 0;
}

//----------------------------------------------------------------------
static int idaapi move_segm(ea_t from, ea_t to, asize_t /*size*/, const char* /*fileformatname*/)
{
    return 0;
}

//----------------------------------------------------------------------
//
//      LOADER DESCRIPTION BLOCK
//
//----------------------------------------------------------------------

// Make sure we export LDSC
idaman loader_t ida_module_data LDSC;

loader_t LDSC =
{
  IDP_INTERFACE_VERSION,
  // loader flags
  0,

  // check input file format. if recognized, then return 1
  // and fill 'fileformatname'.
  // otherwise return 0
  accept_file,

  // load file into the database.
  load_file,

  // create output file from the database.
  // this function may be absent.
  save_file,

  // take care of a moved segment (fix up relocations, for example)
  move_segm,
  nullptr,
};
