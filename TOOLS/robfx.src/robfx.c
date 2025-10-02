#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef unsigned char byte;

#if 'B' == ROBFX_EDITION_C
	#define ROBFX_EDITION "Build"
	const byte kAppletCount = 9;
	// DJGPP names
	const char* kApplets[] = { "chrmap", "cru", "extend", "fon", "inccol", "makecol", "apendcol", "mapdec", "cgx2fx" };

	// Prototypes
	#include "../inccol_src/inccol.h"
	int chrmap_main(int argc, char** argv);
	int sfcrunch_main(int argc, char** argv);
	int extend_main(int argc, char** argv);
	int foxfont_main(int argc, char** argv);
	int inccol_main(int argc, char** argv);
	int makecol_main(int argc, char** argv);
	int appendcol_main(int argc, char** argv);
	int mapdecoder_main(int argc, char** argv);
	int cgx2fx_main(int argc, char** argv);
#elif 'T' == ROBFX_EDITION_C
	#define ROBFX_EDITION "Tool"
	const byte kAppletCount = 7;
	const char* kApplets[] = { "palconv", "sf_crunch", "foxchr", "cgx2fx", "fx2cgx", "foxfont", "sf_decrunch" };

	// Prototypes
	int palconv_main(int argc, char** argv);
	int sfcrunch_main(int argc, char** argv);
	int sfdecrunch_main(int argc, char** argv);
	int foxchr_main(int argc, char** argv);
	int cgx2fx_main(int argc, char** argv);
	int fx2cgx_main(int argc, char** argv);
	int foxfont_main(int argc, char** argv);
#elif 'S' == ROBFX_EDITION_C
	#define ROBFX_EDITION "Sink"
	const byte kAppletCount = 5;
	const char* kApplets[] = { "romExtender2", "inccol", "argonautmapdecoder", "unmerge", "chrmap" };

	// Prototypes
	#include "../inccol_src/inccol.h"
	int chrmap_main(int argc, char** argv);
	int extend_main(int argc, char** argv);
	int inccol_main(int argc, char** argv);
	int mapdecoder_main(int argc, char** argv);
	int unmerge_main(int argc, char** argv);
#else
	#error "ROBFX_EDITION_C not defined correctly. Must be either B, T or S, but got " ROBFX_EDITION_C
#endif

// Detect target libc at build time
#ifndef TRIPLET
	#define QUAD "unknown platform"
#elif defined(__DJGPP__)
	#define TARGETLIBC "djgpp"
#elif defined(__linux__)
	#ifdef __UCLIBC__
		#define TARGETLIBC "uclibc"
	#elif defined(__GLIBC__)
		#define TARGETLIBC "gnu"
	#else
		#define TARGETLIBC "musl"
	#endif
#endif
#ifdef TARGETLIBC
	#define QUAD TRIPLET "-" TARGETLIBC
#elif !defined(QUAD)
	#define QUAD TRIPLET
#endif
// TODO : Rename folder in DOS

void output_logo()
{
	puts("RobFX UltraStarFox multi-call binary, v0.2 " ROBFX_EDITION " Edition " QUAD "\n"
		"2025 Repzilon. Credits: Everything, Phonymike, Segaretro92 and Sunlitspace542.\n"
	);
}

void output_usage()
{
	puts("NAME\n\tRobFX - UltraStarFox tool multi-call executable\n\n"
		"SYNOPSIS\n\trobfx <command> [<command arguments...>]\n\n"
		"DESCRIPTION\n\tRobFX combines several separate tools used for building or helping\n"
		"\tdevelopment with UltraStarFox into a single executable, smaller in size\n"
		"\tthan the sum of the standalone tools. On *nix operating systems, links\n"
		"\t(hard or symbolic) can be named like the standalone utilities and\n"
		"\tpointing to the RobFX binary. RobFX would then act like the utility it\n"
		"\treplaces. This program uses the same principle as BusyBox.\n"
	);
	//puts("OPTIONS\n\t\n");
	puts("COMMANDS\n\tCan be one of the following in the " ROBFX_EDITION " edition:");
	printf("\t");
	for (byte i = 0; i < kAppletCount; i++) {
		if (i > 0) {
			printf(", ");
		}
		printf("%s", kApplets[i]);
	}
	puts(".\n\tCommand names are case-insensitive to accommodate DOS and Windows.\n");
	//puts("ENVIRONMENT\n\t\n");
	puts("EXIT STATUS\n\t0 on command success, 1 when this general help message is shown.\n"
		"\tNon-zero value is generally returned on command failure, but read the\n"
		"\tsource code of the individual tools to be sure."
	);
	//puts("EXAMPLES\n\t\n");
	//puts("COMPATIBILITY\n\t\n");
	//puts("SEE ALSO\n\t\n");
	//puts("STANDARDS\n\t\n");
	//puts("HISTORY\n\t\n");
	//puts("BUGS\n\t\n");
}

const char* get_applet_name(const char* candidate)
{
	// From https://bug1041962.bmoattachments.org/attachment.cgi?id=8516179
	// by Natanel Copa, creator of the Alpine Linux distribution
	// basename's behavior is less than ideal so avoid it
	const char *p = strrchr(candidate, '/');
	char* realCandidate = p ? p + 1 : candidate;
	for (byte i = 0; i < kAppletCount; i++) {
		if (strcasecmp(realCandidate, kApplets[i]) == 0) {
			return kApplets[i];
		}
	}
	return NULL;
}

int pivot_applet(const char* applet_name, byte shift_args, int main_argc, char* argv[])
{
	int new_argc = main_argc - shift_args;
	char** new_argv = &argv[shift_args];

#if 'B' == ROBFX_EDITION_C
	if (strcasecmp(applet_name, "chrmap") == 0) {
		return chrmap_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "cru") == 0) {
		return sfcrunch_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "extend") == 0) {
		return extend_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "fon") == 0) {
		return foxfont_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "inccol") == 0) {
		return inccol_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "makecol") == 0) {
		return makecol_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "apendcol") == 0) {
		return appendcol_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "mapdec") == 0) {
		return mapdecoder_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "cgx2fx") == 0) {
		return cgx2fx_main(new_argc, new_argv);
	} else {
#elif 'T' == ROBFX_EDITION_C
	if (strcasecmp(applet_name, "palconv") == 0) {
		return palconv_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "sf_crunch") == 0) {
		return sfcrunch_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "sf_decrunch") == 0) {
		return sfdecrunch_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "foxchr") == 0) {
		return foxchr_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "cgx2fx") == 0) {
		return cgx2fx_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "fx2cgx") == 0) {
		return fx2cgx_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "foxfont") == 0) {
		return foxfont_main(new_argc, new_argv);
	} else {
#elif 'S' == ROBFX_EDITION_C
	if (strcasecmp(applet_name, "chrmap") == 0) {
		return chrmap_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "romExtender2") == 0) {
		return extend_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "inccol") == 0) {
		return inccol_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "argonautmapdecoder") == 0) {
		return mapdecoder_main(new_argc, new_argv);
	} else if (strcasecmp(applet_name, "unmerge") == 0) {
		return unmerge_main(new_argc, new_argv);
	} else {
#endif
		printf("RobFX Info: command would be %s, not yet implemented.\n", applet_name);
		return 2;
#ifdef ROBFX_EDITION_C
	}
#endif
}

int main(int argc, char* argv[])
{
#if DEBUG
	fprintf(stderr, "RobFX Debug: argc=%d argv[0]=\"%s\"\n", argc, argv[0]);
#endif
	const char* applet_name = get_applet_name(argv[0]);
	char* unknown_name = NULL;
	byte shift = 0;
	if ((applet_name == NULL) && (argc >= 2)) {
		applet_name = get_applet_name(argv[1]);
		if (applet_name == NULL) {
			unknown_name = argv[1];
		} else {
			shift = 1;
		}
	}
	if (argc <= 1 + shift) {
		output_logo();
	}
	if (unknown_name != NULL) {
		fprintf(stderr, "RobFX Error: unknown command \"%s\"\n", unknown_name);
	}
	if (applet_name == NULL) {
		output_usage();
		return 1;
	} else {
		return pivot_applet(applet_name, shift, argc, argv);
	}
}
