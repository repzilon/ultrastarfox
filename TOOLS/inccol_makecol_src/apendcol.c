#include <stdio.h>
#include <stdlib.h>

#ifdef ROBFX
int inccol_common(int argc, char** argv, const char* destination, const char* mode);

int appendcol_main(int argc, char** argv)
#else
#include "inccol.h"

int main(int argc, char *argv[])
#endif
{
    int code = inccol_common(argc, argv, "allcols.col", "ab");
    if (code == EXIT_SUCCESS) {
        printf("%s stripped successfully.\n", argv[1]);
    }
    return code;
}
