; 2-1 Corneria 2
level2_1
	scrambleandbaseexit	1

	mapobj	0000,-600,0000,2000,BU_1,HARD180YR_ISTRAT
	mapobj	0000,0600,0000,2000,BU_1,HARD180YR_ISTRAT

	mapobj	0000,-700,0000,3500,BU_1,HARD180YR_ISTRAT
	mapobj	0000,0700,0000,3500,BU_1,HARD180YR_ISTRAT

.tower
	mapobj	0000,-1000,0000,5000,TOWER_2,TOWER0_ISTRAT
	mapobj	2000,01000,0000,5000,TOWER_2,TOWER0_ISTRAT
	maploop .tower,02
	cspecial	0000,-500,-300,0000,zaco_5,zaco1l_istrat
	mapobj	0000,-1200,0000,5000,TOWER_2,TOWER0_ISTRAT
	mapobj	2000,01200,0000,5000,TOWER_2,TOWER0_ISTRAT

	mapobj	0000,-1200,0000,5000,TOWER_2,TOWER0_ISTRAT
	mapobj	0000,01200,0000,5000,TOWER_2,TOWER0_ISTRAT
	cspecial	0000,0500,-300,0000,zaco_5,zaco1r_istrat


	setrestart	
	mapplayermode	onplanet
	mapjsr	map2_1b

	mapobj	1000,-800,0000,8000,TOWER_2,TOWER0_ISTRAT
	mapobj	1500,800,0000,10000,TOWER_2,TOWER0_ISTRAT

	mapjsr	cl_ground ; Clear type
	mapend





