#include <stdio.h>

#include <pro.h>
#include <idalib.hpp>
#include <funcs.hpp>

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Usage: %s <database>\n", argv[0]);
        return 1;
    }

    int ok = init_library();
    if (ok != 0)
    {
        printf("Failed to initialize idalib: %d\n", ok);
        return 1;
    }

    ok = open_database(argv[1], false);
    if (ok != 0)
    {
        printf("Failed to open database: %d\n", ok);
        return 1;
    }

    size_t nfuncs = get_func_qty();
    printf("Number of functions: %zd\n", nfuncs);
    for (size_t i = 0; i < nfuncs; i++)
    {
        func_t* f = getn_func(i);
        qstring name;
        if (get_func_name(&name, f->start_ea) > 0)
            printf("Function %zd: %s\n", i, name.c_str());
    }

    close_database(false);

    return 0;
}