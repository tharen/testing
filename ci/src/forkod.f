      SUBROUTINE FORKOD
      use contrl_mod
      use plot_mod
      use prgprm_mod
      implicit none
C----------
C  **FORKOD--CI   DATE OF LAST REVISION:  06/20/11
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C----------
COMMONS
C----------
C  NATIONAL FORESTS:
C  117 = NEZ PERCE
C  402 = BOISE
C  406 = CHALLIS
C  412 = PAYETTE
C  413 = SALMON
C  414 = SAWTOOTH
C----------
      INTEGER JFOR(6),KFOR(6),NUMFOR,I
C----------
C  DATA STATEMENTS
C----------
      DATA JFOR/117,402,406,412,413,414/, NUMFOR /6/
      DATA KFOR/1,2,2,3,2,2 /
C
      IF (KODFOR .EQ. 0) GOTO 30
      DO 10 I=1,NUMFOR
      IF (KODFOR .EQ. JFOR(I)) GOTO 20
   10 CONTINUE
      CALL ERRGRO (.TRUE.,3)
      WRITE(JOSTND,11) JFOR(IFOR)
   11 FORMAT(T12,'FOREST CODE USED FOR THIS PROJECTION IS',I5)
      GOTO 30
   20 CONTINUE
      IFOR=I
      IGL=KFOR(I)
   30 CONTINUE
      KODFOR=JFOR(IFOR)
C
      RETURN
      END
