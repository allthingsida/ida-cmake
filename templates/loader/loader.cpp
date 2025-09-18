#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <diskio.hpp>

// Check if input file can be loaded
int idaapi accept_file(qstring *fileformatname, qstring *processor, linput_t *li, const char *filename)
{
    // Read file signature
    uint32_t sig;
    if (qlread(li, &sig, sizeof(sig)) != sizeof(sig))
        return 0;

    // Check if this is our file format (example: 'MYFF' signature)
    if (sig != 0x4646594D)  // 'MYFF' in little-endian
        return 0;

    // Set format name and processor
    fileformatname->sprnt("My Custom Format");
    processor->sprnt("metapc");  // Use x86 processor

    return ACCEPT_FIRST;  // We want to be the first loader to process this file
}

// Load the file
void idaapi load_file(linput_t *li, ushort neflag, const char *fileformatname)
{
    // Seek to beginning
    qlseek(li, 0);

    // Read and process file
    msg("Loading custom file format...\n");

    // Example: Create a segment
    segment_t s;
    s.start_ea = 0x1000;
    s.end_ea = 0x2000;
    s.sel = setup_selector(0);
    s.type = SEG_CODE;
    s.perm = SEGPERM_EXEC | SEGPERM_READ;
    s.bitness = 1;
    add_segm_ex(&s, "CODE", "CODE", ADDSEG_NOSREG | ADDSEG_OR_DIE);

    file2base(li, 4, s.start_ea, s.start_ea + qlsize(li) - 4, FILEREG_PATCHABLE);

    // Set entry point
    inf_set_start_ip(0x1000);
    inf_set_start_cs(0);
}

// Make sure we export LDSC
idaman loader_t ida_module_data LDSC;

// Loader definition
loader_t LDSC =
{
    IDP_INTERFACE_VERSION,
    0,                      // Loader flags
    accept_file,           // Check if we can load the file
    load_file,             // Load the file
    NULL,                  // Save file (not implemented)
    NULL,                  // Reserved
    NULL,                  // Reserved
};