      FUNCTION BRATIO(IS,D,H)
      use coeffs_mod
      use prgprm_mod
      implicit none
C----------
C  **BRATIO--NI DATE OF LAST REVISION:  04/09/08
C----------
C
C FUNCTION TO COMPUTE BARK RATIOS. THIS ROUTINE IS VARIANT SPECIFIC
C AND EACH VARIANT USES ONE OR MORE OF THE ARGUMENTS PASSED TO IT.
C
      INTEGER IS
      REAL H,D,BRATIO
C
      BRATIO=BKRAT(IS)
      RETURN
      END
