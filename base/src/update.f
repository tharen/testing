      SUBROUTINE UPDATE
      use plot_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C  UPDATE:
C     ADDS GROWTH INCREMENT
C     DEDUCTS MORTALITY
C     COMPUTES VOLUME STATISTICS
C     EXECUTES SOME OF THE SUMMARY LOGIC.
C----------
COMMONS
      LOGICAL DEBUG
      REAL SPCMO(MAXSP,3),WKI,BRATIO
      INTEGER I,IS,I1,I2,J,IM
C-----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'UPDATE',6,ICYC)
C---------
C  ZERO OUT MORTALITY ACCUMULATOR ARRAYS
C---------
      DO 5 I=1,7
      OMORT(I)=0.0
    5 CONTINUE
      DO 10 I=1,MAXSP
      SPCMO(I,1)=0.0
      SPCMO(I,2)=0.0
      SPCMO(I,3)=0.0
   10 CONTINUE
C----------
C  DO FOR ALL TREES BY SPECIES.
C----------
      DO 100 IS=1,MAXSP
      I1=ISCT(IS,1)
      IF (I1 .EQ. 0) GO TO 100
      I2=ISCT(IS,2)
      DO 90 J=I1,I2
      I=IND1(J)
C----------
C  ADD THE HEIGHT INCREMENT TO THE HEIGHTS
C----------
      HT(I) = HT(I)+HTG(I)
      IF (NORMHT(I).GT.0) NORMHT(I) = NORMHT(I)+(HTG(I)*100.+.5)
C----------
C  DEDUCT THE MORTALITY FROM PROB AND PREPARE THE SUMMARY.
C----------
      IM=IMC(I)
      WKI = WK2(I)
      IF (WKI.GT.PROB(I)) WKI=PROB(I)
      WK6(I) = WKI*CFV(I)/FINT
      SPCMO(IS,IM)=SPCMO(IS,IM)+WK6(I)
      PROB(I)=MAX(0.,PROB(I)-WKI)
C----------
C  END OF TREE WITHIN SPECIES LOOP.
C----------
   90 CONTINUE
      IF(.NOT.DEBUG) GO TO 100
      WRITE(JOSTND,9001)  IS,(SPCMO(IS,J),J=1,3)
 9001 FORMAT(' IN UPDATE,  SPECIES=',I3,
     &       ',  CUM. MORT. VOL. BY TREE CLASS=',3(F8.3,','))
C----------
C  END OF SPECIES LOOP.
C----------
  100 CONTINUE
C----------
C  CALL **PCTILE** TO LOAD WK3 WITH PERCENTILES IN THE DISTRIBUTION
C  OF VOLUME MORTALITY IN DESCENDING ORDER OF DIAMETER.
C----------
      CALL PCTILE(ITRN,IND,WK6,WK3,OMORT(7))
C----------
C  FIND THE PERCENTILE POINTS IN THE DISTRIBUTION OF MORTALITY
C  VOLUME.
C----------
      CALL DIST(ITRN,OMORT,WK3)
C----------
C  COMPUTE SPECIES TREE CLASS COMPOSITION CORRESPONDING TO OMORT.
C----------
      CALL COMP(OSPMO,IOSPMO,SPCMO)
C----------
C  COMPUTE TREE AND STAND VOLUME STATISTICS.
C----------
      IF(DEBUG) WRITE(JOSTND,9017) ICYC
 9017 FORMAT(' CALLING VOLS, CYCLE=',I2)
      CALL VOLS
C----------
C  UPDATE DIAMETERS TO END OF CYCLE VALUES.
C----------
      IF (ITRN.EQ.0) THEN
        RETURN
      ENDIF

      DO 110 I=1,ITRN
      IS=ISP(I)
      DBH(I)=DBH(I)+DG(I)/BRATIO(IS,DBH(I),HT(I))
  110 CONTINUE

      RETURN
      END
