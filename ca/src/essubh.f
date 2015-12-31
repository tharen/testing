      SUBROUTINE ESSUBH (I,HHT,EMSQR,DILATE,DELAY,ELEV,IHTSER,GENTIM,
     &  TRAGE)
      IMPLICIT NONE
C----------
C  **ESSUBH--CA   DATE OF LAST REVISION:   02/22/08
C----------
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
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
C     ASSIGNS HEIGHTS TO SUBSEQUENT AND PLANTED TREE RECORDS
C     CREATED BY THE ESTABLISHMENT MODEL.
C
C
C     COMING INTO ESSUBH, TRAGE IS THE AGE OF THE TREE AS SPECIFIED ON
C     THE PLANT OR NATURAL KEYWORD.  LEAVING ESSUBH, TRAGE IS THE NUMBER
C     BETWEEN PLANTING (OR NATURAL REGENERATION) AND THE END OF THE
C     CYCLE.  AGE IS TREE AGE UP TO THE TIME REGENT WILL BEGIN GROWING
C     THE TREE.
C
      INTEGER IHTSER,I,N,ITIME
      REAL TRAGE,GENTIM,ELEV,DELAY,DILATE,EMSQR,HHT,AGE
C
      N=DELAY+0.5
      IF(N.LT.-3) N=-3
      DELAY=FLOAT(N)
      ITIME=TIME+0.5
      IF(N.GT.ITIME) DELAY=TIME
      AGE=TIME-DELAY-GENTIM+TRAGE
      IF(AGE.LT.1.0) AGE=1.0
      TRAGE=TIME-DELAY
      GO TO (20, 20, 20, 20, 10, 10, 20, 20, 10, 30,
     &       30, 30, 30, 30, 20, 20, 20, 20, 20, 20,
     &       30, 20, 20, 40, 20, 50, 50, 50, 50, 40,
     &       40, 50, 50, 50, 50, 50, 50, 50, 40, 40,
     &       50, 50, 50, 50, 50, 50, 50, 50, 50),I
C
C     HEIGHT OF TALLEST SUBSEQUENT SPECIES 5:RF (6,9)
C
   10 CONTINUE
      HHT = 1.0
      GO TO 70
C
C     HEIGHT OF TALLEST SUBS. SPECIES 7:DF (1-4,8,15-20,22-23,25)
C
   20 CONTINUE
      HHT = 2.0
      GO TO 70
C
C     HT OF TALLEST SUBS. SPECIES 12:LP (10-14,21)
C
   30 CONTINUE
      HHT = 3.0
      GO TO 70
C
C     HT OF TALLEST SUBS. SPECIES 31:BO (24,30-32,35,39,40)
C
   40 CONTINUE
      HHT = 1.0
      GO TO 70
C
C     HT OF TALLEST SUBS. SPECIES 37:MA (26-29,33,34,36-39,41-49)
C
   50 CONTINUE
      HHT = 2.0
      GO TO 70

   70 CONTINUE
      RETURN
      END
