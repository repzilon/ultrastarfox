/*romExtender V2*/
/*Usage example:
romExtender SF.ROM 16 FF or romExtender SF.ROM --auto FF */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if ROBFX
int extend_main(int argc, char** argv)
#else
int main(int argc, const char* argv[])
#endif
{
    // ROM sizes of all released SNES games, from the list at
    // https://docs.google.com/spreadsheets/d/1XH9xKZFQ09lLWfFzo4Y9-1FUAqSTnH6FPrQUINa__Lw/edit?usp=sharing
    const unsigned char kAutoRomMBits[] = { 2,4,8,10,12,16,20,32,48 };

    if (argc != 4) {
        printf("ROM Extender V2.1\nUsage:\t%s <romFile> <Padded size in MBits> <Fill Byte>\n\t%s <romFile> --auto <Fill Byte>\n8 Mbits = 1Mbyte, 16Mbits = 2Mbytes...\n", argv[0], argv[0]);
        return 1;
    }

    const char* romFile = argv[1];
    const char* megaBits = argv[2];
    const char* padByte = argv[3];
    FILE* currentFile = fopen(romFile, "rb");

    long int actualPadByte = strtol(padByte, NULL, 16);

    if (currentFile == NULL) {
        fputs("Error opening file\n", stderr);
        return 1;
    } else if (strtol(padByte, NULL, 16) > 0xff) {
        fputs("Error: Pad byte too large\n", stderr);
        return 1;
    }

    fseek(currentFile, 0, SEEK_END);
    long romFileSize = ftell(currentFile);
    fseek(currentFile, 0, SEEK_SET);

    int maxSize;
    if (strcmp(megaBits, "--auto") == 0) {
        maxSize = 2 * 0x20000;
        int i;
        for (i = 1; (i < 9) && (maxSize < romFileSize); i++) {
            maxSize = kAutoRomMBits[i] * 0x20000;
        }
    } else {
        maxSize = atoi(megaBits) * 0x20000;
    }

    if (romFileSize < maxSize) {
        long zeroFillAmt = maxSize - romFileSize;

        // Allocate memory for the ROM data
        char* romData = (char*)malloc(maxSize);

        if (romData == NULL) {
            fclose(currentFile);
            fputs("Error allocating memory\n", stderr);
            return 1;
        }

        // Read the existing ROM data
        fread(romData, 1, romFileSize, currentFile);
        fclose(currentFile);

        // Fill the remaining space with zeros
        for (long i = romFileSize; i < maxSize; i++) {
            romData[i] = actualPadByte;
        }

        // Write the modified ROM data back to the file
        currentFile = fopen(romFile, "wb");
        if (currentFile == NULL) {
            fputs("Error opening file for writing\n", stderr);
            free(romData);
            return 1;
        }

        fwrite(romData, 1, maxSize, currentFile);
        fclose(currentFile);
        free(romData);

        printf("ROM successfully expanded to %d Mbits.\nAdded %ld %lXs to ROM.\n", maxSize / 0x20000, zeroFillAmt, actualPadByte);
    } else {
        fclose(currentFile);
        printf("Nothing to do for %s\n", romFile);
    }

    return 0;
}
