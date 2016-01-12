      SUBROUTINE POTHTG (I,ISPEC,H,SI50,SI100,PHTG,DEBUG)
      use contrl_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **POTHTG--EM   DATE OF LAST REVISION:  03/26/09
C----------
C
C THIS ROUTINE CALCULATES POTENTIAL HTG USING A VARIETY OF
C SITE OR HTG GROWTH CURVES.
C----------
COMMONS
C----------
      LOGICAL DEBUG
C
      INTEGER ISPEC,I
      REAL H,CCF,A,B,C,TEM,EFAGE,EFAG10,Z1,Z2,TEMHT,TEMSI,TERM1
      REAL H10,D,P1,P2,P3,P4,P5,TERM2,PHTG,SI100,SI50
C----------
C  SPECIES ORDER:
C   1=WB,  2=WL,  3=DF,  4=LM,  5=LL,  6=RM,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=GA, 12=AS, 13=CW, 14=BA, 15=PW, 16=NC,
C  17=PB, 18=OS, 19=OH
C
C  SPECIES EXPANSION
C  LM USES IE LM (ORIGINALLY FROM TT VARIANT)
C  LL USES IE AF (ORIGINALLY FROM NI VARIANT)
C  RM USES IE JU (ORIGINALLY FROM UT VARIANT)
C  AS,PB USE IE AS (ORIGINALLY FROM UT VARIANT)
C  GA,CW,BA,PW,NC,OH USE IE CO (ORIGINALLY FROM CR VARIANT)
C----------
      IF (DEBUG) WRITE(JOSTND,3) ICYC
    3 FORMAT(' ENTERING SUBROUTINE POTHTG  CYCLE =',I5)
C
      IF(ISPEC .EQ. 1 .OR. ISPEC .EQ. 7 .OR.
     &   ISPEC .EQ. 2 .OR. ISPEC .EQ. 18)GO TO 100
      IF(ISPEC .EQ. 3)GO TO 200
      IF(ISPEC .EQ. 8 .OR. ISPEC .EQ. 9)GO TO 300
      IF(ISPEC .EQ. 10) GO TO 400
      IF(ISPEC.EQ.12 .OR. ISPEC.EQ.17) GO TO 500
      PHTG=0.0
      GO TO 1000
C----------
C SECTION TO CALC POT HTG FOR WBP AND LP VIA ALEXANDER TACKLE AND DAHMS
C----------
  100 CONTINUE
      CCF= 125.0
      A= 9.72443 - 0.00091*SI100*CCF - H
      B= -0.23733 + 0.0149*SI100
      C= 0.00160 - 0.00005*SI100
C----------
C CALCULATE THE EFFECTIVE AGE OF THE TREE IN QUESTION
C----------
      IF (DEBUG) WRITE (JOSTND,900) A,B,C
  900 FORMAT(' IN POTHGF 900 A,B,C = ',3F12.5)
      TEM = B*B - 4.0*A*C
      IF(TEM .LT. 0.0)TEM = 0.0
      IF(C .NE. 0.) THEN
        EFAGE=(-B + SQRT(TEM))/(2.0*C)
      ELSE
        EFAGE = -A/B
      ENDIF
      IF(ABIRTH(I) .LE. 0.0)ABIRTH(I)= EFAGE
      EFAG10= EFAGE + 10.0
      IF (DEBUG) WRITE (JOSTND,905) EFAGE,EFAG10
  905 FORMAT(' IN POTHGF 905 EFAGE,EFAG10 = ',2F12.5)
      PHTG = -2.3733 + 0.00160*(EFAG10*EFAG10-EFAGE*EFAGE) +
     &        0.1490*SI100 - 0.00005*SI100*(EFAG10*EFAG10-
     &        EFAGE*EFAGE)
      GO TO 1000
C----------
C SECTION TO CALCUALE POT HTG VIA MONSERUD'S 1985 DF HT AGE CURVES
C----------
  200 CONTINUE
      Z1= 0.3197
      Z2 = 1.0232
      TEMHT = H - 4.5
      IF(TEMHT .EQ. 1.) TEMHT=1.1
      TEMSI = SI50 - 4.5
      TERM1 = (42.397*TEMSI**Z1)/TEMHT-1.0
      IF(TERM1 .LT. 0.0) THEN
        PHTG = 0.0
        GO TO 1000
      ENDIF
      TERM1 = ALOG(TERM1)
      EFAGE = EXP ((TERM1 + Z2*ALOG(TEMSI) - 9.7278)/(-1.2934))
      IF(ABIRTH(I) .LE. 0.0)ABIRTH(I)= EFAGE
      EFAG10 = EFAGE + 10.0
      H10 = (42.397*TEMSI**Z1)/(1.0 + EXP(9.7278-
     &     1.2934*ALOG(EFAG10) - ALOG(TEMSI)*Z2))
      PHTG = H10 - TEMHT
      GO TO 1000
C----------
C SECTION TO CALCULATE POT HTG FOR ES AND AF VIA ALEXANDER LOOK ALIKE
C CURVES
C----------
  300 CONTINUE
      A = SI100
C
C A IS THEN THE ASYMPTOTE
C
      B = 0.931764
      C = 0.01679
      D = 0.302381
      IF (DEBUG) WRITE (JOSTND,920) H,A,D,B
  920 FORMAT(' IN POTHTG H,A,D,B = ',4F12.5)
      IF(H .GE. A)THEN
        PHTG = 1.0
        GO TO 1000
      ENDIF
      TERM1 = ALOG((1.0-((H/A)**(1.0-D)))/B)
      EFAGE = TERM1/(-C)
      IF(ABIRTH(I) .LE. 0.0)ABIRTH(I)= EFAGE
      EFAG10 = EFAGE + 10.0
      IF (DEBUG) WRITE (JOSTND,925) A,B,C,D,EFAG10,EFAGE,TERM1
  925 FORMAT(' IN POTHTG A,B,C,D,EFAG10,EFAGE,TERM1 = ',7F12.5)
      H10 = A*(1.0 - B*EXP(-C*EFAG10))**(1.0/(1.0-D))
      PHTG = H10-H
      GO TO 1000
C----------
C SECTION TO CALCULATE POT HTG FOR PP VIA MEYER LOOK ALIKE CURVES
C----------
  400 CONTINUE
      P1 = 3.635794
      P2 = 0.916307
      P3 = 6.09478
      P4 = 0.96483
      P5 = 0.277025
      TERM1 = ((P1*SI100**P2)/H)-1.0
      IF(TERM1 .LE. 0.0) THEN
       PHTG=0.0
       GO TO 1000
      ENDIF
      TERM1=ALOG(TERM1)
      TERM2 = TERM1-P3 + P5*ALOG(SI100)
      EFAGE = EXP(TERM2/(-P4))
      IF(ABIRTH(I) .LE. 0.0)ABIRTH(I)= EFAGE
      EFAG10 = EFAGE + 10.0
      H10 = P1*SI100**P2/(1.0 + EXP(P3-P4*ALOG(EFAG10) -
     &        P5*ALOG(SI100)))
      PHTG = H10-H
C---------
C  COMPUTE AGE FOR ASPEN. THIS EQUATION IS ALSO USED FOR PAPER BIRCH.
C  EQUATION FORMULATED BY
C  WAYNE SHEPPERD, ROCKY MTN FOREST EXP STATION, FT COLLINS, CO.
C----------
  500 CONTINUE
      IF (PROB(I).LE.0.0) GO TO 1000
      IF(ISPEC.EQ.12 .OR. ISPEC.EQ.17)THEN
        EFAGE = (H*2.54*12.0/26.9825)**(1.0/1.1752)
        IF(ABIRTH(I) .LE. 0.0)ABIRTH(I)= EFAGE
        PHTG=0.
      ENDIF
C
 1000 CONTINUE
      IF (DEBUG) WRITE(JOSTND,1100) ICYC
 1100 FORMAT(' LEAVING SUBROUTINE POTHTG CYCLE =',I5)
      RETURN
      END
