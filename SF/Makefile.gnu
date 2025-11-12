#########################
# UltraStarFox Makefile #
#########################

# Detect what we're running on
ifneq ($(strip ${DJGPP}),)
    PLATFORM := djgpp
else ifeq ($(OS),Windows_NT)
    ifndef MSYSTEM
        # Windows without MSYS2
        PLATFORM := windows
    else
        # Windows with MSYS2
        PLATFORM := msys2
    endif
else
    # Assume *nix if not Windows
    PLATFORM := nix
    UNAME_S := $(shell uname)
endif

# Silence the assembler+linker unless an error occurs
QUIET ?= false

# Whether to colorize build messages
COLOR ?= 1

# Disable assembler ANSI codes (must be handled differently for MSYS2, see below)
NOANSI=

# Build MSU-1 data file?
MSU1 ?= 0

# Use the RobFX integrated multi-purpose build tool from Repzilon's fork?
USEROBFX ?= 0

# Newline character to use (adjust this if newlines aren't working in your terminal)
# TODO : handle colors on DJGPP
ifeq ($(PLATFORM),djgpp)
	NEWLINE=\r\n
    DIRSEP=\\
    EXE=.EXE
else ifeq ($(PLATFORM),windows)
    COLOR=1
    NEWLINE=
    DIRSEP=\\
    EXE=.exe
else ifeq ($(PLATFORM),msys2)
    # If we detect MSYS, handle disabling assembler ANSI codes internally in INC/HEADER.INC and use the correct newline
    NOANSI=
    NEWLINE=\r\n
    DIRSEP=/
    EXE=.exe
else ifeq ($(PLATFORM),nix)
    NEWLINE=\n
    DIRSEP=/
    EXE=
endif

# If on Linux, use Wine to run DOSBox-X headless for Windows, if installed. Otherwise, run the native version
ifeq ($(UNAME_S),Linux)
    WINE=$(shell which wine)
else
    WINE=
endif

# DOSBox-X Headless DOS userland application emulator executable
# No need for an emulator on DJGPP, it is already DOS
ifeq ($(PLATFORM),djgpp)
    MSDOS=
else ifeq ($(PLATFORM),windows)
    MSDOS=dosbox-x.exe -headless
else ifneq ($(WINE),)
    MSDOS=$(WINE) ./dosbox-x.exe -headless
else
    MSDOS=$(shell which dosbox-x) -headless
    #MSDOS=$(shell which dosbox-x) -fastlaunch -nolog -set "sdl videodriver=dummy" -set "cpu cycles=max"
endif

## Common tool directories
# Essential MS-DOS binaries
DIR_USFBIN := ..$(DIRSEP)BIN$(DIRSEP)
# Per-platform community built binaries
ifeq ($(PLATFORM),djgpp)
    DIR_TOOLBIN := ..$(DIRSEP)TOOLS$(DIRSEP)binaries$(DIRSEP)msdos$(DIRSEP)
else ifeq ($(PLATFORM),windows)
    DIR_TOOLBIN := ..$(DIRSEP)TOOLS$(DIRSEP)binaries$(DIRSEP)windows$(DIRSEP)
else
    DIR_TOOLBIN := ..$(DIRSEP)TOOLS$(DIRSEP)binaries$(DIRSEP)$(UNAME_S)$(DIRSEP)
endif
# Main toolchain directory, selected per platform
ifeq ($(PLATFORM),djgpp)
    DIR_TOOLCHAIN := $(DIR_USFBIN)
else ifeq ($(PLATFORM),windows)
    DIR_TOOLCHAIN := ..$(DIRSEP)win_bin$(DIRSEP)
else
    DIR_TOOLCHAIN := $(DIR_TOOLBIN)
endif

# Assembler
ASM=$(MSDOS) ARGSFXX.EXE
# Setup heap for SASM and export symbols for ARGSFX
ASMFLAGS=$(NOANSI) -m30 -e__notitle -e__heap=14400 -z

# MSU-1 Data file Assembler
MSUASM=$(MSDOS) SASMX.EXE
MSUFLAGS=$(NOANSI) -m30 -e__heap=14400 -e__notitle

# Linker
LINK=$(MSDOS) ARGLINK.EXE
LOPTS=-b30 -h1024 -t7d -z

# Checksum Fixer
ifeq ($(PLATFORM),djgpp)
    CHECK=$(DIR_USFBIN)sfcheck$(EXE)
else ifeq ($(PLATFORM),windows)
    CHECK=../bin/superfamicheck$(EXE)
else
    CHECK=$(DIR_TOOLBIN)superfamicheck$(EXE)
endif
COPTS=-s -f

ifeq ($(USEROBFX), 1)
    ifeq ($(PLATFORM),djgpp)
        ROBFXB=$(DIR_USFBIN)robfxb$(EXE)
    else
        ROBFXB=..$(DIRSEP)TOOLS$(DIRSEP)robfx.src$(DIRSEP)robfxb$(EXE)
    endif

    EXTEND=$(ROBFXB) extend
    MERGE=$(ROBFXB) cgx2fx
    CRU=$(ROBFXB) cru
    FONT=$(ROBFXB) fon
    MAPDEC=$(ROBFXB) mapdec
    MC=$(ROBFXB) apendcol
    CHRMAP=$(ROBFXB) chrmap
else
# ROM Extender
    ifeq ($(PLATFORM),djgpp)
        EXTEND=$(DIR_TOOLCHAIN)extend$(EXE)
    else ifeq ($(PLATFORM),windows)
        EXTEND=$(DIR_TOOLCHAIN)romextender$(EXE)
    else
        EXTEND=$(DIR_TOOLCHAIN)romExtender2$(EXE)
    endif

# FXGFX Interleaver
    MERGE=$(DIR_TOOLCHAIN)cgx2fx$(EXE)

# Graphics Cruncher
    ifeq ($(PLATFORM),djgpp)
        CRU=$(DIR_TOOLCHAIN)cru$(EXE)
    else
        CRU=$(DIR_TOOLCHAIN)sf_crunch$(EXE)
    endif

# ALLCOLS Builder
    ifeq ($(PLATFORM),windows)
        MC=DATA\COL\MC.BAT
    else
        MC=$(DIR_TOOLBIN)apendcol$(EXE)
    endif

# Font Converter
    ifeq ($(PLATFORM),djgpp)
        FONT=$(DIR_TOOLCHAIN)fon$(EXE)
    else
        FONT=$(DIR_TOOLCHAIN)foxfont$(EXE)
    endif

# Argonaut .MAP File Decoder
    ifeq ($(PLATFORM),djgpp)
        MAPDEC=$(DIR_TOOLCHAIN)mapdec$(EXE)
    else
        MAPDEC=$(DIR_TOOLCHAIN)argonautmapdec$(EXE)
    endif

# Script Tokenizer
    CHRMAP=$(DIR_TOOLCHAIN)chrmap$(EXE)
endif

# Extended size in Mbits, byte to pad with
EXTOPTS= --auto ff

# USB2SNES CLI Utility
USB2SNES=../bin/usb2snes-cli.exe

# Terminal-specific commands

# Print Command
ifeq ($(PLATFORM),djgpp)
    PRINT ?= ..$(DIRSEP)BIN$(DIRSEP)printf.exe
else ifeq ($(PLATFORM),windows)
    PRINT ?= ..\win_bin\printf.exe
else
    PRINT ?= printf
endif

# Move Command
ifeq ($(PLATFORM),djgpp)
    MV=move
else ifeq ($(PLATFORM),windows)
    MV=move
else
    MV=mv
endif

# Delete Command
ifeq ($(PLATFORM),djgpp)
    DEL=del
else ifeq ($(PLATFORM),windows)
    DEL=del
else
    DEL=rm -rf
endif

# Touch Command
ifeq ($(PLATFORM),djgpp)
    TOUCH=copy NUL
else ifeq ($(PLATFORM),windows)
# FIXME : for Windows NT CMD, a macro doing «type nul >>file & copy file +,,» is needed
    TOUCH=copy NUL
else
    TOUCH=touch
endif

# File Checksum Calculator
SHA1SUM=sha1sum

############################

# ANSI color codes for status messages
ifeq ($(COLOR),1)
NO_COL=\033[0m
GREEN=\033[32m
YELLOW=\033[33m
BLUE=\033[34m
RED=\033[31m
BLINK=\033[32;5m
endif

# Common build print status functions
define print
  @$(PRINT) "$(GREEN)$(1) $(YELLOW)$(2)$(GREEN) -> $(BLUE)$(3)$(NO_COL)$(NEWLINE)"
endef

define print2
  @$(PRINT) "$(GREEN)$(1) $(BLUE)$(2)$(NO_COL)$(NEWLINE)"
endef

define print3
  @$(PRINT) "$(GREEN)$(1)$(NO_COL)$(NEWLINE)"
endef

# Function to interleave FXGfx
#	@$(PRINT) "$(GREEN)Interleaving FXGfx: $(YELLOW)$(1) + $(2) $(GREEN) -> $(BLUE)$@$(NO_COL)$(NEWLINE)"
ifeq ($(QUIET), true)
define merge
	@$(MERGE) MSPRITES/$(1) MSPRITES/$(2) $@ > /dev/null 2> /dev/null || \
	@$(MERGE) MSPRITES/$(1) MSPRITES/$(2) $@
endef
else
define merge
	@$(MERGE) MSPRITES/$(1) MSPRITES/$(2) $@
endef
endif

DIR_PAL := DATA$(DIRSEP)COL$(DIRSEP)
ifeq ($(QUIET), true)
define makecol
	@$(MC) $(DIR_PAL)$(1).COL $(2) $(3) > /dev/null 2> /dev/null || \
	@$(MC) $(DIR_PAL)$(1).COL $(2) $(3)
endef
else
define makecol
	@$(MC) $(DIR_PAL)$(1).COL $(2) $(3)
endef
endif

# Recipe to assemble a .ASM file and create a linkable .SOB file
BANK/%.SOB: BANK/%.ASM
	$(call print,Assembling:,$<,$@)

ifeq ($(PLATFORM),windows)
	@$(ASM) -o "$(ASMFLAGS) $(subst /,\,$<) -v$(subst /,\,$@)"
else
    ifneq ($(strip ${MSDOS}),)
        ifeq ($(QUIET), true)
	@$(ASM) -o "$(ASMFLAGS) $< -v$@" > /dev/null 2> /dev/null || \
	@$(ASM) -o "$(ASMFLAGS) $< -v$@"
        else
	$(ASM) -o "$(ASMFLAGS) $< -v$@"
        endif
    else
        ifeq ($(QUIET), true)
	@$(ASM) $(ASMFLAGS) $< -v$@ > /dev/null 2> /dev/null || $(ASM) $(ASMFLAGS) $< -v$@
        else
	$(ASM) $(ASMFLAGS) $< -v$@
        endif
    endif
endif

# I have no idea why it is needed with DJGPP for tiles and screens, and
# not for neither assembly source nor bitmap fonts.
ifeq ($(PLATFORM),djgpp)
DATA/%.CGX:
	true

DATA/%.SCR:
	true
endif

# Recipes to crunch graphics
DATA/%.CCR: DATA/%.CGX
#	$(call print,Crunching Tiles:,$<,$@)
    ifeq ($(QUIET), true)
	@$(CRU) $< DATA/$*.CCR > /dev/null 2> /dev/null || @$(CRU) $< DATA/$*.CCR
    else
	@$(CRU) $< $@
    endif

DATA/%.PCR: DATA/%.SCR
#	$(call print,Crunching Screen:,$<,$@)
    ifeq ($(QUIET), true)
	@$(CRU) $< DATA/$*.PCR > /dev/null 2> /dev/null || @$(CRU) $< DATA/$*.PCR
    else
	@$(CRU) $< DATA/$*.PCR
    endif

# Recipe to convert BMP to FON
DATA/FONT/%.fon: DATA/FONT/%.bmp
#	$(call print,Encoding Font:,$<,$@)
    ifeq ($(QUIET), true)
	@$(FONT) $< > /dev/null 2> /dev/null || @$(FONT) $<
    else
	@$(FONT) $<
    endif

#!! If you add/remove a cgx/scr in these two lists, make sure to add/remove the corresponding file.
# Crunched tilesets
CCRFILES= DATA/1-3-B.CCR DATA/2-3B.CCR DATA/3-4.CCR DATA/B.CCR DATA/CONT.CCR DATA/DOG.CCR \
 DATA/F-1.CCR DATA/FS-BG3.CCR DATA/MAP-G.CCR DATA/OBJ-2.CCR DATA/SPACE.CCR DATA/T-ST.CCR \
 DATA/1-4.CCR DATA/2-4.CCR DATA/AND.CCR DATA/C-M.CCR DATA/CP-P.CCR DATA/E-TEST.CCR \
 DATA/F-OBJ.CCR DATA/HOLE-A.CCR DATA/MAP.CCR DATA/OBJ-3.CCR DATA/ST-P.CCR DATA/TI-3-G.CCR \
 DATA/2-2.CCR DATA/3-2.CCR DATA/B-HOLE.CCR DATA/CONT-2-G.CCR DATA/CP.CCR DATA/E-TEST2.CCR \
 DATA/FOX-G.CCR DATA/LSB.CCR DATA/OBJ-1-G.CCR DATA/OBJ-4.CCR DATA/OOPS.CCR DATA/STARS.CCR \
 DATA/TI-3-US.CCR DATA/2-3.CCR DATA/3-3.CCR DATA/B-M.CCR DATA/CONT-2.CCR DATA/DEMO.CCR \
 DATA/FOX.CCR DATA/M.CCR DATA/OBJ-1.CCR DATA/T-SP.CCR DATA/TI-3.CCR DATA/CONT-2-F.CCR \
 DATA/MAP-F.CCR DATA/OBJ-1-F.CCR DATA/OBJ-2-F.CCR DATA/FOX-F.CCR DATA/CP-FF.CCR

# Crunched tilemaps
PCRFILES= DATA/1-3-B.PCR DATA/2-3.PCR DATA/3-2.PCR DATA/B-HOLE.PCR DATA/CONT.PCR DATA/DOG.PCR \
 DATA/F-1.PCR DATA/LAST.PCR DATA/T-SP.PCR DATA/TI-3-US.PCR DATA/1-3.PCR DATA/2-3B.PCR \
 DATA/3-3.PCR DATA/B.PCR DATA/CP-P.PCR DATA/E-TEST.PCR DATA/FOX.PCR DATA/LSB.PCR DATA/ST-P.PCR \
 DATA/T-SS.PCR DATA/TI-3.PCR DATA/1-4.PCR DATA/2-3H.PCR DATA/3-4.PCR DATA/CONT-2-G.PCR \
 DATA/CP.PCR DATA/E-TEST2.PCR DATA/FS-NI.PCR DATA/M.PCR DATA/OOPS.PCR DATA/STARS.PCR DATA/T-ST.PCR \
 DATA/2-2.PCR DATA/2-4.PCR DATA/AND.PCR DATA/CONT-2.PCR DATA/DEMO.PCR DATA/HOLE-A.PCR DATA/MAP.PCR \
 DATA/T-F-S.PCR DATA/TI-3-G.PCR DATA/MAP-2.PCR DATA/CONT-2-F.PCR

#!! If you add/remove a font, make sure to add/remove the corresponding file.
# Font files converted from bmp
FONFILES= DATA/FONT/MOJI_0.fon DATA/FONT/MOJI_D.fon

# Banks to assemble
SOBFILES= \
 BANK/BANK0.SOB \
 BANK/BANK1.SOB \
 BANK/BANK2.SOB \
 BANK/BANK4.SOB \
 BANK/BANK5.SOB \
 BANK/BANK6.SOB \
 BANK/BANK7.SOB \
 BANK/BANK8.SOB \
 BANK/BANK9.SOB \
 BANK/BANK10.SOB \
 BANK/BANK11.SOB \
 BANK/SHBANKS.SOB \
 BANK/INCBINS.SOB


# Everything that should be done when make is executed
all: welcome check-jobs text make-allcols msprites crunch fonts sf.msu sf.sfc donebld

welcome:
	@$(PRINT) "$(YELLOW)Welcome to UltraStarFox (Repzilon's fork)!!$(NO_COL)$(NEWLINE)"
# Platform Detection
ifeq ($(PLATFORM),windows)
	@$(PRINT) "$(GREEN)You're on $(YELLOW)Windows!$(NO_COL)$(NEWLINE)"
else ifeq ($(PLATFORM),msys2)
	@$(PRINT) "$(GREEN)You're on $(YELLOW)MSYS2!$(NO_COL)$(NEWLINE)"
else ifeq ($(PLATFORM),nix)
	@$(PRINT) "$(GREEN)You're on $(YELLOW)$(UNAME_S)!$(NO_COL)$(NEWLINE)"
else ifeq ($(PLATFORM),djgpp)
	@$(PRINT) "$(GREEN)You're on $(YELLOW)DJGPP!$(NO_COL)$(NEWLINE)"
endif
ifeq ($(USEROBFX),1)
	@$(PRINT) "$(GREEN)Introducing the integrated multipurpose build tool, $(YELLOW)RobFX!$(NO_COL)$(NEWLINE)"
endif

# Check for job flags and print a warning
check-jobs:
ifeq ($(PLATFORM), djgpp)
else ifeq ($(PLATFORM), windows)
else
	$(call print3,Checking parallel build jobs...)
	@case "$(MAKEFLAGS)" in \
		*-j*) \
			$(PRINT) "$(RED)WARNING: A parallel job count greater than 1 may cause issues!!$(NO_COL)$(NEWLINE)"; \
		;; \
	esac
endif

# Tokenize localized script
text:
	$(call print3,Tokenizing localized scripts...)
	@$(CHRMAP) --tokenize MSG$(DIRSEP)chrmap15.dat MSG$(DIRSEP)GERMAN.INC MSG$(DIRSEP)GERMAN.MSG
	@$(CHRMAP) --tokenize MSG$(DIRSEP)chrmap15.dat MSG$(DIRSEP)FRENCH.INC MSG$(DIRSEP)FRENCH.MSG
	@$(CHRMAP) --tokenize MSG$(DIRSEP)chrmapjp.dat MSG$(DIRSEP)JAPANESE.INC MSG$(DIRSEP)JAPANESE.MSG

# Initialize allcols.col
init-allcols:
	$(call print3,Building ALLCOLS...)
	@$(DEL) allcols.col
	@$(TOUCH) allcols.col
	@$(TOUCH) col2.tmp

# List of palette source files
# Both of these lists must match SF/INC/KALCS.INC's list!!
ALLCOLS_PALETTES := \
 $(DIR_PAL)OOPS.COL \
 $(DIR_PAL)BG2-A.COL \
 $(DIR_PAL)BG2-B.COL \
 $(DIR_PAL)BG2-C.COL \
 $(DIR_PAL)BG2-D.COL \
 $(DIR_PAL)BG2-E.COL \
 $(DIR_PAL)BG2-F.COL \
 $(DIR_PAL)BG2-G.COL \
 $(DIR_PAL)T-M.COL \
 $(DIR_PAL)T-M-2.COL \
 $(DIR_PAL)T-M-3.COL \
 $(DIR_PAL)T-M-4.COL \
 $(DIR_PAL)B-M.COL \
 $(DIR_PAL)LIGHT.COL \
 $(DIR_PAL)SPACE.COL \
 $(DIR_PAL)STARS.COL \
 $(DIR_PAL)CP.COL \
 $(DIR_PAL)CP-US.COL \
 $(DIR_PAL)CP-USP.COL \
 $(DIR_PAL)CP-P.COL \
 $(DIR_PAL)HOLE.COL \
 $(DIR_PAL)L.COL \
 $(DIR_PAL)E-TEST0.COL \
 $(DIR_PAL)E-TEST.COL \
 $(DIR_PAL)OBJ-1.COL \
 $(DIR_PAL)BG2-E-P.COL

# Palettes to include in ALLCOLS
DATA/COL/allcols.pac: $(ALLCOLS_PALETTES)
	$(call makecol,OOPS,0,2)
	$(call makecol,BG2-A,0,7)
	$(call makecol,BG2-B,0,13)
	$(call makecol,BG2-C,0,7)
	$(call makecol,BG2-D,0,7)
	$(call makecol,BG2-E,0,9)
	$(call makecol,BG2-F,0,7)
	$(call makecol,BG2-G,0,7)
	$(call makecol,T-M,0,7)
	$(call makecol,T-M-2,0,7)
	$(call makecol,T-M-3,0,7)
	$(call makecol,T-M-4,0,7)
	$(call makecol,B-M,0,7)
	$(call makecol,LIGHT,0,7)
	$(call makecol,SPACE,0,7)
	$(call makecol,STARS,0,7)
	$(call makecol,CP,0,7)
	$(call makecol,CP-US,0,7)
	$(call makecol,CP-USP,0,7)
	$(call makecol,CP-P,0,7)
	$(call makecol,HOLE,0,7)
	$(call makecol,L,0,7)
	$(call makecol,E-TEST0,0,7)
	$(call makecol,E-TEST,0,7)
	$(call makecol,OBJ-1,8,13)
	$(call makecol,BG2-E-P,0,9)

# Final step: Crunch all palettes into allcols.pac
	$(CRU) allcols.col DATA/COL/allcols.pac
	$(call print3,Palette crunching complete.)

make-allcols: init-allcols DATA/COL/allcols.pac

# FXGFX files to be interleaved
msprites: MSPRITES/TEX_01.BIN MSPRITES/TEX_23.BIN MSPRITES/TEX_23_A.BIN
	$(call print3,Crunching all tiles then all screens...)

# MSPRITES .BIN recipes
MSPRITES/TEX_01.BIN:
	$(call print3,Interleaving all FXGfx...)
	$(call merge,tex_0.CGX,tex_1.CGX)

MSPRITES/TEX_23.BIN:
	$(call merge,tex_2.CGX,tex_3.CGX)

MSPRITES/TEX_23_A.BIN:
	$(call merge,tex_2.CGX,tex_3_a.CGX)

# Crunch all compressible GFX
crunch: $(CCRFILES) $(PCRFILES)
	$(call print3,Encoding all fonts...)

# Convert fonts
fonts: $(FONFILES)

# The ROM Itself
sf.sfc: $(SOBFILES)
	$(call print2,Linking ROM:,$@)

ifeq ($(PLATFORM),windows)
	@echo $(SOBFILES) > flist.tmp
else
	@echo $(SOBFILES) | sed 's/\//\\/g' > flist.tmp
endif

ifeq ($(PLATFORM),windows)
	$(LINK) -o "$(LOPTS) -o$@ @flist.tmp"
else
    ifneq ($(strip ${MSDOS}),)
        ifeq ($(QUIET), true)
	@$(LINK) -o "$(LOPTS) -o$@ @flist.tmp" > /dev/null 2> /dev/null || \
	@$(LINK) -o "$(LOPTS) -o$@ @flist.tmp"
        else
	$(LINK) -o "$(LOPTS) -o$@ @flist.tmp"
        endif
    else
        ifeq ($(QUIET), true)
	@$(LINK) $(LOPTS) -o$@ @flist.tmp > /dev/null 2> /dev/null || $(LINK) $(LOPTS) -o$@ @flist.tmp
        else
	$(LINK) $(LOPTS) -o$@ @flist.tmp
        endif
    endif
endif

	@$(DEL) flist.tmp

ifeq ($(PLATFORM),windows)
	@$(EXTEND) SF.SFC $(EXTOPTS)
else
	$(call print2,Extending ROM:,$@)
    ifeq ($(QUIET), true)
	@$(EXTEND) SF.SFC $(EXTOPTS) > /dev/null 2> /dev/null || $(EXTEND) SF.SFC $(EXTOPTS)
    else
	@$(EXTEND) SF.SFC $(EXTOPTS)
    endif
endif

ifeq ($(PLATFORM),djgpp)
	@ren SF.SFC sf.sfc
	@ren SF.MSU sf.msu
else ifeq ($(PLATFORM),windows)
	@ren SF.SFC sf.sfc
	@ren SF.MSU sf.msu
else
	@$(MV) SF.SFC sf.sfc || true
	@$(MV) SF.MSU sf.msu || true
endif
ifeq ($(PLATFORM),windows)
	@$(CHECK) $(COPTS) $@
else
	$(call print2,Fixing Checksum:,$@)
    ifeq ($(QUIET), true)
	@$(CHECK) $(COPTS) sf.sfc > /dev/null 2> /dev/null || $(CHECK) $(COPTS) sf.sfc
    else
	@$(CHECK) $(COPTS) sf.sfc
    endif
endif

ifeq ($(PLATFORM),windows)
	@certutil -hashfile sf.sfc SHA1
else ifneq ($(PLATFORM),djgpp)
	@$(SHA1SUM) sf.sfc
endif
	@$(PRINT) "${BLINK}Build succeeded.$(NO_COL)$(NEWLINE)"

# MSU-1 Data File
sf.msu:
ifeq ($(MSU1),1)
ifeq ($(PLATFORM),windows)
	@$(MSUASM) -o "$(MSUFLAGS) MSUDATA\MSUDATA.ASM -o$@"
else
    ifneq ($(strip ${MSDOS}),)
        ifeq ($(QUIET), true)
	@$(MSUASM) -o "$(MSUFLAGS) MSUDATA/MSUDATA.ASM -o$@" > /dev/null 2> /dev/null || \
	@$(MSUASM) -o "$(MSUFLAGS) MSUDATA/MSUDATA.ASM -o$@"
        else
	$(MSUASM) -o "$(MSUFLAGS) MSUDATA/MSUDATA.ASM -o$@"
        endif
    else
        ifeq ($(QUIET), true)
	@$(MSUASM) $(MSUFLAGS) MSUDATA/MSUDATA.ASM -o$@ > /dev/null 2> /dev/null || \
	@$(MSUASM) $(MSUFLAGS) MSUDATA/MSUDATA.ASM -o$@
        else
	$(MSUASM) $(MSUFLAGS) MSUDATA/MSUDATA.ASM -o$@
        endif
    endif
endif
endif

donebld: sf.sfc
ifeq ($(PLATFORM),djgpp)
	@copy sf.sfc ..\\sf.sfc
	@del sf.sfc
	@copy sf.msu ..\\sf.msu
	@del sf.msu
	@if exist BANKS.CSV $(MV) BANKS.CSV ..\\banks.csv
else ifeq ($(PLATFORM),windows)
	@copy sf.sfc ..\\sf.sfc
	@del sf.sfc
	@copy sf.msu ..\\sf.msu
	@del sf.msu
	@if exist BANKS.CSV $(MV) BANKS.CSV ..\\banks.csv
else
	@$(MV) sf.sfc ../sf.sfc
	@$(MV) sf.msu ../sf.msu || true
	@{ [ -f BANKS.CSV ] && $(MV) BANKS.CSV ../banks.csv || true; }
endif
	@$(MAPDEC) SF.MAP ..$(DIRSEP)symbols.txt
	@$(DEL) SF.MAP
	@$(DEL) MSGS.TXT
	@$(DEL) MSG$(DIRSEP)FRENCH.MSG
	@$(DEL) MSG$(DIRSEP)GERMAN.MSG
	@$(DEL) MSG$(DIRSEP)JAPANESE.MSG

# It is miserable I cannot use $(DIRSEP) here and must resort to
# command duplication
clean:
ifeq ($(PLATFORM),djgpp)
	@$(DEL) ..\sf.sfc
	@$(DEL) ..\banks.csv
	@$(DEL) BANK\*.SOB
	@$(DEL) BANK\*.MAP 
	@$(DEL) *.MAP
	@$(DEL) MSPRITES\*.BIN
	@$(DEL) DATA\*.CCR
	@$(DEL) DATA\*.PCR
	@$(DEL) DATA\FONT\MOJI_0.fon
	@$(DEL) DATA\FONT\MOJI_D.fon
	@$(DEL) DATA\COL\allcols.col
	@$(DEL) DATA\COL\allcols.pac
	@$(DEL) DATA\allcols.col
	@$(DEL) DATA\allcols.pac
	@$(DEL) sf.sfc
	@$(DEL) BANKS.CSV
	@$(DEL) ..\symbols.txt
	@$(DEL) MSUDATA\MSUDATA.INC
	@$(DEL) MSG\FRENCH.MSG
	@$(DEL) MSG\GERMAN.MSG
	@$(DEL) MSG\JAPANESE.MSG
else
	@$(DEL) ../sf.sfc
	@$(DEL) ../banks.csv
	@$(DEL) BANK/*.SOB
	@$(DEL) BANK/*.MAP 
	@$(DEL) *.MAP
	@$(DEL) MSPRITES/*.BIN
	@$(DEL) DATA/*.CCR
	@$(DEL) DATA/*.PCR
	@$(DEL) DATA/FONT/MOJI_0.fon
	@$(DEL) DATA/FONT/MOJI_D.fon
	@$(DEL) DATA/COL/allcols.col
	@$(DEL) DATA/COL/allcols.pac
	@$(DEL) DATA/allcols.col
	@$(DEL) DATA/allcols.pac
	@$(DEL) sf.sfc
	@$(DEL) BANKS.CSV
	@$(DEL) ../symbols.txt
	@$(DEL) MSUDATA/MSUDATA.INC
	@$(DEL) MSG/FRENCH.MSG
	@$(DEL) MSG/GERMAN.MSG
	@$(DEL) MSG/JAPANESE.MSG
endif

upload:
	@$(USB2SNES) --upload ..$(DIRSEP)sf.sfc --path .$(DIRSEP)sf.sfc
	@$(PRINT) "$(NEWLINE)"

boot:
	@$(USB2SNES) --boot .$(DIRSEP)sf.sfc
	@$(PRINT) "$(NEWLINE)"

## The great big list of source files to detect changes for and whatnot

INCFILES = $(wildcard INC/*.INC)
MSUDATA = $(wildcard MSUDATA/*.INC)
EXTFILES = $(wildcard EXT/*.EXT)
CFGFILES = $(wildcard CONFIG/*.INC)
MAPFILES = $(wildcard MAPS/*.*)
SNDFILES = $(wildcard SND/*.*)
MSPRITESFILES = $(wildcard MSPRITES/*.BIN)
STRATFILES = $(wildcard STRAT/*.ASM)
SHAPEFILES = $(wildcard SHAPES/*.ASM)
PATHFILES = $(wildcard PATH/*.ASM)
MSGFILES = $(wildcard MSG/*.*)
ALLFONFILES = $(wildcard DATA/FONT/*.*)
COLFILES = $(wildcard DATA/COL/*.COL)
MARIOFILES = $(wildcard MARIO/*.MC)

STDFILES = $(INCFILES) $(MSUDATA) $(EXTFILES) $(CFGFILES)

## Banks to assemble and files they include

## Banks 0, 32
BANK/BANK0.SOB: \
 $(STDFILES) $(ALLFONFILES) $(STRATFILES) $(PCRFILES) $(SHAPEFILES) \
 BANK/BANK0.ASM \
 ASM/SGTABS.ASM ASM/SGDATA.ASM ASM/MSUDRV.ASM \
 DATA/ETABS.DAT DATA/MAP-OBJ.CGX

## Banks 1, 41
BANK/BANK1.SOB: \
 $(STDFILES) $(ALLFONFILES) $(MSGFILES) $(MARIOFILES) \
 BANK/BANK1.ASM \
 ASM/FONTDATA.ASM ASM/GAMETEXT.ASM

## Banks 2, 3, 31, 36
BANK/BANK2.SOB: \
 $(STDFILES) $(STRATFILES) $(COLFILES) $(PCRFILES) \
 BANK/BANK2.ASM \
 ASM/RAMSTUFF.ASM ASM/IRQ.ASM ASM/HDMATABS.ASM ASM/COLDET.ASM ASM/COLBOXES.ASM ASM/TRANS.ASM \
 ASM/MAIN.ASM ASM/GAME.ASM ASM/WINDOWS.ASM ASM/COLTABS.ASM ASM/DEFSPR.ASM ASM/COLTAB.ASM \
 ASM/LIGHT.ASM ASM/BGS.ASM ASM/OBJ.ASM ASM/PLANETS.ASM ASM/SPRITES.ASM ASM/CONTINUE.ASM \
 ASM/WORLD.ASM ASM/MOTHER.ASM ASM/DEBUG.ASM ASM/BOOTNMI.ASM ASM/BLINK.ASM ASM/NMI.ASM \
 ASM/DRAW.ASM ASM/ENDSEQ.ASM ASM/CONT.ASM ASM/SOUND.ASM \
 DATA/MAPANIM.CHR DATA/MAP-OBJ.COL

## Bank 4
BANK/BANK4.SOB: \
 $(STDFILES) $(STRATFILES) $(PATHFILES) \
 BANK/BANK4.ASM

## Banks 5, 13, 39
BANK/BANK5.SOB: \
 $(STDFILES) $(MAPFILES) $(CCRFILES) $(PCRFILES) $(STRATFILES) \
 BANK/BANK5.ASM

## Banks 6, 33
BANK/BANK6.SOB: \
 $(STDFILES) $(STRATFILES) $(MARIOFILES) \
 BANK/BANK6.ASM

## Bank 7
BANK/BANK7.SOB: \
 $(STDFILES) $(STRATFILES) \
 BANK/BANK7.ASM

## Bank 8
BANK/BANK8.SOB: \
 $(STDFILES) $(STRATFILES) $(SNDFILES) \
 BANK/BANK8.ASM

## Bank 9
BANK/BANK9.SOB: \
 $(STDFILES) $(STRATFILES) $(SNDFILES) \
 BANK/BANK9.ASM

## Bank 10
BANK/BANK10.SOB: \
 $(STDFILES) $(STRATFILES) $(SNDFILES) \
 BANK/BANK10.ASM \
 ASM/MEM.ASM

## Banks 11, 40
BANK/BANK11.SOB: \
 $(STDFILES) $(STRATFILES) \
 BANK/BANK11.ASM \
 ASM/STRINGS.ASM

## Banks 12, 14, 15, 16, 17, 37, 38
BANK/SHBANKS.SOB: \
 $(STDFILES) $(CCRFILES) $(PCRFILES) $(STRATFILES) $(SHAPEFILES) $(SNDFILES) \
 BANK/SHBANKS.ASM

## Banks 18, 19, 20, 21, 22, 23, 35 
BANK/INCBINS.SOB: \
 $(STDFILES) $(CCRFILES) $(PCRFILES) $(COLFILES) $(SNDFILES) $(MSPRITESFILES) $(MARIOFILES) \
 BANK/INCBINS.ASM \
 DATA/COL/allcols.pac DATA/FACE.CGX
