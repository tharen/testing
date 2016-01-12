      SUBROUTINE ESADVH (EMSQR,I,HHT,DELAY,ELEV,DILATE,IHTSER,
     &  GENTIM,TRAGE)
      use esparm_mod
      use escomn_mod
      use prgprm_mod
      implicit none
C----------
C  **ESADVH--NI23   DATE OF LAST REVISION:   04/01/08
C----------
C
      INCLUDE 'ESCOM2.F77'
C
C     CALCULATES HEIGHTS OF ADVANCE TREES FOR REGENERATION MODEL
C
      REAL THAB(5,MAXSP),TPRE(4,MAXSP),TPHY(5,MAXSP)
      REAL TRAGE,GENTIM,DILATE,ELEV,DELAY,HHT,EMSQR
      REAL AGE,AGELN,BNORM,PN
      INTEGER IHTSER,I,ITIME,N
C
C     CONSTANTS FOR ADVANCE HEIGHTS BY HABITAT TYPE GROUP
C     HAB.TYPE--> WET DFIR  DRY DFIR  GRANDFIR  WRC/WH   SAF
C
      DATA THAB/ 5*0.0,
     2           5*0.0,
     3           -0.00683,  0.12521, 0.16327,  0.26886,   0.0,
     4             0.0,      0.0,    0.20183,  0.31082,   0.0,
     5           5*0.0,
     6           5*0.0,
     7           5*0.0,
     8           5*0.0,
     9           5*0.0,
     O           5*0.0,
     1           5*0.0,
     &          60*0.0/
C
C     CONSTANTS FOR ADVANCE HEIGHTS BY SITE PREP
C     SITE PREP--> NONE      MECH      BURN      ROAD
C
      DATA TPRE/ 4*0.0,
     2           4*0.0,
     3           4*0.0,
     4           4*0.0,
     5             0.0,   -0.10356, -1.23036, -0.40522,
     6           4*0.0,
     7           4*0.0,
     8           4*0.0,
     9             0.0,  -0.20770, -0.12903,  0.18322,
     O           4*0.0,
     1             0.0,  -0.10356, -1.23036, -0.40522,
     2           4*0.0,
     3           4*0.0,
     4             0.0,  -0.20770, -0.12903,  0.18322,
     &          32*0.0,
     3             0.0,  -0.10356, -1.23036, -0.40522/
C
C     CONSTANTS FOR ADVANCE HEIGHTS BY PHYSIOGRAPHIC POSITION
C     PHY.POS--> BOTTOM   LOWER     MID      UPPER   RIDGE
C
      DATA TPHY/ 5*0.0,
     2           5*0.0,
     3           0.04770, 0.41224, 0.25028, 0.23537,  0.0,
     4           5*0.0,
     5           5*0.0,
     6           0.32413, 0.39404, 0.25123, 0.23419,  0.0,
     7          -0.28223,-0.99702,-0.47684,-0.20872,  0.0,
     8           5*0.0,
     9           5*0.0,
     O          -0.18689, 0.27119, 0.70375, 0.65555,  0.0 ,
     1           5*0.0,
     &          60*0.0/
      N=DELAY+0.5
      IF(N.GT.2) N=1
      DELAY=FLOAT(N)
      TRAGE=3.0-DELAY
      AGE=3.0-DELAY-GENTIM
      IF(AGE.LT.1.0) AGE=1.0
      AGELN=ALOG(AGE)
      ITIME=TIME+0.5
      BNORM=BNORML(ITIME)
      GO TO (10,20,30,40,50,60,70,80,90,100,110,
     &       120,130,140,150,160,170,180,190,200,210,220,230),I
C
C     HEIGHT OF TALLEST ADV. WWP. 6JAN88 CARLSON
C
   10 CONTINUE
      PN=  0.05585 +0.84765*AGELN -0.003824*BAA -0.02835*ELEV
     &    -0.79565*XCOS +0.39278*XSIN -0.68673*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.51878)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. WESTERN LARCH.
C
   20 CONTINUE
      PN= -1.80559 +1.24136*AGELN
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54325)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. D-FIR. 8JAN88 CARLSON
C
   30 CONTINUE
      PN= -1.15433 +1.09480*AGELN +TPHY(IPHY,3) +THAB(IHTSER,3)
     &    -0.04804*ELEV +0.0004225*ELEV*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.63678)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. GRAND FIR. 6JAN88 CARLSON
C
   40 CONTINUE
      PN= -1.96040 +1.02403*AGELN -0.00233*BAA +THAB(IHTSER,3)
     &    +0.04315*XCOS +0.13456*XSIN -0.21468*SLO
     &    -0.05224*BWB4 -0.01898*BWAF
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.61195)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. W HEMLOCK. 7JAN88 CARLSON
C
   50 CONTINUE
      PN= -0.43269 +0.77433*AGELN -0.00378*BAA +TPRE(IPREP,5)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54794)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. WRC. 7JAN88 CARLSON
C
   60 CONTINUE
      PN=  2.11552 +0.71766*AGELN +TPHY(IPHY,6) -0.17259*ELEV
     &    +0.12506*XCOS +0.63747*XSIN -0.35258*SLO +0.0022033*ELEV*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.62044)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. LPP. 7JAN88 CARLSON
C
   70 CONTINUE
      PN= -0.59267 +0.88997*AGELN +TPHY(IPHY,7) +0.79158*XCOS
     &    +0.49060*XSIN +0.49071*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.68842)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. E. SPRUCE. 7JAN88 CARLSON
C
   80 CONTINUE
      PN= -2.19638 +1.12147*AGELN -0.002270*BAA
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.59475)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. SAF.  6JAN88 CARLSON
C
   90 CONTINUE
      PN= -1.69509 +0.87242*AGELN -0.001107*BAA +TPRE(IPREP,9)
     &    -0.06402*BWB4 +0.02299*BWAF -0.01189*XCOS +0.15379*XSIN
     &    +0.44637*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.59957)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. PONDEROSA PINE.  7JAN88 CARLSON
C
  100 CONTINUE
      PN= -6.33095 +0.79936*AGELN +TPHY(IPHY,10) +0.06347*BWAF
     &    +0.19305*ELEV -0.0020058*ELEV*ELEV
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.53813)
      GO TO 300
C
C     HEIGHT OF TALLEST ADV. M HEMLOCK (USES WH EQUATION).
C
  110 CONTINUE
      PN= -0.43269 +0.77433*AGELN -0.00378*BAA +TPRE(IPREP,11)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54794)
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED WHITEBARK PINE (USE WL)
C
  120 CONTINUE
      PN= -1.80559 +1.24136*AGELN
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54325)
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED LIMBER PINE
C
  130 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED SUBALPINE LARCH (USE SAF)
C
  140 CONTINUE
      PN= -1.69509 +0.87242*AGELN -0.001107*BAA +TPRE(IPREP,9)
     &    -0.06402*BWB4 +0.02299*BWAF -0.01189*XCOS +0.15379*XSIN
     &    +0.44637*SLO
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.59957)
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED PINYON
C
  150 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED JUNIPER
C
  160 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED PACIFIC YEW
C
  170 CONTINUE
      PN = 0.0
      HHT = 0.5
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED ASPEN
C
  180 CONTINUE
      PN = 0.0
      HHT = 5.0
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED COTTONWOOD
C
  190 CONTINUE
      PN = 0.0
      HHT = 5.0
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED MOUNTAIN MAPLE
C
  200 CONTINUE
      PN = 0.0
      HHT = 5.0
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED PAPER BIRCH
C
  210 CONTINUE
      PN = 0.0
      HHT = 5.0
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED OTHER HARDWOODS
C
  220 CONTINUE
      PN = 0.0
      HHT = 5.0
      GO TO 300
C
C     HEIGHT OF TALLEST ADVANCED OTHER SOFTWOODS (USE MH)
C
  230 CONTINUE
      PN= -0.43269 +0.77433*AGELN -0.00378*BAA +TPRE(IPREP,11)
      HHT = EXP(PN +EMSQR*DILATE*BNORM*0.54794)
C
  300 CONTINUE
      RETURN
      END
