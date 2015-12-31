      SUBROUTINE LBSPLR (KEYWRD,JOSTND,IREAD,IRECNT,RECORD,KODE,LKECHO)
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     READ A STAND POLICY LABEL FROM IREAD.
C
C     PART OF THE LABEL PROCESSING COMPONENT OF THE PROGNOSIS SYSTEM
C     N.L. CROOKSTON -- INTERMOUNTAIN RESEARCH STATION -- JAN 1987
C
C     KEYWRD= KEYWORD STRING.
C     JOSTND= PRINT MESSAGE FILE.
C     IREAD = READER FILE
C     IRECNT= NUMBER OF RECORDS READ ON IRECNT.
C     RECORD= INPUT RECORD
C     KODE  = 0: OK, 1: END-OF-DATA FOUND ON IREAD.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
COMMONS
C
C
      CHARACTER*8 KEYWRD
      CHARACTER*(*) RECORD
      LOGICAL LKECHO
      INTEGER KODE,IRECNT,IREAD,JOSTND,I1,I2
C
C     READ THE STAND LABEL SET
C
      CALL LBSTRD (IREAD,LENSLS,SLSET,IRECNT,RECORD,KODE,WKSTR1,WKSTR2)
      IF (KODE.GT.1) THEN
         KODE=1
         GOTO 40
      ENDIF
C
C     SIGNAL THAT LABEL PROCESSING HAS BEEN ACTIVATED.
C
      LBSETS=.TRUE.
C
C     ECHO THE KEYWORD AND THE SLS.
C
      IF(LKECHO)WRITE(JOSTND,10) KEYWRD
   10 FORMAT (/A8,'   STAND POLICY LABEL SET:')
      I1=1
      I2=100
   20 CONTINUE
      IF (I2.GT.LENSLS) I2=LENSLS
      IF(LKECHO)WRITE(JOSTND,'(T12,A)') SLSET(I1:I2)
      IF (I2.LT.LENSLS) THEN
         I1=I2+1
         I2=I2+100
         GOTO 20
      ENDIF
      IF (KODE.EQ.1) THEN
         KODE=0
         WRITE (JOSTND,30)
   30    FORMAT (/'********   WARNING: THIS LABEL SET IS SHORTER ',
     >           'THAN THE ONE YOU SPECIFIED.')
         CALL RCDSET (1,.TRUE.)
      ENDIF
   40 CONTINUE
      RETURN
      END





