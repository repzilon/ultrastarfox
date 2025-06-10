## Tools Makefile intended to run modern host systems (macOS, Linux)

SFCONV_VER := 0.11.0
SFCONV_OUT := build/release
CC := cc
# Does -march=native also work on Clang?
CFLAGS_OPTIM := -O2 -pipe

all: bgconv/bin/palconv mugconv/foxchr bgconv/bin/sf_crunch bgconv/bin/superfamiconv mugconv/superfamiconv/superfamiconv cgx2fx fx2cgx fontconv/foxfont

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

clean: clean-tools clean-superfamiconv

distclean: clean-tools
	rm -f SuperFamiconv-*.tar.gz
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

mrproper: distclean nowindows

bgconv/bin/palconv: palconv_src/palconv.c
	$(CC) $(CFLAGS_OPTIM) palconv_src/palconv.c -o bgconv/bin/palconv

bgconv/bin/sf_crunch: cru_src/sf_crunch_mod.c
	$(CC) $(CFLAGS_OPTIM) cru_src/sf_crunch_mod.c -o bgconv/bin/sf_crunch

mugconv/foxchr: mugconv/foxchr_source/foxchr.c mugconv/foxchr_source/foxchr.h
	$(CC) $(CFLAGS_OPTIM) -pipe mugconv/foxchr_source/foxchr.c -o mugconv/foxchr

SuperFamiconv-$(SUPERFAMICONV_VERSION).tar.gz:
	curl https://codeload.github.com/Optiroc/SuperFamiconv/tar.gz/refs/tags/v$(SUPERFAMICONV_VERSION) -o SuperFamiconv-$(SUPERFAMICONV_VERSION).tar.gz

SuperFamiconv-$(SUPERFAMICONV_VERSION)/Makefile: SuperFamiconv-$(SUPERFAMICONV_VERSION).tar.gz
	tar -zxf SuperFamiconv-$(SUPERFAMICONV_VERSION).tar.gz

SuperFamiconv-$(SUPERFAMICONV_VERSION)/bin/superfamiconv: SuperFamiconv-$(SUPERFAMICONV_VERSION)/Makefile
	make -C SuperFamiconv-$(SUPERFAMICONV_VERSION)

bgconv/bin/superfamiconv: SuperFamiconv-$(SUPERFAMICONV_VERSION)/bin/superfamiconv
	install -CS ./SuperFamiconv-$(SUPERFAMICONV_VERSION)/bin/superfamiconv ./bgconv/bin

mugconv/superfamiconv/superfamiconv: SuperFamiconv-$(SUPERFAMICONV_VERSION)/bin/superfamiconv
	install -CS ./SuperFamiconv-$(SUPERFAMICONV_VERSION)/bin/superfamiconv ./mugconv/superfamiconv

cgx2fx: cgx2fx_fx2cgx_src/cgx2fx.c
	$(CC) $(CFLAGS_OPTIM) cgx2fx_fx2cgx_src/cgx2fx.c -o cgx2fx

fx2cgx: cgx2fx_fx2cgx_src/fx2cgx.c
	$(CC) $(CFLAGS_OPTIM) cgx2fx_fx2cgx_src/fx2cgx.c -o fx2cgx

fontconv/foxfont: fontconv/foxfont_source/foxfont.c fontconv/foxfont_source/foxfont.h
	$(CC) $(CFLAGS_OPTIM) fontconv/foxfont_source/foxfont.c -o fontconv/foxfont

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

.PHONY: all clean distclean nowindows mrproper
