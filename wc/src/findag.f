      SUBROUTINE FINDAG(I,ISPC,D,D2,H,SITAGE,SITHT,AGMAX1,HTMAX,HTMAX2,
     &                  DEBUG)
      IMPLICIT NONE
C----------
C  **FINDAG--WC  DATE OF LAST REVISION:  01/12/11
C----------
C  THIS ROUTINE FINDS EFFECTIVE TREE AGE BASED ON INPUT VARIABLE(S)
C  CALLED FROM **COMCUP
C  CALLED FROM **CRATET
C  CALLED FROM **HTGF
C----------
C  COMMONS
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
C----------
C  DECLARATIONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,MAPPHD,MAPHD(MAXSP)
      REAL AGMAX(MAXSP),AG,DIFF,H,HGUESS,SINDX,TOLER
      REAL HDRAT1(8),HDRAT2(8)
      REAL SITAGE,SITHT,AGMAX1,HTMAX,HTMAX2,D,D2
C----------
C  DATA STATEMENTS
C----------
      DATA AGMAX  / MAXSP*200. /
      DATA MAPHD  /3*1,2*2,6,2,2*3,2,4,4*5,2*6,3,2*7,8*8,5*3,4*8,2*6/
      DATA HDRAT1 /4.3396271,4.3149844,3.2412923,2.3475244,
     &             5.5324838,6.3657425,4.0156013,3.9033821/
      DATA HDRAT2 /43.9957174,39.6317079,62.7139427,65.7622908,
     &             18.6043842,16.2223589,51.9732476,59.3370816/
C----------
C  INITIALIZATIONS
C----------
      TOLER=2.0
      SINDX = SITEAR(ISPC)
      AGMAX1 = AGMAX(ISPC)
      AG = 2.0
      MAPPHD=MAPHD(ISPC)
      HTMAX=HDRAT1(MAPPHD)*D+HDRAT2(MAPPHD)
      HTMAX2=HDRAT1(MAPPHD)*D2+HDRAT2(MAPPHD)
C----------
C  CRATET CALLS FINDAG AT THE BEGINING OF THE SIMULATION TO
C  CALCULATE THE AGE OF INCOMMING TREES.  AT THIS POINT ABIRTH(I)=0.
C  THE AGE OF INCOMMING TREES HAVING H>=HMAX IS CALCULATED BY
C  ASSUMEING A GROWTH RATE OF 0.10FT/YEAR FOR THE INTERVAL H-HMAX.
C  TREES REACHING HMAX DURING THE SIMULATION ARE IDENTIFIED IN HTGF.
C----------
      IF(H .GE. HTMAX) THEN
        SITAGE = AGMAX1 + (H - HTMAX)/0.10
        SITHT = H
        IF(DEBUG)WRITE(JOSTND,*)' H,HTMAX,AGMAX1,SITAGE,SITHT= ',
     &  H,HTMAX,AGMAX1,SITAGE,SITHT
        GO TO 30
      ENDIF
C
   75 CONTINUE
C----------
C  CALL HTCALC TO CALCULATE POTENTIAL HT GROWTH
C----------
      HGUESS = 0.0
      CALL HTCALC(SINDX,ISPC,AG,HGUESS,JOSTND,DEBUG)
C
      IF(DEBUG)WRITE(JOSTND,91200)AG,HGUESS,H
91200 FORMAT(' IN GUESS AN AGE--AGE,HGUESS,H ',3F10.2)
C
      DIFF=ABS(HGUESS-H)
      IF(DIFF .LE. TOLER .OR. H .LT. HGUESS)THEN
        SITAGE = AG
        SITHT = HGUESS
        GO TO 30
      END IF
      AG = AG + 2.
C
      IF(AG .GT. AGMAX1) THEN
C----------
C  H IS TOO GREAT AND MAX AGE IS EXCEEDED
C----------
        SITAGE = AGMAX1
        SITHT = H
        GO TO 30
      ELSE
        GO TO 75
      ENDIF
C
   30 CONTINUE
      IF(DEBUG)WRITE(JOSTND,50)I,SITAGE,SITHT
   50 FORMAT(' LEAVING SUBROUTINE FINDAG  I,SITAGE,SITHT =',
     &I5,2F10.3)
C
      RETURN
      END
C**END OF CODE SEGMENT