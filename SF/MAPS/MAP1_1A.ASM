; 1-1 Corneria 1 Part A: SCRAMBLE Sequence Map
map1_1a
fudge	=	250

	mapobjnomem	0000,0000,0000,fudge,op_0,gnd_Istrat
	setalxvar	depthoffset,1
	mapobjnomem	0000,0000,0000,fudge,op_1,nocoll_Istrat
	setalxvar	depthoffset,1
	mapobjnomem	0000,0000,0000,fudge+(100<<3),op_0,gnd_Istrat	; 220
	setalxvar	depthoffset,1
	mapobjnomem	0000,0000,0000,fudge+(100<<3),op_1,nocoll_Istrat	; 220
	setalxvar	depthoffset,1
	mapobjnomem	0000,0000,0000,fudge+(200<<3),op_0,gnd_Istrat	; 240
	setalxvar	depthoffset,1
	mapobjnomem	0000,0000,0000,fudge+(200<<3),op_1,nocoll_Istrat	; 240
	setalxvar	depthoffset,1
	

	mapobj	0000,-40,0,-200,imyship_4,shipintro_istrat
	setalvar.w	sword1,-70
	setalvar	sbyte1,40
	mapobj	0000,40,0,-200,imyship_4,shipintro_istrat
	setalvar.w	sword1,-70
	setalvar	sbyte1,30
	; Miyu n' Fay
	mapobj	0000,-40,0,-300,imyship_4,shipintro_istrat
	setalvar.w	sword1,-70
	setalvar	sbyte1,60
	mapobj	0000,40,0,-300,imyship_4,shipintro_istrat
	setalvar.w	sword1,-70
	setalvar	sbyte1,50
	; Falco? idk
	mapobj	0000,0000,0,-300,imyship_4,shipintro_istrat
	setalvar.w	sword1,-100
	setalvar	sbyte1,70

.here2	
	mapwait		(100<<3)-medpspeed
	mapobjnomem	0000,0000,0000,fudge+(200<<3),op_0,gnd_Istrat
	setalxvar	depthoffset,1
	mapobjnomem	0000,0000,0000,fudge+(200<<3),op_1,nocoll_Istrat
	setalxvar	depthoffset,1

	maploop	.here2,8

.here3
	mapwait		(100<<3)-medpspeed
	mapobjnomem	0000,0000,0000,fudge+(200<<3),op_2,gnd_Istrat
	setalxvar	depthoffset,1
	mapif	chkstratdone1,.fin
	mapgoto		.here3
.fin

	maprts

