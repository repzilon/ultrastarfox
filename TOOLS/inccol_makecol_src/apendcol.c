#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef ROBFX
int inccol_common(int argc, char** argv, const char* destination, const char* mode, long* sourceSize, long* destSize, long* destBegin);

int appendcol_main(int argc, char** argv)
#else
#include "inccol.h"

int main(int argc, char *argv[])
#endif
{
    long sourceSize, destSize, destBegin;
    int code = inccol_common(argc, argv, "allcols.col", "ab", &sourceSize, &destSize, &destBegin);
    if (code == EXIT_SUCCESS) {
        printf("%7ld%7ld%7ld %3.0f%% %s =>> allcols.col\n", 
         sourceSize, destSize - destBegin, destSize, ceil((destSize - destBegin) * 100.0 / sourceSize), argv[1]);
    }
    return code;
}
