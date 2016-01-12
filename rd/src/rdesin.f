      SUBROUTINE RDESIN
      use eshap_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  **RDESIN      LAST REVISION:  08/28/14
C----------
C
C  THIS SUBROUTINE HAS ONE FUNCTION: TO CHANGE THE VALUE OF
C  MINREP FROM 50 TO 30 WHEN THE ROOT DISEASE MODEL IS
C  BEING USED. THIS SUBROUTINE IS BEING CALLED FROM INITRE
C  AFTER THE CALL TO ESINIT BUT BEFORE THE CALL TO THE ESTAB
C  KEYWORD PROCESSOR. THUS, THE FOLLOWING CONDITIONS WILL EXIST
C  DEPENDING ON USER-SPECIFIED OPTIONS.
C  1) IF ROOT DISEASE IS NOT ACTIVE MINREP WILL BE THE DEFAULT OF
C     50 UNLESS THE MINREP KEYWORD IS SPECIFIED.
C  2) IF ROOT DISEASE IS ACTIVE MINREP WILL HAVE THE VALUE OF 30
C     UNLESS THE MINREP KEYWORD IS SPECIFIED.
C
C  CALLED BY :
C     INITRE  [PROGNOSIS]
C
C  CALLS     :
C     NONE
C
C  Revision History :
C   08/24/89 - Last revision date.
C   08/28/14 Lance R. David (FMSC)
C
C----------------------------------------------------------------------
C
      MINREP = 30

      RETURN
      END
