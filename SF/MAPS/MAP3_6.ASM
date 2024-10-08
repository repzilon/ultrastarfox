; 3-6 Venom 3 Orbital
map3_6
	mapwait	2000

;big_missille
	cspecial	2000,0000,space_viewcy,4000,big_m,misspod_istrat
	cspecial	2000,0100,space_viewCY-100,4000,big_m,misspod_istrat	
	cspecial	3000,-100,space_viewCY+100,4000,big_m,misspod_istrat
	cspecial	2000,-100,space_viewCY-100,4000,big_m,misspod_istrat
	cspecial	2000,0100,space_viewCY+100,4000,big_m,misspod_istrat
	
;zacos
	mapmother	6000,0000,1035+space_viewcy,1800,mother1,mother2_istrat,map_mine2

	pathcspecial	2000,1000,-700,2000,shark,call_fol,10,10
	pathcspecial	2000,-1000,-700,2000,shark,call_fol,10,10
	pathcspecial	2000,1000,-700,2000,shark,call_fol,10,10
	pathcspecial	2000,-1000,-700,2000,shark,call_fol,10,10
	pathcspecial	04000,-700,100,-100,bzaco_8,patret_ifal,10,10
	maprem	mother1
;
	mapwait	2000

; M formation
	szaco2_mapobj	0,2000,0,0,100

	szaco2_mapobj	-500,1000,-300,100,0
	szaco2_mapobj	500,1000,300,100,100

	szaco2_mapobj	-1000,1000,-400,-100,0
	szaco2_mapobj	1000,1000,400,-100,100

	mapwait	2000
	mapmother	9000,0000,1035+space_viewcy,1800,mother1,mother2_istrat,map_mine2
;friend
	pathobj	0000,0000,0400,0000,friendship_4,chase3_1,200,10
	pathobj	02000,0000,400,0000,zaco_b,chase3_2,10,10
	mapobj	2000,200,-200,2000,spacepilon,spacepilon_istrat

	cspecial	1200,0000,2000,3000,uper_m,uperm_Istrat
	cspecial	1200,0100,2000,3000,uper_m,uperm_Istrat
	cspecial	1200,-100,2000,3000,uper_m,uperm_Istrat
	maprem	mother1


;mothers
	mapmother	05000,0000,2000,3000,mother1,mother2_istrat,map_uperm
	maprem	mother1
;windmill
	special	0,0,0,4000,round_0,windmill_istrat
	setalvar	roty,deg180
	setalvar	sword1,1

	mapmother	6000,0000,1035+space_viewcy,1800,mother1,mother2_istrat,map_mine2
	maprem	mother1
	cspecial	3000,0000,space_viewCY,4000,asteroid1,misspod_istrat	
;skillfly
	skillfly_init
	skillfly_set 0000,space_viewCY,6000,100
	mapobj	0000,0000,space_viewCY,6000,item_5,item5_istrat
	setalvar	sbyte1,1
	special		000,-180,-250,6000,r_hou_0,shou0a_istrat
	pathcspecial	000,0180,-250,6000,b_hou_0,damyscr,2,4
	cspecial	000,0300,0000,6000,r_hou_0,shou0a_istrat
	special		000,0180,0250,6000,r_hou_0,shou0a_istrat
	pathcspecial	000,-180,0250,6000,b_hou_0,damyscr,2,4
	cspecial	6000,-300,0000,6000,r_hou_0,shou0a_istrat
	skillfly_bonus 0000,0000,space_viewCY,1500,item_6,item6_istrat
	setalvar	sbyte1,1
	skillfly_set 0000,space_viewCY,1500,100
	mapwait	1500
	skillfly_bonus 0000,0000,space_viewCY,1500,item_7,item7_istrat
	setalvar	sbyte1,1

	mapwait	1000
;friend
	pathobj	0000,-900,0000,0000,friendship_4,chase2_1,10,10
	pathobj	02000,-900,000,0000,zaco_b,chase2_2,10,10

	mapobj	0000,-280,space_viewCY,3000,gate_0,gate_istrat
	pathobj	2000,3000,0,1000,nullshape,e_gate,10,10


;warp
	mapmother	02000,0000,2000,3000,mother1,mother2_istrat,map_uperm
	cspecial	2000,0000,0000,1500,warp,warp_Istrat
	special	2000,0000,0000,1500,warp,warp_Istrat
	cspecial	4000,0000,0000,1500,warp,warp_Istrat
	maprem	mother1
;bazooka
	cspecial	1000,-100,1000,3500,bazooka,bazookaL_Istrat
	cspecial	1200,0000,2000,3000,uper_m,uperm_Istrat
	cspecial	1200,0100,2000,3000,uper_m,uperm_Istrat
	cspecial	3000,0100,1000,3500,bazooka,bazookaR_Istrat
	skillfly_init
	skillfly_set 0000,space_viewCY,4000,100
	pathcspecial	000,0000,0000,4000,b_hou_0,damyscr,2,4
	mapmother	4000,0000,1035+space_viewcy,1500,mother1,mother2_istrat,map_mine2
	skillfly_bonus 4000,0000,space_viewCY,1500,item_5,item5_istrat
;supply_bird
	pathobj	4000,-400,-300,0,my_bird,my_bird,10,10
	maprem	mother1

	mapmother	3000,0000,2000,3000,mother1,mother2_istrat,map_uperm
	cspecial	3000,0100,space_viewCY-100,3000,big_m,misspod_istrat	
	cspecial	2000,-100,space_viewCY+100,3000,big_m,misspod_istrat

	cspecial	4000,-200,1000,3500,bazooka,bazookaL_Istrat

	pathspecial	0200,0100,100,3000,shieldr,e_shieldr,10,10
	pathcspecial	0200,0000,000,3000,shieldr,e_shieldr,10,10
	pathcspecial	5000,-100,100,3000,shieldr,e_shieldr,10,10
	mapobj	10000,200,-200,2000,spacepilon,spacepilon_istrat
	maprem	mother1
	mapwait	4500
;-------------------------------------------------------------------
.boss

	mapwait	1


	start_65816
	a8
	lda	pshipflags
	and	#psf_noctrl
	bne	.twait
	switch	.tcont
.twait	switch	.boss
	end_65816

.tcont

; king joh boss
 
.owait	mapwait	5
	start_65816
	a8
	lda		pshipflags2
	and		#psf2_playerHP0
	beq		.ocont
	switch	.owait
.ocont
	lda		splayerflymode
	cmp		#spfm_inside
	beq		.doout
	switch		.cont2
.doout	lda		#spfm_tonorm
	sta		splayerflymode
	jsl		changeviewmode_l
	end_65816
	setvar.b	splayerflymodeopt,spfmo_AB
	mapwait		2000
.cont2

	fadeoutbgm
	setbgm	5
	mapobj	0000,0000,2000,2500,boss_f_3,bossf_Istrat
	mapwaitboss
	markboss	boss36
	maprts
;-------------------------------------------------------------------

