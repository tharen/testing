      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C  **HTGF--NI23  DATE OF LAST REVISION:  07/08/11
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT INCREMENT FOR
C  EACH CYCLE AND LOADS IT INTO THE ARRAY HTG. HEIGHT INCREMENT IS
C  PREDICTED FROM SPECIES, HABITAT TYPE, HEIGHT, DBH, AND PREDICTED DBH
C  INCREMENT.  THIS ROUTINE IS CALLED FROM **TREGRO** DURING REGULAR
C  CYCLING.  ENTRY **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE
C  DEPENDENT CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
COMMONS
C----------
C   MODEL COEFFICIENTS AND CONSTANTS:
C
C    BIAS -- THE AVERAGE RESIDUAL.
C
C   HTCON -- AN ARRAY CONTAINING HABITAT TYPE CONSTANTS FOR
C            HEIGHT GROWTH MODEL (SUBSCRIPTED BY SPECIES)
C
C  HDGCOF -- COEFFICIENT FOR DIAMETER GROWTH TERMS.
C
C    HGLD -- AN ARRAY, SUBSCRIPTED BY SPECIES, OF THE
C             COEFFICIENTS FOR THE DIAMETER TERM IN THE HEIGHT
C             GROWTH MODEL.
C
C   H2COF -- COEFFICIENT FOR HEIGHT SQUARED TERMS.
C    IND2 -- ARRAY OF POINTERS TO SMALL TREES.
C
C   SCALE -- TIME FACTOR DERIVED BY DIVIDING FIXED POINT CYCLE
C            LENGTH BY GROWTH PERIOD LENGTH FOR DATA FROM
C            WHICH MODELS WERE DEVELOPED.
C
C  SPECIES ORDER:
C  1=WP,  2=WL,  3=DF,  4=GF,  5=WH,  6=RC,  7=LP,  8=ES,  9=AF, 10=PP,
C 11=MH, 12=WB, 13=LM, 14=LL, 15=PI, 16=JU, 17=PY, 18=AS, 19=CO, 20=MM,
C 21=PB, 22=OH, 23=OS
C
C WB USES COEFFICIENTS FOR WL
C LM AND PY USE COEFFICIENTS FROM TT FOR LM
C LL USES COEFFICIENTS FOR AF
C AS, MM, PB, CO, AND OH USE COEFFICIENTS FROM UT FOR AS
C OS USES COEFFICIENTS FOR MH
C PI AND JU USE COEFFICIENTS FROM UT
C------------
      LOGICAL DEBUG
      REAL HGLD(MAXSP),HGHC(8),HGLDD(8),HGSC(MAXSP),HGH2(8)
      INTEGER MAPHAB(30),I,ISPC,I1,I2,I3,ITFN,IICR,K,IXAGE,IHT
      REAL HGLH,BIAS,SCALE,XHT,HTI,D,CON,COF1,COF2,COF3,COF4,COF5
      REAL COF6,COF7,COF8,COF9,TEMD,Y1,Y2,FBY1,FBY2,Z,ZADJ,CLOSUR
      REAL DIA,BRATIO,PSI,H,HTNEW,TEMHTG
      REAL COFLM(9,3),COFAS(9,3)
      REAL MISHGF
C
      DATA HGLD/-.04935,-.3899,-.4574,-.09775,-.1555,-.1219,
     &       -.2454,-.5720,-.1997,-.5657,-.1219,
     &       -.3899,0.0,-.1997,8*0.0,-.1219/
C
      DATA (COFLM(I,1),I=1,9)/
     +37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697,
     +3.57635,0.90283/
      DATA (COFLM(I,2),I=1,9)/
     +45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375,
     +2.17942,0.88103/
      DATA (COFLM(I,3),I=1,9)/
     +45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453,
     +2.46480,1.00316/
C
       DATA (COFAS(I,1),I=1,9)/
     +30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051,
     +3.00551,1.01433/
      DATA (COFAS(I,2),I=1,9)/
     +30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051,
     +3.00551,1.01433/
      DATA (COFAS(I,3),I=1,9)/
     +35.0,85.0,1.80388,-0.07682,1.70032,1.29148,0.72343,
     +2.91519,0.95244/
C
      DATA BIAS/ .4809 /, HGLH/ 0.23315 /
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      SCALE=FINT/YR
      ISMALL=0
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      XHT=1.0
      XHT=XHMULT(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.
      IF (PROB(I).LE.0.0)THEN 
        IF(LTRIP)THEN
          ITFN=ITRN+2*I-1
          HTG(ITFN)=0.
          HTG(ITFN+1)=0.
        ENDIF
        GO TO 30
      ENDIF
      HTI=HT(I)
      D = DBH(I)
C----------
C   HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C
C ORIGINAL NI SECTION
C----------
      IF(ISPC.LE.12 .OR. ISPC.EQ.14 .OR. ISPC.EQ.23)THEN
        CON=HTCON(ISPC)+H2COF*HTI*HTI+HGLD(ISPC)*ALOG(D)+
     &      HGLH*ALOG(HTI)
        HTG(I)=EXP(CON+HDGCOF*ALOG(DG(I)))+BIAS
        IF(HTG(I).LT.0.1)HTG(I)=0.1
C----------
C  SKIP THIS SECTION FOR PI AND JU
C----------
      ELSEIF(ISPC.EQ.15 .OR. ISPC.EQ.16)THEN
        GO TO 30
C----------
C  EQUATIONS FROM UT AND TT VARIANTS
C----------
      ELSE
        IICR= ICR(I)/10.0 + 0.5
        IF(IICR .GT. 9) IICR=9
        GO TO(101,101,102,102,102,102,102,103,103),IICR
  101   K=1
        GO TO 110
  102   K=2
        GO TO 110
  103   K=3
  110   CONTINUE
        IF(ISPC.EQ.13 .OR. ISPC.EQ.17)THEN
          COF1=COFLM(1,K)
          COF2=COFLM(2,K)
          COF3=COFLM(3,K)
          COF4=COFLM(4,K)
          COF5=COFLM(5,K)
          COF6=COFLM(6,K)
          COF7=COFLM(7,K)
          COF8=COFLM(8,K)
          COF9=COFLM(9,K)       
        ELSE
          COF1=COFAS(1,K)
          COF2=COFAS(2,K)
          COF3=COFAS(3,K)
          COF4=COFAS(4,K)
          COF5=COFAS(5,K)
          COF6=COFAS(6,K)
          COF7=COFAS(7,K)
          COF8=COFAS(8,K)
          COF9=COFAS(9,K)         
        ENDIF
C-----------
C  CHECK IF HEIGHT OR DBH EXCEED PARAMETERS
C-----------
        IF (HTI.LE. 4.5) GOTO 180
        IF((0.1 + COF1) .LE. D) GO TO 180
        IF((4.5 + COF2) .LE. HTI) GO TO 180
        GO TO 490
  180   CONTINUE
C------------
C    THE SBB IS UNDEFINED IF CERTAIN INPUT VALUES EXCEED PARAMETERS IN
C    THE FITTED DISTRIBUTION.  IN INPUT VALUES ARE EXCESSIVE THE HEIGHT
C    GROWTH IS TAKEN TO BE ZERO.
C------------
        HTG(I) = 0.1
        GO TO 60
  490   CONTINUE
C------------
C CALCULATE ALPHA FOR THE TREE USING SCHREUDER + HAFLEY
C------------
        TEMD=D
        IF(TEMD .LE. 0.2)TEMD=0.2
        Y1=(TEMD - 0.1)/COF1
        Y2=(HTI - 4.5)/COF2
        FBY1=ALOG(Y1/(1.0 - Y1))
        FBY2= ALOG(Y2/(1.0 - Y2))
        Z=( COF4 + COF6*FBY2 - COF7*( COF3 +
     +   COF5*FBY1))*(1.0 - COF7**2)**(-0.5)
C------------
C THE HT DIA MODEL NEEDS MODIFICATION TO CORRECT KNOWN BIAS
C------------
        IF(ISPC.NE.13 .AND. ISPC.NE.17)THEN
          ZADJ = .1 - .10273*Z + .00273*Z*Z
          IF(ZADJ .LT. 0.0)ZADJ=0.0
          Z=Z+ZADJ
        ENDIF
C-----------
C YOUNG SMALL LODGEPOLE HTG ACCELLERATOR BASED ON TARGHEE HTG
C-----------
        IF(IAGE .EQ. 0 .OR. ICYC .GT. 1)GO TO 184
        IXAGE=IAGE + IY(ICYC) -IY(1)
        IF(IXAGE .LT. 40. .AND. IXAGE .GT. 10. .AND. D
     &     .LT. 9.0)THEN
          IF(Z .GT. 2.0) GO TO 184
          ZADJ=.3564*DG(I)*FINT/YR
          CLOSUR=PCT(I)/100.0
          IF(RELDEN .LT. 100.0)CLOSUR=1.0
          IF(DEBUG)WRITE(JOSTND,9650)ELEV,IXAGE,ZADJ,FINT,YR,
     &     DG(I),CLOSUR
 9650     FORMAT(' ELEV',F6.1,'IXAGE',F5.0,'ZADJ',
     &    F10.4,'FINT',F6.0,'YR',F6.0,'DG',F10.3,'CLOSUR',F10.1)
          ZADJ=ZADJ*CLOSUR
C-----------
C ADJUSTMENT IS HIGHER FOR LONG CROWNED TREES
C-----------
          IF(IICR .EQ. 9 .OR. IICR .EQ. 8)ZADJ=ZADJ*1.1
          Z=Z + ZADJ
          IF(Z .GT. 2.0)Z=2.0
        ENDIF
  184   CONTINUE
C-----------
C CALCULATE DIAMETER AFTER 10 YEARS
C-----------
        DIA= D + DG(I)/BRATIO(ISPC,D,HTI)
        IF((0.1 + COF1) .GT. DIA) GO TO 185
        HTG(I) = 0.1
        GO TO 60
  185   CONTINUE
C-----------
C  CALCULATE HEIGHT AFTER 10 YEARS
C-----------
        PSI= COF8*((DIA-0.1)/(0.1 + COF1 - DIA))**COF9
     +     * (EXP(Z*((1.0 - COF7**2  ))**0.5/COF6))
C
        H= ((PSI/(1.0 + PSI))* COF2) + 4.5
C 
        IF(.NOT. DEBUG)GO TO 191
        WRITE(JOSTND,9631)D,DIA,HTI,DG(I),Z ,H
 9631   FORMAT(1X,'IN HTGF DIA=',F7.3,'DIA+10=',F7.3,'H=',F7.1,
     &  'DIA GR=',F8.3,'Z=',E15.8,'NEW H=',F8.1)
  191   CONTINUE
C------------
C  CALCULATE HEIGHT GROWTH
C   NEGATIVE HEIGHT GROWTH IS NOT ALLOWED
C------------
        IF(H .LT. HT(I)) H=HT(I)
        HTG(I)= (H - HT(I))
      ENDIF
C
   60 CONTINUE
C
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS (HTGMULT).
C    MULTIPLIED BY EXP(HTCON()) FOR SPECIES WHERE HCOR2 MULTIPLIER
C    HAS NOT ALREADY BEEN ACCOUNTED FOR (READCORH).
C
      SELECT CASE (ISPC)
      CASE(13,15:22)
        HTG(I)=HTG(I)*SCALE*XHT*EXP(HTCON(ISPC))
      CASE DEFAULT
        HTG(I)=HTG(I)*SCALE*XHT
      END SELECT
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
C
      TEMHTG=HTG(I)
C
      IF(DEBUG)THEN
        HTNEW=HT(I)+HTG(I)
        WRITE (JOSTND,9000) HTG(I),CON,HTCON(ISPC),H2COF,D,
     &  WK1(I),HGLH,HTNEW,HDGCOF,I,ISPC
 9000   FORMAT(' 9000 HTGF, HTG=',F8.4,' CON=',F8.4,' HTCON=',F8.4,
     &  ' H2COF=',F12.8,' D =',F8.4/' WK1=',F8.4,' HGLH=',F8.4,
     &  ' HTNEW=',F8.4,' HDGCOF=',F8.4,' I=',I4,' ISPC=',I2)
      ENDIF     
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
C
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      IF(ISPC.EQ.13 .OR. (ISPC.GE.17 .AND. ISPC.LE.22))THEN
        HTG(ITFN)=TEMHTG
      ELSE
        HTG(ITFN)=EXP(CON+HDGCOF*ALOG(DG(ITFN)))+BIAS
        IF(HTG(ITFN).LT.0.1)HTG(ITFN)=0.1
        HTG(ITFN)=HTG(ITFN)*SCALE*XHT
      ENDIF
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      IF(ISPC.EQ.13 .OR. (ISPC.GE.17 .AND. ISPC.LE.22))THEN
        HTG(ITFN+1)=TEMHTG
      ELSE
        HTG(ITFN+1)=EXP(CON+HDGCOF*ALOG(DG(ITFN+1)))+BIAS
        HTG(ITFN+1)=HTG(ITFN+1)*SCALE*XHT
        IF(HTG(ITFN+1).LT.0.1)HTG(ITFN+1)=0.1
      ENDIF
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
C----------
C   END OF TREE LOOP
C----------
   30 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
   40 CONTINUE
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT ARE
C  SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.  HGHC CONTAINS
C  HABITAT TYPE INTERCEPTS, HGLDD CONTAINS HABITAT DEPENDENT
C  COEFFICIENTS FOR THE DIAMETER INCREMENT TERM, HGH2 CONTAINS HABITAT
C  DEPENDENT COEFFICIENTS FOR THE HEIGHT-SQUARED TERM, AND HGHC CONTAINS
C  SPECIES DEPENDENT INTERCEPTS.  HABITAT TYPE IS INDEXED BY ITYPE (SEE
C  /PLOT/ COMMON AREA).
C----------
      DATA MAPHAB/
     & 1,1, 7*2, 3,3,4,5,6, 4*7, 4,4,1,4,4, 3*8, 4*1/
      DATA  HGHC /
     & 2.03035, 1.72222, 1.19728, 1.81759, 2.14781, 1.76998, 2.21104,
     & 1.74090/
      DATA  HGLDD /
     & 0.62144, 1.02372, 0.85493, 0.75756, 0.46238, 0.49643, 0.37042,
     & 0.34003/
      DATA  HGH2 /
     & -13.358E-05, -3.809E-05, -3.715E-05, -2.607E-05, -5.200E-05,
     & -1.605E-05, -3.631E-05, -4.460E-05/
      DATA  HGSC /
     &  -.5342, .1433, .1641,-.6458,-.6959,-.9941,-.6004, .2089,
     &  -.5478, .7316,-.9941, .1433, .0,   -.5478, 8*0.0,-.9941/
C----------
C  ASSIGN HABITAT DEPENDENT COEFFICIENTS.
C----------
      IHT=MAPHAB(ITYPE)
      HGHCH=HGHC(IHT)
      H2COF=HGH2(IHT)
      HDGCOF=HGLDD(IHT)
C----------
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
      IF(ISPC.LE.12.OR.ISPC.EQ.14.OR.ISPC.EQ.23)THEN
        HTCON(ISPC)=HGHCH+HGSC(ISPC)
      ELSE
        HTCON(ISPC) = 0.0
      ENDIF
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END
