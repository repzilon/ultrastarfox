#include <stdio.h>
#include <stdlib.h>

#ifdef ROBFX
int inccol_common(int argc, char** argv, const char* destination, const char* mode);

int inccol_main(int argc, char** argv)
#else
#include "inccol.h"

int main(int argc, char *argv[])
#endif
{
    int code = inccol_common(argc, argv, "col.tmp", "wb");
    if (code == EXIT_SUCCESS) {
        printf("%s stripped successfully.\n", argv[1]);
    }
    return code;
}
