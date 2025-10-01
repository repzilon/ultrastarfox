## Tools Makefile intended to run modern *nix host systems (macOS, Linux)

SFCONV_VER := 0.11.0
SFCONV_OUT := build/release
CC := cc
# Does -march=native also work on Clang?
CFLAGS_OPTIM := -O2 -pipe -fomit-frame-pointer
CFLAGS_WARN := -W -Wall -Werror=format-security
#CXXFLAGS_OPTIM := $(CFLAGS_OPTIM) -fvisibility=hidden
#CXXFLAGS_WARN := $(CFLAGS_WARN)
ifneq (,$(wildcard /etc/alpine-release))
  INSTALL_FLAGS := -p
else
  ifeq ("Darwin",$(shell uname))
    INSTALL_FLAGS := -CSv
  else
    INSTALL_FLAGS := -Cv
  endif
endif 
COMPILE := $(CC) $(CFLAGS_OPTIM) $(CFLAGS_WARN)

all: bgconv/bin/palconv mugconv/foxchr bgconv/bin/sf_crunch sf_decrunch bgconv/bin/superfamiconv mugconv/superfamiconv/superfamiconv cgx2fx fx2cgx fontconv/foxfont

sink: romExtender2 inccol argonautmapdec unmerge chrmap

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
	rm -f sf_decrunch

clean-sink:
	rm -f romExtender2 
	rm -f inccol 
	rm -f argonautmapdec 
	rm -f unmerge
	rm -f chrmap

clean: clean-tools clean-sink clean-superfamiconv
	rm -rf SharpUltraStarFoxTools/*/bin/
	rm -rf SharpUltraStarFoxTools/*/obj/
	$(MAKE) -C robfx_src clean

distclean: clean-tools clean-sink
	rm -rf SuperFamiconv-*
	$(MAKE) -C robfx_src clean

nowindows:
	rm -f palconv.exe
	rm -f palconv_win64.exe
	rm -f sf_crunch.exe
	rm -f sf_decrunch.exe
	rm -f bgconv/bin/palconv.exe
	rm -f bgconv/bin/sf_crunch.exe
	rm -f bgconv/bin/superfamiconv.exe
	rm -f mugconv/superfamiconv/superfamiconv.exe
	rm -f mugconv/foxchr.exe
	rm -f cgx2fx_win.exe
	rm -f fx2cgx_win.exe
	rm -f fontconv/foxfont.exe
	rm -f unmerge.exe

permissions:
	chmod -x *.* */*.* */*/*.*
	chmod +x */*.sh

mrproper: distclean nowindows permissions
	rm -f SuperFamiconv-*.tar.gz

bgconv/bin/palconv: palconv_src/palconv.c
	$(COMPILE) $< -o $@

bgconv/bin/sf_crunch: cru_src/sf_crunch_mod.c
	$(COMPILE) $< -o $@

sf_decrunch: cru_src/sf_decrunch.c
	$(COMPILE) $< -o $@

mugconv/foxchr: mugconv/foxchr_source/foxchr.c mugconv/foxchr_source/foxchr.h
	$(COMPILE) mugconv/foxchr_source/foxchr.c -o $@

cgx2fx: cgx2fx_fx2cgx_src/cgx2fx.c
	$(COMPILE) $< -o $@

fx2cgx: cgx2fx_fx2cgx_src/fx2cgx.c
	$(COMPILE) $< -o $@

fontconv/foxfont: fontconv/foxfont_source/foxfont.c fontconv/foxfont_source/foxfont.h
	$(COMPILE) fontconv/foxfont_source/foxfont.c -o $@

SuperFamiconv-$(SFCONV_VER).tar.gz:
	curl https://codeload.github.com/Optiroc/SuperFamiconv/tar.gz/refs/tags/v$(SFCONV_VER) -o SuperFamiconv-$(SFCONV_VER).tar.gz

SuperFamiconv-$(SFCONV_VER)/Makefile: SuperFamiconv-$(SFCONV_VER).tar.gz
	tar -zxf $<

SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv: SuperFamiconv-$(SFCONV_VER)/Makefile
	$(MAKE) -C SuperFamiconv-$(SFCONV_VER)

bgconv/bin/superfamiconv: SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv
	install $(INSTALL_FLAGS) $< ./bgconv/bin

mugconv/superfamiconv/superfamiconv: SuperFamiconv-$(SFCONV_VER)/$(SFCONV_OUT)/superfamiconv
	install $(INSTALL_FLAGS) $< ./mugconv/superfamiconv

romExtender2: extend_src/romExtenderv2.c
	$(COMPILE) $< -o $@

inccol: inccol_src/inccol.c
	$(COMPILE) $< -o $@

argonautmapdec: mapdec_src/argonautmapdecoder.c
	$(COMPILE) $< -o $@

unmerge: unmerge_src/fxedit_v2.c
	$(COMPILE) $< -o $@

chrmap: chrmap_src/chrmap.c
	$(COMPILE) $< -o $@

help:
	@echo "Available targets: all sink kitchensink clean distclean nowindows permissions mrproper"

.PHONY: all sink kitchensink clean distclean nowindows permissions mrproper help
