      SUBROUTINE AVHT40
      IMPLICIT NONE
C----------
C  **AVHT40--SO/M   DATE OF LAST REVISION:  06/03/10
C----------
C  THIS SUBROUTINE IS USED TO CALCULATE THE AVERAGE HEIGHT
C  OF THE 40 TPA OF LARGEST DIAMETER. (METRIC EQUIV)
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'ARRAYS.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'METRIC.F77'
C
C
COMMONS
C
      INTEGER I,II
      REAL    SSUMN,TARG,P
      
      AVH=0.
      IF (ITRN.LE.0) GOTO 70
      SSUMN=0.
      TARG = 100.0/HAtoACR ! METRIC VERSION = 40.47/AC
      DO 60 I=1,ITRN
      II=IND(I)
      P=PROB(II)
      IF(SSUMN+P.GT.TARG) P=TARG-SSUMN
      SSUMN=SSUMN+P
      AVH=AVH+HT(II)*P
      IF(SSUMN.GE.TARG) GO TO 65
   60 CONTINUE
   65 CONTINUE
      IF (SSUMN .GT. 0.) AVH = AVH/SSUMN
   70 CONTINUE
      RETURN
      END
