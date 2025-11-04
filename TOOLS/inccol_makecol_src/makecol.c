#include <stdio.h>
#include <stdlib.h>

// this is specifically for building on DOS with Zortech Make -- if we ever switch to a native-based or otherwise more modern toolchain in the future, this will be rendered obsolete

#ifdef ROBFX
int inccol_common(int argc, char** argv, const char* destination, const char* mode, long* sourceSize, long* destSize, long* destBegin);

int makecol_main(int argc, char** argv)
#else
#include "inccol.h"

int main(int argc, char *argv[])
#endif
{
    long sourceSize, destSize, destBegin;
    int code = inccol_common(argc, argv, "col.tmp", "wb", &sourceSize, &destSize, &destBegin);
    if (code == EXIT_SUCCESS) {
        // Execute commands from MC.BAT internally so Zortech Make can actually catch errors
        if (system("copy /b allcols.col col2.tmp") != 0) {
            fputs("Error executing: copy /b allcols.col col2.tmp\n", stderr);
            return EXIT_FAILURE;
        }

        if (system("copy /b col2.tmp+col.tmp allcols.col") != 0) {
            fputs("Error executing: copy /b col2.tmp+col.tmp allcols.col\n", stderr);
            return EXIT_FAILURE;
        }

        printf("%s stripped successfully.\n", argv[1]);
    }
    return code;
}
