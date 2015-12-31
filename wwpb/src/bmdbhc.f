      SUBROUTINE BMDBHC (DBH,INDEX)
 
C     PART OF THE MOUNTAIN PINE BEETLE EXTENSION OF PROGNOSIS.
C     N.L. CROOKSTON--FOREST SCIENCES LAB--MOSCOW ID--JULY 1985
 
C     PARAMETERS:
C        DBH - FOUR BYTE REAL DBH OF TREE.
C        INDEX - FOUR BYTE INTEGER SIZE CLASS.

C     GIVEN A DBH, ASSIGNS A DBH CLASS FROM THE ARRAY 'UPSIZ'.
                         
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'PPEPRM.F77'
      INCLUDE 'BMPRM.F77'
      
      INCLUDE 'BMCOM.F77'
                         
	INTEGER I, INDEX

      INDEX= 1 
      DO 10 I=1,NSCL-1
      	IF (DBH .LT. FLOAT(UPSIZ(I))) GOTO 20
      	INDEX= INDEX + 1
   10 CONTINUE
   20 CONTINUE

      RETURN
      END
