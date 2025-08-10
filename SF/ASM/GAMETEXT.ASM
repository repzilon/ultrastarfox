; Character set of this file is ISO-8859-15.
; format is:
; textname	txt colour(1-15), <TEXT>

	IFNE	GERMAN
pausetxt	txt	14,<PAUSIERT>		;german pause
scoretxt	txt	14,<PUNKTE>
totalscoretxt	txt	14,<GESAMTPUNKTZAHL>		;german total score
slashtxt	txt	14,</>
percenttxt	txt	14,<PROZENTSATZ>
bonustxt	txt	14,<BONUS 1 VERSUCH>
teamtxt	txt	14,<SCHILD DER TEAMMITGLIEDER>
percenttxt2	txt	14,<%>
perfecttxt	txt	14,<PERFEKT//>
slippytxt	txt	14,<SLIPPY>
peppytxt	txt	14,<PEPPY>
falcotxt	txt	14,<FALCO>
miyutxt		txt	14,<MIYU>
faytxt		txt	14,<FAY>
deadtxt		txt	14,<. . .>
deadfemtxt	txt	14,<. . .>
stagetxt	txt	14,<ETAPPE>
	ENDC

	IFNE	FRENCH
pausetxt	txt	14,<EN PAUSE>		;french pause
scoretxt	txt	14,<SCORE>
totalscoretxt	txt	14,<POINTAGE TOTAL>		;french total score
slashtxt	txt	14,</>
percenttxt	txt	14,<POURCENTAGE>
bonustxt	txt	14,<BONI UN CRÉDIT>
teamtxt	txt	14,<ÉTAT DES ÉQUIPIERS ET ÉQUIPIÈRES>
percenttxt2	txt	14,<%>
perfecttxt	txt	14,<PARFAIT//>
slippytxt	txt	14,<SLIPPY>
peppytxt	txt	14,<PEPPY>
falcotxt	txt	14,<FALCO>
miyutxt		txt	14,<MIYU>
faytxt		txt	14,<FAY>
deadtxt		txt	14,<MORT>
deadfemtxt	txt	14,<MORTE>
stagetxt	txt	14,<ETAPE>
	ENDC

	IFNE	JAPANESE
pausetxt	txt	14,<PAUSED>		;japanese pause
scoretxt	txt	14,<SCORE>		;japanese score
totalscoretxt	txt	14,<TOTAL SCORE>		;japanese total score
slashtxt	txt	14,</>
percenttxt	txt	14,<PERCENTAGE>
bonustxt	txt	14,<BONUS 1 CREDIT>
teamtxt	txt	14,<SHIELD OF TEAMMATES>
percenttxt2	txt	14,<%>
perfecttxt	txt	14,<PERFECT//>
slippytxt	txt	14,<SLIPPY>
peppytxt	txt	14,<PEPPY>
falcotxt	txt	14,<FALCO>
miyutxt		txt	14,<MIYU>
faytxt		txt	14,<FAY>
deadtxt		txt	14,<DOWN>
deadfemtxt	txt	14,<DOWN>
stagetxt	txt	14,<STAGE>
	ENDC
	
	IFNE	SPANISH			
pausetxt	txt	14,<EN PAUSA>		;spanish pause
scoretxt	txt	14,<SCORE>		;spanish score
totalscoretxt	txt	14,<PUNTUACION>		;spanish total score
slashtxt	txt	14,</>
percenttxt	txt	14,<PORCENTAJE>
bonustxt	txt	14,<BONUS 1 CREDIT>
teamtxt	txt	14,<ESTADO DEL EQUIPO>
percenttxt2	txt	14,<%>
perfecttxt	txt	14,<PERFECTO//>
slippytxt	txt	14,<SLIPPY>
peppytxt	txt	14,<PEPPY>
falcotxt	txt	14,<FALCO>
miyutxt		txt	14,<MIYU>
faytxt		txt	14,<FAY>
deadtxt		txt	14,<CAÍDO>
deadfemtxt	txt	14,<CAÍDA>
stagetxt	txt	14,<ETAPA>
	ENDC

	IFEQ	SPANISH
	IFEQ	GERMAN
	IFEQ	FRENCH
	IFEQ	JAPANESE
pausetxt	txt	14,<PAUSED>		;english pause
scoretxt	txt	14,<SCORE>
totalscoretxt	txt	14,<TOTAL SCORE>		;english total score
slashtxt	txt	14,</>
percenttxt	txt	14,<PERCENTAGE>
bonustxt	txt	14,<BONUS 1 CREDIT>
teamtxt	txt	14,<SHIELD OF TEAMMATES>
percenttxt2	txt	14,<%>
perfecttxt	txt	14,<PERFECT//>
slippytxt	txt	14,<SLIPPY>
peppytxt	txt	14,<PEPPY>
falcotxt	txt	14,<FALCO>
miyutxt		txt	14,<MIYU>
faytxt		txt	14,<FAY>
deadtxt		txt	14,<DOWN>
deadfemtxt	txt	14,<DOWN>
stagetxt	txt	14,<STAGE>
	ENDC
	ENDC
	ENDC
	ENDC

;-------------------------------------------------------------------

helpsnd	=	0
downsnd	=	1
othersnd	=	2

msgcolour_red = 3
msgcolour_yellow = 4
msgcolour_blue = 8
msgcolour_white = 14

message	MACRO	[colour,person,text,sound]

	printf	"%tDW%t",*&WM,"%t; (",msgnum,") {text} ** %n"
	DB	friend_{person}

	IFEQ	NARG-3
	db	othersnd
	ELSEIF
	DB	{sound}snd
	ENDC

	txt	msgcolour_{colour},<{text}>
msgnum	=	msgnum+1
	ENDM

;-------------------------------------------------------------------

msgnum	=	1

	fopen	msgs.txt

	IFNE	german			;if german = 1
	include	MSG\german.msg		;use german message file
	ENDC

	IFNE	french			;if french = 1
	include	MSG\french.msg		;use french message file
	ENDC

	IFNE	spanish			;if spanish = 1
	include	MSG\spanish.inc		;use spanish message file
	ENDC

	IFNE	JAPANESE
	include	MSG\JAPANESE.msg	;use japanese message file
	ENDC

	IFEQ	GERMAN
	IFEQ	FRENCH
	IFEQ	SPANISH
	IFEQ	JAPANESE
	include	MSG\ENGLISH.inc	;use english message file
	ENDC
	ENDC
	ENDC
	ENDC

	fclose	!

messages	include	msgs.txt




