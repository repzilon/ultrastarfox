Graphic files are located in SF/DATA, palettes in SF/DATA/COL.

|                 | Japanese  | GB English | US English  |    German    | CGX palette | SCR palette |
|-----------------|-----------|------------|-------------|--------------|-------------|-------------|
|Title logo       | TI-3.CGX  | TI-2-G.CGX | TI-3-US.CGX | TI-3-G.CGX   | CP*.COL?    | CP*.COL     |
|Controls screen  | CONT.CGX  | CONT-2.CGX | CONT-2.CGX  | CONT-2-G.CGX | BG2-E*.COL? | BG2-E*.COL  |
|Training/Game    | OBJ-2.CGX | OBJ-3.CGX  | OBJ-3.CGX   | OBJ-4.CGX    | ?           |             |
|Lylat system map | MAP.CGX   | MAP.CGX    | MAP.CGX     | MAP-G.CGX    | NIGHT.COL   | MAP_C.COL   |
|Scramble/Stage   | OBJ-1.CGX | OBJ-1.CGX  | OBJ-1.CGX   | OBJ-1-G.SGX  | ?           | ?           |

Scramble/Stage/Clear messages are displayed through series of macro invocations in SF/ASM/SPRITES.ASM between lines 450 and 500 approximatively, one invocation per letter. Look for the GERMAN conditional assembly directive.

Which graphic files gets included to the ROM is defined in SF/BANK/INCBINS.ASM source file.
