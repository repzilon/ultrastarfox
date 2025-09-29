CC := cc
CFLAGS_OPTIM := -O2 -pipe -fomit-frame-pointer
CFLAGS_WARN := -W -Wall -Werror=format-security

COMPILE := $(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN)

ROBFXB_SOURCES := robfx.c ../chrmap_src/chrmap.c ../cru_src/sf_crunch_mod.c ../extend_src/romExtenderv2.c ../fontconv/foxfont_source/foxfont.c ../inccol_src/inccol.c ../inccol_src/makecol.c ../inccol_src/apendcol.c ../mapdec_src/argonautmapdecoder.c ../cgx2fx_fx2cgx_src/cgx2fx.c
ROBFXT_SOURCES := robfx.c ../palconv_src/palconv.c ../cru_src/sf_crunch_mod.c ../cru_src/sf_decrunch.c ../mugconv/foxchr_source/foxchr.c ../cgx2fx_fx2cgx_src/cgx2fx.c ../cgx2fx_fx2cgx_src/fx2cgx.c ../fontconv/foxfont_source/foxfont.c
# "romExtender2", "inccol", "argonautmapdecoder", "unmerge", "chrmap"
ROBFXS_SOURCES := robfx.c ../extend_src/romExtenderv2.c ../inccol_src/inccol.c ../mapdec_src/argonautmapdecoder.c ../unmerge_src/fxedit_v2.c ../chrmap_src/chrmap.c

all: robfxb robfxt

kitchensink: all robfxs

# Numbers below for DROBFX_EDITION_C are ASCII codes of B, T and S

robfxb: $(ROBFXB_SOURCES)
	$(COMPILE) -DROBFX -DROBFX_EDITION_C=66 $(ROBFXB_SOURCES) -o $@

robfxt: $(ROBFXT_SOURCES)
	$(COMPILE) -DROBFX -DROBFX_EDITION_C=84 $(ROBFXT_SOURCES) -o $@

robfxs: $(ROBFXS_SOURCES)
	$(COMPILE) -DROBFX -DROBFX_EDITION_C=83 $(ROBFXS_SOURCES) -o $@

clean:
	rm -f robfxb
	rm -f robfxt
	rm -f robfxs
	rm -f robfx

.PHONY: all clean kitchensink
