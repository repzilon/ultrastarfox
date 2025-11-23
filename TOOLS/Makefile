## Tools Makefile intended to run modern *nix host systems (macOS, Linux)

SFCONV_VER := 0.11.0
SFCHECK_VER := 1.1.0
OPTIROC_OUT := build/release
CC := $(shell which cc)
CFLAGS_OPTIM := -O2 -pipe -fomit-frame-pointer
CFLAGS_HARDEN := -Wall -Wformat -Wformat=2 -Wconversion -Wimplicit-fallthrough -Werror=format-security \
-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=3 \
-fstrict-flex-arrays=3 \
-fstack-protector-strong \
-fno-delete-null-pointer-checks -fno-strict-overflow -fno-strict-aliasing -ftrivial-auto-var-init=zero
# Flags exclusive to C language, not to be used for C++
CCFLAGS_HARDEN := -Werror=implicit -Werror=incompatible-pointer-types -Werror=int-conversion
CXXFLAGS_OPTIM := $(CFLAGS_OPTIM) -fvisibility=hidden
CXXFLAGS_HARDEN := $(CFLAGS_HARDEN) -D_GLIBCXX_ASSERTIONS

OS := $(shell uname)
ifneq (,$(wildcard /etc/alpine-release))
  INSTALL_FLAGS := -p
else
  ifeq (Darwin,$(OS))
    INSTALL_FLAGS := -CSv
  else
    INSTALL_FLAGS := -Cv
  endif
endif
ifeq (Linux,$(OS))
  CFLAGS_LINUX := -Wl,-z,nodlopen -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -Wl,--no-copy-dt-needed-entries
endif
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

# FIXME : On aarch64, add the following to CFLAGS
#-mbranch-protection=standard

COMPILE := $(CC) $(CFLAGS_OPTIM) $(CFLAGS_HARDEN) $(CFLAGS_LINUX) $(CFLAGS_GCC) $(CFLAGS_ISA) $(CCFLAGS_HARDEN)
CPLUSPLUS := $(CXX) --std=c++11 $(CXXFLAGS_OPTIM) $(CXXFLAGS_HARDEN) $(CFLAGS_LINUX) $(CFLAGS_GCC) $(CFLAGS_ISA)
$(info Compiler and flags: $(COMPILE))

BINDIR := binaries/$(OS)

all: $(BINDIR)/sf_crunch $(BINDIR)/sf_decrunch $(BINDIR)/cgx2fx $(BINDIR)/fx2cgx $(BINDIR)/foxchr $(BINDIR)/foxfont $(BINDIR)/superfamicheck

sink: $(BINDIR)/romExtender2 $(BINDIR)/inccol $(BINDIR)/argonautmapdec $(BINDIR)/unmerge $(BINDIR)/chrmap

kitchensink: all sink

clean-robfx:
	$(MAKE) -C robfx.src clean

clean-csharp:
	rm -rf SharpUltraStarFoxTools/*/bin/
	rm -rf SharpUltraStarFoxTools/*/obj/

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
	rm -f $(BINDIR)/palconv
	rm -f $(BINDIR)/sf_crunch
	rm -f $(BINDIR)/sf_decrunch
	rm -f $(BINDIR)/cgx2fx
	rm -f $(BINDIR)/fx2cgx
	rm -f $(BINDIR)/foxchr
	rm -f $(BINDIR)/foxfont
	rm -f $(BINDIR)/superfamicheck

clean-sink:
	rm -f romExtender2
	rm -f inccol
	rm -f argonautmapdec
	rm -f unmerge
	rm -f chrmap
	rm -f $(BINDIR)/romExtender2
	rm -f $(BINDIR)/inccol
	rm -f $(BINDIR)/argonautmapdec
	rm -f $(BINDIR)/unmerge
	rm -f $(BINDIR)/chrmap
	rm -f $(BINDIR)/superfamicheck
	rm -f $(BINDIR)/apendcol
	rm -f $(BINDIR)/makecol

clean: clean-tools clean-sink clean-robfx clean-csharp clean-superfamiconv
	rmdir $(BINDIR) || true

distclean: clean-tools clean-sink clean-robfx clean-csharp
	rm -rf SuperFamiconv-*
	rm -rf sfcheck.src
	rm -f sfcheck.tgz
	rmdir $(BINDIR) || true

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
	rm -f binaries/windows/cgx2fx_win.exe
	rm -f binaries/windows/fx2cgx_win.exe
	rm -f binaries/windows/palconv_win64.exe
	rm -f binaries/windows/sf_crunch.exe
	rm -f binaries/windows/sf_decrunch.exe
	rm -f binaries/windows/unmerge.exe
	rmdir binaries/windows

permissions:
	chmod -x *.* */*.* */*/*.*
	chmod +x */*.sh

mrproper: distclean nowindows permissions
	rm -f SuperFamiconv-*.tar.gz

$(BINDIR): binaries
	mkdir $(BINDIR) || true

$(BINDIR)/palconv: $(BINDIR) palconv_src/palconv.c
	$(COMPILE) palconv_src/palconv.c -o $@

$(BINDIR)/sf_crunch: $(BINDIR) cru_src/sf_crunch_mod.c
	$(COMPILE) cru_src/sf_crunch_mod.c -o $@

$(BINDIR)/sf_decrunch: $(BINDIR) cru_src/sf_decrunch.c
	$(COMPILE) cru_src/sf_decrunch.c -o $@

$(BINDIR)/cgx2fx: $(BINDIR) cgx2fx_fx2cgx_src/cgx2fx.c
	$(COMPILE) cgx2fx_fx2cgx_src/cgx2fx.c -o $@

$(BINDIR)/fx2cgx: $(BINDIR) cgx2fx_fx2cgx_src/fx2cgx.c
	$(COMPILE) cgx2fx_fx2cgx_src/cgx2fx.c -o $@

$(BINDIR)/foxchr: $(BINDIR) mugconv/foxchr_source/foxchr.c mugconv/foxchr_source/foxchr.h
	$(COMPILE) mugconv/foxchr_source/foxchr.c -o $@

$(BINDIR)/romExtender2: $(BINDIR) extend_src/romExtenderv2.c
	$(COMPILE) extend_src/romExtenderv2.c -o $@

$(BINDIR)/inccol: $(BINDIR) inccol_makecol_src/inccol.c
	$(COMPILE) inccol_makecol_src/inccol.c -o $@

$(BINDIR)/argonautmapdec: $(BINDIR) mapdec_src/argonautmapdecoder.c
	$(COMPILE) mapdec_src/argonautmapdecoder.c -o $@

$(BINDIR)/unmerge: $(BINDIR) unmerge_src/fxedit_v2.c
	$(COMPILE) unmerge_src/fxedit_v2.c -o $@

$(BINDIR)/chrmap: $(BINDIR) chrmap_src/chrmap.c
	$(COMPILE) chrmap_src/chrmap.c -o $@

$(BINDIR)/foxfont: $(BINDIR) fontconv/foxfont_source/foxfont.c fontconv/foxfont_source/foxfont.h
	$(COMPILE) fontconv/foxfont_source/foxfont.c -o $@

install: bgconv/bin/palconv mugconv/foxchr bgconv/bin/sf_crunch bgconv/bin/superfamiconv mugconv/superfamiconv/superfamiconv fontconv/foxfont

bgconv/bin/palconv: $(BINDIR)/palconv
	install $(INSTALL_FLAGS) $< ./bgconv/bin

bgconv/bin/sf_crunch: $(BINDIR)/sf_crunch
	install $(INSTALL_FLAGS) $< ./bgconv/bin

mugconv/foxchr: $(BINDIR)/foxchr
	install $(INSTALL_FLAGS) $< ./mugconv

fontconv/foxfont: $(BINDIR)/foxfont
	install $(INSTALL_FLAGS) $< ./fontconv

SuperFamiconv-$(SFCONV_VER).tar.gz:
	curl https://codeload.github.com/Optiroc/SuperFamiconv/tar.gz/refs/tags/v$(SFCONV_VER) -o SuperFamiconv-$(SFCONV_VER).tar.gz

SuperFamiconv-$(SFCONV_VER)/Makefile: SuperFamiconv-$(SFCONV_VER).tar.gz
	tar -zxf $<

SuperFamiconv-$(SFCONV_VER)/$(OPTIROC_OUT)/superfamiconv: SuperFamiconv-$(SFCONV_VER)/Makefile
	$(MAKE) -C SuperFamiconv-$(SFCONV_VER)

bgconv/bin/superfamiconv: SuperFamiconv-$(SFCONV_VER)/$(OPTIROC_OUT)/superfamiconv
	install $(INSTALL_FLAGS) $< ./bgconv/bin

mugconv/superfamiconv/superfamiconv: SuperFamiconv-$(SFCONV_VER)/$(OPTIROC_OUT)/superfamiconv
	install $(INSTALL_FLAGS) $< ./mugconv/superfamiconv

# Names are for DJGPP (use this Makefile to download and extract, then build with the DJGPP Makefile)
sfcheck.tgz:
	curl https://codeload.github.com/Optiroc/SuperFamicheck/tar.gz/refs/tags/v$(SFCHECK_VER) -o $@

SuperFamicheck-$(SFCHECK_VER): sfcheck.tgz
	tar -zxf $<

sfcheck.src/src/superfamicheck.cpp: SuperFamicheck-$(SFCHECK_VER)
	mv SuperFamicheck-$(SFCHECK_VER) sfcheck.src

$(BINDIR)/superfamicheck: sfcheck.src/src/sfcRom.cpp sfcheck.src/src/superfamicheck.cpp
	$(CPLUSPLUS) sfcheck.src/src/sfcRom.cpp sfcheck.src/src/superfamicheck.cpp -o $@

help:
	@echo "Available targets: all sink kitchensink install clean distclean nowindows permissions mrproper"

.PHONY: all sink kitchensink install clean distclean nowindows permissions mrproper help clean-robfx clean-superfamiconv clean-tools clean-sink clean-sfcheck clean-csharp
