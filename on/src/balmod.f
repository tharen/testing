      SUBROUTINE BALMOD(ISPC,D,BA,RMSQD,GM,DEBUG)
	IMPLICIT NONE
C----------
C  **BALMOD--ON    DATE OF LAST REVISION:  07/10/08
C----------
C  THIS SUBROUTINE COMPUTES THE VALUE OF A GROWTH MODIFIER BASED
C  ON BAL. ORIGINALLY THIS WAS JUST PART OF THE LARGE TREE DIAMETER
C  GROWTH SEQUENCE. HOWEVER, THERE NEEDS TO BE A SIMILAR ACCOUNTING
C  OF STAND POSITION IN THE LARGE TREE AND SMALL TREE HEIGHT GROWTH
C  ESTIMATION SEQUENCE. THIS ROUTINE IS CALLED BY DGF, HTGF, AND
C  RGNTHW.
C
C  ON VERSION: this is currently not required
C----------
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER ISPC
	REAL    D,BA,RMSQD,GM

      GM = 1.0
      RETURN
      END
