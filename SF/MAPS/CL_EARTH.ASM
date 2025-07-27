cl_earth
	mapmother	0,0,0,3000,mother1,mother1_istrat,mother_CLasteroids
	mapplayeroutview

	setbgm	$f1
	
	mapCLplayermode	ClearEarth
	setbgm	bgm_fanfare
	mapwait	3300


friendwait	=	medpspeed ; was *30

	setvar.n	stageclear,1
	mapmsg	1
	mapwait	friendwait


	mapjmpfrienddead	frog,.nf
	mapobj	friendwait,02000,-50,50,myship_4,clshipEARTHb_Istrat
	clfriendmsg	frog
.nf
	mapjmpfrienddead	bunny,.nb
	mapobj	friendwait,-2000,-50,50,myship_4,clshipEARTHa_Istrat
	clfriendmsg	bunny
.nb
	mapjmpfrienddead	miyu,.nm
	mapobj	friendwait,02000,-400,-1000,myship_4,clshipEARTHe_Istrat
	clfriendmsg	miyu
.nm
	mapjmpfrienddead	fay,.nfay
	mapobj	friendwait,-2000,-400,-1000,myship_4,clshipEARTHd_Istrat
	clfriendmsg	fay
.nfay
	mapjmpfrienddead	cock,.nc
	mapobj	friendwait,00000,1000,-700,myship_4,clshipEARTHc_Istrat
	clfriendmsg	cock
.nc

	mapwait	5000

.sdloop	mapif	chkstagedone,.sdcont
	mapgoto	.sdloop
.sdcont

	setvar.b	clb2,0
	setvar.n	stageclear,0
	printlevelfin
.eswait	mapwait		1
	maploop		.eswait,100
	mapendwipe	roundwipefill,90*medpspeed
	maprts



