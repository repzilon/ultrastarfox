; 3-1 Corneria 3
level3_1
	scrambleandbaseexit	3

	mapobj	0000,-600,0000,2000,BU_1,HARD180YR_ISTRAT
	mapobj	0000,0600,0000,2000,BU_1,HARD180YR_ISTRAT

	mapobj	0000,-700,0000,3500,BU_1,HARD180YR_ISTRAT
	mapobj	0000,0700,0000,3500,BU_1,HARD180YR_ISTRAT

	mapobj	0000,-900,0000,5000,bu_1,hard180yr_ISTRAT
	mapobj	2000,0900,0000,5000,bu_1,hard180yr_ISTRAT

	mapobj	0000,-1100,0000,4800,bu_1,hard180yr_ISTRAT
	mapobj	0000,01100,0000,4800,bu_1,hard180yr_ISTRAT
	mapobj	0000,-500,0000,5000,HOUDAI_0,houdains_ISTRAT
	mapobj	2000,0500,0000,5000,HOUDAI_0,houdains_ISTRAT

	cspecial	0000,-500,-300,0000,zaco_5,zaco1l_istrat
	mapobj	0000,-1200,0000,4800,bu_1,hard180yr_ISTRAT
	mapobj	2000,01200,0000,4800,bu_1,hard180yr_ISTRAT

	cspecial	0000,0500,-300,0000,zaco_5,zaco1r_istrat

	mapobj	0000,-1200,0000,4800,bu_1,hard180yr_ISTRAT
	mapobj	0000,01200,0000,4800,bu_1,hard180yr_ISTRAT
	mapobj	0000,-600,0000,5000,HOUDAI_0,houdains_ISTRAT
	mapobj	0000,0600,0000,5000,HOUDAI_0,houdai_ISTRAT

	setrestart	
	mapplayermode	onplanet
	mapjsr	map3_1b

	mapobj	1000,-800,0000,8000,bu_4,hard180yr_ISTRAT
	mapobj	1500,1000,0000,10000,bu_2,hard180yr_ISTRAT

	mapjsr	cl_ground ; Clear type
	mapend



