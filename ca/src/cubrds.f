      BLOCK DATA CUBRDS
      IMPLICIT NONE
C----------
C  **CUBRDS--CA    DATE OF LAST REVISION:  02/22/08
C----------
C  DEFAULT PARAMETERS FOR THE CUBIC AND BOARD FOOT VOLUME EQUATIONS.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
COMMONS
C----------
C  COEFFICIENTS FOR CUBIC FOOT VOLUME FOR TREES THAT ARE SMALLER THAN
C  THE TRANSITION SIZE
C----------
      DATA CFVEQS/343*0.0/
C----------
C  COEFFICIENTS FOR CUBIC FOOT VOLUME FOR TREES THAT ARE LARGER THAN
C  THE TRANSITION SIZE
C----------
      DATA CFVEQL/ 343*0.0001/
C----------
C  FLAG IDENTIFYING THE SIZE TRANSITION VARIABLE; 0=D, 1=D2H
C----------
      DATA ICTRAN/49*0/
C----------
C  TRANSITION SIZE.  TREES OF LARGER SIZE (D OR D2H) WILL COEFFICIENTS
C  FOR LARGER SIZE TREES.
C----------
      DATA CTRAN/49*0.0/
C----------
C  COEFFICIENTS FOR BOARD FOOT VOLUME FOR TREES THAT ARE SMALLER THAN
C  THE TRANSITION SIZE
C----------
      DATA BFVEQS/ 343*1.0/
C----------
C  COEFFICIENTS FOR BOARD FOOT VOLUME FOR TREES THAT ARE LARGER THAN
C  THE TRANSITION SIZE
C----------
      DATA BFVEQL/ 343*1.0/
C----------
C  FLAG IDENTIFYING THE SIZE TRANSITION VARIABLE; 0=D, 1=D2H
C----------
      DATA IBTRAN/49*0/
C----------
C  TRANSITION SIZE.  TREES OF LARGER SIZE (D OR D2H) WILL USE COEFFICIENTS
C  FOR LARGER SIZE TREES.
C----------
      DATA BTRAN/49*20.5/
      END
