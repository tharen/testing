      SUBROUTINE REGENT(LESTB,ITRNIN)
      use htcal_mod
      use multcm_mod
      use pden_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **REGENT--BM   DATE OF LAST REVISION:  08/03/12
C----------
C  THIS SUBROUTINE COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR
C  SMALL TREES.  THE HEIGHT INCREMENT MODEL IS APPLIED TO TREES
C  THAT ARE LESS THAN 10 INCHES DBH (5 INCHES FOR LODGEPOLE PINE),
C  AND THE DBH INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS
C  THAN 3 INCHES DBH.  FOR TREES THAT ARE GREATER THAN 2 INCHES
C  DBH (1 INCH FOR LODGEPOLE PINE), HEIGHT INCREMENT PREDICTIONS
C  ARE AVERAGED WITH THE PREDICTIONS FROM THE LARGE TREE MODEL.
C  HEIGHT INCREMENT IS A FUNCTION OF SITE HEIGHT, CALCULATED
C  IN **SMHTGF**, AND MODIFIED BY VIGOR AND DENSITY FUNCTIONS
C  OF CCF, TOP HEIGHT AND CROWN RATIO. DIAMETER IS ASSIGNED FROM
C  A HEIGHT-DIAMETER FUNCTION WITH ADJUSTMENTS FOR RELATIVE SIZE
C  AND STAND DENSITY.  INCREMENT IS COMPUTED BY SUBTRACTION.
C  THIS ROUTINE IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **TREGRO** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
      INCLUDE 'CALCOM.F77'
C
      INCLUDE 'ESTCOR.F77'
C
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C    RHCON -- CONSTANT FOR THE HEIGHT INCREMENT MODEL.  ZERO FOR ALL
C             SPECIES IN THIS VARIANT
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      CHARACTER SPEC*2
      INTEGER KK,ISPEC,KOUT,IPCCF,IREFI,N,KSPC,I3,I,IP,J
      INTEGER IICR,K,L,ITRNIN,NUMCAL(MAXSP),I1,I2,ISPC,JCR,INDX
      REAL SLO(MAXSP),SHI(MAXSP),AB(9),DGMAX(MAXSP),CCF,AVHT,X,HITE2
      REAL PCTRED,SI,DGMX,CR,VIGOR,TEMT,BX,AX,RELSI,RSIMOD,HITE1,AG2
      REAL CON,XMX,XMN,RSI,D,H,BARK,TBAL,TCR,RAN,RCR,PPCCF,TPCCF,HLESS4
      REAL CRCODE,PTCCF,POTHTG,SATBA,BBALIM,PNTWT,BAWT,HBA,DLESS3,DDUM
      REAL XHMOD,HTGR,ZZRAN,XPPMLT,XWT,HK,DKK,DK,DDS,HTNEW,ALHT,ALHK
      REAL SCALE3,CORNEW,SNP,SNX,SNY,EDH,P,TERM,XMIN(MAXSP),XMAX(MAXSP)
      REAL CORTEM(MAXSP),DIAM(MAXSP),REGYR,FNT,SCALE,SCALE2,XRHGRO
      REAL BACHLO,HBALIM,XRDGRO,BRATIO
      REAL RDCON(3),RDCR(3),RDLHT(3),RDHT(3),RDDUM(3),BKPT,DAT45,AG1,H2
      REAL SITHT,SITAGE,D2,AGMAX,HTMAX,HTMAX2
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
C  DATA STATEMENTS.
C----------
C MAX DIAMETER GROWTHS
C----------
      DATA DGMAX/ 2.8, 2.8, 2.4, 3.6, 2.5, 2.0, 3.5, 3.6, 3.6, 2.8,
     &            2.8, 2.8, 5.0, 5.0, 2.5, 5.0, 2.8, 5.0/
C
      DATA XMAX/  3.0, 2.0, 4.0, 4.0, 2.0, 99., 4.0, 4.0, 4.0, 5.0,
     &            3.0, 4.0, 4.0, 4.0, 4.0, 4.0, 5.0, 4.0/
C
     &     XMIN/  2.0, 1.0, 2.0, 2.0, 1.0, 90., 2.0, 2.0, 2.0, 1.0,
     &            1.5, 2.0, 2.0, 2.0, 2.0, 2.0, 1.0, 2.0/
C----------
C  IF THESE SITE INDEX RANGES CHANGE, ALSO CHANGE THEM IN **SITSET**
C  AND **HTGF**
C----------
      DATA SLO/   20., 50., 50., 50., 15.,  5., 30., 40., 50., 70.,
     &            20., 20.,  5., 50., 30., 10., 70.,  5./
C
      DATA SHI/   80.,110.,110.,110., 30., 40., 66.,120.,150.,140.,
     &            65., 50., 75.,110., 66.,191.,140.,125./
C
      DATA DIAM/  0.4, 0.3, 0.3, 0.3, 0.2, 0.3, 0.4, 0.3, 0.3, 0.5,
     &            0.4, 0.4, 0.2, 0.2, 0.2, 0.2, 0.5, 0.2/
C
      DATA AB/
     & 1.11436,-.011493,.43012E-4,-.72221E-7,.5607E-10,-.1641E-13,3*0./
C
      DATA REGYR/10.0/
C----------
C COEFS FOR THE DIA LOOKUP FUNCTION - WC VARIANT SPECIES
C 1=PY, 2=YC, 3=CW&OH
C----------
      DATA RDCON/ -2.089, -0.532, 3.102/
C
      DATA RDCR/     0.0,    0.0,   0.0/
C
      DATA RDLHT/  1.980,  1.531,   0.0/
C
      DATA RDHT/     0.0,    0.0, 0.021/
C
      DATA RDDUM/    0.0,    0.0,   0.0/
C-----------
C  CHECK FOR DEBUG.
C-----------
      LSKIPH=.FALSE.
      CALL DBCHK (DEBUG,'REGENT',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,9980)ICYC
 9980 FORMAT('ENTERING SUBROUTINE REGENT  CYCLE =',I5)
C----------
C  IF THIS IS THE FIRST CALL TO REGENT, BRANCH TO STATEMENT 40 FOR
C  MODEL CALIBRATION.
C----------
      IF(LSTART) GOTO 40
      CALL MULTS (3,IY(ICYC),XRHMLT)
      CALL MULTS(6,IY(ICYC),XRDMLT)
      IF (ITRN.LE.0) GO TO 91
C----------
C  HEIGHT INCREMENT IS DERIVED FROM A HEIGHT-AGE CURVE AND IS NOMINALLY
C  BASED ON A 10-YEAR GROWTH PERIOD.  THE VARIABLE SCALE IS USED TO CONVERT
C  HEIGHT INCREMENT PREDICTIONS TO A FINT-YEAR PERIOD.  DIAMETER
C  INCREMENT IS PREDICTED FROM CHANGE IN HEIGHT, AND IS SCALED TO A 10-
C  YEAR PERIOD BY APPLICATION OF THE VARIABLE SCALE2.  DIAMETER INCREMENT
C  IS CONVERTED TO A FINT-YEAR BASIS IN **UPDATE**.
C----------
      FNT=FINT
      IF(LESTB) THEN
        IF(FINT.LE.5.0) THEN
          LSKIPH=.TRUE.
        ELSE
          FNT=FNT-5.0
        ENDIF
      ENDIF
      SCALE=FNT/REGYR
      SCALE2=YR/FNT
C----------
C  IF CALLED FROM **ESTAB** INTERPOLATE MID-PERIOD CCF AND TOP HT
C  FROM VALUES AT START AND END OF PERIOD.
C----------
      CCF=RELDEN
      AVHT=AVH
      IF(LESTB.AND.FNT.GT.0.0) THEN
        CCF=(5.0/FINT)*RELDEN +((FINT-5.0)/FINT)*ATCCF
        AVHT=(5.0/FINT)*AVH +((FINT-5.0)/FINT)*ATAVH
      ENDIF
C---------
C COMPUTE DENSITY MODIFIER FROM CCF AND TOP HEIGHT.
C---------
      X=AVHT*(CCF/100.0)
      IF(X .GT. 300.0) X=300.0
      PCTRED=AB(1)
     & + X*(AB(2) + X*(AB(3) + X*(AB(4) + X*(AB(5)+ X*AB(6)))))
      IF(PCTRED .GT. 1.0) PCTRED = 1.0
      IF(PCTRED .LT. 0.01) PCTRED = 0.01
      IF(DEBUG) WRITE(JOSTND,9982) AVHT,CCF,X,PCTRED
 9982 FORMAT('IN REGENT AVHT,CCF,X,PCTRED = ',4F10.4)
C----------
C  ENTER GROWTH PREDICTION LOOP.  PROCESS EACH SPECIES AS A GROUP;
C  LOAD CONSTANTS FOR NEXT SPECIES.
C----------
      DO 30 ISPC=1,MAXSP
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0) GO TO 30
      I2=ISCT(ISPC,2)
      XRHGRO=XRHMLT(ISPC)
      XRDGRO=XRDMLT(ISPC)
      CON=RHCON(ISPC) * EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
      SI=SITEAR(ISPC)
      IF(SI .GT. SHI(ISPC)) SI=SHI(ISPC)
      IF(SI .LE. SLO(ISPC)) SI=SLO(ISPC) + 0.5
C----------
C     PUT A CEILING ON DIAMETER GROWTH BASED ON OLIVER AND COCHRAN EMPR.
C     RJ 11/28/88
C     FOR WB, USE TT SETTING
C----------
      DGMX = DGMAX(ISPC) * SCALE
      IF(ISPC .EQ. 11)DGMX=FINT*0.2
C----------
C  PROCESS NEXT TREE RECORD.
C----------
      DO 25 I3=I1,I2
      I=IND1(I3)
      D=DBH(I)
      IF(D .GE. XMX) GO TO 25
      IPCCF=ITRE(I)
C----------
C  BYPASS INCREMENT CALCULATIONS IF CALLED FROM ESTAB AND THIS IS NOT A
C  NEWLY CREATED TREE.
C----------
      IF(LESTB) THEN
        IF(I.LT.ITRNIN) GO TO 25
C----------
C  ASSIGN CROWN RATIO FOR NEWLY ESTABLISHED TREES.
C----------
        CR = 0.89722 - 0.0000461*PCCF(IPCCF)
    1   CONTINUE
        RAN = BACHLO(0.0,1.0,RANN)
        IF(RAN .LT. -1.0 .OR. RAN .GT. 1.0) GO TO 1
        CR = CR + 0.07985 * RAN
        IF(CR .GT. .90) CR = .90
        IF(CR .LT. .20) CR = .20
        ICR(I)=(CR*100.0)+0.5
      ENDIF
      K=I
      L=0
C---------
C COMPUTE VIGOR MODIFIER FROM CROWN RATIO.
C---------
      JCR=ICR(I)/10.
      H=HT(I)
      BARK=BRATIO(ISPC,D,H)
      IF(LSKIPH) THEN
        HTG(K)=0.0
        GO TO 4
      ENDIF
      X=FLOAT(ICR(I))/100.
      VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
      IF(VIGOR .GT. 1.0)VIGOR=1.0
C----------
C  VIGOR ADJUSTMENT TO DRASTIC FOR PINYON; CUT IT BY TWO-THIRDS
C----------
      IF(ISPC .EQ. 6)VIGOR=1.-((1.-VIGOR)/3.)
C----------
C     RETURN HERE TO PROCESS NEXT TRIPLE.
C----------
    2 CONTINUE
C----------
C  BEGIN POTHTG SECTION
C----------
C
      SELECT CASE(ISPC)
C
C----------
C ORIGINAL BM SPECIES
C
C CALL SMHTGF, THE SMALL TREE HEIGHT GROWTH ROUTINE.
C SMHTGF IS ALSO CALLED FROM ESSUBH TO GROW PLANTED TREES
C FROM ESTABLISHMENT TO 5 YEARS INTO THE CYCLE
C-----------
      CASE(1:11,13:14,16:18)
        TEMT=10.
        CALL SMHTGF(ISPC,POTHTG,H,1,TEMT,ICYC,JOSTND,DEBUG)
        IF(DEBUG)WRITE(JOSTND,*)'SMHTGF-ICYC,ISPC,H,TEMT,POTHTG= '
        IF(DEBUG)WRITE(JOSTND,*)ICYC,ISPC,H,TEMT,POTHTG
C----------
C LIMBER PINE FROM THE UT VARIANT
C----------
      CASE(12)
        POTHTG = SI/5.0
C----------
C  QUAKING ASPEN
C----------
      CASE(15)
        RELSI=(SI-SLO(ISPC))/(SHI(ISPC)-SLO(ISPC))
        RSIMOD = 0.5 * (1.0 + RELSI)
C----------
C COMPUTE HT GROWTH AND AGE FOR ASPEN. EQN FROM WAYNE SHEPPARD RMRS.
C----------
        IF(LESTB) THEN
          SITAGE=ABIRTH(I)
        ELSE
C----------
C  CALL FINDAG TO CALCULATE EFFECTIVE AGE
C----------
          SITAGE = 0.0
          SITHT = 0.0
          AGMAX = 0.0
          HTMAX = 0.0
          HTMAX2 = 0.0
          H = HT(I)
          D2 = 0.0
          CALL FINDAG(I,ISPC,D,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,
     &                DEBUG)
        ENDIF
        HITE1 = 26.9825 * SITAGE**1.1752
        AG2 = SITAGE+10.0
        HITE2 = 26.9825 * AG2**1.1752
        HTGR = (HITE2-HITE1)/(2.54*12.0) * RSIMOD * CON
        HTGR=HTGR*2.40
C----------
C GROWTH RATES APPEAR HIGH, REDUCE BY 25 PERCENT. DIXON 8-27-92
C----------
        HTGR = HTGR * .75
        GO TO 3
C
      END SELECT
C
      HTGR=POTHTG*PCTRED*VIGOR*CON
      IF(DEBUG) WRITE(JOSTND,9983) X,VIGOR,HTGR,CON
 9983 FORMAT('IN REGENT X,VIGOR,HTGR,CON = ',4F10.4)
    3 CONTINUE
      ZZRAN = 0.0
      IF(DGSD.GE.1.0) ZZRAN=BACHLO(0.0,1.0,RANN)
      IF((ZZRAN .GT. 0.5) .OR. (ZZRAN .LT. -2.0)) GO TO 3
      IF(DEBUG)WRITE(JOSTND,9984) HTGR,ZZRAN,XRHGRO,SCALE
 9984 FORMAT('IN REGENT 9984 FORMAT',4(F10.4,2X))
      HTGR = (HTGR +ZZRAN*0.1)*XRHGRO * SCALE
C----------
C     GET A MULTIPLIER FOR THIS TREE FROM PPREGT TO ACCOUNT FOR
C     THE DENSITY EFFECTS OF NEIGHBORING TREES.
C----------
      XPPMLT=1.
      CALL PPREGT (XPPMLT,AVHT/100.,AB,CCF)
      HTGR = HTGR * XPPMLT
C-------------
C     COMPUTE WEIGHTS FOR THE LARGE AND SMALL TREE HEIGHT INCREMENT
C     ESTIMATES.  IF DBH IS LESS THAN OR EQUAL TO XMN, THE LARGE TREE
C     PREDICTION IS IGNORED (XWT=0.0).
C----------
      XWT=(D-XMN)/(XMX-XMN)
      IF(D.LE.XMN .OR. LESTB) XWT = 0.0
C----------
C     COMPUTE WEIGHTED HEIGHT INCREMENT FOR NEXT TRIPLE.
C----------
      IF(DEBUG)WRITE(JOSTND,9985)XWT,HTGR,HTG(K),I,K
 9985 FORMAT('IN REGENT 9985 FORMAT',3(F10.4,2X),2I7)
      HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
      IF(HTG(K) .LT. .1) HTG(K) = .1
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((H+HTG(K)).GT.SIZCAP(ISPC,4))THEN
        HTG(K)=SIZCAP(ISPC,4)-H
        IF(HTG(K) .LT. 0.1) HTG(K)=0.1
      ENDIF
C
    4 CONTINUE
C----------
C     ASSIGN DBH AND COMPUTE DBH INCREMENT FOR TREES WITH DBH LESS
C     THAN 3 INCHES (COMPUTE 10-YEAR DBH INCREMENT REGARDLESS OF
C     PROJECTION PERIOD LENGTH).
C----------
      BKPT = 3.
      IF(ISPC .EQ. 6)BKPT=99.
      IF(D.GE.BKPT) GO TO 23
      HK=H + HTG(K)
      IF(HK .LE. 4.5) THEN
        DG(K)=0.0
        DBH(K)=D+0.001*HK
      ELSE
        SELECT CASE(ISPC)
        CASE(7)
          DK = (-9.8752/(ALOG(HK-4.5)-4.8656))-1.0
          IF (H .LE. 4.5) THEN
            DKK = D
          ELSE
            DKK= (-9.8752/(ALOG(H -4.5)-4.8656))-1.0
          ENDIF
        CASE(10,17)
          DK=(HK-8.31485+.59200*7.)/3.03659
          DKK=(H-8.31485+.59200*7.)/3.03659
          IF(H .LT. 4.5) DKK = D
        CASE(1:6,8:9,11,12,15)
          BX=HT2(ISPC)
          IF(IABFLG(ISPC).EQ.1) THEN
            AX=HT1(ISPC)
          ELSE
            AX=AA(ISPC)
          ENDIF
        END SELECT
C----------
C  DIAMETER CALCUALTIONS
C----------
        SELECT CASE(ISPC)
C
C  ORIGINAL BM SPECIES EXCEPT LP(7), PP(10), OS(17)
C  QUAKING ASPEN(15) FROM UT
C  LIMBER PINE(12) FROM UT
C
        CASE(1:5,8:9,12,15)
          DK=(BX/(ALOG(HK-4.5)-AX))-1.0
          IF(H .LE. 4.5) THEN
            DKK=D
          ELSE
            DKK=(BX/(ALOG(H-4.5)-AX))-1.0
          ENDIF
          IF(DEBUG)WRITE(JOSTND,9986) AX,BX,ISPC,HK,BARK,
     &                                XRDGRO,DK,DKK
 9986     FORMAT('IN REGENT 9986 FORMAT AX,BX,ISPC,HK',
     &    ' BARK,XRDGRO,DK,DKK= '/T12, F10.3,2X,F10.3,2X,I5,2X,5F10.3)
C----------
C  WESTERN JUNIPER FROM UT
C----------
        CASE(6)
          DK=(HK-4.5)*10./(SITEAR(ISPC)-4.5)
          IF(DK .LT. 0.1) DK=0.1
          DKK=(H-4.5)*10./(SITEAR(ISPC)-4.5)
          IF(DKK .LT. 0.1) DKK=0.1
          IF(H .LT. 4.5) DKK=D
C----------
C  WHITEBARK PINE FROM TT
C----------
        CASE(11)
C----------
C  COEFFICIENTS FROM EM/SMDGF
C  ASSIGN DIAMETER INCREMENT AND SCALE FOR BARK THICKNESS AND
C  PERIOD LENGTH.  SCALE ADJUSTMENT IS ON GROWTH IN DDS RATHER
C  THAN INCHES OF DG TO MAINTAIN CONSISTENCY WITH GRADD.
C----------
          PPCCF=1.
          TPCCF=PCCF(IPCCF)*PPCCF
          IF(TPCCF.GT.300.0) TPCCF=300.0
          IF(TPCCF.LT.25.0) TPCCF=25.0
C
          CR = FLOAT(ICR(K))
          HLESS4 = H - 4.5
          DLESS3 = 0.000231*HLESS4*CR - 0.00005 * HLESS4 * TPCCF
     &     + 0.001711 * CR + 0.17023 * HLESS4
          DKK = DLESS3 + 0.3
C
          IF(DEBUG)WRITE(JOSTND,*)'SMDGF CALL PARMS- ,I,ISPC,H,CR,',
     &    'TPCCF,DKK= ',I,ISPC,H,FLOAT(ICR(K)),TPCCF,DKK
C----------
C  PPCCF IS A PROPORTIONAL ADJUSTMENT FOR POINT CCF VALUES BASED ON
C  CHANGE IN STAND CCF FOR THE SUBCYCLE.
C----------
          HLESS4 = HK - 4.5
          DLESS3 = 0.000231*HLESS4*CR - 0.00005 * HLESS4 * TPCCF
     &     + 0.001711 * CR + 0.17023 * HLESS4
          DK = DLESS3 + 0.3

          IF(DEBUG)WRITE(JOSTND,*)'SMDGF CALL PARMS- ,I,ISPC,HK,CR,',
     &    'PCCF(IPCCF),DKK= ',I,ISPC,HK,FLOAT(ICR(K)),PCCF(IPCCF),DK
C----------
C  SPECIES FROM WC VARIANT
C  SET DDUM = 1 IF THIS IS A MANAGED STAND
C----------
        CASE(13,14,16,18)
          DDUM = 0.0
          IF(MANAGD.EQ.1 .OR. LESTB) DDUM=1.0
C----------
C   BEGIN THE DIAMETER LOOKUP SECTION
C      DK = DIAMETER WITH HTG ADDED TO THE STARTING HEIGHT
C      DKK  = DIAMETER AT THE START OF THE PROJECTION
C   DAT45  = DIAMETER AT 4.5 FEET PREDICTED FROM EQUATION.
C----------
          CRCODE = FLOAT(ICR(K))/10.0
          ALHT = ALOG(H)
          ALHK = ALOG(HK)
          SELECT CASE (ISPC)
          CASE(13)
            INDX=1
          CASE(14)
            INDX=2
          CASE(16,18)
            INDX=3
          END SELECT
          DAT45 = RDCON(INDX) + RDCR(INDX)*CRCODE
     &    + RDLHT(INDX)*ALOG(4.5) + RDHT(INDX)*4.5 + RDDUM(INDX)*DDUM
C
          DKK = RDCON(INDX) + RDCR(INDX) * CRCODE
     &         + RDLHT(INDX)*ALHT + RDHT(INDX)*H  +RDDUM(INDX)*DDUM
          IF(DKK .LT. 0.0) DKK=D
C
          DK = RDCON(INDX) + RDCR(INDX) * CRCODE
     &         + RDLHT(INDX)*ALHK + RDHT(INDX)*HK + RDDUM(INDX)*DDUM
          IF(DK .LT. DKK) DK=DKK+.01
          IF(DEBUG)WRITE(JOSTND,*)'I,INDX,DBH,H,HK,DK,DKK,CRCODE,DDUM=
     &    ',I,INDX,DBH(I),H,HK,DK,DKK,CRCODE,DDUM
C
        END SELECT
        IF(ISPC.EQ.6 .OR. ISPC.EQ.11 .OR. ISPC.EQ.12 .OR. ISPC.EQ.15)
     &    GO TO 300
C----------
C  USE INVENTORY EQUATIONS IF CALIBRATION OF THE HT-DBH FUNCTION IS TURNED
C  OFF, OR IF WYKOFF CALIBRATION DID NOT OCCUR.
C  NOTE: THIS SIMPLIFIES TO IF(IABFLB(ISPC).EQ.1) BUT IS SHOWN IN IT'S
C        ENTIRITY FOR CLARITY.
C----------
        IF(.NOT.LHTDRG(ISPC) .OR.
     &     (LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.1))THEN
          CALL HTDBH (IFOR,ISPC,DK,HK,1)
          IF(H .LE. 4.5) THEN
            DKK=D
          ELSE
            CALL HTDBH (IFOR,ISPC,DKK,H,1)
          ENDIF
          IF(DEBUG)WRITE(JOSTND,*)'INV EQN DUBBING IFOR,ISPC,H,HK,DK,'
     &    ,'DKK= ',IFOR,ISPC,H,HK,DK,DKK
          IF(DEBUG)WRITE(JOSTND,*)'ISPC,LHTDRG,IABFLG= ',
     &    ISPC,LHTDRG(ISPC),IABFLG(ISPC)
        ENDIF
  300   CONTINUE
C----------
C  IF CALLED FROM **ESTAB** ASSIGN DIAMETER
C----------
        IF(LESTB) THEN
          IF(ISPC.EQ.13 .OR. ISPC.EQ.14 .OR. ISPC.EQ.16 .OR. ISPC.EQ.18)
     &    THEN
            IF(DAT45.GT.0.0 .AND. HK.GE.4.5 .AND. LHTDRG(ISPC) .AND.
     &         IABFLG(ISPC).EQ.0) THEN
              DBH(K)=DK - DAT45 + DIAM(ISPC)
            ELSE
              DBH(K)=DK
            ENDIF
          ELSE
            DBH(K)=DK
          ENDIF
          IF(DBH(K).LT.DIAM(ISPC) .OR. HK.LT.4.5) DBH(K)=DIAM(ISPC)
          DBH(K)=DBH(K)+0.001*HK
          DG(K)=DBH(K)
        ELSE
C----------
C         COMPUTE DIAMETER INCREMENT BY SUBTRACTION, APPLY USER
C         SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF COMPUTED VALUE
C         IS WITHIN BOUNDS.
C----------
C IF THE TREE JUST REACHED 4.5 FEET, SET DKK TO PRESENT DBH.
C RJ 12/6/91
          IF(H .LT. 4.5 )DKK = D
          BARK=BRATIO(ISPC,D,H)
C
          IF(DEBUG)WRITE(JOSTND,*)'BARK,XRDGRO= ',BARK,XRDGRO
C
          SELECT CASE (ISPC)
C
C----------
C FROM WC
C PROBLEM WITH HARDWOOD EQN, REDUCES TO .021*HG. SET TO RULE
C OF THUMB VALUE .1*HG FOR NOW. DIXON 11-04-92
C DON'T USE R.O.T. IF USING INVENTORY EQNS.  DIXON 03-31-98
C----------
          CASE(13,14,16,18)
            IF(DK.LT.0.0 .OR. DKK.LT.0.0)THEN
              DG(K)=HTG(K)*0.2*BARK*XRDGRO
              DK=D+DG(K)
            ELSE
              DG(K)=(DK-DKK)*BARK*XRDGRO
            ENDIF
            IF(DEBUG)WRITE(JOSTND,*)'K,DK,DKK,DG,BARK,XRDGRO= ',
     &       K,DK,DKK,DG(K),BARK,XRDGRO
            IF(LHTDRG(ISPC) .AND. IABFLG(ISPC).EQ.0)
     &         DG(K)=0.1*HTG(K)*XRDGRO
            IF(DG(K) .LT. 0.0) DG(K)=0.1
            IF (DG(K) .GT. DGMX) DG(K)=DGMX
            IF(DEBUG)WRITE(JOSTND,*)'HARDWOOD EQU DG(K),DGMX,LHTDRG= '
            IF(DEBUG)WRITE(JOSTND,*)DG(K),DGMX,LHTDRG(ISPC)
C
          CASE DEFAULT
            IF(DK.LT.0.0 .OR. DKK.LT.0.0)THEN
              DG(K)=HTG(K)*0.2*BARK*XRDGRO
              DK=D+DG(K)
            ELSE
              DG(K)=(DK-DKK)*BARK*XRDGRO
            ENDIF
C
          END SELECT
C----------
C         SCALE DIAMETER INCREMENT TO 10-YR ESTIMATE.
C         SCALE ADJUSTMENT IS ON GROWTH IN DDS TERMS RATHER THAN
C         INCHES OF DG TO BE CONSISTENT WITH GRADD.
C----------
            IF(DG(K) .LT. 0.0) DG(K)=0.0
            IF (DG(K) .GT. DGMX) DG(K)=DGMX
            IF(ISPC.EQ.11 .AND. (DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
              DG(K)=DIAM(ISPC)-DBH(K)
            ENDIF
C
            DDS = DG(K)*(2.0*BARK*D+DG(K))*SCALE2
            DG(K) = SQRT((D*BARK)**2.0 + DDS)-BARK*D
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
C----------
C  CHECK FOR TREE SIZE CAP COMPLIANCE
C----------
      CALL DGBND(ISPC,DBH(K),DG(K))
C
   23 CONTINUE
C----------
C  RETURN TO PROCESS NEXT TRIPLE IF TRIPLING.  OTHERWISE,
C  PRINT DEBUG AND RETURN TO PROCESS NEXT TREE.
C----------
      IF(LESTB .OR. .NOT.LTRIP .OR. L.GE.2) GO TO 22
      L=L+1
      K=ITRN+2*I-2+L
      GO TO 2
C----------
C  END OF GROWTH PREDICTION LOOP.  PRINT DEBUG INFO IF DESIRED.
C----------
   22 CONTINUE
      IF(DEBUG)THEN
      HTNEW=HT(I)+HTG(I)
      WRITE(JOSTND,9987) I,ISPC,HT(I),HTG(I),HTNEW,DBH(I),DG(I)
 9987 FORMAT('IN REGENT, I=',I4,',  ISPC=',I3,'  CUR HT=',F7.2,
     &       ',  HT INC=',F7.4,',  NEW HT=',F7.2,',  CUR DBH=',F10.5,
     &       ',  DBH INC=',F7.4)
      ENDIF
   25 CONTINUE
   30 CONTINUE
      GO TO 91
C
C----------
C  SMALL TREE HEIGHT CALIBRATION SECTION.
C----------
   40 CONTINUE
      DO 45 ISPC=1,MAXSP
      HCOR(ISPC)=0.0
      CORTEM(ISPC)=1.0
      NUMCAL(ISPC)=0
   45 CONTINUE
      IF (ITRN.LE.0) GO TO 91
      IF(IFINTH .EQ. 0)  GOTO 95
      SCALE3 = REGYR / FINTH
C---------
C COMPUTE DENSITY MODIFIER FROM CCF AND TOP HEIGHT.
C---------
      X=AVH*(RELDEN/100.0)
      IF(X .GT. 300.0) X=300.0
      PCTRED=AB(1)
     & + X*(AB(2) + X*(AB(3) + X*(AB(4) + X*(AB(5)+ X*AB(6)))))
      IF(PCTRED .GT. 1.0) PCTRED = 1.0
      IF(PCTRED .LT. 0.01) PCTRED = 0.01
      IF(DEBUG)WRITE(JOSTND,9989)AVH,RELDEN,X,PCTRED
 9989 FORMAT('IN REGENT AVH,RELDEN,X,PCTRED = ',4F10.4)
C----------
C  BEGIN PROCESSING TREE LIST IN SPECIES ORDER.  DO NOT CALCULATE
C  CORRECTION TERMS IF THERE ARE NO TREES FOR THIS SPECIES.
C----------
      DO 100 ISPC=1,MAXSP
      CORNEW=1.0
      I1=ISCT(ISPC,1)
      IF(I1.EQ.0 .OR. .NOT. LHTCAL(ISPC)) GO TO 100
      N=0
      SNP=0.0
      SNX=0.0
      SNY=0.0
      I2=ISCT(ISPC,2)
      IREFI=IREF(ISPC)
      SI=SITEAR(ISPC)
      IF(SI .GT. SHI(ISPC)) SI=SHI(ISPC)
      IF(SI .LE. SLO(ISPC)) SI=SLO(ISPC) + 0.5
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS LESS THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
      JCR=ICR(I)/10.
      IPCCF=ITRE(I)
C----------
C  DIA GT 3 INCHES INCLUDED IN OVERALL MEAN
C----------
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
C----------
C  COMPUTE VIGOR MODIFIER FROM CROWN RATIO.
C----------
      X=FLOAT(ICR(I))/100.
      VIGOR = (150.0 * (X**3.0)*EXP(-6.0*X))+0.3
      IF(VIGOR .GT. 1.0)VIGOR=1.0
C----------
C  VIGOR ADJUSTMENT TO DRASTIC FOR PINYON, CUT IT BY TWO-THIRDS
C----------
      IF(ISPC .EQ. 6)VIGOR=1.-((1.-VIGOR)/3.)
C----------
C  BEGIN POTHTG SECTION
C----------
C
      SELECT CASE(ISPC)
C
C QUAKING ASPEN
C
      CASE(15)
        RELSI=(SI-SLO(ISPC))/(SHI(ISPC)-SLO(ISPC))
        RSIMOD = 0.5 * (1.0 + RELSI)
C----------
C COMPUTE HT GROWTH AND AGE FOR ASPEN. EQN FROM WAYNE SHEPPARD RMRS.
C----------
        AG1 = (H*12.0*2.54/26.9825)**0.8509
        AG2 = AG1 + 10.0
        H2  = (26.9825*AG2**1.1752)/(2.54*12.0)
        EDH = (H2-H) * RSIMOD * RHCON(ISPC)
        EDH=EDH*2.4
C----------
C GROWTH RATES APPEAR HIGH, REDUCE BY 25 PERCENT. DIXON 8-27-92.
C----------
        EDH=EDH*.75
        IF(EDH .LT. 0.0) EDH=0.0
        GO TO 9988
C----------
C LIMBER PINE FROM THE UT VARIANT
C----------
      CASE(12)
        POTHTG = SI/5.0
C----------
C ORIGINAL BM SPECIES AND OTHERS (EXCEPT ASPEN AND LIMBER PINE)
C----------
      CASE DEFAULT
C----------
C CALL SMHTGF, THE SMALL TREE HEIGHT GROWTH ROUTINE
C----------
      CALL SMHTGF(ISPC,POTHTG,H,1,REGYR,ICYC,JOSTND,DEBUG)
C
      END SELECT
C
      EDH=POTHTG*PCTRED*VIGOR*RHCON(ISPC)
C
 9988 CONTINUE
      IF(DEBUG)WRITE(JOSTND,9990) X,VIGOR,EDH
 9990 FORMAT('IN REGENT X,VIGOR,EDH = ',3F10.4)
      P=PROB(I)
      IF(HTG(I).LT.0.001) GO TO 60
      TERM=HTG(I) * SCALE3
      SNP=SNP+P
      SNX=SNX+EDH*P
      SNY=SNY+TERM*P
      N=N+1
C----------
C  PRINT DEBUG INFO IF DESIRED.
C----------
      IF(DEBUG)WRITE(JOSTND,9991) NPLT,I,ISPC,H,DBH(I),ICR(I),
     & PCT(I),ATCCF,RHCON(ISPC),EDH,TERM
 9991 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 12X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3)
C----------
C  END OF TREE LOOP WITHIN SPECIES.
C----------
   60 CONTINUE
      IF(DEBUG) WRITE(JOSTND,9992) ISPC,SNP,SNX,SNY
 9992 FORMAT(/'SUMS FOR SPECIES ',I2,':  SNP=',F10.2,
     & ';  SNX=',F10.2,';  SNY=',F10.2)
C----------
C  COMPUTE CALIBRATION TERMS.  CALIBRATION TERMS ARE NOT COMPUTED
C  IF THERE WERE FEWER THAN NCALHT (DEFAULT=5) HEIGHT INCREMENT
C  OBSERVATIONS FOR A SPECIES.
C----------
      IF(N.LT.NCALHT) GO TO 80
C----------
C  CALCULATE MEANS FOR THE POPULATION AND FOR THE SAMPLE ON THE
C  NATURAL SCALE.
C----------
      SNX=SNX/SNP
      SNY=SNY/SNP
C----------
C  CALCULATE RATIO ESTIMATOR.
C----------
      CORNEW = SNY/SNX
      IF(CORNEW.LE.0.0) CORNEW=1.0E-4
      HCOR(ISPC)=ALOG(CORNEW)
C----------
C  TRAP CALIBRATION VALUES OUTSIDE 2.5 STANDARD DEVIATIONS FROM THE
C  MEAN. IF C IS THE CALIBRATION TERM, WITH A DEFAULT OF 1.0, THEN
C  LN(C) HAS A MEAN OF 0.  -2.5 < LN(C) < 2.5 IMPLIES
C  0.0821 < C < 12.1825
C----------
      IF(CORNEW.LT.0.0821 .OR. CORNEW.GT.12.1825) THEN
        CALL ERRGRO(.TRUE.,27)
        WRITE(JOSTND,9194)ISPC,JSP(ISPC),CORNEW
 9194   FORMAT(T28,'SMALL TREE HTG: SPECIES = ',I2,' (',A3,
     &  ') CALCULATED CALIBRATION VALUE = ',F8.2)
        CORNEW=1.0
        HCOR(ISPC)=0.0
      ENDIF
   80 CONTINUE
      CORTEM(IREFI) = CORNEW
      NUMCAL(IREFI) = N
  100 CONTINUE
C----------
C  END OF CALIBRATION LOOP.  PRINT CALIBRATION STATISTICS AND RETURN
C----------
      WRITE(JOSTND,9993) (NUMCAL(I),I=1,NUMSP)
 9993 FORMAT(/'NUMBER OF RECORDS AVAILABLE FOR SCALING'/
     >       'THE SMALL TREE HEIGHT INCREMENT MODEL',
     >        ((T48,11(I4,2X)/)))
   95 CONTINUE
      WRITE(JOSTND,9994) (CORTEM(I),I=1,NUMSP)
 9994 FORMAT(/'INITIAL SCALE FACTORS FOR THE SMALL TREE'/
     >      'HEIGHT INCREMENT MODEL',
     >       ((T48,11(F5.2,1X)/)))
C----------
C OUTPUT CALIBRATION TERMS IF CALBSTAT KEYWORD WAS PRESENT.
C----------
      IF(JOCALB .GT. 0) THEN
        KOUT=0
        DO 207 K=1,MAXSP
        IF(CORTEM(K).NE.1.0 .OR. NUMCAL(K).GE.NCALHT) THEN
          SPEC=NSP(MAXSP,1)(1:2)
          ISPEC=MAXSP
          DO 203 KK=1,MAXSP
          IF(K .NE. IREF(KK)) GO TO 203
          ISPEC=KK
          SPEC=NSP(KK,1)(1:2)
          GO TO 2031
  203     CONTINUE
 2031     WRITE(JOCALB,204)ISPEC,SPEC,NUMCAL(K),CORTEM(K)
  204     FORMAT(' CAL: SH',1X,I2,1X,A2,1X,I4,1X,F6.3)
          KOUT = KOUT + 1
        ENDIF
  207   CONTINUE
        IF(KOUT .EQ. 0)WRITE(JOCALB,209)
  209   FORMAT(' NO SH VALUES COMPUTED')
        WRITE(JOCALB,210)
  210   FORMAT(' CALBSTAT END')
      ENDIF
   91 IF(DEBUG)WRITE(JOSTND,9995)ICYC
 9995 FORMAT('LEAVING SUBROUTINE REGENT  CYCLE =',I5)
      RETURN
C
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS THAT REQUIRE ONE-TIME RESOLUTION.
C---------
      DO 90 ISPC=1,MAXSP
      RHCON(ISPC) = 1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)
     &RHCON(ISPC)= RCOR2(ISPC)
   90 CONTINUE
      RETURN
      END
