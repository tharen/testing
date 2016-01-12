      SUBROUTINE DGF(DIAM)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use pden_mod
      use prgprm_mod
      implicit none
C----------
C  **DGF--PN    DATE OF LAST REVISION:  01/11/2012
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF DDS (CHANGE IN SQUARED
C  DIAMETER) FOR EACH TREE RECORD, AND LOADS IT INTO THE ARRAY
C  WK2.  DDS IS PREDICTED FROM SITE INDEX, LOCATION, SLOPE,
C  ASPECT, ELEVATION, DBH, CROWN RATIO, BASAL AREA IN LARGER TREES,
C  AND CCF.  THE SET OF TREE DIAMETERS TO BE USED IS PASSED AS THE
C  ARGUEMENT DIAM.  THE PROGRAM THUS HAS THE FLEXIBILITY TO
C  PROCESS DIFFERENT CALIBRATION OPTIONS.  THIS ROUTINE IS CALLED
C  BY **DGDRIV** DURING CALIBRATION AND WHILE CYCLING FOR GROWTH
C  PREDICTION.  ENTRY **DGCONS** IS CALLED BY **RCON** TO LOAD SITE
C  DEPENDENT COEFFICIENTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
C  ** REFIT CHANGES 060396 DMD.  CHANGES TO MOST DATA ARRAYS FOR
C     SS,DF,RC,WH.
C  ** REPLACED OREGON WHITE OAK EQUATION CREATED BY GOULD AND HARRINGTON
C     FROM PNW STATION DATE 04/19/10 ESM
C----------
C  RED FIR EQUATION IS BAD (RESULTS IN 3" TREES 150' TALL). OBTAINED
C  RED FIR DATA FROM TOMMY GREGG FOR R6, AND PLOTTED HT VS DBH. GROWING
C  RED FIR WITH THE NOBLE FIR EQUATION MATCHES VERY WELL. 2/15/02 GED.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
C  DIMENSIONS FOR INTERNAL VARIABLES.
C
C     DIAM -- ARRAY LOADED WITH TREE DIAMETERS (PASSED AS AN
C             ARGUEMENT).
C     DGLD -- ARRAY CONTAINING COEFFICIENTS FOR THE LOG(DIAMETER)
C             TERM IN THE DDS MODEL.
C     DGCR -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO TERM IN THE DDS MODEL.
C   DGCRSQ -- ARRAY CONTAINING THE COEFFICIENTS FOR THE CROWN
C             RATIO SQUARED TERM IN THE DDS MODEL.
C    DGBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE BASAL AREA IN
C             LARGER TREES TERM IN THE DDS MODEL.
C   DGDBAL -- ARRAY CONTAINING COEFFICIENTS FOR THE INTERACTION
C             BETWEEN BASAL AREA IN LARGER TREES AND LN(DBH).
C    DGLBA -- ARRAY OF COEFFICIENTS FOR LOG(BASIL AREA).
C     DGBA -- ARRAY OF COEFFICIENTS OF BASIL AREA.
C   DGSITE -- ARRAY OF COEFFICIENTS OF LOG(SITE).
C     DGEL -- ARRAY OF COEFFICIENTS OF ELEVATION.
C    DGEL2 -- ARRAY OF COEFFICIENTS OF ELEVATION**2.
C   DGCASP -- ARRAY OF COEFFICIENTS OF COS(ASPECT)*SLOPE.
C   DGSASP -- ARRAY OF COEFFICIENTS FOR SIN(ASPECT)*SLOPE.
C   DGSLOP -- ARRAY OF COEFFICIENTS FOR SLOPE.
C   DGSLSQ -- ARRAY OF COEFFICIENTS FOR SLOPE**2.
C   DGPCCF -- ARRAY OF COEFFICIENTS FOR POINT CROWN COMPETITION FACTOR.
C    DGHAH -- ARRAY OF COEFFICIENTS FOR THE RELATIVE HEIGHT TERM.
C
C----------
C  SPECIES ORDER 1=SF,  2=WF,  3=GF,  4=AF,  5=RF,  6=SS,  7=NF,  8=YC,
C                9=IC, 10=ES, 11=LP, 12=JP, 13=SP, 14=WP, 15=PP, 16=DF,
C               17=RW, 18=RC, 19=WH, 20=MH, 21=BM, 22=RA, 23=WA, 24=PB,
C               25=GC, 26=AS, 27=CW, 28=WO, 29=J , 30=LL, 31=WB, 32=KP,
C               33=PY, 34=DG, 35=HT, 36=CH, 37=WI, 38=  , 39=OT
C
C COEFFICIENT ORDER
C 1=SF, 2=WF/GF,  3=RF,  4=NF,  5=SP/WP,  6=JP/PP,  7=DF,  8=RC,
C 9=WH,  10=WH,  11=IC/ES/RW/LL/WB/KP/PY,  12=BM, 13=RA,
C 14=WA/PB/GC/AS/CW/J/DG/HT/CH/WI,  15=YC,  16=LP,  17=AF,  18=SS,  19=WO
C
C  THE COEFFICIENTS FOR JP/PP ARE FROM THE CA VARIANT. THE EQUATION
C  DEVELOPED FROM THE VERY LIMITED DATA SET AVAILABLE FROM THE WC
C  AREA DID NOT PERFORM VERY WELL.  GED 1/29/03
C
      REAL DIAM(MAXTRE),DGLD(19),DGLBA(19),DGCR(19),DGCRSQ(19),
     &   DGDBAL(19),DGBAL(19),DGFOR(3,19),DGDS(3,19),DGEL(19),
     &   DGEL2(19),DGSASP(19),DGCASP(19),DGSLOP(19),DGSLSQ(19),
     &   DGBA(19),DGSITE(19),DGPCCF(19),DGHAH(19)
      INTEGER MAPDSQ(6,19),MAPLOC(6,19),MAPSPC(39),OBSERV(19)
      INTEGER ISPC,I1,I2,JSPC,I3,I,IPCCF
      REAL CONSPP,D,BARK,BRATIO,CONST,DIAGR,DDS,CR,BAL,RELHT,X1
      REAL XPPDDS,SASP,XSITE,TEMEL
C
      DATA MAPSPC/
     & 1,2,2,3, 4,18,4,15,11,11,16,6,5,5,6,7,11,8,9,10,12,
     & 13,14,14,14,14,14,19,14,11,11,11,11,14,14,14,14,14,14/
C
      DATA DGLD/
     & 0.919402, 0.905119, 0.993986, 0.904253, 0.844690, 0.738750,
     & 0.802905, 0.744005, 0.641956, 0.857131, 0.879338, 1.024186,
     & 0.511442, 0.889596, 0.816880, 0.478504, 0.949631, 1.049845,
     & 1.66609/
C
      DATA DGCR/
     & 1.290568, 1.754811, 1.522401, 4.123101, 1.597250, 3.454857,
     & 1.936912, 0.771395, 1.471926, 1.505513, 1.970052, 0.459387,
     & 0.623093, 1.732535, 2.471226, 1.905011, 1.826879, 1.632468,
     & 0.0/
C
      DATA DGCRSQ/
     & 0.125823, 0.0     , 0.0     ,-2.689340, 0.0     ,-1.773805,
     & 0.0     , 0.0     , 0.0     , 0.0     , 0.0     , 0.0     ,
     & 0.0     , 0.0     , 0.0     , 0.0     , 0.0     , 0.0     ,
     & 0.0/
C
      DATA DGSITE/
     & 0.541881, 0.318254, 0.349888, 0.684939, 0.404010, 1.011504,
     & 0.495162, 0.708166, 0.634098, 0.208040, 0.252853, 1.965888,
     & 0.237269, 0.227307, 0.244694, 0.391327, 0.375175, 0.0     ,
     & 0.14995/
C
      DATA DGDBAL/
     & -0.002133, -0.005355, -0.002979, -0.006368, -0.003726, -0.013091,
     & -0.001827, -0.016240, -0.012589, -0.004101, -0.004215, -0.010222,
     & -0.027074, -0.001265, -0.005950, -0.004706, -0.005350, -0.000086,
     & 0.0/
C
      DATA DGLBA/
     & -0.136818,  0.0     ,  0.0     ,  0.0     ,  0.0     , -0.131185,
     & -0.129474, -0.130036, -0.085525,  0.0     ,  0.0     ,  0.0     ,
     & -0.481983,  0.0     ,  0.0     ,  0.0     ,  0.0     , -0.198636,
     & 0.0/
C
      DATA DGBA/
     &  0.0     ,  0.0     , -0.000137,  0.0     ,  0.0     ,  0.0     ,
     &  0.0     ,  0.0     ,  0.0     ,  0.0     , -0.000173,  0.0     ,
     &  0.0     , -0.000981, -0.000147, -0.000114,  0.000040,  0.0     ,
     & -0.00204/
C
      DATA DGBAL/
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     & -0.001639,  0.003883,  0.002385,  0.0     ,  0.0     ,  0.0     ,
     &  0.008903,  0.0     ,  0.0     ,  0.0     ,  0.0     , -0.002319,
     & -0.00326/
C
      DATA DGPCCF/
     &  0.0     ,  0.0     ,  0.0     , -0.000471, -0.000257, -0.000593,
     &  0.0     ,  0.0     ,  0.0     , -0.000201,  0.0     , -0.000757,
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0/
C
      DATA DGHAH/
     &  0.0     , -0.000661,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0/
C----------
C  IDTYPE IS A HABITAT TYPE INDEX THAT IS COMPUTED IN **RCON**.
C  ASPECT IS STAND ASPECT.  OBSERV CONTAINS THE NUMBER OF
C  OBSERVATIONS BY SPECIES FOR THE UNDERLYING MODEL (THIS DATA
C  IS ACTUALLY USED BY **DGDRIV** FOR CALIBRATION).
C  INDEX NUMBERS FOR ARRAY OBSERV ARE SHOWN ABOVE IN COMMENTS ABOUT
C  COEFICIENT ORDER.
C----------
      DATA  OBSERV/
     &   622., 1487., 747., 1467.,  596., 2482., 11563., 1192., 4293.,
     &  2848.,  475.,  78., 1369.,  220., 112.,   759.,  542.,  502.,
     &  2144/
C----------
C  DGFOR CONTAINS LOCATION CLASS CONSTANTS FOR EACH SPECIES.
C  MAPLOC IS AN ARRAY WHICH MAPS FOREST ONTO A LOCATION CLASS.
C----------
      DATA MAPLOC/
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,1,1,1,1,1,
     & 1,2,2,2,2,2,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,1,1,1,1,1,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,2,3,3,3,3,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,1,1,1,1,1,
     & 1,2,1,2,2,2,
     & 1,1,1,1,1,1/
C
      DATA DGFOR/
     & -0.627531,  0.0     ,  0.0     ,
     & -0.643920,  0.0     ,  0.0     ,
     & -1.888949, -1.276180,  0.0     ,
     & -1.401865, -1.127977,  0.0     ,
     & -0.589570, -0.909553,  0.0     ,
     & -2.922255,  0.0     ,  0.0     ,
     & -0.739354, -0.199200,  0.0     ,
     & -0.688250, -0.405590,  0.0     ,
     & -0.594460, -0.522658,  0.0     ,
     & -1.052161, -0.793945,  0.0     ,
     & -1.310067, -1.432659,  0.0     ,
     & -7.753469, -8.279266,  0.0     ,
     &  4.253807,  3.913250,  3.507520,
     & -0.107648, -0.098335,  0.0     ,
     & -1.277664, -1.178041,  0.0     ,
     & -0.524624, -0.803095,  0.0     ,
     & -9.211184, -9.800653,  0.0     ,
     &  2.075598,  2.100904,  0.0     ,
     & -1.33299 ,  0.0     ,  0.0     /
C----------
C  DGDS CONTAINS COEFFICIENTS FOR THE DIAMETER SQUARED TERMS
C  IN THE DIAMETER INCREMENT MODELS    ARRAYED BY FOREST BY
C  SPECIES.  MAPDSQ IS AN ARRAY WHICH MAPS FOREST ONTO A DBH**2
C  COEFFICIENT.
C----------
      DATA MAPDSQ/
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,2,1,2,2,2,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,2,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,1,1,1,1,1,
     & 1,2,1,2,2,2,
     & 1,1,1,1,1,1/
C
      DATA DGDS/
     & -0.0002641,  0.0      ,  0.0      ,
     & -0.0003137,  0.0      ,  0.0      ,
     & -0.0002621,  0.0      ,  0.0      ,
     & -0.0003996,  0.0      ,  0.0      ,
     & -0.0000596,  0.0      ,  0.0      ,
     & -0.0004708,  0.0      ,  0.0      ,
     & -0.0000896, -0.0000641,  0.0      ,
     & -0.0000572, -0.0000862,  0.0      ,
     & -0.0001736, -0.0001040,  0.0      ,
     & -0.0002214,  0.0      ,  0.0      ,
     & -0.0001323,  0.0      ,  0.0      ,
     & -0.0001737,  0.0      ,  0.0      ,
     & -0.0005099,  0.0      ,  0.0      ,
     &  0.0      ,  0.0      ,  0.0      ,
     & -0.0002536,  0.0      ,  0.0      ,
     &  0.0      ,  0.0      ,  0.0      ,
     & -0.0003552,  0.0      ,  0.0      ,
     & -0.0002123, -0.0001361,  0.0      ,
     & -0.00154  ,  0.0      ,  0.0      /
C----------
C  DGEL CONTAINS THE COEFFICIENTS FOR THE ELEVATION TERM IN THE
C  DIAMETER GROWTH EQUATION.  DGEL2 CONTAINS THE COEFFICIENTS FOR
C  THE ELEVATION SQUARED TERM IN THE DIAMETER GROWTH EQUATION.
C  DGSASP CONTAINS THE COEFFICIENTS FOR THE SIN(ASPECT)*SLOPE
C  TERM IN THE DIAMETER GROWTH EQUATION.  DGCASP CONTAINS THE
C  COEFFICIENTS FOR THE COS(ASPECT)*SLOPE TERM IN THE DIAMETER
C  GROWTH EQUATION.  DGSLOP CONTAINS THE COEFFICIENTS FOR THE
C  SLOPE TERM IN THE DIAMETER GROWTH EQUATION.  DGSLSQ CONTAINS
C  COEFFICIENTS FOR THE (SLOPE)**2 TERM IN THE DIAMETER GROWTH
C  MODELS.  ALL OF THESE ARRAYS ARE SUBSCRIPTED BY SPECIES.
C----------
      DATA DGCASP/
     & -0.217205,  0.0     , -0.782418, -0.374512,  0.0     ,  0.0     ,
     &  0.014165, -0.106936, -0.056608, -0.104495,  0.0     ,  0.0     ,
     &  0.022254,  0.085958, -0.023186,  0.207853, -0.935870, -0.221095,
     &  0.0/
C
      DATA DGSASP/
     &  0.096326,  0.0     ,  0.022160, -0.207659,  0.0     ,  0.0     ,
     &  0.003263, -0.106020,  0.061254, -0.126130,  0.0     ,  0.0     ,
     & -0.085538, -0.863980,  0.679903,  0.378860,  0.202507,  0.100081,
     &  0.0/
C
      DATA DGSLOP/
     & -0.265612,  0.0     ,  0.319956,  0.400223,  0.0     ,  0.0     ,
     & -0.340401, -0.303490,  0.736143,  0.411602,  0.0     ,  0.0     ,
     &  0.0     ,  0.0     ,  0.0     , -0.066440,  0.0     , -0.169141,
     &  0.0/
C
      DATA DGSLSQ/
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0     ,  0.0     , -1.082191,  0.0     ,  0.0     ,  0.0     ,
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0/
C
      DATA DGEL/
     & -0.023858, -0.003051, -0.003773, -0.069045, -0.023376, -0.003784,
     & -0.009845, -0.009564, -0.018444, -0.003809,  0.0     , -0.012111,
     &  0.0     , -0.075986,  0.0     , -0.005414,  0.323546,  0.007009,
     &  0.0/

      DATA DGEL2/
     &  0.0     ,  0.0     ,  0.0     ,  0.000608,  0.0     , 0.0000666,
     &  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,  0.0     ,
     &  0.0     ,  0.001193,  0.0     ,  0.0     , -0.003130,  0.0     ,
     &  0.0/
C
      LOGICAL DEBUG
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE DGF  CYCLE =',I5)
C----------
C  DEBUG OUTPUT: MODEL COEFFICIENTS.
C----------
      IF(DEBUG) WRITE(JOSTND,*) 'IN DGF,HTCON=',HTCON,
     *'ELEV=',ELEV,'RELDEN=',RELDEN
      IF(DEBUG)
     & WRITE(JOSTND,9000) DGCON,DGDSQ
 9000 FORMAT(/11(1X,F10.5))
C----------
C  BEGIN SPECIES LOOP.  ASSIGN VARIABLES WHICH ARE SPECIES
C  DEPENDENT
C----------
      DO 20 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 20
      I2=ISCT(ISPC,2)
      JSPC=MAPSPC(ISPC)
      CONSPP= DGCON(ISPC) + COR(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES ISPC.
C----------
      DO 10 I3=I1,I2
      I=IND1(I3)
      D=DIAM(I)
      IF (D.LE.0.0) GOTO 10
C----------
C  RED ALDER USES A DIFFERENT EQUATION.
C  FUNCTION BOTTOMS OUT AT D=18. DECREASE LINERALY AFTER THAT TO
C  DG=0 AT D=28, AND LIMIT TO .1 ON LOWER END.  GED 4-15-93.
C----------
      IF(JSPC .EQ. 13) THEN
	BARK=BRATIO(22,D,HT(I))
	CONST=3.250531 - 0.003029*BA
	IF(D .LE. 18.) THEN
	  DIAGR = CONST - 0.166496*D + 0.004618*D*D
	ELSE
	  DIAGR = CONST - (CONST/10.)*(D-18.)
	ENDIF
	IF(DIAGR .LT. 0.1) DIAGR=0.1
	DDS = ALOG(DIAGR*(2.0*D*BARK+DIAGR))+ALOG(COR2(ISPC))+COR(ISPC)
	GO TO 5
      ENDIF
C
      CR=ICR(I)*0.01
      BAL = (1.0 - (PCT(I)/100.)) * BA
      IPCCF=ITRE(I)
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
C----------
C  THIS FUNCTION OCCASIONALLY GIVES UNDERFLOW ERROR ON PC. SPLITTING
C  IT INTO TWO PARTS IS A TEMPORARY FIX WHICH WORKS. GD 2/20/97
C----------
       DDS = CONSPP + DGLD(JSPC)*ALOG(D)
     & + CR*(DGCR(JSPC) + CR*DGCRSQ(JSPC))
     & + DGDSQ(JSPC)*D*D  + DGDBAL(JSPC)*BAL/(ALOG(D+1.0))
       DDS = DDS + DGPCCF(JSPC)*PCCF(IPCCF) + DGHAH(JSPC)*RELHT
     & + DGLBA(JSPC)*ALOG(BA)
     & + DGBAL(JSPC)*BAL + DGBA(JSPC)*BA
    5 CONTINUE
      IF(DEBUG) WRITE(JOSTND,8000)
     &I,ISPC,CONSPP,D,BA,CR,BAL,PCCF(IPCCF),RELDEN,HT(I),AVH
 8000 FORMAT(1H0,'IN DGF 8000F',2I5,9F11.4)
C---------
C     CALL PPDGF TO GET A MODIFICATION VALUE FOR DDS THAT ACCOUNTS
C     FOR THE DENSITY OF NEIGHBORING STANDS.
C
      X1=0.
      XPPDDS=0.
      CALL PPDGF (XPPDDS,X1,X1,X1,X1,X1,X1)
C
      DDS=DDS+XPPDDS
C---------
      IF(DDS.LT.-9.21) DDS=-9.21
      WK2(I)=DDS
C----------
C  END OF TREE LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)THEN
      WRITE(JOSTND,9001) I,ISPC,DDS
 9001 FORMAT(' IN DGF, I=',I4,',  ISPC=',I3,',  LN(DDS)=',F7.4)
      ENDIF
   10 CONTINUE
C----------
C  END OF SPECIES LOOP.
C----------
   20 CONTINUE
      IF(DEBUG) WRITE(JOSTND,100)ICYC
  100 FORMAT(' LEAVING SUBROUTINE DGF  CYCLE =',I5)
      RETURN
      ENTRY DGCONS
C----------
C  ENTRY POINT FOR LOADING COEFFICIENTS OF THE DIAMETER INCREMENT
C  MODEL THAT ARE SITE SPECIFIC AND NEED ONLY BE RESOLVED ONCE.
C----------
C  CHECK FOR DEBUG.
C----------
      CALL DBCHK (DEBUG,'DGF',3,ICYC)
C----------
C  ENTER LOOP TO LOAD SPECIES DEPENDENT VECTORS.
C  CONSTRAIN ELEVATION TERM FOR MODEL 14 TO BE LE 30
C  WO USES KINGS SI FOR DF IN DDS EQUATION, SO HAS TO BE TRANSLATED
C----------
      DO 30 ISPC=1,MAXSP
      JSPC=MAPSPC(ISPC)
      ISPFOR=MAPLOC(IFOR,JSPC)
      ISPDSQ=MAPDSQ(IFOR,JSPC)
      SASP =
     &                 +(DGSASP(JSPC) * SIN(ASPECT)
     &                 + DGCASP(JSPC) * COS(ASPECT)
     &                 + DGSLOP(JSPC)) * SLOPE
     &                 + DGSLSQ(JSPC) * SLOPE * SLOPE
      XSITE=SITEAR(ISPC)
      IF(JSPC.EQ.10)XSITE=XSITE*3.281
      IF(JSPC.EQ.19)XSITE=-37.60812*ALOG(1-(XSITE/114.24569)**.4444)
      TEMEL=ELEV
      IF(JSPC.EQ.14 .AND. TEMEL.GT.30.)TEMEL=30.
      DGCON(ISPC) =
     &                   DGFOR(ISPFOR,JSPC)
     &                 + DGEL(JSPC) * TEMEL
     &                 + DGEL2(JSPC) * TEMEL * TEMEL
     &                 + DGSITE(JSPC)*ALOG(XSITE)
     &                 + SASP
      DGDSQ(JSPC)=DGDS(ISPDSQ,JSPC)
      ATTEN(JSPC)=OBSERV(JSPC)
      SMCON(ISPC)=0.
      IF(DEBUG)WRITE(JOSTND,9030)DGFOR(ISPFOR,JSPC),
     &DGEL(JSPC),ELEV,DGEL2(JSPC),DGSASP(JSPC),ASPECT,
     &DGCASP(JSPC),DGSLOP(JSPC),SLOPE,DGSITE(JSPC),
     &SITEAR(ISPC),DGCON(ISPC),SASP,XSITE
 9030 FORMAT(' IN DGF 9030',13F9.5)
C----------
C  IF READCORD OR REUSCORD WAS SPECIFIED (LDCOR2 IS TRUE) ADD
C  LN(COR2) TO THE BAI MODEL CONSTANT TERM (DGCON).  COR2 IS
C  INITIALIZED TO 1.0 IN BLKDATA.
C----------
      IF (LDCOR2.AND.COR2(ISPC).GT.0.0) DGCON(ISPC)=DGCON(ISPC)
     &  + ALOG(COR2(ISPC))
   30 CONTINUE
      RETURN
      END
