      SUBROUTINE CUTSTK
      IMPLICIT NONE
C----------
C  NI  $ID
C----------
C  THIS SUBROUTINE CONTAINS ENTRY POINTS FOR CALCULATING STOCKING
C  LEVELS FOR VARIOUS THINNING OPTIONS.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
COMMONS
C----------
      LOGICAL LINCL
      REAL TPA
      REAL FSTOCK,TOTBA,TEMBA,TBA,TMPMAX,HU,HL,DU,DL,CSTOCK,H,D
      INTEGER I,ISPC,JSPCUT,JTYP,IC,IGRP,IULIM,IG,JPNUM
C----------
C  ENTRY AUTSTK CALCULATES NORMAL STOCKING FOR AUTOMATIC THINS.
C-----------
      ENTRY AUTSTK (FSTOCK)
C----------
C  CALCULATE MAXIMUM SDI WEIGHTED BY BASAL AREA
C  NOTE: 10.0 ** -1.605 = 0.02483133
C----------
      TOTBA = 0.0
      TEMBA = 0.0
C
      DO 210 I=1,ITRN
      ISPC = ISP(I)
      TBA = 0.0054542 * DBH(I) * DBH(I) * PROB(I)
      TEMBA = TEMBA + TBA * SDIDEF(ISPC)
      TOTBA = TOTBA + TBA
  210 CONTINUE
C
      IF(TOTBA.LE.1. .OR. TEMBA.LE.1)THEN
        FSTOCK=0.
        GO TO 50
      ELSE
        TMPMAX = TEMBA / TOTBA
      ENDIF
C
      FSTOCK= 1./((0.02483133/TMPMAX) * 2.0**1.605)
      IF(RMSQD.GT.2.0)
     &  FSTOCK= 1./((0.02483133/TMPMAX) *  RMSQD**1.605)
   50 CONTINUE
      RETURN
C
C-----------
C  ENTRY CLSSTK COMPUTES BA OR TPA STOCKING IN A SPECIFIED
C  DBH/HT/SPECIES CLASS.
C
C  CSTOCK = CLASS STOCKING
C  JTYP   = 1 IF STOCKING IS IN TPA,  2 IF STOCKING IS IN BA
C  JSPCUT = SPECIES WHICH WILL BE CUT
C  LINCL  = LOGICAL VARIABLE USED TO INCLUDE SPECIES OR NOT.
C  DL,DU  = LOWER AND UPPER DIAMETER LIMITS RESPECTIVELY (GE,LT)
C  HL,HU  = LOWER AND UPPER HEIGHT LIMITS RESPECTIVELY (GE,LT)
C  JPNUM = POINT NUMBER (IN FVS SEQUENCE FORMAT), 0 = ALL POINTS
C----------
      ENTRY CLSSTK (CSTOCK,JTYP,JSPCUT,DL,DU,HL,HU,JPNUM)
      CSTOCK=0.0
      DO 100 IC=1,ITRN
      IF(JPNUM.GT.0 .AND. ITRE(IC).NE.JPNUM)GO TO 100
C
      LINCL = .FALSE.
      IF((JSPCUT.EQ.0 .OR. JSPCUT.EQ.ISP(IC)).AND.
     &    .NOT.LEAVESP(ISP(IC)))THEN
        LINCL = .TRUE.
      ELSEIF(JSPCUT.LT.0)THEN
        IGRP = -JSPCUT
        IULIM = ISPGRP(IGRP,1)+1
        DO 60 IG=2,IULIM
        IF((ISP(IC) .EQ. ISPGRP(IGRP,IG)).AND..NOT.LEAVESP(ISP(IC)))THEN
          LINCL = .TRUE.
          GO TO 61
        ENDIF
   60   CONTINUE
      ENDIF
   61 CONTINUE
C
      IF (LINCL) THEN
        D=DBH(IC)
        H=HT(IC)
        TPA=WK4(IC)
        IF(JPNUM.GT.0)TPA=TPA*(PI-FLOAT(NONSTK))
        IF(D.LT.DL .OR. D.GE.DU) GO TO 100
        IF(H.LT.HL .OR. H.GE.HU) GO TO 100
        IF(JTYP.EQ.1) THEN
          CSTOCK=CSTOCK + TPA
        ELSE
          CSTOCK=CSTOCK + TPA*(D*D*0.005454154)
        ENDIF
      ENDIF
  100 CONTINUE
      RETURN
C
      END
