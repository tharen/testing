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
      use calcom_mod
      use estcor_mod
      implicit none
C----------
C  **REGENT--WC   DATE OF LAST REVISION:  02/08/13
C----------
C  THIS SUBROUTINE COMPUTES HEIGHT AND DIAMETER INCREMENTS FOR
C  SMALL TREES.  THE **SMHTGF ROUTINE IS CALLED TO CALCULATE
C  HEIGHT INCREMENT.  THE MODEL IS APPLIED TO TREES
C  THAT ARE LESS THAN  5 INCHES DBH,
C  AND THE DBH INCREMENT MODEL IS APPLIED TO TREES THAT ARE LESS
C  THAN 3 INCHES DBH.  FOR TREES THAT ARE GREATER THAN 3 INCHES
C  DBH, HEIGHT INCREMENT PREDICTIONS
C  ARE AVERAGED WITH THE PREDICTIONS FROM THE LARGE TREE MODEL.
C  THIS ROUTINE IS CALLED FROM **CRATET** DURING CALIBRATION AND
C  FROM **TREGRO** DURING CYCLING.  ENTRY **REGCON** IS CALLED FROM
C  **RCON** TO LOAD MODEL PARAMETERS THAT NEED ONLY BE RESOLVED ONCE.
C  **SMHGDG IS CALLED TO CALCULATE SMALL TREE HEIGHT AND DIAMETER
C  INCREMENT
C----------
COMMONS
C----------
C  DIMENSIONS FOR INTERNAL VARIABLES:
C
C   CORTEM -- A TEMPORARY ARRAY FOR PRINTING CORRECTION TERMS.
C   NUMCAL -- A TEMPORARY ARRAY FOR PRINTING NUMBER OF HEIGHT
C             INCREMENT OBSERVATIONS BY SPECIES.
C    RHCON -- CONSTANT FOR THE HEIGHT INCREMENT MODEL.
C     XMAX -- UPPER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM SMALL AND LARGE TREE MODELS
C             ARE AVERAGED.
C     XMIN -- LOWER END OF THE RANGE OF DIAMETERS OVER WHICH HEIGHT
C             INCREMENT PREDICTIONS FROM THE SMALL AND LARGE TREE
C             ARE AVERAGED.
C     DIAM -- BUD WIDTH FOR SEEDLINGS, MINIMUM DBH OF ESTAB TREES.
C----------
      EXTERNAL RANN
      LOGICAL DEBUG,LESTB,LSKIPH
      REAL CORTEM(MAXSP)
      INTEGER NUMCAL(MAXSP)
      REAL XMAX(MAXSP),XMIN(MAXSP)
      REAL DGMAX(MAXSP),DIAM(MAXSP)
      INTEGER IRDMAP(MAXSP)
      REAL AB(6)
      INTEGER IREFI,ISPEC,KOUT,KK
      REAL H,BARK,VIGOR,TEMT,POTHTG,HTGR,ZZRAN,X1,XPPMLT,XWT
      REAL CON,XMX,XMN,SI,DGMX,D,CR,RAN,BACHLO,BRATIO,HK,DK,DKK
      REAL BX,AX,DDS,HTNEW,SCALE3,CORNEW,SNP,SNX,SNY,EDH,P,TERM
      REAL REGYR,FNT,SCALE,SCALE2,CCF,AVHT,X,PCTRED,XRHGRO,XRDGRO
      INTEGER ITRNIN,ISPC,I1,I2,I3,I,IPCCF,K,L,N,IRDX,MODE
      REAL DDUM,CRCODE,ALHT,ALHK,DAT45
      CHARACTER SPEC*2
      REAL DGR,DGR5,HG5,HG10
C----------
C IRDMAP IS A POINTER TO THE DIAMETER EQUATION COEF FOR EACH SPEC
C----------
C  DATA STATEMENTS.
C----------
C
C WH USED 10 IN IRDMAP.  BAD EQUATION. CHANGED TO 11. 2/8/95. GED.
C LP, SP, WP, LL, WB, KP, PY USED 6. CHANGED TO 5.  5/19/95. GD.
C PP & JP USED 7 IN IRDMAP.  BAD EQN. CHANGED TO 5. 5/19/95. GD.
C ALL THE ABOVE EQNS WERE UNDERESTIMATING SMALL TREE DG.
C
      DATA IRDMAP/
C         SF  WF  GF  AF  RF   DUM  NF  YC   IC   ES  LP  JP  SP
     &     1,  2,  2,  3,  3,    3,  5,  4,   4,   4,  5,  5,  5,
C         WP   PP  DF  RW  RC   WH  MH  BM   RA  WA  PB   GC   AS
     &     5,  5,  8,  8,   9,  11, 11, 12,  12, 12, 12,  12,  12,
C         CO   WO  J   LL  WB   KP  PY   DG   HW  BC  WI  DUM  DUM
     &    12,  12, 4,   5,  5,   5,  5,  12,  12,  12, 12,  12, 12  /
      DATA AB/ 1.11436, -0.011493, 0.43015E-4,
     &        -0.72221E-7, 0.5607E-10, -0.1641E-13 /
      DATA DGMAX/ 39*5.0 /
      DATA XMAX/ 10*4.0,3.0,28*4.0 /
      DATA XMIN/ 10*2.0,1.0,28*2.0 /
      DATA REGYR/10.0 /
      DATA DIAM/ 7*0.3, 2*0.2, 0.3, 4*0.4, 0.5, 0.3, 13*0.2,
     &           0.3, 2*0.4, 7*0.2 /
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
C  BASED ON A 10-YEAR GROWTH PERIOD.   SCALE IS USED TO CONVERT
C  HEIGHT INCREMENT PREDICTIONS TO A FINT-YEAR PERIOD.  DIAMETER
C  INCREMENT IS PREDICTED FROM CHANGE IN HEIGHT, AND IS SCALED TO A 10-
C  YEAR PERIOD BY APPLICATION OF THE VARIABLE SCALE2. DIAMETER INCREMENT
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
      CON = RHCON(ISPC) * EXP(HCOR(ISPC))
      XMX=XMAX(ISPC)
      XMN=XMIN(ISPC)
C----------
C     PUT A CEILING ON DIAMETER GROWTH BASED ON OLIVER AND COCHRAN EMPR.
C     RJ 11/28/88
C----------
      DGMX = DGMAX(ISPC) * SCALE
C----------
C  PROCESS NEXT TREE RECORD.
C----------
      DO 25 I3=I1,I2
      I=IND1(I3)
      IPCCF=ITRE(I)
      D=DBH(I)
      IF(D .GE. XMX) GO TO 25
C----------
C  SET DDUM = 1 IF THIS IS A MANAGED STAND
C  BYPASS INCREMENT CALCULATIONS IF CALLED FROM ESTAB AND THIS IS NOT A
C  NEWLY CREATED TREE.
C----------
      DDUM = 0.0
      IF(MANAGD .EQ. 1) DDUM=1.0
      IF(LESTB) THEN
        IF(I.LT.ITRNIN) GO TO 25
C----------
C  ASSIGN CROWN RATIO FOR NEWLY ESTABLISHED TREES.
C  SET THE DUMMY FOR DIA LOOKUP TO 1 (= MGT STAND)
C----------
        DDUM=1.0
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
      H=HT(I)
      BARK=BRATIO(ISPC,D,H)
      IF(LSKIPH) THEN
        HTG(K)=0.0
        DGR=0.0
        GO TO 4
      ENDIF
C----------
C     RETURN HERE TO PROCESS NEXT TRIPLE.
C----------
    2 CONTINUE
C----------
C  CALL SMHGDG, THE SMALL TREE HEIGHT AND DIAMETER GROWTH ROUTINE.
C  SMHGDG IS ALSO CALLED FROM ESSUBH TO GROW PLANTED TREES
C  FROM ESTABLISHMENT TO 5 YEARS INTO THE CYCLE
C  THE DEFAULT CYCLE LENGHT IS 10 YEARS SO CALL SMHGDG TWO TIMES
C  TO ESTIMATE THE 10 YEAR HEIGHT INCREMENT, SCALE WILL BE APPLIED
C  TO ADJUST TO FINT CYCLE LENGTH, CAN NOT PASS K (TRIPLED RECORD)
C  BECAUSE SMHGDG USES POINT STATISTICS THAT HAVE NOT BEEN CALCULATED
C  FOR RECORDS TRIPLED IN REGENT
C-----------
      MODE=1
      HG5=0.
      DGR5=0.
      CALL SMHGDG(I,ISPC,H,D,HG5,DGR5,ICYC,JOSTND,DEBUG,MODE)
      HTGR=HG5
      DGR=DGR5
      HK=H+HTGR
      DK=D+DGR
      IF(DEBUG) WRITE(JOSTND,*)'1ST-K,ISPC,HK,DK,HTGR,DGR,FINT= ',
     &K,ISPC,HK,DK,HTGR,DGR,FINT
      CALL SMHGDG(I,ISPC,HK,DK,HG5,DGR5,ICYC,JOSTND,DEBUG,MODE)
      HTGR=HTGR+HG5
      DGR=DGR+DGR5
      HK=H+HTGR
      DK=D+DGR
      IF(DEBUG) WRITE(JOSTND,*)' 2ND-K,ISPC,HTGR,DGR,DK,HK= ',
     &K,ISPC,HTGR,DGR,DK,HK
    3 CONTINUE
      ZZRAN = 0.0
      IF(DGSD.GE.1.0) ZZRAN=BACHLO(0.0,1.0,RANN)
      IF((ZZRAN .GT. 0.5) .OR. (ZZRAN .LT. -2.0)) GO TO 3
C
      IF(DEBUG)WRITE(JOSTND,*)' ZZRAN,XRHGRO,SCALE,FNT,CON,WK4(I)= ',
     &ZZRAN,XRHGRO,SCALE,FNT,CON,WK4(I)
C
      HTGR =(HTGR+ZZRAN*0.1)*XRHGRO*SCALE*CON*WK4(I)
      IF(HTGR .LT. 0.1) HTGR = 0.1
C----------
C     GET A MULTIPLIER FOR THIS TREE FROM PPREGT TO ACCOUNT FOR
C     THE DENSITY EFFECTS OF NEIGHBORING TREES.
C----------
      X1=0.
      XPPMLT=0.
      CALL PPREGT (XPPMLT,X1,X1,X1,X1)
      HTGR = HTGR + XPPMLT
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
      HTG(K)=HTGR*(1.0-XWT) + XWT*HTG(K)
      IF(HTG(K) .LT. .1) HTG(K) = .1
C
      IF(DEBUG)WRITE(JOSTND,*)' XWT,HTGR,HTG(K),I,K,XPPMLT= ',
     &XWT,HTGR,HTG(K),I,K,XPPMLT
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
      IF(D.GE.3.0) GO TO 23
      HK=H + HTG(K)
      IF(DEBUG)WRITE(JOSTND,*)' K,HK,H,HTG(K)= ',K,HK,H,HTG(K)
      IF(HK .LT. 4.5) THEN
        DG(K)=0.0
        DBH(K)=D+0.001*HK
      ELSE
C----------
C       SCALE DG TO AN FNT BASIS SINCE DDS IS SCALED TO A 10 YEAR
C       BASIS BELOW
C----------
        DG(K)=DGR*SCALE*WK4(I)
C----------
C       IF CALLED FROM **ESTAB** ASSIGN DIAMETER
C----------
        IF(LESTB) THEN
          DBH(K)=DG(K)
          IF(DBH(K).LT.DIAM(ISPC) .OR. HK.LT.4.5) DBH(K)=DIAM(ISPC)
        ELSE
C----------
C         APPLY USER SUPPLIED MULTIPLIERS, AND CHECK TO SEE IF
C         COMPUTED VALUE IS WITHIN BOUNDS.
C----------
          BARK=BRATIO(ISPC,D,H)
          IF(DEBUG)WRITE(JOSTND,*)' BARK,XRDGRO= ',BARK,XRDGRO
          IF((D.LT.0.).OR.(DG(K).LT.0.))THEN
            DG(K)=HTG(K)*0.2*BARK*XRDGRO
            DBH(K)=D+DG(K)
          ELSE
            DG(K)=DG(K)*BARK*XRDGRO
          ENDIF
          IF(DEBUG)WRITE(JOSTND,*)' K,DBH(K),DG(K)= ',K,DBH(K),DG(K)
C
          IF(DG(K) .LT. 0.0) DG(K)=0.1
          IF(DG(K) .GT. DGMX) DG(K)=DGMX
C----------
C         SCALE DIAMETER INCREMENT TO 10-YR ESTIMATE.
C         SCALE ADJUSTMENT IS ON GROWTH IN DDS RATHER THAN INCHES
C         OF DG TO BE CONSISTENT WITH GRADD.
C----------
          DDS=DG(K)*(2.0*BARK*D+DG(K))*SCALE2
          DG(K)=SQRT((D*BARK)**2.0+DDS)-BARK*D
        ENDIF
        IF((DBH(K)+DG(K)).LT.DIAM(ISPC))THEN
          DG(K)=DIAM(ISPC)-DBH(K)
        ENDIF
      ENDIF
      IF(DEBUG)THEN
        WRITE(JOSTND,*)' SCALE2,SCALE,YR,FNT,FINT= ',
     &  SCALE2,SCALE,YR,FNT,FINT
        HTNEW=HT(K)+HTG(K)
        WRITE(JOSTND,9987) K,ISPC,HT(K),HTG(K),HTNEW,DBH(K),DG(K)
 9987   FORMAT(' IN REGENT, K=',I4,',  ISPC=',I3,'  CUR HT=',F7.2,
     &       ',  HT INC=',F7.4,',  NEW HT=',F7.2,',  CUR DBH=',F10.5,
     &       ',  DBH INC=',F7.4)
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
   25 CONTINUE
   30 CONTINUE
      GO TO 91
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
      CON = RHCON(ISPC)
C----------
C  BEGIN TREE LOOP WITHIN SPECIES.  IF MEASURED HEIGHT INCREMENT IS
C  LESS THAN OR EQUAL TO ZERO, OR DBH IS LESS THAN 5.0, THE RECORD
C  WILL BE EXCLUDED FROM THE CALIBRATION.
C----------
      DO 60 I3=I1,I2
      I=IND1(I3)
      H=HT(I)
      D=DBH(I)
C----------
C  DIA GT 3 INCHES INCLUDED IN OVERALL MEAN
C----------
      IF(IHTG.LT.2) H=H-HTG(I)
      IF(DBH(I).GE.5.0.OR.H.LT.0.01) GO TO 60
C----------
C CALL SMHGDG, THE SMALL TREE HEIGHT AND DIAMETER GROWTH ROUTINE
C IT PREDICTS A 5 YEAR GROWTH INCREMENT SO CALL 2 TIMES
C----------
      MODE=1
      HG5=0.
      DGR5=0.
      CALL SMHGDG(I,ISPC,H,D,HG5,DGR5,ICYC,JOSTND,DEBUG,MODE)
      HTGR=HG5
      HK=H+HTGR
      DK=D+DGR
      IF(DEBUG) WRITE(JOSTND,*)'1ST-K,ISPC,HK,DK,HTGR,DGR,FINT= ',
     &K,ISPC,HK,DK,HTGR,DGR,FINT
      CALL SMHGDG(I,ISPC,HK,DK,HG5,DGR5,ICYC,JOSTND,DEBUG,MODE)
      HTGR=HTGR+HG5
      IF(DEBUG) WRITE(JOSTND,*)' 2ND-K,ISPC,HTGR,DGR,DK,HK,SCALE3= ',
     &K,ISPC,HTGR,DGR,DK,HK,SCALE3
      EDH=HTGR*RHCON(ISPC)
      IF(EDH .LT. 0.1) EDH=0.1
      IF(DEBUG)WRITE(JOSTND,9990) EDH
 9990 FORMAT(' IN REGENT-EDH = ',2F10.4)
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
     & PCT(I),ATCCF,RHCON(ISPC),EDH,TERM,SCALE3,FINTH
 9991 FORMAT('NPLT=',A26,',  I=',I5,',  ISPC=',I3,',  H=',F6.1,
     & ',  DBH=',F5.1,',  ICR',I5,',  PCT=',F6.1,',  RELDEN=',
     & F6.1 / 13X,'RHCON=',F10.3,',  EDH=',F10.3,', TERM=',F10.3,
     &' SCALE3= ',F6.1,' FINTH= ',F6.1)
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
      ENTRY REGCON
C----------
C  ENTRY POINT FOR LOADING OF REGENERATION GROWTH MODEL
C  CONSTANTS  THAT REQUIRE ONE-TIME RESOLUTION.
C---------
      DO 90 ISPC=1,MAXSP
      RHCON(ISPC) = 1.0
      IF(LRCOR2.AND.RCOR2(ISPC).GT.0.0)
     &RHCON(ISPC) = RCOR2(ISPC)
   90 CONTINUE
      RETURN
      END
