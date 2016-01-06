      SUBROUTINE FMTRIP (ITFN,I,WEIGHT)
      use fmcom_mod
      use arrays_mod
      use fmparm_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C  THIS FIRE/SNAGE MODEL SUBROUTINE IS USED
C  TO TRIPLE THE FIRE/SNAG ATTRIBUTES
C
C  CALLED BY :
C     TRIPLE  [PROGNOSIS]
C
C  CALLS     :
C     FMATV
C
C  PARAMETERS :
C     ITFN   -
C     I      -
C     WEIGHT -
C
C      INCLUDE 'PPEPRM.F77'

      INTEGER I,ITFN,JJ
      REAL    WEIGHT

C     NO TRIPLING IS REQUIRED IF THE FIRE/SNAG MODEL IS ABSENT

      IF (.NOT. LFMON) RETURN

      FMPROB(ITFN) = FMPROB(I) * WEIGHT
      FMICR(ITFN)  = FMICR(I)

      OLDHT(ITFN)  = OLDHT(I)
      OLDCRL(ITFN) = OLDCRL(I)
      GROW(ITFN) = GROW(I)

      DO JJ = 0, 5
        OLDCRW(ITFN, JJ) = OLDCRW(I, JJ)
        CROWNW(ITFN, JJ) = CROWNW(I, JJ)
      ENDDO

      RETURN
      END

