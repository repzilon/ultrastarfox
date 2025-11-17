; TRAINING: Training Mode
trainingmap
	IFEQ trainingbossroll
	initlevel	training,mstarwipe_circle
	setvar.n	prttraining,1
	mapwait	2000
	ENDC
	
	IFNE	messagetest
;*************************      MSG TEST   *****************************
	mapwait	3000

	start_65816
	lda	#-1
	sta	friends_meter
	end_65816

trnmapmsgcnt = 1

.trnmsgtest

; loops through messages in the message file, except very long ones
; that would hang the test for minutes before resuming

	REPT	87
	mapwait	1875
	mapmsg	trnmapmsgcnt
trnmapmsgcnt = trnmapmsgcnt+1
	ENDR	; skip [88; 92]
trnmapmsgcnt = 93
	REPT	105-93+1; last would be 105
	mapwait	1875
	mapmsg	trnmapmsgcnt
trnmapmsgcnt = trnmapmsgcnt+1
	ENDR	; skip [106; 116]
trnmapmsgcnt = 117
	REPT	totalmsgs-117+1
	mapwait	1875
	mapmsg	trnmapmsgcnt
trnmapmsgcnt = trnmapmsgcnt+1
	ENDR

	mapwait	1000

	mapgoto	.trnmsgtest

	ENDC

	IFNE	trainingbossroll
	start_65816
	; select boss roll route with the controller mode
	; A for route 1, B for route 2, C for route 3, D for all routes
	; I have to make 2 small jumps instead of a bigger one to work around
	; the relative offset argument of beq
	lda	c_type
	cmp	#1
	beq	.b
	cmp	#2
	beq	.nearc	; 1st hop for control C/route 3 block
	end_65816
	markboss	boss11
	markboss	boss12
	markboss	boss13
	markboss	boss14
	markboss	boss15
	markboss	boss16
	start_65816
	lda	c_type
.nearc
	cmp	#2	; 2nd hop to control C/route 3 block
	beq	.c
	cmp	#0
	beq	.nearf	; for control A, 1st hop to mark final boss
	end_65816
.b
	markboss	boss21
	markboss	boss22
	markboss	boss23
	markboss	boss24
	markboss	boss25
	markboss	boss26
	start_65816
	lda	c_type
.nearf
	cmp	#0	; for control A, 2nd hop to mark final boss
	beq	.f
	cmp	#1	; for control B, hop staight to mark final boss
	beq	.f
	end_65816
.c
	markboss	boss31
	markboss	boss32
	markboss	boss33
	markboss	boss34
	markboss	boss35
	markboss	boss36
	markboss	boss37
	; for controls C and D, just continue for final boss
.f
	markboss	bossfinal
	setvar.n	levelfinished,6
	setvar.n	levelfinished,9

	start_65816
	bgm	endseq
	jsl	endseq_l
	end_65816
	ENDC

	IFEQ messagetest+trainingbossroll
;***********************************************************************
	pathobj	0000,0000,0000,3000,zaco_5,trn_ck,10,10
	mapobj	0000,1200,0000,5000,BU_8,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_1,HARD180YR_ISTRAT
;------
	mapobj	0000,000,0500,5000,pilon,groundpilon_ISTRAT
;------
	mapobj	0000,1200,0000,5000,BU_0,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_2,HARD180YR_ISTRAT
	mapobj	0000,1200,0000,5000,BU_1,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_1,HARD180YR_ISTRAT
	mapobj	0000,1000,0000,5000,TOWER_2,TOWER0_ISTRAT
	mapobj	2000,-1000,0000,5000,TOWER_2,TOWER0_ISTRAT
.et
;	skillfly_init
;	skillfly_set 0000,-100,5000,70
	pathobj	0000,0000,-100,5000,training,trn_ring,10,10
	mapobj	0000,1200,0000,5000,BU_8,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_1,HARD180YR_ISTRAT
;	skillfly_set 0200,-150,5000,70
	pathobj	0000,0200,-150,5000,training,trn_ring2,10,10
	mapobj	0000,1200,0000,5000,BU_0,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_2,HARD180YR_ISTRAT
;	skillfly_set 0000,-200,5000,70
	pathobj	0000,0000,-200,5000,training,trn_ring,10,10
	mapobj	0000,1200,0000,5000,BU_1,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_1,HARD180YR_ISTRAT
;	skillfly_set -200,-150,5000,70
	pathobj	0000,-200,-150,5000,training,trn_ring2,10,10
	mapobj	0000,1000,0000,5000,TOWER_2,TOWER0_ISTRAT
	mapobj	2000,-1000,0000,5000,TOWER_2,TOWER0_ISTRAT

;	skillfly_set 0000,-100,5000,70
	pathobj	0000,0000,-100,5000,training,trn_ring,10,10
	mapobj	0000,1200,0000,5000,pillar3,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,pillar3,HARD180YR_ISTRAT
;	skillfly_set 200,-200,5000,70
	pathobj	0000,0200,-200,5000,training,trn_ring2,10,10
	mapobj	0000,1200,0000,5000,robot_0,HARD180YR_ISTRAT
	mapobj	1200,-1200,0000,5000,robot_0,HARD180YR_ISTRAT
;	skillfly_set -330,-100,5000,70
	pathobj	0000,-330,-100,5000,training,trn_ring,10,10
	mapobj	0000,1200,0000,5000,BU_7,HARD180YR_ISTRAT
	mapobj	2000,-1200,0000,5000,BU_7,HARD180YR_ISTRAT
;	skillfly_set 00,-100,5000,70
	pathobj	1000,000,-100,5000,training,trn_ring2,10,10
	mapobj	0800,0000,0000,5000,BU_7,HARD180YR_ISTRAT
;	skillfly_set 00,-100,5000,70
	pathobj	1000,0000,-100,5000,training,trn_ring,10,10
;	skillfly_set 0100,-100,5000,70
	pathobj	1000,0100,-100,5000,training,trn_ring2,10,10
;	skillfly_set -200,-300,5000,70
	pathobj	0800,-200,-300,5000,training,trn_ring,10,10
;	skillfly_set -100,-100,5000,70
	pathobj	0800,-100,-100,5000,training,trn_ring2,10,10
;	skillfly_set 0000,-300,5000,70
	pathobj	0800,0000,-300,5000,training,trn_ring,10,10
;	skillfly_set 0000,-100,5000,70
	pathobj	2000,0000,-100,5000,training,trn_ring2,10,10
	mapobj	0300,0000,0000,5000,base_1,base_1_ISTRAT
;	skillfly_set 0000,-100,5000,70
	pathobj	8000,0000,-100,5000,training,trn_ring,10,10
	eguchifly_goto .et

	pathobj	0000,0000,-570,-100,friendship_4,hentai_fal,10,10
	pathobj	0000,100,-470,-100,friendship_4,hentai_fro,10,10
	pathobj	1000,-100,-470,-100,friendship_4,hentai_rab,10,10

	mapmsg	123
.etlop
	mapobj	0000,1200,0000,5000,BU_8,HARD180YR_ISTRAT
	mapobj	4200,-1200,0000,5000,BU_1,HARD180YR_ISTRAT
	mapobj	0000,1200,0000,5000,BU_7,HARD180YR_ISTRAT
	mapobj	4200,-1200,0000,5000,BU_7,HARD180YR_ISTRAT

	maploop	.etlop,4
	mapobj	0000,-200,-70,5000,pilon,groundpilon_ISTRAT
	mapobj	0000,0000,-70,5000,pilon,groundpilon_ISTRAT
	mapobj	6000,0200,-70,5000,pilon,groundpilon_ISTRAT
	mapobj	0000,0000,-70,5000,pilon,groundpilon_ISTRAT
	mapobj	0000,0000,-140,5000,pilon,groundpilon_ISTRAT
	mapobj	8000,0000,-210,5000,pilon,groundpilon_ISTRAT

	mapgoto	.et
	ENDC



