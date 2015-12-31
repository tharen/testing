      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C  **FORKOD--UT  DATE OF LAST REVISION:  05/19/2008
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
C----------
C  NATIONAL FORESTS:
C  401 = ASHLEY 
C  407 = DIXIE 
C  408 = FISHLAKE
C  410 = MANTI LASAL       
C  418 = UINTA
C  419 = WASATCH
C  404 = CACHE (MAPPED TO WASATCH)
C  409 = HUMBOLDT (MAPPED TO FISHLAKE)
C  417 = TOIYABE (MAPPED TO FISHLAKE)
C----------
      INTEGER JFOR(9),KFOR(9),NUMFOR,I
      DATA JFOR/401,407,408,410,418,419,404,409,417/,NUMFOR/9/
      DATA KFOR/9*1/
C
      IF (KODFOR .EQ. 0) GOTO 30
      DO 10 I=1,NUMFOR
      IF (KODFOR .EQ. JFOR(I)) GOTO 20
   10 CONTINUE
      CALL ERRGRO (.TRUE.,3)
      WRITE(JOSTND,11) JFOR(IFOR)
   11 FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS  ',I4)
      GOTO 30
   20 CONTINUE
      IF(I .EQ. 7)THEN
        WRITE(JOSTND,21)
   21   FORMAT(T12,'CACHE NF (404) BEING MAPPED TO WASATCH ',
     &  '(419) FOR FURTHER PROCESSING.')
        I=6
      ELSEIF(I .EQ. 8)THEN
        WRITE(JOSTND,22)
   22   FORMAT(T12,'HUMBOLDT NF (409) BEING MAPPED TO FISHLAKE ',
     &  '(408) FOR FURTHER PROCESSING.')
        I=3
      ELSEIF(I .EQ. 9)THEN
        WRITE(JOSTND,23)
   23   FORMAT(T12,'TOIYABE NF (417) BEING MAPPED TO FISHLAKE ',
     &  '(408) FOR FURTHER PROCESSING.')
        I=3
      ENDIF
      IFOR=I
      IGL=KFOR(I)
   30 CONTINUE
      KODFOR=JFOR(IFOR)
      RETURN
      END
