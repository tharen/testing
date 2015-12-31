      SUBROUTINE CCFCAL(ISPC,D,H,JCR,P,LTHIN,CCFT,CRWDTH,MODE)
      IMPLICIT NONE
C----------
C  **CCFCAL--SO   DATE OF LAST REVISION:  08/19/15
C----------
C  THIS ROUTINE COMPUTES CROWN WIDTH AND CCF FOR INDIVIDUAL TREES.
C  CALLED FROM DENSE, REGENT (TT VARIANT), PRTRLS, AND SSTAGE.
C
C  ARGUMENT DEFINITIONS:
C    ISPC = NUMERIC SPECIES CODE
C       D = DIAMETER AT BREAST HEIGHT
C       H = TOTAL TREE HEIGHT
C     JCR = CROWN RATIO IN PERCENT (0-100)
C       P = TREES PER ACRE
C   LTHIN = .TRUE. IF THINNING HAS JUST OCCURRED
C         = .FALSE. OTHERWISE
C    CCFT = CCF REPRESENTED BY THIS TREE
C  CRWDTH = CROWN WIDTH OF THIS TREE
C    MODE = 1 IF ONLY NEED CCF RETURNED
C           2 IF ONLY NEED CRWDTH RETURNED
C
C  DIMENSION AND DATA STATEMENTS FOR INTERNAL VARIABLES.
C
C     CCF COEFFICIENTS FOR TREES THAT ARE GREATER THAN 10.0 IN. DBH:
C      RD1 -- CONSTANT TERM IN CROWN COMPETITION FACTOR EQUATION,
C             SUBSCRIPTED BY SPECIES
C      RD2 -- COEFFICIENT FOR SUM OF DIAMETERS TERM IN CROWN
C             COMPETITION FACTOR EQUATION,SUBSCRIPTED BY SPECIES
C      RD3 -- COEFFICIENT FOR SUM OF DIAMETER SQUARED TERM IN
C             CROWN COMPETITION EQUATION, SUBSCRIPTED BY SPECIES
C
C     CCF COEFFICIENTS FOR TREES THAT ARE LESS THAN 10.0 IN. DBH:
C      RDA -- MULTIPLIER.
C      RDB -- EXPONENT.  CCF(I) = RDA*DBH**RDB
C
C  SPECIES ORDER:
C  1=WP,  2=SP,  3=DF,  4=WF,  5=MH,  6=IC,  7=LP,  8=ES,  9=SH,  10=PP,
C 11=JU, 12=GF, 13=AF, 14=SF, 15=NF, 16=WB, 17=WL, 18=RC, 19=WH,  20=PY,
C 21=WA, 22=RA, 23=BM, 24=AS, 25=CW, 26=CH, 27=WO, 28=WI, 29=GC,  30=MC,
C 31=MB, 32=OS, 33=OH
C
C  SOURCE OF CCF COEFFICIENTS:
C     1 = PAINE AND HANN TABLE 2: WESTERN WHITE PINE
C     2 = PAINE AND HANN TABLE 2: SUGAR PINE
C     3 = PAINE AND HANN TABLE 2: DOUGLAS-FIR
C     4 = PAINE AND HANN TABLE 2: WHITE/GRAND FIR
C     5 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: PONDEROSA PINE 
C     6 = PAINE AND HANN TABLE 2: INCENSE CEDAR
C     7 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE 
C     8 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: ENGELMANN SPRUCE
C     9 = R5 FIAS USER'S GUIDE (SEE R5CRWD): RED FIR
C    10 = PAINE AND HANN TABLE 2: PONDEROSA PINE
C    11 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C    12 = PAINE AND HANN TABLE 2: WHITE/GRAND FIR
C    13 = PAINE AND HANN TABLE 2: RED FIR
C    14 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: GRAND FIR
C    15 = PAINE AND HANN TABLE 2: NOBLE FIR
C    16 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: LODGEPOLE PINE
C    17 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN LARCH
C    18 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C    19 = PAINE AND HANN TABLE 2: WESTERN HEMLOCK
C    20 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    21 = PAINE AND HANN TABLE 2: TANOAK
C    22 = PAINE AND HANN TABLE 2: TANOAK
C    23 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    24 = NORTHERN IDAHO VARIANT INT-133 TABLE 8: WESTERN RED CEDAR
C    25 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    26 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    27 = R5 FIAS USER'S GUIDE (SEE R5CRWD): OREGON WHITE OAK
C    28 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    29 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    30 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    31 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C    32 = PAINE AND HANN TABLE 2: CALIFORNIA DOUGLAS-FIR
C    33 = PAINE AND HANN TABLE 2: CALIFORNIA BLACK OAK
C
C      PAINE AND HANN, 1982. MAXIMUM CROWN WIDTH EQUATIONS FOR
C        SOUTHWESTERN OREGON TREE SPECIES. RES PAP 46, FOR RES LAB
C        SCH FOR, OSU, CORVALLIS. 20PP.
C
C      WYKOFF, CROOKSTON, STAGE, 1982. USER'S GUIDE TO THE STAND
C        PROGNOSIS MODEL. GEN TECH REP INT-133. OGDEN, UT:
C        INTERMOUNTAIN FOREST AND RANGE EXP STN. 112P.
C----------
C
C  CROWN WIDTH EQUATIONS FOR REGION 5:
C  FROM WARBINGTON/LEVITAN & DIXON --- SEE DOCUMENTATION IN
C                                      SUBROUTINE **R5CRWD**
C
C  CROWN WIDTH EQUATIONS FOR REGION 6:
C  FROM DONNELLY --- SEE DOCUMENTATION IN SUBROUTINE **R6CRWD**
C----------
COMMONS
C
C
      INCLUDE  'PRGPRM.F77'
C
C
      INCLUDE  'PLOT.F77'
C
C
COMMONS
C----------
C----------
      LOGICAL LTHIN
      REAL RD1(MAXSP),RD2(MAXSP),RD3(MAXSP),RDA(MAXSP),RDB(MAXSP)
      REAL CRWDTH,CCFT,P,H,D
      INTEGER MODE,JCR,ISPC
C
      DATA RD1/
     &     .0186,     .0392,     .0388,     .0690,       .03,
     &     .0194,    .01925,       .03,        .0,     .0219,
     &    .01925,     .0690,     .0172,      0.04,   0.02453,
     &    .01925,      0.02,      0.03,   0.03758,    0.0204,
     &   0.03561,   0.03561,    0.0204,       .03,    0.0204,
     &    0.0204,        .0,    0.0204,    0.0204,     .0204,
     &     .0204,     .0388,     .0204/
      DATA RD2/
     &     .0146,     .0180,     .0269,     .0225,      .018,
     &     .0142,    .01676,     .0173,        .0,     .0169,
     &    .01676,     .0225,    .00877,    0.0270,   0.01147,
     &    .01676,    0.0148,    0.0238,   0.02329,    0.0246,
     &    0.0273,    0.0273,    0.0246,     .0238,    0.0246,
     &    0.0246,        .0,     .0246,     .0246,     .0246,
     &     .0246,     .0269,     .0246/
      DATA RD3/
     &    .00288,    .00207,    .00466,    .00183,    .00281,
     &    .00261,    .00365,    .00259,        .0,    .00325,
     &    .00365,    .00183,    .00112,   0.00405,   0.00134,
     &    .00365,   0.00338,   0.00490,   0.00361,    0.0074,
     &   0.00524,   0.00524,    0.0074,    .00490,    0.0074,
     &    0.0074,        .0,     .0074,     .0074,     .0074,
     &     .0074,    .00466,     .0074/
      DATA RDA/
     &  0.009884,  0.007244,  0.017299,  0.015248,   0.011109,
     &  0.008915,  0.009187,  0.007875,        .0,   0.007813,
     &  0.009187,  0.015248,  0.011402,  0.015248,         .0,
     &  0.009187,  0.007244,  0.008915,        .0,         .0,
     &        .0,        .0,        .0,  0.008915,         .0,
     &        .0,        .0,        .0,        .0,         .0,
     &        .0,  0.017299,        .0/
      DATA RDB/
     &    1.6667,    1.8182,    1.5571,    1.7333,    1.7250,
     &    1.7800,    1.7600,    1.7360,        .0,    1.7780,
     &    1.7600,    1.7333,    1.7560,    1.7333,        .0,
     &    1.7600,    1.8182,    1.7800,        .0,        .0,
     &        .0,        .0,        .0,    1.7800,        .0,
     &        .0,        .0,        .0,        .0,        .0,
     &        .0,    1.5571,        .0/
C----------
C  INITIALIZE RETURN VARIABLES.
C----------
      CCFT = 0.
      CRWDTH = 0.
      IF(P.LE.0.)GOTO 900
C----------
C  COMPUTE CROWN WIDTH, MODE=2; ALSO NEED CW TO COMPUTE CCF FOR 
C  SPECIES 9=SH AND 27=WO
C----------
      IF(MODE.EQ.2 .OR. ISPC.EQ.9 .OR. ISPC.EQ.27)THEN
C
        SELECT CASE (IFOR)
        CASE(4,5,6,7,8,9)
          CALL R5CRWD (ISPC,D,H,CRWDTH)
C----------
C  FOR REGION 6 FORESTS, COMPUTE CROWN WIDTH WITH DONNELLY EQUATIONS
C----------
        CASE DEFAULT
          CALL R6CRWD (ISPC,D,H,CRWDTH)
        END SELECT
C----------
C  LIMIT CROWN WIDTH FOR PRINTING ON TREELIST.
C----------
        IF(CRWDTH .GT. 99.9) CRWDTH=99.9
      ENDIF
C----------
C  COMPUTE CCF
C----------
      IF(MODE.EQ.1 .OR.
     &   ISPC.EQ.11.OR.ISPC.EQ.16.OR.ISPC.EQ.24) THEN
C
        SELECT CASE (ISPC)
C----------
C  SPECIES FROM WC
C----------
        CASE(15,19:23,25,26,28:31,33)
          IF (D .LT. 1.0) THEN
            CCFT = D * (RD1(ISPC)+RD2(ISPC)+RD3(ISPC))
          ELSE
            CCFT = RD1(ISPC) + RD2(ISPC)*D + RD3(ISPC)*D**2.0
          ENDIF
          CCFT = CCFT * P
        CASE(9,27)
C----------
C  SPECIES FROM CA
C----------
          CCFT= CRWDTH  * CRWDTH  * 0.001803
          CCFT = CCFT * P
C----------
C  ALL OTHER SPECIES
C----------
        CASE DEFAULT
          IF (D .GE. 1.0) THEN
            CCFT = RD1(ISPC) + D*RD2(ISPC) + D*D*RD3(ISPC)
          ELSE IF(D.GT.0.1) THEN
            CCFT = RDA(ISPC) * (D**RDB(ISPC))
          ELSE
            CCFT=0.001
          ENDIF
C
          CCFT = CCFT * P
        END SELECT
      ENDIF
C
      IF((MODE.EQ.2).AND.
     &  (ISPC.EQ.11.OR.ISPC.EQ.16.OR.ISPC.EQ.24)) THEN
C----------
C  COMPUTE CROWN WIDTH WHEN CRWDTH=F(CCF) - UT AND TT SPECIES
C----------
        CRWDTH = SQRT(CCFT/0.001803)
        IF(CRWDTH .GT. 99.9) CRWDTH=99.9
      ENDIF
C
  900 CONTINUE
      RETURN
      END
