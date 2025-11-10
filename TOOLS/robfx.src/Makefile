## RobFX Makefile for GNU Make and native compilation

# Use spaces ONLY to indent inside conditionals
ifneq ($(strip ${DJGPP}),)
  CC := gcc
  # Note : you cannot use -pipe with DOS
  CFLAGS_OPTIM := -O2 -fomit-frame-pointer -march=pentium3 -s
  # Note: "del" must be lower-case even in DOS
  RM := del
  CP := copy /y
  DIRSEP := \\
  EXE := .EXE
  TRIPLET := i686-pc-dos
  # 8.3 paths for DOS (short names as shown in Windows 98)
  SRC_CHRMAP := ../chrmap~1/Chrmap.c
  SRC_SFCRUNCH := ../cru_src/sf_cru~1.c
  SRC_SFDECRUNCH := ../cru_src/sf_dec~1.c
  SRC_EXTEND := ../extend~1/romExt~1.c
  SRC_FOXFONT := ../Fontconv/foxfon~1/Foxfont.c
  SRC_INCCOL := ../inccol~2/inccol.c
  SRC_MAKECOL := ../inccol~2/Makecol.c
  SRC_APENDCOL := ../inccol~2/apendcol.c
  SRC_MAPDEC := ../mapdec~1/argona~1.c
  SRC_CGX2FX := ../cgx2fx~1/Cgx2fx.c
  SRC_FX2CGX := ../cgx2fx~1/Fx2cgx.c
  SRC_PALCONV := ../palcon~1/palconv.c
  SRC_FOXCHR := ../mugconv/foxchr~1/foxchr.c
  SRC_UNMERGE := ../unmerg~1/fxedit~1.c
  SRC_FREEBSDPRINTF := ../fbsdprtf.src/printf.c
else
  CC := $(shell which cc)
  CFLAGS_OPTIM := -O2 -pipe -fomit-frame-pointer
  # I really mean an NT-based Windows here
  ifeq (${OS},Windows_NT)
    RM := del /q
    CP := copy /y
    DIRSEP := \\
    EXE := .exe
    TRIPLET := ${PROCESSOR_ARCHITECTURE}-pc-winnt
  else
    # *nix assumed here
    RM := rm -f
    ifneq (,$(wildcard /etc/alpine-release))
      CP := install -p
      FORMFACTOR := alpine
    else
      ifeq (Darwin,$(shell uname))
        CP := install -CSv
      else
        CP := install -Cv
      endif
      FORMFACTOR := unknown
    endif
    DIRSEP := /
    EXE :=
    TRIPLET := $(shell uname -m)-$(FORMFACTOR)-$(shell uname)
  endif
  # Long file names for other operating systems
  SRC_CHRMAP := ../chrmap_src/chrmap.c
  SRC_SFCRUNCH := ../cru_src/sf_crunch_mod.c
  SRC_SFDECRUNCH := ../cru_src/sf_decrunch.c
  SRC_EXTEND := ../extend_src/romExtenderv2.c
  SRC_FOXFONT := ../fontconv/foxfont_source/foxfont.c
  SRC_INCCOL := ../inccol_makecol_src/inccol.c
  SRC_MAKECOL := ../inccol_makecol_src/makecol.c
  SRC_APENDCOL := ../inccol_makecol_src/apendcol.c
  SRC_MAPDEC := ../mapdec_src/argonautmapdecoder.c
  SRC_CGX2FX := ../cgx2fx_fx2cgx_src/cgx2fx.c
  SRC_FX2CGX := ../cgx2fx_fx2cgx_src/fx2cgx.c
  SRC_PALCONV := ../palconv_src/palconv.c
  SRC_FOXCHR := ../mugconv/foxchr_source/foxchr.c
  SRC_UNMERGE := ../unmerge_src/fxedit_v2.c
  SRC_FREEBSDPRINTF := ../fbsdprtf.src/printf.c
endif

CFLAGS_HARDEN := -Wall -Wformat -Wformat=2 -Wconversion -Wimplicit-fallthrough -Werror=format-security \
-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 \
-fstack-protector-strong \
-fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing \
-Werror=implicit -Werror=incompatible-pointer-types -Werror=int-conversion
ifneq ($(strip ${DJGPP}),)
  CFLAGS_GCC := -fstack-clash-protection -Wtrampolines
else
  ifeq (Linux,$(shell uname))
    CFLAGS_LINUX := -Wl,-z,nodlopen -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -Wl,--no-copy-dt-needed-entries
  endif
  CFLAGS_NOTDJGPP := -fstrict-flex-arrays=3 -ftrivial-auto-var-init=zero
  ifeq (gcc,$(CC))
    CFLAGS_GCC := -march=native -fstack-clash-protection -Wtrampolines -Wbidi-chars=any
  else 
    CC_IS_SYMLINK := $(shell test -L $(CC); echo $$?)
    # test returns a process exit code; 0 is a success (anything else a failure)
    ifeq (0,$(CC_IS_SYMLINK))
      CC_TARGET := $(shell readlink $(CC))
      ifeq (gcc,$(CC_TARGET))
        CFLAGS_GCC := -march=native -fstack-clash-protection -Wtrampolines -Wbidi-chars=any
      endif
    endif
  endif
  ISA := $(shell uname -m)
  ifeq (x86_64,$(ISA))
    CFLAGS_ISA := -fcf-protection=full
  endif
endif

# FIXME : On aarch64, add the following to CFLAGS_WARN
#-mbranch-protection=standard

COMPILE := $(CC) $(CFLAGS_OPTIM) $(CFLAGS_HARDEN) $(CFLAGS_LINUX) $(CFLAGS_GCC) $(CFLAGS_NOTDJGPP) $(CFLAGS_ISA) -DROBFX -DTRIPLET='"$(TRIPLET)"'
$(info Compiler and flags: $(COMPILE))
USFBIN := ..$(DIRSEP)..$(DIRSEP)bin
ifneq ($(strip ${DJGPP}),)
  BINDIR := ..$(DIRSEP)binaries$(DIRSEP)msdos
else
  ifeq (${OS},Windows_NT)
    BINDIR := ..$(DIRSEP)binaries$(DIRSEP)windows
  else
    BINDIR := ..$(DIRSEP)binaries$(DIRSEP)$(shell uname)
  endif
endif

ROBFXB_SOURCES := robfx.c $(SRC_CHRMAP) $(SRC_SFCRUNCH) $(SRC_EXTEND) $(SRC_FOXFONT) $(SRC_INCCOL) \
$(SRC_MAKECOL) $(SRC_APENDCOL) $(SRC_MAPDEC) $(SRC_CGX2FX) $(SRC_FREEBSDPRINTF)
ROBFXT_SOURCES := robfx.c $(SRC_PALCONV) $(SRC_SFCRUNCH) $(SRC_SFDECRUNCH) $(SRC_FOXCHR) $(SRC_CGX2FX) \
$(SRC_FX2CGX) $(SRC_FOXFONT)
ROBFXS_SOURCES := robfx.c $(SRC_EXTEND) $(SRC_INCCOL) $(SRC_MAPDEC) $(SRC_UNMERGE) $(SRC_CHRMAP)

all: robfxb$(EXE) robfxt$(EXE)

kitchensink: all robfxs$(EXE)

# Commands to build targets (BELOW) must be indented with tabs, never spaces
# Numbers below for DROBFX_EDITION_C are ASCII codes of B, T and S

robfxb$(EXE): $(ROBFXB_SOURCES)
	$(COMPILE) -DROBFX_EDITION_C=66 $(ROBFXB_SOURCES) -o $@

robfxt$(EXE): $(ROBFXT_SOURCES)
	$(COMPILE) -DROBFX_EDITION_C=84 $(ROBFXT_SOURCES) -o $@

robfxs$(EXE): $(ROBFXS_SOURCES)
	$(COMPILE) -DROBFX_EDITION_C=83 $(ROBFXS_SOURCES) -o $@

clean:
	$(RM) robfxb$(EXE)
	$(RM) robfxt$(EXE)
	$(RM) robfxs$(EXE)
	$(RM) robfx$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)robfxb$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)robfxt$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)robfxs$(EXE)
	$(RM) ..$(DIRSEP)robfxt$(EXE)
	$(RM) ..$(DIRSEP)robfxs$(EXE)

# For an unknown reason, mkdir crashes on Windows 98
$(BINDIR): ..$(DIRSEP)binaries
ifeq ($(strip ${DJGPP}),)
	mkdir $(BINDIR)
endif
	
install: kitchensink $(BINDIR)
ifneq ($(strip ${DJGPP}),)
	$(CP) robfxb$(EXE) $(USFBIN)
endif
	$(CP) robfxt$(EXE) $(BINDIR)
	$(CP) robfxs$(EXE) $(BINDIR)

takeover-build: install
	$(RM) $(USFBIN)$(DIRSEP)chrmap$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)cru$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)extend$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)fon$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)inccol$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)makecol$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)apendcol$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)mapdec$(EXE)
	$(RM) $(USFBIN)$(DIRSEP)cgx2fx$(EXE)
ifneq ($(strip ${DJGPP}),)
	$(RM) $(BINDIR)$(DIRSEP)chrmap$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)extend$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)fon$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)inccol$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)makecol$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)apendcol$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)mapdec$(EXE)
endif

# Note: the mix of tabs and spaces under this target is intentional
takeover-tools: install
	$(RM) $(BINDIR)$(DIRSEP)cru$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)decru$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)cgx2fx$(EXE)
ifeq ($(strip ${DJGPP}),)
	$(RM) $(BINDIR)$(DIRSEP)sf_decrunch$(EXE)
  ifneq (${OS},Windows_NT)
	$(RM) ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)palconv && ln -s "../$(BINDIR)/robfxt" ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)palconv
	$(RM) ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)sf_crunch && ln -s "../$(BINDIR)/robfxt" ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)sf_crunch
	$(RM) ..$(DIRSEP)fontconv$(DIRSEP)foxfont && ln -s "$(BINDIR)/robfxt" ..$(DIRSEP)fontconv$(DIRSEP)foxfont
	$(RM) ..$(DIRSEP)mugconv$(DIRSEP)foxchr &&  ln -s "$(BINDIR)/robfxt" ..$(DIRSEP)mugconv$(DIRSEP)foxchr
  endif
else
	$(RM) $(BINDIR)$(DIRSEP)palconv$(EXE)
	$(RM) $(BINDIR)$(DIRSEP)foxchr$(EXE)
endif

takeover-sink: install
ifneq ($(strip ${DJGPP}),)
	@echo "takeover-sink is empty on DJGPP"
else
	$(RM) ..$(DIRSEP)romExtender2$(EXE)
	$(RM) ..$(DIRSEP)inccol$(EXE)
	$(RM) ..$(DIRSEP)argonautmapdec$(EXE)
	$(RM) ..$(DIRSEP)unmerge$(EXE)
	$(RM) ..$(DIRSEP)chrmap$(EXE)
endif

ifneq ($(strip ${DJGPP}),)
takeover: takeover-build takeover-tools takeover-sink
else
takeover: takeover-tools takeover-sink
endif
	@echo "RobFX took over"

help:
	@echo "Available targets: all clean kitchensink install takeover"

.PHONY: all clean kitchensink install takeover takeover-build takeover-tools takeover-sink help
