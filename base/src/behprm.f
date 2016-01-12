      SUBROUTINE BEHPRM (VMAX,D,H,BARK,LCONE)
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C  SUBROUTINE TO COMPUTE THE TREE SPECIFIC PARAMETERS FOR THE
C  BEHRE HYPERBOLA   (I.E. AHAT, BHAT, LCONE)
C
      LOGICAL LCONE
      REAL BARK,H,D,VMAX
C
      LCONE=.FALSE.
C----------
C  BHAT IS INITIALIZED WITH VALUE OF CYLINDRICAL FORM FACTOR.
C----------
      BHAT = VMAX / (.00545415*D*D*BARK*BARK*H)
      IF(BHAT.GT.0.95) BHAT = 0.95
C----------
C     AHAT = AN ESTIMATE OF THE BEHRE TAPER CURVE PARAMETER 'A'
C----------
      AHAT = .44277 - .99167/BHAT - 1.43237*ALOG(BHAT)
     &       + 1.68581*SQRT(BHAT) - .13611*BHAT*BHAT
      IF(ABS(AHAT) .LT. 0.05) THEN
        LCONE=.TRUE.
        IF(AHAT.LT. 0.) THEN
          AHAT = -0.05
        ELSE
          AHAT = 0.05
        ENDIF
      ENDIF
      BHAT = 1.-AHAT
      IF (BHAT .LT. 0.0001) BHAT=0.0001
      RETURN
      END
