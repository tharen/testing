      SUBROUTINE MAICAL
      IMPLICIT NONE
C----------
C  **MAICAL--NI23  DATE OF LAST REVISION:  06/21/10
C----------
C  THIS SUBROUTINE CALCULATES THE MAI FOR THE STAND. IT IS CALLED
C  FROM CRATET.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE  'CONTRL.F77'
C
C
      INCLUDE  'PLOT.F77'
C
C
COMMONS
C
C----------
C
      LOGICAL DEBUG
      INTEGER ISPNUM(MAXSP),ISICD,IERR
      REAL SSSI,ADJMAI
C----------
C  INITIALIZE INTERNAL VARIABLES:
C----------
      DATA ISPNUM/119,073,202,017,263,242,108,093,019,122,264,
     &            101,101,101,101,101,101,746,740,746,375,998,
     &            101/
C
C
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'MAICAL',6,ICYC)
C
      IF(DEBUG) WRITE(JOSTND,3)ICYC,ISISP,SITEAR(ISISP)
    3 FORMAT(' ENTERING SUBROUTINE MAICAL  CYCLE =',I5,1X,I3,
     &        F6.2)
C-------
C   RMAI IS FUNCTION TO CALCULATE ADJUSTED MAI.
C-------
      IF (ISISP .EQ. 0) ISISP=3
      SSSI=SITEAR(ISISP)
      IF (SSSI .EQ. 0.) SSSI=140.
      ISICD=ISPNUM(ISISP)
      RMAI=ADJMAI(ISICD,SSSI,10.0,IERR)
      IF(RMAI .GT. 128.0)RMAI=128.0
      IF(DEBUG) WRITE(JOSTND,10)ICYC,RMAI
   10 FORMAT(' LEAVING SUBROUTINE MAICAL  CYCLE =',I5,5X,'RMAI =',F10.3)
C
      RETURN
      END
