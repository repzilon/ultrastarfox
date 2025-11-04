//
// Created by Repzilon on 2025-09-28.
//
#ifndef INCCOL_H
#define INCCOL_H
#include <stdlib.h>

void copyData(FILE *source, FILE *destination, long startOffset, long endOffset) {
    fseek(source, startOffset, SEEK_SET);  // Move to the start offset
    size_t dataSize = (size_t)(endOffset - startOffset);
    char *buffer = (char *)malloc(dataSize);

    if (buffer == NULL) {
        fputs("Memory allocation failed\n", stderr);
        exit(EXIT_FAILURE);
    }

    fread(buffer, 1, dataSize, source);    // Read data from source file
    fwrite(buffer, 1, dataSize, destination);  // Write data to destination file

    free(buffer);
}

int inccol_common(int argc, char** argv, const char* destination, const char* mode, long* sourceSize, long* destSize, long* destBegin)
{
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <file_name> <start_offset> <end_offset>\n", argv[0]);
        return EXIT_FAILURE;
    }

    char *fileName = argv[1];
    long startOffset = strtol(argv[2], NULL, 10) * 32;
    long endOffset = strtol(argv[3], NULL, 10) * 32;

    FILE *sourceFile = fopen(fileName, "rb");
    if (sourceFile == NULL) {
        fprintf(stderr, "Error opening file: %s\n", fileName);
        return EXIT_FAILURE;
    }

    FILE *destinationFile = fopen(destination, mode);
    if (destinationFile == NULL) {
        fprintf(stderr, "Error creating output file: %s\n", destination);
        fclose(sourceFile);
        return EXIT_FAILURE;
    }

    fseek(destinationFile, 0, SEEK_END);
    *destBegin = ftell(destinationFile);
    fseek(destinationFile, 0, SEEK_SET);

    copyData(sourceFile, destinationFile, startOffset, endOffset);

    fseek(sourceFile, 0, SEEK_END);
    *sourceSize = ftell(sourceFile);
    fseek(destinationFile, 0, SEEK_END);
    *destSize = ftell(destinationFile);

    fclose(sourceFile);
    fclose(destinationFile);

    return EXIT_SUCCESS;
}

#endif //INCCOL_H
