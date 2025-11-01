# Putting on a physical cartridge

If you plan to put UltraStarFox or any hack based it in a physical cartridge, that is one of the eight SuperFX games released in the 1990s, you must choose carefully the donor cartridge or the game will simply not boot.

**Legend**:
* SFEX: StarFox Exploration Showcase. THE ROM hack from kandowontu.
* USF: UltraStarFox (THIS!). StarFox rebuilt from nicer sources.
* SF2: StarFox 2, either the 1995 betas or the 2017 SNES Classic edition release
* USF2: UltraStarFox 2. StarFox 2 rebuilt from nicer sources.

| Donor cartridge               | SFEX | Upstream USF | SF2  | USF2 |
|-------------------------------|:----:|:------------:|:----:|:----:|
| StarFox (NTSC)/Starwing (PAL) |  no  |      no      |  no  |  no  |
| Dirt Racer (PAL only)         |  no  |      no      |  no  |  no  |
| Dirt Trax FX                  |  no  |      no      |  no  |  no  |
| DOOM 1995                     | YES! |     YES!     | YES! | YES! |
| Stunt Race FX                 |  no  |      no      | YES! |  no  |
| Vortex                        |  no  |      no      |  no  |  no  |
| Winter Gold (PAL only)        | YES! |     YES!     | YES! | YES! |
| Yoshi's Island                | YES! |     YES!     | YES! | YES! |

### Repzilon's USF (tentatively, not tested on hardware)
| Donor cartridge               | Default config | FAST=0 | Custom config |
|-------------------------------|:--------------:|:------:|:-------------:|
| StarFox (NTSC)/Starwing (PAL) |       no       |  YES   |      no       |
| Dirt Racer (PAL only)         |       no       |   no   |      no       |
| Dirt Trax FX                  |       no       |   no   |      no       |
| DOOM 1995                     |      YES       |  YES   |      YES      |
| Stunt Race FX                 |      YES       |  YES   |      no       |
| Vortex                        |       no       |   no   |      no       |
| Winter Gold (PAL only)        |      YES       |  YES   |      YES      |
| Yoshi's Island                |      YES       |  YES   |      YES      |

StarFox 2 was never released in cartridge format. DOOM 1995 refers to the first released SNES port of the 1993 DOS game. Compatibility details for the Limited Run DOOM 2026 enhanced SNES port on physical media will come after its release.

Important: do not set ``FASTROM equ 1`` in ``SF/CONFIG/ROM.INC`` when targeting real cartridges. They will not start at all, even with 120ns FastROM-compatible ROM chips swapped in. None of the SuperFX chip revisions can handle FastROM. Flash carts, such as SD2SNES/FXPak (Pro), and emulators, inaccurately support the SuperFX and FastROM combination.

Also, ``FAST`` (see above) and ``FASTROM`` are different unrelated settings. FAST enables the doubled clock speed and the fast multiply mode of the SuperFX 2. Do not put UltraStarFox with FAST set (which is the default) on the original StarFox cartridge in an attempt to get an improved StarFox. The SuperFX 1 (aka MARIO chip), only used by the original StarFox/Starwing, cannot be overclocked.

Speaking of overclocking, the SuperFX 2 in all other cartridges can be overclocked from 21.4 (stock) to 26 MHz by replacing the clock generator with a faster one, without changes to the ROM chip contents. However, every event in the game will happen sooner along with the framerate increase. Overclocking over 26 MHz may be possible, but the game ROM must be modified accordingly.
