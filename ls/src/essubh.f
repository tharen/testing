      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,IHTSER,GENTIM,
     &  TRAGE,SI,LOSTND)
      IMPLICIT NONE
C----------
C  **ESSUBH--LS   DATE OF LAST REVISION:   07/11/08
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
COMMONS
C
      REAL MAPLS(68)
      LOGICAL DEBUG
      INTEGER LOSTND,IHTSER,I,IAGE,IVAR,N,ITIME,MODE0
      REAL SI,TRAGE,GENTIM,ELEV,DELAY,DILATE,EMSQR,HHT,CARAGE,YRS,H
      REAL AGET,HTG1,HTMAX,AGE
C
      DATA MAPLS/
     &  20,   15,   20,   20,    5,   15,   15,   20,   20,   10,
     &  20,   20,   10,   10,   20,   35,   15,   15,   20,   20,
     &  20,   20,   20,   20,   20,   20,   20,   20,   20,   10,
     &  30,   10,   10,   20,   10,   10,   20,   20,   20,   20,
     &  20,   20,   20,   20,   20,   20,   10,   10,   10,   10,
     &  10,   10,   10,   20,   10,   10,   10,   10,   25,   20,
     &  10,   10,   10,   10,   10,   10,   10,   10/
C
C----------
C  ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C  CREATED BY THE ESTABLISHMENT MODEL.
C
C  COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON 
C  THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER 
C  OF YEARS BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF 
C  THE CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING 
C  THE TREE.
C
C  FIRST CALL HTCALC TO GET THE HT AT THE LOWEST REFERENCE AGE, GIVEN A
C  SITE INDEX FROM CARMEAN'S CURVES. THEN INTERPOLATE HT GIVEN THE AGE
C  OF THE TREE ASSUMING A STRAIGHT LINE RELATIONSHIP THROUGH THE ORIGIN.
C----------
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'ESSUBH',6,ICYC)
      IF(DEBUG) WRITE(LOSTND,9980)ICYC
 9980 FORMAT(' ENTERING SUBROUTINE ESSUBH  CYCLE =',I5)
      IAGE = MAPLS(I)
      CARAGE=FLOAT(IAGE)
      MODE0=1
      IVAR=1
      YRS=0.
      H=0.
      AGET=CARAGE
      CALL HTCALC (MODE0,IVAR,I,SI,YRS,H,AGET,HTMAX,
     &               HTG1,LOSTND,DEBUG)
      HHT = (H/CARAGE)*MIN(5.0,TIME-DELAY)
      IF(DEBUG) WRITE(LOSTND,*)' IN ESSUBH SI,CARAGE,TRAGE,H,HHT= ',
     &SI,CARAGE,TRAGE,H,HHT
C
      IF(DEBUG) WRITE(LOSTND,*)' IN ESSUBH DELAY,TIME,GENTIM,TRAGE= ',
     &DELAY,TIME,GENTIM,TRAGE
      N=DELAY+0.5
      IF(N.LT.-3) N=-3
      DELAY=FLOAT(N)
      ITIME=TIME+0.5
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      TRAGE=TIME-DELAY
      IF(DEBUG)WRITE(LOSTND,*)' LEAVING ESSUBH AGE,TRAGE= ',AGE,TRAGE
C
      RETURN
      END
