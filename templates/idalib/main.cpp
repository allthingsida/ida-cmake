#include <iostream>
#include <ida.hpp>
#include <idp.hpp>
#include <loader.hpp>
#include <auto.hpp>
#include <name.hpp>
#include <funcs.hpp>
#include <segment.hpp>
#include <bytes.hpp>
#include <idalib.hpp>

int main(int argc, char* argv[])
{
    if (argc < 2)
    {
        std::cerr << "Usage: " << argv[0] << " <idb_file>" << std::endl;
        std::cerr << "Example: " << argv[0] << " $IDASDK/ida-cmake/samples/wizmo32.exe.i64" << std::endl;
        return 1;
    }

    // Initialize IDA library
    int ok = init_library();
    if (ok != 0)
    {
        std::cerr << "Failed to initialize IDA library: " << ok << std::endl;
        return 1;
    }

    // Open the database
    const char* idb_path = argv[1];
    std::cout << "Opening IDA database: " << idb_path << std::endl;

    ok = open_database(idb_path, true);  // true = run auto-analysis
    if (ok != 0)
    {
        std::cerr << "Failed to open database: " << ok << std::endl;
        return 1;
    }

    // Wait for auto-analysis to complete
    auto_wait();

    // Display basic information
    std::cout << "\n=== Database Information ===" << std::endl;
    std::cout << "Processor: " << inf_get_procname().c_str() << std::endl;
    std::cout << "Entry point: 0x" << std::hex << inf_get_start_ip() << std::endl;
    std::cout << "Min address: 0x" << std::hex << inf_get_min_ea() << std::endl;
    std::cout << "Max address: 0x" << std::hex << inf_get_max_ea() << std::endl;

    // Enumerate segments
    std::cout << "\n=== Segments ===" << std::endl;
    int seg_qty = get_segm_qty();
    for (int i = 0; i < seg_qty; i++)
    {
        segment_t* seg = getnseg(i);
        if (seg != nullptr)
        {
            qstring seg_name;
            get_segm_name(&seg_name, seg);
            std::cout << "  " << seg_name.c_str()
                      << " [0x" << std::hex << seg->start_ea
                      << " - 0x" << seg->end_ea << "]" << std::endl;
        }
    }

    // Enumerate functions
    std::cout << "\n=== Functions (first 10) ===" << std::endl;
    size_t func_qty = get_func_qty();
    size_t count = 0;
    for (size_t i = 0; i < func_qty && count < 10; i++)
    {
        func_t* f = getn_func(i);
        if (f != nullptr)
        {
            qstring name;
            get_func_name(&name, f->start_ea);
            std::cout << "  " << name.c_str()
                      << " at 0x" << std::hex << f->start_ea
                      << " (size: " << std::dec << (f->end_ea - f->start_ea) << " bytes)"
                      << std::endl;
            count++;
        }
    }
    if (func_qty > 10)
    {
        std::cout << "  ... and " << (func_qty - 10) << " more functions" << std::endl;
    }

    // Count imports
    std::cout << "\n=== Statistics ===" << std::endl;
    std::cout << "Total functions: " << std::dec << func_qty << std::endl;
    std::cout << "Total segments: " << seg_qty << std::endl;

    // Example: Find specific function by name
    ea_t main_ea = get_name_ea(BADADDR, "main");
    if (main_ea != BADADDR)
    {
        std::cout << "\nFound 'main' function at: 0x" << std::hex << main_ea << std::endl;
    }

    // Clean up
    close_database(false);  // false = don't save changes

    std::cout << "\nIDALib example completed successfully!" << std::endl;
    return 0;
}