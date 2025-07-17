Repzilon's TODO
===============

Immediate fixes
---------------
- [x] Fix missing GROUND.COL when trying to build UltraStarFox!

Tool porting
------------
- [x] Add a kitchensink target in the TOOLS Makefile
- [x] Remove duplicated DOS/DJGPP binaries in TOOLS that are also in BIN
- [ ] Test the Makefiles under Linux
- [ ] MUCH Later: provide a Makefile for cross compiling tools on DJGPP (might build a retro PC to test on native DJGPP, including my 20-25 year-old DJGPP Zip disk from a parallel port Zip drive as well). Important: keep the existing executables in the repository so anybody with a modern computer can still build the game without the pain of setting up a cross-compiler.
- [ ] MUCH Later: try to build UltraStarFox on a retro PC (something like the fastest PC able to run Windows 98, so the main build system can run natively without waiting days after it)

Miscellanous hacks
------------------
- [x] Add an FPS counter without the full debug information (code comment was erroneous)
- [x] Improve message character translation documentation
- [x] Support 4bpp bitmaps in foxfont
- [ ] Cross compile updated foxfont for DJGPP
- [x] Correct timing of the intro sequence when built for 21 MHz Super FX
- [ ] MUCH Later: raise the cap to 24 fps on NTSC by implementing a telecine-inspired approach

French Canadian Translation
---------------------------
- [x] Edit the German bitmap font to put umlauted letters in a more logical place, hopefully something ISO-8859-1 compliant for ease of editing
- [x] Update the German messages to reflect new placement of letters
- [x] Edit the German bitmap font (again) to add French diacritics
- [x] Modify the French language build to use the modified German bitmap font
- [x] Update the French messages to use diacritics
- [x] Find out how German map, control and stage title graphics are selected
- [x] Convert graphics to a easier format to edit
- [x] Make French version of the graphics
- [x] Edit build system to select French graphics
- [ ] Extract strings from ENDSEQ.ASM
- [ ] Translate end sequence
- [ ] Add the French Canadian build configuration (NTSC, language code FC, French messages, StarFox (not Starwing) logo, North American (purple) controller button image)
