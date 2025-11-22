#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "foxchr.h"

#ifdef _WIN64
#define PRIdLong2 "lld"
#else
#ifdef __LP64__
#define PRIdLong2 "ld"
#else
#define PRIdLong2 "d"
#endif
#endif

#ifdef ROBFX
int foxchr_main(int argc, char** argv)
#else
int main(int argc, char *argv[])
#endif
{
	if (argc < 2){
		puts("* " CLI_FILEDESCRIPTION_STR " " CLI_FILEVERSION_STR " *\n");
		puts("USAGE: foxchr graphics.cgx");
		exit(EX_USAGE);
	}

	// create output filename
	char *outputFileName = chr_createOutputFileName(argv[1]);

	// verify input file size, create file pointer
	FILE * fpInput = openSnes(argv[1]);

	// convert horizontal format to vertical format and save to disk
	convertHoriz2Vert(fpInput, outputFileName);

	puts("PROGRAM ERROR: Foxchr ended unexpectedly.");
	exit(EX_SOFTWARE);
}

void convertHoriz2Vert(FILE * fpInput, char * outputFileName)
{
	size_t fileSize = (size_t)ftell(fpInput);
	fseek(fpInput, 0, SEEK_SET);

	// determine how many mugshots there are
	size_t mugShotCnt = fileSize / MUGSIZE;

	// create input buffer, and a pointer that we can mangle
	char *inBuff = (char*)malloc(fileSize * sizeof(*inBuff));
	char *inBuffPtr = inBuff;

	// copy graphics from disk to buffer
	fread(inBuff, 1, fileSize, fpInput);
	fclose(fpInput);

	// create 4bpp output buffer, zero filled, and pointer to mangle
	char *outBuff = (char*)calloc(fileSize, sizeof(*outBuff));
	char *outBuffPtr = outBuff;

	#define NEXTTILEDOWN (TILESIZE * MUGWDTH * mugShotCnt)

	for (size_t mugShot = 0; mugShot < mugShotCnt; mugShot++) {
		// copy a single 4x5 tile mugshot
		for (int outCol = 0; outCol < MUGWDTH; outCol++) {
			// copy a single 5 tile column to the output
			for (int outTile = 0; outTile < MUGHGHT; outTile++) {
				// copy 1 tile
				memcpy(outBuffPtr, inBuffPtr, TILESIZE);
				inBuffPtr += NEXTTILEDOWN;
				outBuffPtr += TILESIZE;
			}
			inBuffPtr -= MUGSIZE * mugShotCnt - TILESIZE;
		}
	}

	#ifdef DEBUG
	if (inBuffPtr != inBuff + NEXTTILEDOWN) {
		printf("DEBUG ERROR: inBuffPtr off by %" PRIdLong2 "\n", inBuffPtr - (inBuff + NEXTTILEDOWN));
		free(inBuff);
		free(outBuff);
		exit(EX_SOFTWARE);
	}
	#endif

	// open 4bpp output file
	FILE *fpOut;
	if ((fpOut = fopen(outputFileName, "wb")) == NULL) {
		printf("ERROR: Cannot create file \"%s\" for saving.\n", outputFileName);
		exit(EX_CANTCREAT);
	}

	// save 4bpp outBuff to output file
	fwrite(outBuff, 1, fileSize, fpOut);
	fclose(fpOut);

	// don't need output buffers anymore
	free(inBuff);
	free(outBuff);

	printf("Foxchr done, output: %s\n", outputFileName);
	free(outputFileName);

	exit(EX_OK);
}

FILE * openSnes(char *fileName)
{
	// ==================================
	// open fileName and verify file size
	// return file pointer
	// ==================================
	static FILE *fpInput;

	if ((fpInput = fopen(fileName, "rb")) == NULL)	{
		printf("ERROR: Cannot open input .cgx file \"%s\"\n", fileName);
		exit(EX_NOINPUT);
	}

	// get file size for error detection
	fseek(fpInput, 0, SEEK_END);
	long fileSize = ftell(fpInput);

	if (fileSize > 0x10000) {
		printf("ERROR: \"%s\" file size is larger than 64KB.\n", fileName);
		fclose(fpInput);
		exit(EX_DATAERR);
	}

	if (fileSize < MUGSIZE) {
		printf("ERROR: \"%s\" file size must at least %d bytes.\n", fileName, MUGSIZE);
		fclose(fpInput);
		exit(EX_DATAERR);
	}

	if (fileSize & 0x1F) {
		printf("ERROR: \"%s\" file size must be a multiple of 32 bytes.\n", fileName);
		fclose(fpInput);
		exit(EX_DATAERR);
	}

	return fpInput;
}

char * chr_createOutputFileName(char * inputFileName)
{
	ptrdiff_t posdot   = strrchr(inputFileName, '.') - inputFileName; // position of last .
	// special case for *nix hidden files or those without an extension
	size_t    noextlen = (posdot <= 0) ? strlen(inputFileName) : (size_t)posdot;
	size_t    scrlen   = strlen(EXT_SCR);
	size_t    cgxlen   = strlen(EXT_CGX);
	char*     outputFileName = (char*)calloc(noextlen + scrlen + cgxlen + 1, sizeof(char));
	if (outputFileName == NULL) {
		puts("foxchr error: cannot allocate output file name.");
		exit(EX_SOFTWARE);
	}

	// copy file title
	memcpy(outputFileName, inputFileName, noextlen);
	// append -SCRAMBLED to filename
	memcpy(outputFileName + noextlen, EXT_SCR, strlen(EXT_SCR));
	// append .cgx extension to outputFileName
	memcpy(outputFileName + noextlen + strlen(EXT_SCR), EXT_CGX, strlen(EXT_CGX));

	return outputFileName;
}
