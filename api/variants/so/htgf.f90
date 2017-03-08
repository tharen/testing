      SUBROUTINE HTGF
      use findage_mod, only: findag

      use htcal_mod
      use multcm_mod
      use pden_mod
      use arrays_mod
      use contrl_mod
      use coeffs_mod
      use outcom_mod
      use plot_mod
      use prgprm_mod
      implicit none
!----------
!  **HTGF--SO   DATE OF LAST REVISION:  07/08/11
!----------
!  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
!  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
!  HEIGHT INCREMENT IS PREDICTED FROM SPECIES, HABITAT TYPE,
!  HEIGHT, DBH, AND PREDICTED DBH INCREMENT.  THIS ROUTINE
!  IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.  ENTRY
!  **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE DEPENDENT
!  CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
!----------
!OMMONS
!----------
      LOGICAL DEBUG
      INTEGER ISPC,I,I1,I2,I3,INDEX,ITFN
      INTEGER IICR,KEYCR,K,L,IXAGE,J
      REAL CRC,CRB,CRA,RHXS,RHK,SCALE,SINDX,XHT,BAL,H,D,POTHTG
      REAL AGP10,HGUESS,XMOD,CRATIO,RELHT,CRMOD,RHMOD,HGMDCR,RHX
      REAL FCTRKX,FCTRRB,FCTRXB,FCTRM,HGMDRH,WTCR,WTRH,HTGMOD,HTNOW
      REAL HTNOWMOD,TEMPH,TEMHTG
      REAL AGMAX,HTMAX,SITHT,SITAGE,HTMAX2,D2
      REAL XI2,XI1,BARK,X1,Z,HTI,PSI,HHT
      REAL BRATIO,Y1,Y2,FBY1,FBY2,ZBIAS,ZTEST,ZADJ,CLOSUR,DIA
      REAL RHR(MAXSP), RHYXS(MAXSP), RHM(MAXSP), RHB(MAXSP)
      REAL COF(9,5),COF1(9,3),COF6(9,5),AZBIAS(MAXSP),BZBIAS(MAXSP)
      REAL MISHGF

!----------
!  COEFFICIENTS--CROWN RATIO (CR) BASED HT. GRTH. MODIFIER
!----------
      CRA = 100.0
      CRB = 3.0
      CRC = -5.0
!----------
!  COEFFICIENTS--RELATIVE HEIGHT (RH) BASED HT. GRTH. MODIFIER
!----------
      RHK = 1.0
      RHXS = 0.0
!----------
!  COEFFS BASED ON SPECIES SHADE TOLERANCE AS FOLLOWS:
!                                   RHR  RHYXS    RHM    RHB
!        VERY TOLERANT             20.0   0.20    1.1  -1.10
!        TOLERANT                  16.0   0.15    1.1  -1.20
!        INTERMEDIATE              15.0   0.10    1.1  -1.45
!        INTOLERANT                13.0   0.05    1.1  -1.60
!        VERY INTOLERANT           12.0   0.01    1.1  -1.60
!  IN THE SO VARIANT THE SHADE TOLLERANCE WAS RESOLVED TO THE RANGE
!  1 THROUGH 11, WITH 1 REPRESENTING THE MOST TOLERANT AND 11 THE
!  LEAST SHADE TOLERANT AS FOLLOWS
!  SEQ. NO.   CHAR. CODE    SHADE TOLERANCE     INDEX
!      1      WP            INTM                 7
!      2      SP            INTM                 9
!      3      DF            INTM                 6
!      4      WF            TOLN                 3
!      5      MH            VTOL                 1
!      6      IC            VTOL                 2
!      7      LP            VINT                11
!      8      ES            TOLN                 5
!      9      RF            TOLN                 4
!      10     PP            INTL                10
!      11     OT            INTM                 8
!----------
      RHR = (/ &
       15.0, 15.0, 15.0, 20.0, 20.0, 20.0, 12.0, 16.0, 16.0, 13.0, &
       13.0, 13.0, 20.0, 20.0, 15.0, 15.0, 12.0, 20.0, 20.0, 20.0, &
       13.0, 13.0, 20.0, 15.0, 12.0, 13.0, 15.0, 12.0, 15.0, 15.0, &
       15.0, 15.0, 15.0/)
!
      RHYXS = (/ &
       0.10, 0.10, 0.10, 0.20, 0.20, 0.20, 0.01, 0.15, 0.15, 0.05, &
       0.10, 0.20, 0.05, 0.10, 0.10, 0.10, 0.10, 0.10, 0.20, 0.20, &
       0.05, 0.05, 0.20, 0.10, 0.01, 0.05, 0.10, 0.01, 0.10, 0.10, &
       0.10, 0.10, 0.10/)
      RHM = (/(1.1,k=1,maxsp)/)
      
      RHB = (/ &
      -1.45,-1.45,-1.45,-1.10,-1.10,-1.10,-1.60,-1.20,-1.20,-1.60, &
      -1.45,-1.10,-1.20,-1.10,-1.45,-1.60,-1.60,-1.10,-1.10,-1.10, &
      -1.60,-1.60,-1.10,-1.45,-1.60,-1.60,-1.45,-1.60,-1.45,-1.45, &
      -1.45,-1.45,-1.45/)
!
      AZBIAS(:) =  (/(0.0,k=1,MAXSP)/)
      BZBIAS(:) =  (/(0.0,k=1,MAXSP)/)
!
!  COF1 IS FROM TT/HTGF
!
      COF1 = reshape((/ &
      37.0,85.0,1.77836,-0.51147,1.88795,1.20654,0.57697, &
      3.57635,0.90283, &
      45.0,100.0,1.66674,0.25626,1.45477,1.11251,0.67375, &
      2.17942,0.88103, &
      45.0,90.0,1.64770,0.30546,1.35015,0.94823,0.70453, &
      2.46480,1.00316/),(/9,3/))
!
!  COF6 IS FROM UT/HTGF
!
      COF6 = reshape((/ &
      30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051, &
      3.00551,1.01433, &
      30.0,85.0,2.00995,0.03288,1.81059,1.28612,0.72051, &
      3.00551,1.01433, &
      35.0,85.0,1.80388,-0.07682,1.70032,1.29148,0.72343, &
      2.91519,0.95244, &
      (0.0,k=1,18)/),(/9,5/))
!-----------
!  SEE IF WE NEED TO DO SOME DEBUG.
!-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF  CYCLE =',I5)
      IF(DEBUG)WRITE(JOSTND,*) 'IN HTGF AT BEGINNING,HTCON=', &
      HTCON,'RMAI=',RMAI,'ELEV=',ELEV
!
      SCALE=FINT/YR
!----------
!  GET THE HEIGHT GROWTH MULTIPLIERS.
!----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- ISPC,IY(ICYC),XHMULT= ',ISPC, &
       IY(ICYC), XHMULT
!----------
!   BEGIN SPECIES LOOP.
!----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      SINDX = SITEAR(ISPC)
      XHT=XHMULT(ISPC)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- ISPC,IY(ICYC),XHT= ',ISPC, &
       IY(ICYC), XHT
!-----------
!   BEGIN TREE LOOP WITHIN SPECIES LOOP
!-----------
      DO 30 I3 = I1,I2
      I=IND1(I3)
      HTG(I)=0.0
      BAL=((100.0-PCT(I))/100.0)*BA
      H=HT(I)
      D=DBH(I)
!
      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D2 = 0.0
      IF (PROB(I).LE.0.0) GO TO 161
      IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING FINDAG I= ',I
      CALL FINDAG(I,ISPC,D,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,DEBUG)
!
      SELECT CASE (ISPC)
!----------
!  NORMAL HEIGHT INCREMENT CALCULATON BASED ON TREE AGE
!  FIRST CHECK FOR MAXIMUM TREE AGE (CA METHOD SP 9,27)
!----------
      CASE(9,27)
        IF (SITAGE .GT. AGMAX) THEN
          POTHTG= 0.10
          GO TO 1320
        ELSE
          AGP10=SITAGE + 10.0
        ENDIF
!----------
!  SO VARIANT METHOD AND OTHERS (SPECIAL CASE FOR PP(10))
!  AND EC VARIANT METHOD (SP 14,17,18)
!----------
      CASE DEFAULT
        IF(H .GE. HTMAX)THEN
          HTG(I)=0.1
          HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
          GO TO 161
        ENDIF
        IF (SITAGE .GT. AGMAX) THEN
          POTHTG= 0.10
          GO TO 1320
        ELSE
          AGP10= SITAGE + 10.0
        ENDIF
!
      CASE(10)
!----------
! THE FOLLOWING 'IF' BLOCK IS AN RJ FIX.  8-22-88
!----------
        IF(SITAGE .GT. AGMAX)THEN
          POTHTG = -1.31 + 0.05 * SINDX
          IF(POTHTG .LT. 0.1) POTHTG = 0.1
          GO TO 1320
        ELSE
          AGP10= SITAGE + 10.0
        ENDIF
      END SELECT
!----------
!  WJ FROM UT USES HEIGHT INCREMENT FROM **REGENT**
!----------
      IF(ISPC.EQ.11)GO TO 999
!----------
!  NOW CALCULATE NORMAL HEIGHT INCREMENT**********************
!----------
!
!  R5 USE DUNNING/LEVITAN SITE CURVE.
!  R6 USE VARIOUS SPECIES SITE CURVES.
!  SPECIES DIFFERENCES ARE ARE ACCOUNTED FOR BY THE SPECIES
!  SPECIFIC SITE INDEX VALUES WHICH ARE SET AFTER KEYWORD PROCESSING.
!----------
      SELECT CASE (ISPC)
!
      CASE(9,27)
        IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING HTCALC 1'
        CALL HTCALC(IFOR,SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG)
        POTHTG= HGUESS - SITHT
        IF(DEBUG)WRITE(JOSTND,91200)I,ISPC,AGP10,HGUESS,H
91200   FORMAT(' HTGF-91200,I,ISPC,AGEP10,HGUESS,H ',2I5,3F10.2)
!----------
! ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
!----------
        XMOD=1.0
        CRATIO=ICR(I)/100.0
        RELHT=H/AVH
        IF(RELHT .GT. 1.0)RELHT=1.0
        IF(PCCF(ITRE(I)) .LT. 100.0)RELHT=1.0
!--------
!  THE TREE HEIGHT GROWTH MODIFIER (SMHMOD) IS BASED ON THE RITCHIE &
!  HANN WORK (FOR.ECOL.&MGMT. 1986. 15:135-145).  THE ORIGINAL COEFF.
!  (1.117148) IS CHANGED TO 1.016605 TO MAKE THE SMALL TREE HEIGHTS
!  CLOSE TO THE SITE INDEX CURVE.  THE MODIFIER HAS TWO PARTS, ONE
!  (CRMOD) FOR TREE VIGOR USING CROWN RATIO AS A SURROGATE; OTHER
!  (RHMOD) FOR COMPETITION FROM NEIGHBORING TREES USING RELATIVE TREE
!  HEIGHT AS A SURROGATE.
!----------
        CRMOD=(1.0-EXP(-4.26558*CRATIO))
        RHMOD=(EXP(2.54119*(RELHT**0.250537-1.0)))
        XMOD= 1.016605*CRMOD*RHMOD
        HTG(I) = POTHTG * XMOD
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
!
        IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I), &
         POTHTG,BAL,AVH,HTG(I),DBH(I),RMAI,HGUESS
  900   FORMAT(' HTGF',I5,14F9.2)
        GO TO 999
!
      CASE(16,24)
!----------
!  WHITEBARK PINE AND QUAKING ASPEN - JOHNSON'S SBB METHOD
!----------
        IF(ISPC.EQ.16)THEN
          DO J=1,3
          DO K=1,9
          COF(K,J)=COF1(K,J)
          ENDDO
          ENDDO
        ELSE
          DO J=1,5
          DO K=1,9
          COF(K,J)=COF6(K,J)
          ENDDO
          ENDDO
        ENDIF
        XI2=4.5
        XI1=0.1
!----------
!  TRAP TO AVOID LOG(0) ERRORS WITH XI1 AND XI2; HTG WILL COME FROM
!  REGENT FOR THESE SMALL OF TREES ANYWAY.  GED 05/07/09
!
        IF(DBH(I) .LE. 0.1 .OR. HT(I).LE. 4.5)GO TO 180
!----------
        HTG(I)=0.
        HTI=HT(I)
        BARK=BRATIO(ISPC,DBH(I),HTI)
        IF(DEBUG)WRITE(JOSTND,*)' HTI, BARK= ',HTI, BARK
!
!    CHANGE THE CROWN RATIO TO AN INTEGER BETWEEN 0 AND 10
!
        IICR= ICR(I)/10.0 + 0.5
!
!    PLACE THE CROWN RATIO INTO ONE OF THREE GROUPS
!
        IF(IICR .GT. 9) IICR=9
        GO TO(101,101,102,102,102,102,102,103,103),IICR
  101   KEYCR=1
        GO TO 110
  102   KEYCR=2
        GO TO 110
  103   KEYCR=3
  110   CONTINUE
!
!  ROW IDENT FOR SBB COEF LOOKUP
!
        K= KEYCR
!
!  CHECK IF HEIGHT OR DBH EXCEED PARAMETERS
!
        IF(DEBUG) &
          WRITE(JOSTND,9101)(COF(L,K),L=1,9)
 9101   FORMAT(' COFS= ',9F10.4)


  170   CONTINUE
        IF (HTI.LE. 4.5) GOTO 180
        IF((XI1 + COF(1,K)) .LE. DBH(I)) GO TO 180
        IF((XI2 + COF(2,K)) .LE. HTI) GO TO 180
!
        IF(DEBUG)WRITE(JOSTND,*)' XI1, XI2, DBH, HTI,COF(1,K),', &
        'COF(2,K)= ',XI1, XI2, DBH(I), HTI,COF(1,K),COF(2,K)
!
        GO TO 190
  180   CONTINUE
!
!    THE SBB IS UNDEFINED IF CERTAIN INPUT VALUES EXCEED PARAMETERS IN
!    THE FITTED DISTRIBUTION.  IN INPUT VALUES ARE EXCESSIVE THE HEIGHT
!    GROWTH IS TAKEN TO BE 0.1 FOOT.
!
        HTG(I) = 0.1
        GO TO 25
  190   CONTINUE
!
! CALCULATE ALPHA FOR THE TREE USING SCHREUDER + HAFLEY
!
        Y1=(DBH(I) - XI1)/COF(1,K)
        Y2=(HT(I) - XI2)/COF(2,K)
        IF(DEBUG)WRITE(JOSTND,*)' K,COF,DBH,XI1= ',K,COF(1,K),DBH(I),XI1
        IF(DEBUG)WRITE(JOSTND,*)' Y1,Y2,HT,XI2= ',Y1,Y2,HT(I),XI2
!
        FBY1=ALOG(Y1/(1.0 - Y1))
        FBY2= ALOG(Y2/(1.0 - Y2))
        Z=( COF(4,K) + COF(6,K)*FBY2 - COF(7,K)*( COF(3,K) + &
         COF(5,K)*FBY1))*(1.0 - COF(7,K)**2)**(-0.5)
        IF(DEBUG)WRITE(JOSTND,*)' K,COF(1,K)= ',K,COF(1,K)
        IF(DEBUG)WRITE(JOSTND,*)' K,COF(2,K)= ',K,COF(2,K)
!
! THE HT DIA MODEL NEEDS MODIFICATION TO CORRECT KNOWN BIAS
! THE COEFFS FOR AZBIAS AND BZBIAS ARE ZERO FOR THESE SPECIES
!
        ZBIAS=AZBIAS(ISPC)+BZBIAS(ISPC)*ELEV
        IF(ISPC.EQ.24)ZBIAS=AZBIAS(ISPC)+BZBIAS(ISPC)*(ELEV-20.)
        IF(ELEV .LT. 55. .OR. ELEV .GT. 80.0)ZBIAS=0.0
        ZTEST=Z-ZBIAS
        IF(ZTEST .GE. 2.0 .AND. ZBIAS .LT. 0.0)ZBIAS=0.0
        Z=Z-ZBIAS
        IF(ISPC.EQ.24)THEN
          ZADJ = .1 - .10273*Z + .00273*Z*Z
          IF(ZADJ .LT. 0.0)ZADJ=0.0
          Z=Z+ZADJ
        ENDIF
        IF(DEBUG)WRITE(JOSTND,*)' I,Z,K,Y1,Y2,DBH(I),FBY1,FBY2= '
        IF(DEBUG)WRITE(JOSTND,*)I,Z,K,Y1,Y2,DBH(I),FBY1,FBY2
!
! YOUNG SMALL LODGEPOLE HTG ACCELLERATOR BASED ON TARGHEE HTG
! TEMP BYPASS
!
        IF((ICYC .GT. 1) .OR. (IAGE .LE. 0))GO TO 184
        IXAGE=IAGE + IY(ICYC) -IY(1)
!
        IF(DEBUG) &
        WRITE(JOSTND,*)' I, ISPC, IXAGE= ',I, ISPC, IXAGE
!
        IF(IXAGE .LT. 40. .AND. IXAGE .GT. 10. .AND. DBH(I) &
           .LT. 9.0)THEN
          IF(Z .GT. 2.0) GO TO 184
          ZADJ=.3564*DG(I)*FINT/YR
          CLOSUR=PCT(I)/100.0
          IF(RELDEN .LT. 100.0)CLOSUR=1.0
          IF(DEBUG)WRITE(JOSTND,9650)ELEV,IXAGE,ZADJ,FINT,YR, &
           DG(I),CLOSUR
 9650     FORMAT('ELEV',F6.1,'AGE',F5.0,'ZADJ', &
          F10.4,'FINT',F6.0,'YR',F6.0,'DG',F10.3,'CLOSUR',F10.1)
          ZADJ=ZADJ*CLOSUR
!
! ADJUSTMENT IS HIGHER FOR LONG CROWNED TREES
!
          IF(IICR .EQ. 9 .OR. IICR .EQ. 8)ZADJ=ZADJ*1.1
          Z=Z + ZADJ
          IF(Z .GT. 2.0)Z=2.0
        END IF
  184   CONTINUE
!
! CALCULATE DIAMETER AFTER 10 YEARS
!
        DIA= DBH(I) + DG(I)/BARK
        IF((XI1 + COF(1,K)) .GT. DIA) GO TO 185
        HTG(I)=0.1
        GO TO 25
  185   CONTINUE
!
!  CALCULATE HEIGHT AFTER 10 YEARS
!
        PSI= COF(8,K)*((DIA-XI1)/(XI1 + COF(1,K) - DIA))**COF(9,K) &
           * (EXP(Z*((1.0 - COF(7,K)**2  ))**0.5/COF(6,K)))
!
        HHT= ((PSI/(1.0 + PSI))* COF(2,K)) + XI2
!
        IF(.NOT. DEBUG)GO TO 191
        WRITE(JOSTND,9631)DBH(I),DIA,HTI,DG(I),Z ,HHT
 9631   FORMAT(1X,'IN HTGF DIA=',F7.3,'DIA+10=',F7.3,'HTI',F7.1, &
        'DIA GR=',F8.3,'Z=',E15.8,'NEW H=',F8.1)
  191   CONTINUE
!
!  CALCULATE HEIGHT GROWTH
!   NEGATIVE HEIGHT GROWTH IS NOT ALLOWED
!
        IF(HHT .LT. HTI) HHT=HTI
        HTG(I)= HHT - HTI
        IF(HTG(I).LT.0.1)HTG(I)=0.1
!
        IF(DEBUG)WRITE(JOSTND,*)' HHT, HTI, HTG(I)= ',HHT, HTI, HTG(I)
   25   CONTINUE
!
      CASE DEFAULT
!----------
!  CALL HTCALC HERE TO CALCULATE POTENTIAL HT GROWTH FOR ALL
!  SPECIES EXCEPT 9, 11, 16, 24 AND 27
!----------
        IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING HTCALC 2'
        CALL HTCALC(IFOR,SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG)
        IF(DEBUG)WRITE(JOSTND,*)' SINDX,ISPC,AGP10,I,HGUESS= '
        IF(DEBUG)WRITE(JOSTND,*) SINDX,ISPC,AGP10,I,HGUESS
!
        POTHTG = HGUESS-SITHT
!
      END SELECT
!----------
!  WB(16) AND AS(24) DO NOT GET MODIFIED HERE
!----------
        IF(ISPC.EQ.16.OR.ISPC.EQ.24) GO TO 999
!
      IF(DEBUG)WRITE(JOSTND,*)' I, ISPC, AGP10, SITHT,HGUESS= ', &
       I, ISPC, AGP10, SITHT,HGUESS
!      IF(DEBUG)WRITE(JOSTND,*)' HTMAX, AGMAX= ',HTMAX, AGMAX
!
 1320 CONTINUE
!----------
!  HEIGHT GROWTH MODIFIERS
!----------
      IF(DEBUG)WRITE(JOSTND,*) ' AT 1320 CONTINUE FOR TREE',I,' HT= ', &
      HT(I),' AVH= ',AVH
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
!-----------
!     REVISED HEIGHT GROWTH MODIFIER APPROACH.
!-----------
!     CROWN RATIO CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
!     GROWTH PEAKS IN MID-RANGE OF CR, DECREASES SOMEWHAT FOR LARGE
!     CROWN RATIOS DUE TO PHOTOSYNTHETIC ENERGY PUT INTO CROWN SUPPORT
!     RATHER THAN HT. GROWTH.  CROWN RATIO FOR THIS COMPUTATION NEEDS
!     TO BE IN (0-1) RANGE; DIVIDE BY 100.  FUNCTION IS HOERL'S
!     SPECIAL FUNCTION (REF. P.23, CUTHBERT&WOOD, FITTING EQNS. TO DATA
!     WILEY, 1971).  FUNCTION OUTPUT CONSTRAINED TO BE 1.0 OR LESS.
!-----------
      HGMDCR = (CRA * (ICR(I)/100.0)**CRB) * EXP(CRC*(ICR(I)/100.0))
      IF (HGMDCR .GT. 1.0) HGMDCR = 1.0
!-----------
!     RELATIVE HEIGHT CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
!     GROWTH IS ENHANCED BY STRONG TOP LIGHT AND HINDERED BY HIGH
!     SHADE EVEN IF SOME LIGHT FILTERS THROUGH.  ALSO RESPONSE IS
!     GREATER FOR GIVEN LIGHT AS SHADE TOLERANCE INCREASES.  FUNCTION
!     IS GENERALIZED CHAPMAN-RICHARDS (REF. P.2 DONNELLY ET AL. 1992.
!     THINNING EVEN-AGED FOREST STANDS...OPTIMAL CONTROL ANALYSES.
!     USDA FOR. SERV. RES. PAPER RM-307).
!     PARTS OF THE GENERALIZED CHAPMAN-RICHARDS FUNCTION USED TO
!     COMPUTE HGMDRH BELOW ARE SEGMENTED INTO FACTORS
!     FOR PROGRAMMING CONVENIENCE.
!-----------
      RHX = RELHT
      FCTRKX = ( (RHK/RHYXS(ISPC))**(RHM(ISPC)-1.0) ) - 1.0
      FCTRRB = -1.0*( RHR(ISPC)/(1.0-RHB(ISPC)) )
      FCTRXB = RHX**(1.0-RHB(ISPC)) - RHXS**(1.0-RHB(ISPC))
      FCTRM  = -1.0/(RHM(ISPC)-1.0)
!
      IF (DEBUG) &
      WRITE(JOSTND,*) ' HTGF-HGMDRH FACTORS = ', &
      ISPC, RHX, FCTRKX, FCTRRB, FCTRXB, FCTRM
!
      HGMDRH = RHK * ( 1.0 + FCTRKX*EXP(FCTRRB*FCTRXB) ) ** FCTRM
!-----------
!     APPLY WEIGHTED MODIFIER VALUES.
!-----------
      WTCR = .25
      WTRH = 1.0 - WTCR
      HTGMOD = WTCR*HGMDCR + WTRH*HGMDRH
!----------
!    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
!    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
!----------
      IF(DEBUG) THEN
        WRITE(JOSTND,*)' IN HTGF, I= ',I,' ISPC= ',ISPC,'HTGMOD= ', &
        HTGMOD,' ICR= ',ICR(I),' HGMDCR= ',HGMDCR
        WRITE(JOSTND,*)' HT(I)= ',HT(I),' AVH= ',AVH,' RELHT= ',RELHT, &
       ' HGMDRH= ',HGMDRH
      ENDIF
!
      IF (HTGMOD .GE. 2.0) HTGMOD= 2.0
      IF (HTGMOD .LE. 0.0) HTGMOD= 0.1
!
 1322 HTG(I) = POTHTG * HTGMOD
!
      HTNOW=HT(I)+POTHTG
      HTNOWMOD=HT(I)+HTG(I)
!      IF(IOPENX.EQ.0)THEN
!        OPEN(89,FILE='HTNOW.OUT',STATUS='UNKNOWN')
!        IOPENX=1
!      ENDIF
!      WRITE(89,*)' ISPC,ICYC,HTNOW,HTNOWMOD= ',ISPC,ICYC,HTNOW,HTNOWMOD
      IF(DEBUG)WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I), &
       POTHTG,BAL,AVH,HTG(I),DBH(I),RMAI,HGUESS
  901 FORMAT(' HTGF',I5,13F9.2)
!
  999 CONTINUE
!-----------
!    HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
!    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT,
!    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
!    CHECK FOR HT GT MAX HT FOR THE SITE AND SPECIES
!----------
      TEMPH=H + HTG(I)
      IF(TEMPH .GT. HTMAX)THEN
        HTG(I)=HTMAX - H
      ENDIF
      IF(HTG(I).LT.0.1)HTG(I)=0.1
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
!
  161 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*) &
      ' I,SCALE,HTG,HTMAX, H= ',I,SCALE,HTG(I),HTMAX, H
!----------
!    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
!    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
!----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
!
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
!
      HTG(ITFN+1)=TEMHTG
!----------
! CHECK FOR SIZE CAP COMPLIANCE.
!----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
!
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
!----------
!   END OF TREE LOOP
!----------
   30 CONTINUE
!----------
!   END OF SPECIES LOOP
!----------
   40 CONTINUE
!
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN
!
      ENTRY HTCONS
!----------
!  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
!  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.
!  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
!----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)= &
          HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
      RETURN
      END
