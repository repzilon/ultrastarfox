#include <math.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>	// fix by sunlit
#include <string.h>
#ifndef _MSC_VER
#include <strings.h>	// for strncasecmp
#endif
#include "foxfont.h"

#ifdef _MSC_VER
#define strncasecmp _strnicmp
#endif

#ifdef ROBFX
int foxfont_main(int argc, char** argv)
#else
int main(int argc, char *argv[])
#endif
{
	if (argc < 2){
		puts("* " CLI_FILEDESCRIPTION_STR " " CLI_FILEVERSION_STR " *\n");
		puts("USAGE: foxfont 8or4bit_56x240_font.bmp");
		exit(EX_USAGE);
	}

	// create output filename
	char *outputFileName = font_createOutputFileName(argv[1]);

	// verify input bitmap, set file pointer fpBitmap to start of pixel data
	unsigned char bpp; // used as an 8-bit integer, not a character
	unsigned int bmpSize;
	FILE * fpBitmap = openBitmap(argv[1], &bpp, &bmpSize);

	// convert 8bpp or 4bpp to 2bpp and save to disk
	convertBMP2Fon(fpBitmap, argv[1], outputFileName, bpp, bmpSize);

	puts("PROGRAM ERROR: Foxfont ended unexpectedly.");
	exit(EX_SOFTWARE);
}

void convertBMP2Fon(FILE * fpBitmap, char * inputFileName, char * outputFileName, unsigned char bpp, unsigned int inputSize)
{
	// ============================================
	// flip bitmap pixel data so it's easier to use
	// ============================================
	unsigned int divider = 8UL / bpp;

	// create buffer that will have pixels in the right orientation
	char *pixBuff = (char *) malloc(BMPWDTH * BMPHGHT * sizeof(*pixBuff) / divider);

	// create pointer to bottom row of pixBuff
	char *pixBuffPtr = pixBuff + (((BMPWDTH * BMPHGHT) - BMPWDTH) / divider);

	for (int tmp = 0; tmp < BMPHGHT; tmp++) {
		fread(pixBuffPtr, 1, BMPWDTH / divider, fpBitmap);	// copy a row from bottom of bmp to bottom of pixBuff
		pixBuffPtr -= BMPWDTH / divider;					// set pointer to next row of pixels (descending)
	}
	fclose(fpBitmap);

	// =================================================
	// convert 8bit pixel buffer into 2bpp output buffer
	// =================================================

	// create 2bpp buffer, zero filled
	char *outBuff = (char *) calloc((BMPWDTH * BMPHGHT / 4), sizeof(*outBuff)); // fix by Sunlit

	// make some pointers we can mess with
	char *outBuffPtr = outBuff;
	pixBuffPtr = pixBuff;							// reset pixBuffPtr

	int bmpRow, tile, row, shift;
	if (bpp == 8) {
		// convert 20 rows of tiles from pixBuff to outBuff
		for (bmpRow = 0; bmpRow < (BMPHGHT / TILEHGHT); bmpRow++) {
			// draw 7 tiles (columns) per row in bitmap
			for (tile = 0; tile < (BMPWDTH / TILEWDTH); tile++) {
				// draw 8 rows of pixels of the tile
				for (row = 0; row < TILEHGHT; row++) {
					// draw one row of pixels of the tile
					for (shift = (TILEWDTH - 1); shift >= 0; shift--) {
						*outBuffPtr       |= (char)((*pixBuffPtr & 0x01) << shift);
						*(outBuffPtr + 1) |= (char)(((*pixBuffPtr & 0x02) >> 1) << shift);
						pixBuffPtr++;
					}
					outBuffPtr += 2;
					pixBuffPtr += BMPWDTH - TILEWDTH;
				}
				// set pointer to beginning of next tile
				pixBuffPtr -= (BMPWDTH * TILEHGHT) - TILEWDTH;
			}
			// set pointer to next row of tiles in the bitmap
			pixBuffPtr += BMPWDTH * (TILEHGHT - 1);
		}
	} else if (bpp == 4) {
		for (bmpRow = 0; bmpRow < (BMPHGHT / TILEHGHT); bmpRow++) {
			for (tile = 0; tile < (BMPWDTH / TILEWDTH); tile++) {
				for (row = 0; row < TILEHGHT; row++) {
					for (shift = (TILEWDTH - 2); shift >= 0; shift-=2) {
						*outBuffPtr       |= (char)(((*pixBuffPtr & 0x10) >> 4) << (shift + 1));
						*outBuffPtr       |= (char)((*pixBuffPtr & 0x01) << shift);
						*(outBuffPtr + 1) |= (char)(((*pixBuffPtr & 0x20) >> 5) << (shift + 1));
						*(outBuffPtr + 1) |= (char)(((*pixBuffPtr & 0x02) >> 1) << shift);
						pixBuffPtr++;
					}
					outBuffPtr += 2;
					pixBuffPtr += (BMPWDTH - TILEWDTH) / 2;
				}
				pixBuffPtr -= ((BMPWDTH * TILEHGHT) - TILEWDTH) / 2;
			}
			pixBuffPtr += (BMPWDTH * (TILEHGHT - 1)) / 2;
		}
	}

	#ifdef DEBUG
	if (pixBuffPtr != pixBuff + BMPWDTH * BMPHGHT) {
		printf("DEBUG ERROR: pixBuffPtr off by %d\n", pixBuffPtr - (pixBuff + BMPWDTH * BMPHGHT));
		free(pixBuff);
		exit(EX_SOFTWARE);
	}
	#endif

	free(pixBuff);

	// open 2bpp output file
	FILE *fpFont;
	if ((fpFont = fopen(outputFileName, "wb")) == NULL) {
		printf("ERROR: Cannot create file \"%s\" for saving.\n", outputFileName);
		exit(EX_CANTCREAT);
	}

	// =====================
	// calculate font widths
	// =====================
	outBuffPtr = outBuff;						// reset pointer to beginning of 2bpp buffer
	char twoBppRowH, twoBppRowL;				// holds the pixels of each character
	// shift now stores the width of individual characters

	// process 140 tiles
	for(int tile = 0; tile < TILESMAX; tile++) {
		twoBppRowH = 0, twoBppRowL = 0;

		// each tile has 12 rows of pixels, logical OR all rows into a byte to get width
		for(int row = 0; row < TILEHGHT; row++) {
			twoBppRowL |= *outBuffPtr;			// colors 0 and 1 (transparent and extra pixels)
			twoBppRowH |= *(outBuffPtr + 1);	// colors 2 and 3 (main font color and ?)
			outBuffPtr += 2;
		}
		if(twoBppRowL == 0) {
			// if pixels are main font
			for(shift = TILEWDTH + 1; shift > 0; shift--) {
				if(shift == 1) {				// empty tile
					shift = EMPTYTILE;
					break;
				}
				if(twoBppRowH & 0x01) {			// test if rightmost pixel is blank or filled
					break;
				}
				twoBppRowH = twoBppRowH >> 1;	// remove 1 blank pixel from the right
			}
		} else {
			// if character is wider than 8
			for(shift = TILEWDTH + 1; shift > 0; shift--) {
				if(twoBppRowL & 0x01) {			// test if rightmost pixel is blank or filled
					break;
				}
				twoBppRowL = twoBppRowL >> 1;	// remove 1 blank pixel from the right
			}
			shift += TILEWDTH;
		}
		fwrite(&shift, 1, 1, fpFont);
	}
	#ifdef DEBUG
	if (outBuffPtr != outBuff + BMPWDTH * BMPHGHT / 4) {
		printf("DEBUG ERROR: outBuffPtr off by %d\n", outBuffPtr - (outBuff + BMPWDTH * BMPHGHT / 4));
		fclose(fpFont);
		free(outBuff);
		exit(EX_SOFTWARE);
	}
	#endif


	// save 2bpp outBuff to output file
	fwrite(outBuff, 1, BMPWDTH * BMPHGHT / 4, fpFont);
	fseek(fpFont, 0, SEEK_END);
	long outputSize = ftell(fpFont);
	fclose(fpFont);

	// don't need output buffer anymore
	free(outBuff);

	printf("%11u%10ld %3.0f%% %s => %s\n", inputSize, outputSize, ceil(outputSize * 100.0 / inputSize), inputFileName, outputFileName);
	free(outputFileName);

	exit(EX_OK);
}

FILE * openBitmap(char *fileName, unsigned char *bppOut, unsigned int *sizeOut)
{
	// ==============================================
	// open fileName and verify bmp header data
	// return file pointer to beginning of pixel data
	// ==============================================
	static FILE *fpBitmap;

	if ((fpBitmap = fopen(fileName, "rb")) == NULL)	{
		printf("ERROR: Cannot open input image file \"%s\"\n", fileName);
		exit(EX_NOINPUT);
	}

	// get filesize for error detection
	fseek(fpBitmap, 0, SEEK_END);
	*sizeOut = (unsigned int)ftell(fpBitmap);
	fseek(fpBitmap, 0, SEEK_SET);

	BMP_FILE_HEADER bmp_header;

	fread(&bmp_header.type, 2, 1, fpBitmap);
	fread(&bmp_header.file_size, 4, 1, fpBitmap);
	fread(&bmp_header.reserved1, 2, 2, fpBitmap);		// reserved1 and reserved2
	fread(&bmp_header.offset, 4, 1, fpBitmap);
	fread(&bmp_header.header_size, 4, 1, fpBitmap);
	fread(&bmp_header.width, 4, 1, fpBitmap);
	fread(&bmp_header.height, 4, 1, fpBitmap);
	fread(&bmp_header.planes, 2, 1, fpBitmap);
	fread(&bmp_header.bits, 2, 1, fpBitmap);
	fread(&bmp_header.compression, 4, 1, fpBitmap);
	fread(&bmp_header.imagesize, 4, 1, fpBitmap);
	fread(&bmp_header.xresolution, 4, 2, fpBitmap);		// xresolution and yresolution
	fread(&bmp_header.ncolors, 4, 1, fpBitmap);
	fread(&bmp_header.importantcolors, 4, 1, fpBitmap);

	if (bmp_header.type != 0x4D42) {
		printf("ERROR: \"%s\" does not appear to be a bitmap image.\n", fileName);
		fclose(fpBitmap);
		exit(EX_DATAERR);
	}

	if (*sizeOut != bmp_header.file_size) {
		printf("ERROR: \"%s\" file size does not match internal header file size.\n", fileName);
		fclose(fpBitmap);
		exit(EX_DATAERR);
	}

	if (bmp_header.bits == 8) {
		if (*sizeOut < bmp_header.offset + BMPWDTH*BMPHGHT) {
			printf("ERROR: \"%s\" file too small to hold %dx%d font data.\n", fileName, BMPWDTH, BMPHGHT);
			fclose(fpBitmap);
			exit(EX_DATAERR);
		}
	} else if (bmp_header.bits == 4) {
		if (*sizeOut < bmp_header.offset + (BMPWDTH*BMPHGHT/2)) {
			printf("ERROR: \"%s\" file too small to hold %dx%d font data.\n", fileName, BMPWDTH, BMPHGHT);
			fclose(fpBitmap);
			exit(EX_DATAERR);
		}
	} else {
		puts("ERROR: bitmap must be indexed 8bit or 4bit color.");
		fclose(fpBitmap);
		exit(EX_DATAERR);
	}

	if ((bmp_header.width != BMPWDTH) || (bmp_header.height != BMPHGHT)) {
		printf("ERROR: bitmap must be %d pixels wide by %d pixels tall.\n", BMPWDTH, BMPHGHT);
		fclose(fpBitmap);
		exit(EX_DATAERR);
	}

	if (bmp_header.compression != 0) {
		printf("ERROR: \"%s\" appears to be a compressed bitmap, no compression plz.\n", fileName);
		fclose(fpBitmap);
		exit(EX_DATAERR);
	}

	if (!bmp_header.ncolors) {
		bmp_header.ncolors = 256;
		bmp_header.importantcolors = 256;
	}

	//if (bmp_header.ncolors > 4)
	//	printf("NOTICE: bitmap has %d colors, using first 4 only.\n", bmp_header.ncolors);

	// skip reading the palette
	fseek(fpBitmap, (long)(bmp_header.ncolors * 4), SEEK_CUR);

	// after the palette is the pixel data, this should match .offset
	if (ftell(fpBitmap) != bmp_header.offset) {
		puts("NOTICE: bitmap header offset value does not match pixel start address.");
		fseek(fpBitmap, (long)bmp_header.offset, SEEK_SET);
	}

	*bppOut = (unsigned char)(bmp_header.bits & 0xFF);
	return fpBitmap;
}

char * font_createOutputFileName(char * inputFileName)
{
	ptrdiff_t posdot   = strrchr(inputFileName, '.') - inputFileName; // position of last .
	// special case for *nix hidden files or those without an extension
	size_t    noextlen = (posdot <= 0) ? strlen(inputFileName) : (size_t)posdot;
	char*     inputExt = inputFileName + (strlen(inputFileName) - EXT_LEN);

	// verify that input file's extension is ".bmp"
	if (strncasecmp(inputExt, EXT_BMP, EXT_LEN) != 0) {
		puts("foxfont error: input file must have " EXT_BMP " extension.");
		exit(EX_DATAERR);
	}

	char* outputFileName = (char*)calloc(noextlen + EXT_LEN + 1, sizeof(char));
	if (outputFileName == NULL) {
		puts("foxfont error: cannot allocate output file name.");
		exit(EX_SOFTWARE);
	}

	// copy input filename without null termination
	memcpy(outputFileName, inputFileName, noextlen);
	// add .fon extension to outputFileName
	memcpy(outputFileName + noextlen, EXT_FON, EXT_LEN);

	if (strlen(inputFileName) != strlen(outputFileName)) {
		puts("foxfont error: outputFileName is different length than inputFileName");
		exit(EX_SOFTWARE);
	}

	return outputFileName;
}
