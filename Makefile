###############################
# UltraStarFox Linux Makefile #
###############################

DOSBOX=dosbox-x -fastlaunch

all: 
	@$(DOSBOX) BUILD.BAT

log: 
	@$(DOSBOX) BLDTOLOG.BAT

clean:
	@$(DOSBOX) CLEAN.BAT
