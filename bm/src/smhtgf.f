      SUBROUTINE SMHTGF (I,HHT,H,MODE,DTIME,ICYC,JOSTND,DEBUG)
      use pden_mod
      use plot_mod
      use arrays_mod
      use prgprm_mod
      implicit none
C----------
C  **SMHTGF--BM  DATE OF LAST REVISION:  04/28/09
C----------
C  THIS ROUTINE CALCULATES THE HEIGHT GROWTH OF SMALL TREES (D<3.0 IN).
C  WHEN CALLED FROM ESSUBH (MODE=0), DTIME= TOTAL TREE AGE.
C  IF CALLED FROM REGENT (MODE=1), DTIME= FINT AND THE
C  CALLED FROM ***ESSUBH
C  CALLED FROM ***REGENT
C
C  INPUT VARIABLES
C  I      - SPECIES SEQUENCE NUMBER
C  H      - BEGINING HEIGHT
C  SI     - SITE INDEX FOR SPECIES
C  MODE   - = 0 IF CALL IS FROM ESSUBH, = 1 IF CALL IS FROM REGENT
C  DTIME  - DTIME=TOTAL SEEDLING AGE (MODE= 0), DTIME=FINT (MODE= 1)
C
C  RETURN VARIABLES
C  HHT    - HEIGHT GROWTH OVER TIME INCREMENT DTIME (REGENT)
C  HHT    - HEIGHT 5 YEARS INTO CYCLE, OR END OF CYCLE FINT<5 (ESSUBH)
C----------
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,ICYC,JOSTND,MODE
      REAL    AGEPDT,C1,C2,C3,C4,EFFAGE,DTIME,H,HHT,SI,HHT1,HHT2
      REAL     RELHT,DOMHTGR,CRMOD,CR1,RHMOD,SMHMOD,FACTOR,BAL,TEMBAL
      REAL     IPCCF,PPCCF,BACHLO,D,BETA1,BETA2,HTG1,STDDEV
      REAL     SHI,SLO,CR,B0A,B0B,B1A,B1B,B0ASTD,B0BSTD,B1BSTD,HTGRTH
      EXTERNAL RANN
C----------
C  SPECIES ORDER:
C   1=WP,  2=WL,  3=DF,  4=GF,  5=MH,  6=WJ,  7=LP,  8=ES,
C   9=AF, 10=PP, 11=WB, 12=LM, 13=PY, 14=YC, 15=AS, 16=CW,
C  17=OS, 18=OH
C----------
C  SPECIES EXPANSION:
C  WJ USES SO JU (ORIGINALLY FROM UT VARIANT; REALLY PP FROM CR VARIANT)
C  WB USES SO WB (ORIGINALLY FROM TT VARIANT)
C  LM USES UT LM
C  PY USES SO PY (ORIGINALLY FROM WC VARIANT)
C  YC USES WC YC
C  AS USES SO AS (ORIGINALLY FROM UT VARIANT)
C  CW USES SO CW (ORIGINALLY FROM WC VARIANT)
C  OS USES BM PP BARK COEFFICIENT
C  OH USES SO OH (ORIGINALLY FROM WC VARIANT)
C----------
C  IF NO GROWTH IS TO BE CALCULATED ON ESTAB TREES, I.E. PLANTING
C  IS MORE THAN 5 YEARS INTO THE SIMULATION, THEN RETURN AND
C  LEAVE THE SMALL TREE GROWTH, DURING THE PLANTING CYCLE, TO
C  THE REGENT ROUTINE.
C----------
      HHT = 0.
      IF(DTIME .LE. 0.0) GO TO 120
C
      SI= SITEAR(I)
C
      SELECT CASE (I)
C----------
C  HEIGHT OF TALLEST SUBSEQUENT SPECIES 1 (WHITE PINE)
C
C  FOR NON-LINEAR HEIGHT GROWTH MODEL SOLVE FIRST FOR EFFECTIVE
C  AGE BASED ON INPUT HEIGHT.
C----------
      CASE(1)
        C1= 0.375045
        C2= 0.92503
        C3= -0.020796
        C4= 2.48811
C
        IF(MODE .EQ. 0) THEN
          EFFAGE= 0.
          AGEPDT= EFFAGE + DTIME
        ELSEIF(MODE .EQ. 1) THEN
          EFFAGE= ALOG( (1.0 - (C1/SI * H)**(1/C4))/C2 ) / C3
          AGEPDT= EFFAGE + DTIME
        ENDIF
C
        HHT1 = (SI/C1)*(1.0-C2*EXP(C3*EFFAGE))**C4
        HHT2 = (SI/C1)*(1.0-C2*EXP(C3*AGEPDT))**C4
        HHT= HHT2 - HHT1
C----------
C  HEIGHT OF TALLEST SUBSEQUENT SPECIES 2 (WESTERN LARCH)
C----------
      CASE(2)
        HHT = ((-3.9725 + 0.50995*SI)/(28.1168 - 0.05661*SI))*DTIME
C----------
C  HT OF TALLEST SUBS. SPECIES 3 (DOUGLAS-FIR)
C----------
      CASE(3)
        HHT = ((2.0 + 0.420*SI)/(28.5 - 0.05*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 4 (GRAND FIR)
C----------
      CASE(4)
        HHT = ((4.2435 + 0.1510*SI)/(19.0184 - 0.0570*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 5 (MOUNTAIN HEMLOCK)
C  IN METERS CONVERTED TO FEET
C----------
      CASE(5)
        HHT = ((0.965758 + 0.082969*SI)/(55.249612 - 1.288852*SI))*DTIME
     &        *3.280833
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 6 (WESTERN JUNIPER)
C----------
      CASE(6)
        SHI=75.
        SLO=5.
        SI=SITEAR(I)
        IF(SI .GT. SHI) SI=SHI
        IF(SI .LE. SLO) SI=SLO + 0.5
        HHT = (SI/5.0)*(SI*1.5-H)/(SI*1.5)
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 7 (LODGEPOLE PINE)
C----------
      CASE(7)
        HHT = (0.02008805*SI)*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 8 (ENGELMANN SPRUCE)
C----------
      CASE(8)
        HHT = ((0.09211 + 0.208517*SI)/(43.358 - 0.168166*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 9 (SUBALPINE FIR)
C----------
      CASE(9)
        HHT = ((6.0 + 0.14*SI)/(33.882 - 0.06588*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 10 (PONDEROSA PINE) AND
C                           SPECIES 17 (OTHER SOFTWOODS)
C----------
      CASE(10,17)
        HHT = ((-1.0 + 0.32857*SI)/(28.0 - 0.042857*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 11 (WHITEBARK PINE)
C----------
      CASE(11)
        HHT = ((0.02008805*SI)*DTIME)*1.6
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 12 (LIMBER PINE)
C----------
      CASE(12)
        HHT = 0.5
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 13 (PACIFIC YEW)
C----------
      CASE(13)
        HHT = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 14 (ALASKA CEDAR)
C----------
      CASE(14)
        HHT = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 15 (QUAKING ASPEN)
C----------
      CASE(15)
        HHT = 5.0
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 16 (BLACK COTTONWOOD)
C----------
      CASE(16)
        HHT = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*DTIME
C----------
C  HT OF TALLEST SUBSEQUENT SPECIES 18 (OTHER HARDWOODS)
C----------
      CASE(18)
        HHT = ((1.47043 + 0.23317*SI)/(31.56252 - 0.05586*SI))*DTIME
C
      END SELECT
C
  120 CONTINUE
      IF (DEBUG)
     & WRITE(JOSTND,*)' LEAVING SMHTGF, ICYC,I,HHT,DTIME,SI= ',
     &ICYC,I,HHT,DTIME,SI
C
      RETURN
      END
