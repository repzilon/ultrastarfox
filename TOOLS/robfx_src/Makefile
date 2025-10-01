## RobFX Makefile for GNU Make and native compilation

# Use spaces ONLY to indent inside conditionals
ifneq ($(strip ${DJGPP}),)
  CC := gcc
  # Note : you cannot use -pipe with DOS
  CFLAGS_OPTIM := -O2 -fomit-frame-pointer -march=pentium3 -s
  CFLAGS_WARN := -W -Wall -Werror=format-security
  # Note: "del" must be lowercase even in DOS
  RM := del
  CP := copy /y
  DIRSEP := \\
  EXE := .EXE
  QUAD := i686-pc-dos-djgpp
  # 8.3 paths for DOS (short names as shown in Windows 98)
  SRC_CHRMAP := ../chrmap~1/Chrmap.c
  SRC_SFCRUNCH := ../cru_src/sf_cru~1.c
  SRC_SFDECRUNCH := ../cru_src/sf_dec~1.c
  SRC_EXTEND := ../extend~1/romExt~1.c
  SRC_FOXFONT := ../Fontconv/foxfon~1/Foxfont.c
  SRC_INCCOL := ../inccol~1/inccol.c
  SRC_MAKECOL := ../inccol~1/Makecol.c
  SRC_APENDCOL := ../inccol~1/apendcol.c
  SRC_MAPDEC := ../mapdec~1/argona~1.c
  SRC_CGX2FX := ../cgx2fx~1/Cgx2fx.c
  SRC_FX2CGX := ../cgx2fx~1/Fx2cgx.c
  SRC_PALCONV := ../palcon~1/palconv.c
  SRC_FOXCHR := ../mugconv/foxchr~1/foxchr.c
  SRC_UNMERGE := ../unmerg~1/fxedit~1.c
else
  CC := cc
  CFLAGS_OPTIM := -O2 -pipe -fomit-frame-pointer
  # I really mean an NT-based Windows here
  ifeq (${OS},Windows_NT)
    RM := del /q
    CP := copy /y
    DIRSEP := \\
    EXE := .exe
    QUAD := ${PROCESSOR_ARCHITECTURE}-pc-winnt
  else
    # *nix assumed here
    RM := rm -f
    ifneq (,$(wildcard /etc/alpine-release))
      CP := install -p
    else
      CP := install -CS
    endif
    DIRSEP := /
    EXE :=
    QUAD := $(shell uname -m)-unknown-$(shell uname)
  endif
  # Long file names for other operating systems
  SRC_CHRMAP := ../chrmap_src/Chrmap.c
  SRC_SFCRUNCH := ../cru_src/sf_crunch_mod.c
  SRC_SFDECRUNCH := ../cru_src/sf_decrunch.c
  SRC_EXTEND := ../extend_src/romExtenderv2.c
  SRC_FOXFONT := ../Fontconv/foxfont_source/Foxfont.c
  SRC_INCCOL := ../inccol_src/inccol.c
  SRC_MAKECOL := ../inccol_src/Makecol.c
  SRC_APENDCOL := ../inccol_src/apendcol.c
  SRC_MAPDEC := ../mapdec_src/argonautmapdecoder.c
  SRC_CGX2FX := ../cgx2fx_fx2cgx_src/Cgx2fx.c
  SRC_FX2CGX := ../cgx2fx_fx2cgx_src/Fx2cgx.c
  SRC_PALCONV := ../palconv_src/palconv.c
  SRC_FOXCHR := ../mugconv/foxchr_source/foxchr.c
  SRC_UNMERGE := ../unmerge_src/fxedit_v2.c
endif

CFLAGS_WARN := -W -Wall -Werror=format-security
COMPILE := $(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) -DROBFX -DQUAD='"$(QUAD)"'
USFBIN := ..$(DIRSEP)..$(DIRSEP)bin

ROBFXB_SOURCES := robfx.c $(SRC_CHRMAP) $(SRC_SFCRUNCH) $(SRC_EXTEND) $(SRC_FOXFONT) $(SRC_INCCOL) $(SRC_MAKECOL) $(SRC_APENDCOL) $(SRC_MAPDEC) $(SRC_CGX2FX)
ROBFXT_SOURCES := robfx.c $(SRC_PALCONV) $(SRC_SFCRUNCH) $(SRC_SFDECRUNCH) $(SRC_FOXCHR) $(SRC_CGX2FX) $(SRC_FX2CGX) $(SRC_FOXFONT)
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
	$(RM) ..$(DIRSEP)robfxt$(EXE)
	$(RM) ..$(DIRSEP)robfxs$(EXE)

install: kitchensink
ifneq ($(strip ${DJGPP}),)
	$(CP) robfxb$(EXE) $(USFBIN)
endif
	$(CP) robfxt$(EXE) ..
	$(CP) robfxs$(EXE) ..

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

# Note: the mix of tabs and spaces under this target is intentional
takeover-tools: install
	$(RM) ..$(DIRSEP)cru$(EXE)
	$(RM) ..$(DIRSEP)decru$(EXE)
	$(RM) ..$(DIRSEP)cgx2fx$(EXE)
	$(RM) ..$(DIRSEP)fx2cgx$(EXE)
ifeq ($(strip ${DJGPP}),)
	$(RM) ..$(DIRSEP)sf_decrunch$(EXE)
  ifneq (${OS},Windows_NT)
	$(RM) ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)palconv && ln -s "../../robfxt" ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)palconv
	$(RM) ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)sf_crunch && ln -s "../../robfxt" ..$(DIRSEP)bgconv$(DIRSEP)bin$(DIRSEP)sf_crunch
	$(RM) ..$(DIRSEP)fontconv$(DIRSEP)foxfont && ln -s "../robfxt" ..$(DIRSEP)fontconv$(DIRSEP)foxfont
	$(RM) ..$(DIRSEP)mugconv$(DIRSEP)foxchr &&  ln -s "../robfxt" ..$(DIRSEP)mugconv$(DIRSEP)foxchr
  endif
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

.PHONY: all clean kitchensink install takeover takeover-build takeover-tools takeover-sink
