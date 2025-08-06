## Tools Makefile intended to run modern host systems (macOS, Linux)

SFCONV_VER := 0.11.0
SFCONV_OUT := build/release
CC := cc
# Does -march=native also work on Clang?
CFLAGS_OPTIM := -O2 -pipe -fomit-frame-pointer
CFLAGS_WARN := -W -Wall -Werror=format-security
#CXXFLAGS_OPTIM := $(CFLAGS_OPTIM) -fvisibility=hidden
#CXXFLAGS_WARN := $(CFLAGS_WARN)

all: bgconv/bin/palconv mugconv/foxchr bgconv/bin/sf_crunch bgconv/bin/superfamiconv mugconv/superfamiconv/superfamiconv cgx2fx fx2cgx fontconv/foxfont

sink: romExtender2 inccol argonautmapdec fxedit2 chrmap

kitchensink: all sink

clean-superfamiconv:
	$(MAKE) -C SuperFamiconv-$(SFCONV_VER) clean

clean-tools:
	rm -f bgconv/bin/palconv
	rm -f bgconv/bin/sf_crunch
	rm -f mugconv/foxchr
	rm -f bgconv/bin/superfamiconv
	rm -f mugconv/superfamiconv/superfamiconv
	rm -f cgx2fx
	rm -f fx2cgx
	rm -f fontconv/foxfont

clean-sink:
	rm -f romExtender2 
	rm -f inccol 
	rm -f argonautmapdec 
	rm -f fxedit2
	rm -f chrmap

clean: clean-tools clean-sink clean-superfamiconv
	rm -rf SharpUltraStarFoxTools/*/bin/
	rm -rf SharpUltraStarFoxTools/*/obj/

distclean: clean-tools clean-sink
	rm -rf SuperFamiconv-*

nowindows:
	rm -f palconv.exe
	rm -f palconv_win64.exe
	rm -f sf_crunch.exe
	rm -f bgconv/bin/palconv.exe
	rm -f bgconv/bin/sf_crunch.exe
	rm -f bgconv/bin/superfamiconv.exe
	rm -f mugconv/superfamiconv/superfamiconv.exe
	rm -f mugconv/foxchr.exe
	rm -f cgx2fx_win.exe
	rm -f fx2cgx_win.exe
	rm -f fontconv/foxfont.exe

permissions:
	chmod -x *.* */*.* */*/*.*
	chmod +x */*.sh

mrproper: distclean nowindows permissions
	rm -f SuperFamiconv-*.tar.gz

bgconv/bin/palconv: palconv_src/palconv.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) palconv_src/palconv.c -o bgconv/bin/palconv

bgconv/bin/sf_crunch: cru_src/sf_crunch_mod.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) cru_src/sf_crunch_mod.c -o bgconv/bin/sf_crunch

mugconv/foxchr: mugconv/foxchr_source/foxchr.c mugconv/foxchr_source/foxchr.h
	$(CC) $(CFLAGS_OPTIM) -pipe $(CFLAGS_WARN) mugconv/foxchr_source/foxchr.c -o mugconv/foxchr

cgx2fx: cgx2fx_fx2cgx_src/cgx2fx.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) cgx2fx_fx2cgx_src/cgx2fx.c -o cgx2fx

fx2cgx: cgx2fx_fx2cgx_src/fx2cgx.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) cgx2fx_fx2cgx_src/fx2cgx.c -o fx2cgx

fontconv/foxfont: fontconv/foxfont_source/foxfont.c fontconv/foxfont_source/foxfont.h
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) fontconv/foxfont_source/foxfont.c -o fontconv/foxfont

SuperFamiconv-$(SFCONV_VER).tar.gz:
	curl https://codeload.github.com/Optiroc/SuperFamiconv/tar.gz/refs/tags/v$(SFCONV_VER) -o SuperFamiconv-$(SFCONV_VER).tar.gz

SuperFamiconv-$(SFCONV_VER)/Makefile: SuperFamiconv-$(SFCONV_VER).tar.gz
	tar -zxf SuperFamiconv-$(SFCONV_VER).tar.gz

SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv: SuperFamiconv-$(SFCONV_VER)/Makefile
	$(MAKE) -C SuperFamiconv-$(SFCONV_VER)

bgconv/bin/superfamiconv: SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv
	install -CS ./SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv ./bgconv/bin

mugconv/superfamiconv/superfamiconv: SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv
	install -CS ./SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv ./mugconv/superfamiconv

romExtender2: extend_src/romExtenderv2.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) extend_src/romExtenderv2.c -o romExtender2

inccol: inccol_src/inccol.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) inccol_src/inccol.c -o inccol

argonautmapdec: mapdec_src/argonautmapdecoder.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) mapdec_src/argonautmapdecoder.c -o argonautmapdec

fxedit2: unmerge_src/fxedit_v2.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) unmerge_src/fxedit_v2.c -o fxedit2

chrmap: chrmap_src/chrmap.c
	$(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN) chrmap_src/chrmap.c -o chrmap

.PHONY: all sink kitchensink clean distclean nowindows permissions mrproper
