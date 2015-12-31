      SUBROUTINE FNDKEY (NUMBER,KEYWRD,TABLE,
     >                   ISIZE,KODE,DEBUG,IOUT)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C    FUNCTION TO FIND A KEYWORD IN A TABLE.
C
C    NUMBER= THE KEYWORD NUMBER.
C    ISIZE = THE NUMBER OF ENTRIES IN THE TABLE
C    KODE  = RETURN CODE:
C            0= NO ERRORS FOUND.
C            1= KEYWORD NOT FOUND
C    KEYWRD= THE KEYWORD AS A CHARACTER*8.
C    TABLE = KEYWORD TABLE AS A CHARACTER*8 ARRAY OF LENGTH ISIZE
C    DEBUG = TRUE IT DEBUGING.
C    IOUT  = OUTPUT WRITE UNIT REFERENCE NUMBER
C
C    NUMBER IS THE POSITION WITHIN THE TABLE WHICH HOLDS THE
C    KEYWORD.
C----------
      CHARACTER*8 KEYWRD,TABLE(ISIZE)
      LOGICAL DEBUG
      INTEGER IOUT,KODE,NUMBER,ISIZE,J
C
      NUMBER=0
C
      DO 100 J=1,ISIZE
      IF (KEYWRD .EQ. TABLE(J)) GO TO 110
 100  CONTINUE
      KODE=1
      WRITE (IOUT,85) KEYWRD
  85  FORMAT (/1X,'''',A8,''' :KEYWORD SPECIFIED')
      RETURN
 110  CONTINUE
      KODE=0
      NUMBER=J
      RETURN
      END
