	include	INC\header.inc
	include	INC\strathdr.inc
	include	EXT\gastrats.ext
	include	EXT\pstrats.ext
	include	EXT\strings.ext
	include	EXT\paths.ext
	include	EXT\pistrats.ext
	include	EXT\pcstrats.ext
	include	EXT\gb2strat.ext
	include	EXT\ga2strat.ext
	include	EXT\dstrats.ext
	include	INC\shmacs.inc
	include	EXT\windows.ext
	include	INC\bgmacs.inc
	include	EXT\maplist.ext
	include	INC\marioi.inc
	include	EXT\bootnmi.ext
	

	incpublics	EXT\mhofs.ext

;------------------------------------------------------------------
	bank	6
	incfile	STRAT\gcstrats.asm
	incfile	STRAT\expstrat.asm

     	incfile	MARIO\mmacs.mc
	mario	on
	incfile	MARIO\mhofs.mc		;Kristers .mc files
	mario	off

	IFEQ	rumble
	incfile	STRAT\gstrats.asm
	ENDC
	bankend	6

	IFNE	rumble
	bank	35
	incfile	STRAT\gstrats.asm
	bankend	35
	ENDC

	include	INC\tail.inc



