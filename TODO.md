Repzilon's TODO
===============

Immediate fixes
---------------
- [x] Fix missing GROUND.COL when trying to build UltraStarFox!
- [x] Missing scenery in Corneria introduced by the scrambleandbaseexit macro

Tool porting
------------
- [x] Add a kitchensink target in the TOOLS Makefile
- [x] Remove duplicated DOS/DJGPP binaries in TOOLS that are also in BIN
- [x] Test the Makefiles under Linux
- [ ] Provide a Makefile for compiling tools on DJGPP. Important: keep the DOS executables in the repository for newcomers. ==WIP==
- [x] Try to build UltraStarFox on a retro PC/VM
- [x] Regroup the home-grown tools into a single executable
- [ ] Improve compatibility and backport to C ARGLINK_REWRITE from LuigiBlood ==WIP==
- [ ] Tool build system for Windows (Visual Studio solution, Makefiles or CMake) ==WIP==
- [ ] Correct compiler warnings in community-made tools ==WIP==

Miscellaneous hacks
-------------------
- [x] Add an FPS counter without the full debug information (code comment was erroneous)
- [x] Improve message character translation documentation
- [x] Support 4bpp bitmaps in foxfont
- [x] Compile updated foxfont for DJGPP
- [x] Correct timing of the intro sequence when built for 21 MHz Super FX
- [x] Code bank reorganisation to fit the base game inside 1 MiB and extras above that boundary
- [x] Port buildrelease.cmd to a Makefile and generate localized patches from it
- [ ] Skip scramble sequence by pressing Start
- [ ] Better boss roll demo through training (background music, select level with controller mode, return to controls screen with Start) ==WIP==
- [x] Document foxfont width calculation
- [ ] Experiment with RNC ProPack (better graphics compression)
- [ ] Create a tool to extract tiles, screen and font from ROM images (e.g. early ROM hacks)
- [x] Enable the use special ABLR letters for buttons in communication messages
- [ ] MUCH Later: automated bank bin packing
- [ ] MUCH Later: raise the cap to 24 fps on NTSC by implementing a telecine-inspired approach

French Canadian Translation
---------------------------
- [x] Edit the German bitmap font to put letters with umlauts in a more logical place, hopefully something ISO-8859-1 compliant for ease of editing
- [x] Update the German messages to reflect new placement of letters
- [x] Edit the German bitmap font (again) to add French diacritics
- [x] Modify the French language build to use the modified German bitmap font
- [x] Update the French messages to use diacritics
- [x] Find out how German map, control and stage title graphics are selected
- [x] Convert graphics to a easier format to edit
- [x] Make French version of the graphics
- [x] Edit build system to select French graphics
- [x] Extract strings from ENDSEQ.ASM
- [x] Translate end sequence (fix garbled text in great commander measurements)
- [x] Add the French Canadian build configuration (NTSC, language code, French messages, StarFox [not Starwing] logo, North American [purple] controller button image)

Spanish Translation
-------------------
- [x] Extract and apply Quintana's translation available on RHDN
- [ ] Integrate to the build system ==WIP==
- [x] Complete dialog text using earlier translations
- [ ] Make Spanish version of the graphics
- [ ] Help wanted: translate end sequence (boss roll) ==WIP==
