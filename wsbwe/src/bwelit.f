      SUBROUTINE BWELIT
      use contrl_mod
      use prgprm_mod
      implicit none
C-----------
C  **BWELIT                  DATE OF LAST REVISION:  08/28/13
C-----------
C
C THIS SUBROUTINE IS THE HEART OF THE BUDWORM DEFOLIATION
C  --> BUDLITE <--- MODEL.  IT SIMULATES BUDWORM POPULATION
C DYNAMICS (EXCLUDING ADULT DISPERSAL) AND DEFOLIATION FOR
C ONE YEAR IN ONE STAND.
C
C  K.A. SHEEHAN  USDA-FS, R6-NATURAL RESOURCES, PORTLAND, OR
C
C   CALLED FROM: BWEDR
C
C   SUBROUTINES CALLED:
C
C     BWEWEA - GET WEATHER PARAMETERS FOR CURRENT YEAR
C     BWEDIE - CALC. BUDWORM SURVIVAL
C     BWEP1  - PRINT WITHIN (DETAILED WITHIN-YEAR STUFF)
C     BWEP2  - PRINT CANOPY (% DEFOL AMONG CROWN THIRDS)
C     BWEP3  - PRINT DEFSUM (SUMMARIZE UP TO 5 DEFOL. HISTORIES)
C     BWEP4  - PRINT PARAMS (PARAMETER SUMMARY AND EVENTS TABLE)
C     BWEP5  - PRINT ANNUAL (ANNUAL SUMMARY TABLE)
C     BWEP6  - PRINT DEFOL (ANNUAL DEFOLIATION AND EGG DENSITY)
C     BWEP7  - PRINT DYNAMICS (SUMMARIZE BUDWORM DYNAMICS)
C     BWEP8  - PRINT EFFECTS (SUMMARIZE EFFECTS ON TREES,STAND)
C
C   PARAMETERS:
C
C   A1-A4  - SHOOT ELONGATION PARAM.S FROM BECKWITH & KEMP (1984)
C   ACTNEW - ACTUAL AMOUNT OF NEW FOLIAGE GROWN & NOT EATEN TO DATE
C   AMOUNT - AMT. OF OLD FOLIAGE THAT WOULD BE EATEN BY BUDWORMS IF AVAIL.
C   AVAILO - AMT. OF OLD FOLIAGE AVAILABLE FOR BW TO EAT (SEE OLDMAX)
C   AVEAMT - AVERAGE AMT. OF FOLIAGE EATEN BY A FEMALE LARVAE BY HOST
C   BW     - NO. OF BUDWORMS PRESENT BY CELL
C   BWDISP - TOTAL NO. OF LARVAE THAT DISPERSE (ENTIRE STAND)
C   BWNEW  - NO. OF LARVAE THAT COULD EAT NEW FOLIAGE (GIVEN AMT NEW PRESENT)
C   BWOLD  - NO. OF LARVAE THAT COULD EAT OLD FOLIAGE (GIVEN AMT OLD PRESENT)
C   DEADL  - NO. OF LARVAE THAT DIED (CALC. BY BWEDIE)
C   DEDEAT - AMOUNT OF FOLIAGE CLIPPED BY LARVAE BEFORE THEY DIED
C   DEFNEW - PERCENT OF NEW FOLIAGE THAT IS DEFOLIATED BY BW
C   DEFYRS - NO. OF YEARS WITH >20% DEFOL. BY HOST (THIS OUTBREAK ONLY)
C   DEVEL  - AMT. OF FOL. CLIPPED PER LARVA BY LARVAE THAT LATER DIED (=DEADL)
C   DEVELS - MODIFIER FOR DEVEL FOR THOSE LARVAE KILLED BY SPRAYING
C   DFLUSH - NO. OF DAYS FROM L2 EMERG. TO FIRST BUDFLUSH (CALC. IN BWEWEA)
C   DISP   - STORES NUMBER OF LARVAE DISPERSING OUT OF A GIVEN CELL
C   DISPMR - MORTALITY RATE FOR DISPERSING LARVAE
C   DISPX  - SLIP FUNC. TO CONVERT PROP. OF LARVAE THAT ATE NEW FOLIAGE TO
C               PROP. THAT WILL DISPERSE (X VALUES)
C   DISPY  - SLIP FUNC. TO CONVERT PROP. OF LARVAE THAT ATE NEW FOLIAGE TO
C               PROP. THAT WILL DISPERSE (Y VALUES)
C   EARLYP - PROP. OF LARVAE THAT PUPATE EARLY WHEN NOT ENOUGH NEW FOLIAGE
C   EARLYX - SLIP FUNCT. TO CONVERT RATIO TO PROP. OF LARVAE THAT PUPATE
C            EARLY WHEN THERE ISN'T ENOUGH NEW FOLIAGE (X VALUES)
C   EARLYY - SLIP FUNCT. TO CONVERT RATIO TO PROP. OF LARVAE THAT PUPATE
C            EARLY WHEN THERE ISN'T ENOUGH NEW FOLIAGE (Y VALUES)
C   EATEN  - AMOUNT OF FOLIAGE EATEN BY SMALL OR LARGE LARVAE BY HOST
C   EATFOL - AMT. OF FOLIAGE EATEN BY LARVAE THAT DIED LATER IN THIS TIME STEP
C   ECI    - EFFICIENCY INDEX FOR CONVERTING FOLIAGE TO BIOMASS FOR
C            NEW (1,HOST) OR OLD (2,HOST) FOLIAGE
C   EFFIC  - WEIGHTED EFFICIENCY INDEX (WT.S = PROP. OF LARVAE THAT FED
C            ON NEW AND OLD FOLIAGE
C   EGG1,2 - PARAMS. TO CONVERT PUPAL DRY WT TO NO. OF EGGS
C   EGGDEN - INITIAL EGGS PER M2 (SET IN BLOCK DATA)
C   EGGFEM - NO. OF EGGS PRODUCED PER FEMALE (BY HOST)
C   EGGNEW - STORES THE TOTAL NUMBER OF F1 EGGS PRODUCED IN THIS STAND
C   EGGS   - INITIAL TOTAL NUMBER OF EGGS IN THE STAND
C   FEDOLD - PROP. OF LARVAE THAT FEED ON OLD FOLIAGE IF NOT ENOUGH NEW
C   FEMS   - NO. OF ADULT FEMALES BY CELL
C   FNEW   - AMOUNT OF NEW FOLIAGE PRESENT BY CELL
C   FOLD1  - AMOUNT OF 1-YR OLD FOLIAGE PRESENT BY CELL
C   FOLD2  - AMOUNT OF 2-YR OLD FOLIAGE PRESENT BY CELL
C   FOLQL  - FOLIAGE QUALITY INDEX (SEE FOLWTX,Y)
C   FOLWTX - SLIP FUNCT. TO CONVERT NO. YEARS OF DEFOLIATION (DEFYRS) TO
C            RELATIVE FOLIAGE QUALITY (X VALUES)
C   FOLWTY - SLIP FUNCT. TO CONVERT NO. YEARS OF DEFOLIATION (DEFYRS) TO
C            RELATIVE FOLIAGE QUALITY (Y VALUES)
C   FREM   - AMOUNT OF 3-YR+ OLD FOLIAGE PRESENT BY CELL
C   FRESHC - CONVERTS FRESH PUPAL WTS TO DRY PUPAL WTS BY HOST
C   FWSURV - FALL & OVERWINTER SURVIVAL RATE (SET IN BLOCK DATA)
C   GMAX   - MAX. SHOOT LENGTH (FROM BECKWITH & KEMP 1984, SHEEHAN ET AL.1989)
C   GMIN   - MIN. SHOOT LENGTH (FROM BECKWITH & KEMP 1984, SHEEHAN ET AL.1989)
C   GODISP - TOTAL NUMBER OF BW LARVAE THAT DISPERSE
C   GPERM2 - GRAMS OF FOLIAGE PER M2 (SET IN BLOCK DATA)
C   IDONE  - TRACKS WHETHER FOLIAGE EXPANSION HAS BEEN CALC.FOR THIS HOST
C   IEVENT - BW SPECIAL EVENT TABLE (X,1)=SIMULATION YEAR, (X,2)=HOST SPECIES,
C            (X,3)=CROWN 3RD, (X,4)= EVENT CODE, (X,5)=YEAR OF RAWS WEATHER DATA.
C   INSTSP - PEAK INSTAR TARGETED BY SPRAYING(1=PEAK L4, 2=L5, 3=L6)
C   ISTAGE - LIFE STAGE INDEX: 1=SMALL LARVAE, 2=LARGE LARVAE, 3=PUPAE
C   IYRCUR - CURRENT YEAR (INTEGER)
C   LP1-6  - FLAGS FOR PRINTING TABLES 1-6
C   LFIRST - INDICATES THAT THE NEXT CALL TO BWELIT WILL BE AT THE
C            START OF A NEW OUTBREAK
C   NEVENT - POINTS TO NEXT OPENING IN BW SPECIAL EVENTS TABLE (=IEVENT)
C   OLDFOL - AMOUNT OF OLDER FOLIAGE BY CELL
C   OLDMAX - PROP. OF OLD FOLIAGE THAT IS AVAIL. TO FEEDING LARVAE (BLOCK DATA)
C   OLDX   - SLIP FUNCT. TO CONVERT RATIO TO PROP. OF LARVAE THAT FEED ON
C            OLD FOL. WHEN THERE ISN'T ENOUGH NEW FOLIAGE (X VALUES)
C   OLDY   - SLIP FUNCT. TO CONVERT RATIO TO PROP. OF LARVAE THAT FEED ON
C            OLD FOL. WHEN THERE ISN'T ENOUGH NEW FOLIAGE (Y VALUES)
C   OUT1   - STORES VARIABLES FOR TABLE 1 (SEE P1 FOR DETAILS)
C   OUT2   - STORES VARIABLES FOR TABLE 2 (SEE P2 FOR DETAILS)
C   OUT3   - STORES VARIABLES FOR TABLE 3 (SEE P3 FOR DETAILS)
C   PDISP  - PROP. OF LARVAE THAT DISPERSE DUE TO FOLIAGE SHORTAGE
C   PEXPAN - PROP. OF SHOOT EXPANSION BY CELL
C   PHENOL - RELATIVE PHENOLOGY AMONG CROWN THIRDS & HOSTS (BECKWITH & KEMP)
C   PMATED - PROP. OF ADULT FEMALES THAT MATE
C   POTBW  - POT. NO. OF BW THAT START SEARCHING FOR FOLIAGE IN A GIVEN CELL
C   POTCLP - AMT. OF FOLIAGE THAT WOULD BE CLIPPED IF ALL LARVAE
C            IN THIS CELL WERE ABLE TO EAT NEW FOLIAGE
C   POTNEW - POT. AMOUNT OF NEW FOLIAGE BY CELL
C   PUPAWT - PUPAL DRY WEIGHT BY HOST
C   RATNEW - PROPORTION OF LARVAE THAT ARE ABLE TO EAT NEW FOLIAGE
C   RPHEN  - PHENOLOGY OF EACH HOST RELATIVE TO DOUGLAS-FIR
C   SACTN  - SUMS ACTUAL NEW FOLIAGE BY TREE SPECIES
C   SPOTN  - SUMS POT. NEW FOLIAGE BY TREE SPECIES
C   SPRDIE - PROP. OF DEAD LARVAE (DEADL) THAT DIED DUE TO SPRAYING
C   SRATIO - SEX RATIO OF EMERGING ADULTS
C   SYNCH  - EFFECT OF PHENOLOGY ON EMERG. L2 SURVIVAL (USES BWESLP)
C   SYNCHX - SLIP FUNCTION TO CONVERT ELAPSED DAYS TO BW SURVIVAL (X VALUES)
C   SYNCHY - SLIP FUNCTION TO CONVERT ELAPSED DAYS TO BW SURVIVAL (Y VALUES)
C   TOTALN - TOTAL NEW FOLIAGE IN THIS STAND
C   TOTALO - TOTAL OLDER FOLIAGE IN THIS STAND
C   TOTFN  - TOTAL NEW FOLIAGE AT START OF LARGE LARVAL PERIOD
C   TOTFOL - TOTAL FOLIAGE (NEW + OLD) AT START OF LARGE LARVAL PERIOD
C   TOTL2S - NO. OF L2S THAT SURVIVE WINTER & SEARCH FOR FEEDING SITES
C   TREEDD - DEGREE-DAYS ABOVE 5.5C ACCUMULATED AT L4 (SET IN BWEWEA)
C   WASTED - PROP. OF TOTAL NEW CLIPPED FOLIAGE THAT IS WASTED (SMALL,LARGE L)
C   WASTO  - PROP. OF CLIPPED OLD FOLIAGE THAT IS WASTED)
C   WCOLDW - WEATHER PARAM.: EXTREME WINTER WEATHER (SET IN BWEWEA)
C   WHOTF  - WEATHER PARAM.: L2 MORT. DUE TO PREV.WARM FALL TEMPS (BWEWEA)
C   WRAIND - WEATHER PARAM.: HEAVY RAIN DURING L2 EMERG. (SET IN BWEWEA)
C   WTNFOL - POT. AMT. OF NEW FOLIAGE WT'D BY RELATIVE PHENOLOGY
C
C Revision History:
C   22-MAY-00 Lance David (FHTET)
C      .Added debug handling.
C      .Initialize local variables.
C   06-DEC-00 Lance David (FHTET)
C      .Removed .OR.ISPRAY.EQ.3 from ISPRAY.EQ.2 condition, there is no
C       third spray option.
C   30-AUG-2006 Lance R. David (FHTET)
C      Changed array orientation of IEVENT from (4,250) to (250,4).
C   14-JUL-2010 Lance R. David (FMSC)
C   27-FEB-2012 Lance R. David (FMSC)
C      Added test of host TPA (HOSTST) so that BWESLP is not used to
C      determine dispersal mortality when no host trees are available.
C   26-MAR-2012 Lance R. David (FMSC)
C      Local variable IYRW changed to common variable IWYR
C   28-AUG-2013 Lance R. David (FMSC)
C      Added weather year (if using RAWS) to special events table.
C----------------------------------------------------------------------
C
C     COMMONS
C
      INCLUDE 'BWESTD.F77'
      INCLUDE 'BWECOM.F77'
      INCLUDE 'BWECM2.F77'
      INCLUDE 'BWEBOX.F77'

C     LOCAL VARIABLES
C
      INTEGER I, I1, I2, IC, ICODE, ICROWN, IDONE(6), IH, ISIZE,
     &        ISTAGE, N

      REAL AMOUNT, AVAILO, BWDISP, BWESLP, BWNEW, BWOLD, DEADL,
     &     DEDEAT, DEFNEW, DEFOL, DEFOLD, DISP(9,6), DISPIN, DRYWT,
     &     EARLYP(9,6), EATFOL, EGGFEM, EGGNEW, EGSTAY, EPINDX,
     &     FEDOLD(9,6), FEMS, FOLQL, GODISP

      REAL OLDFOL(9,6), PDISP, PEXPAN(9,6), POTBW, POTCLP,
     &     POTNEW(9,6), PRSTRV, PUPAWT, RATIO, RATNEW(9,6), S,
     &     SACTN(6), SHOOTL, SPOTN(6), SPRDIE, STARVE, SUMPOT,
     &     SYNCH(6), TEMPX, TOTALN, TOTALO, TOTFN, TOTFOL, TOTL2S,
     &     WTNFOL, X

      LOGICAL DEBUG

C
C.... Check for DEBUG
C
      CALL DBCHK(DEBUG,'BWELIT',6,ICYC)

      IF (DEBUG) WRITE (JOSTND,*) 'ENTER BWELIT: ICYC = ',ICYC
C
C     Initialize local varables.
C
C      IWYR = 0

      DO I1 = 1,9
        DO I2 = 1,6
          OLDFOL(I1,I2) = 0.0
          POTNEW(I1,I2) = 0.0
          PEXPAN(I1,I2) = 0.0
          RATNEW(I1,I2) = 0.0
          FEDOLD(I1,I2) = 0.0
          EARLYP(I1,I2) = 0.0
          DISP(I1,I2) = 0.0
        END DO
      END DO

      DO I1 = 1,6
        IDONE(I1) = 0
        SYNCH(I1) = 0.0
        SPOTN(I1) = 0.0
        SACTN(I1) = 0.0
      END DO

C
C IF PREV.YEAR'S DEFOL. IS TO BE USED TO TRIGGER AN INSECTICIDE APPLICATION,
C   FIGURE OUT IF THIS IS A SPRAY YEAR
C
      IF (.NOT.LSPRAY) THEN
         IF (ISPRAY.EQ.2) THEN
            IF (DEFLYR.GE.TRIGGR) THEN
               IF (LIMITS.EQ.1.AND.NUMAPP.EQ.0) THEN
                  LSPRAY=.TRUE.
                  NUMAPP=NUMAPP+1
               ELSEIF (LIMITS.EQ.2) THEN
                  LSPRAY=.TRUE.
                  NUMAPP=NUMAPP+1
               ELSE
                  LSPRAY=.FALSE.
               ENDIF
            ELSE
               LSPRAY=.FALSE.
            ENDIF
         ENDIF
      ENDIF
C
C   CALCULATE/INITIALIZE FOLIAGE AND BW SUMMARY VARIABLES
C
      EGGNEW=0.0
      TOTALO=0.0
      TOTALN=0.0
      WTNFOL=0.0

      DO 20 IC=1,9
        ICROWN=MOD(IC,3)
        IF (ICROWN.EQ.0) ICROWN=3

        DO 20 IH=1,6
          ACTNEW(IC,IH)=0.0
          OLDFOL(IC,IH)=FOLD1(IC,IH)+FOLD2(IC,IH)+FREM(IC,IH)
          POTNEW(IC,IH)=FNEW(IC,IH)
          TOTALN=TOTALN+FNEW(IC,IH)
          TOTALO=TOTALO+OLDFOL(IC,IH)
          WTNFOL=WTNFOL+(POTNEW(IC,IH)*PHENOL(ICROWN,IH))

          DO 10 I=1,17
            OUT1(IC,IH,I)=0.0
            OUT3(IC,IH,I)=0.0
   10     CONTINUE

          DO 15 I=18,20
            OUT3(IC,IH,I)=0.0
   15     CONTINUE

          DISP(IC,IH)=0.0
   20 CONTINUE

      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: OLDFOL=', OLDFOL
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: POTNEW=', POTNEW
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: ACTNEW=', ACTNEW
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: TOTALN=', TOTALN
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: TOTALO=', TOTALO
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: WTNFOL=', WTNFOL

      DO 25 IH=1,6
        SPOTN(IH)=0.0
        SACTN(IH)=0.0
   25 CONTINUE

      IF (TOTALN.LT.1.0.AND.TOTALO.LT.1.0) THEN
         WRITE (JOWSBW,825)
  825    FORMAT ('********   ERROR BWElit 825: yikes! both TOTALN & ',
     &           'TOTALO < 1!')
           GO TO 9000                                                  ! RETURN
      ENDIF
      IF (WTNFOL.LT.1.0) THEN
         WRITE (JOWSBW,830) IYRCUR,WTNFOL
  830    FORMAT (/,'********   WARNING: WT.D NEW FOLIAGE IN YEAR ',
     &       I4,' = ',F9.2)
           GO TO 9000                                                  ! RETURN
      ENDIF
C
C  IF THIS IS THE FIRST YEAR OF AN OUTBREAK, CALC. NUMBER OF EGGS
C  BASED ON EGG DENSITY AND FOLIAGE AMOUNTS PRESENT.
C
      IF (LFIRST) THEN
         EGGS=EGGDEN*(TOTALN+TOTALO)/GPERM2
         LFIRST=.FALSE.
         IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: AT LFIRST EGGS=',EGGS
      ENDIF
C
C  GET WEATHER PARAMETERS FOR THIS YEAR
C  IF WEATHER SOURCE IS 1 OR 2, CALL BWEWEA SUBROUTINE TO GENERATE THE
C  PARAMETERS. OTHERWISE THE WEATHER SOURCE IS 3 (RAWS DATA) AND THE
C  BWPRMS ARRAY HAS BEEN LOADED WITH PARAMETERS GENERATED FROM THE
C  DAILY (BWERAWS SUBROUTINE)
C
      IBUDYR=IBUDYR+1

      IF (IWSRC .EQ. 1 .OR. IWSRC .EQ. 2) THEN
        CALL BWEWEA
      ELSE
C
C       CYCLE THROUGH THE YEARS LOADED IN BWPRMS ARRAY AND
C       START OVER AT YEAR 1 IF AT END OF STORED VALUES (IYRCNT)
C
C       IF (IBUDYR .GT. IYRCNT .OR. IWYR .EQ. IYRCNT) THEN
        IF (IWYR .EQ. IYRCNT) THEN
           IWYR = 1
        ELSE
          IWYR = IWYR + 1
        ENDIF
C
C       Precipitation accumulated for predation mortality purposes
C       during small larvae, large larvae, and pupal periods
C       BWPRMS(7,x), (8,x) and (9,x), effect of heavy rain during
C       L2 emergence is not resolved at this time.
C       See variables WRAINx for descriptions. They are multipliers
C       and remain at their 1.0 initial values (minimum value is 0.8).
C       WHOTF is a multiplier for mortality representing effects of
C       hot fall days determined from degree days above 75 F (23.9 C).
C       It's value is determined using the same method as the WRAINx
C       multipliers (see subroutine BWEMUL in file BWEWEATH.f) which
C       requires a mean (or normal) value and a standard deviation.
C       With the other weather options, those values were based on the
C       multiple year weather stream, but did that particular weather
C       stream represent a period of normal? Can't say.
C       Since we are using actual and not simulated weather, we need
C       mean and standard deviation values for these degree days and
C       precipitation values.
C       Lance David, 5/18/2011
C
        DAYS(1)= BWPRMS(1,IWYR)
        DAYS(2)= BWPRMS(2,IWYR)
        DAYS(3)= BWPRMS(3,IWYR)
C       WHOTF  = BWPRMS(4,IWYR)
        DFLUSH = BWPRMS(5,IWYR)
        TREEDD = BWPRMS(6,IWYR)
C       WRAINx = BWPRMS(7,IWYR)
C       WRAINx = BWPRMS(8,IWYR)
C       WRAINx = BWPRMS(9,IWYR)
C       WRAIND = BWPRMS(10,IWYR)

        IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: IBUDYR=',IBUDYR,
     &  ' IWYR=',IWYR,' RAWS YR=',BWPRMS(11,IWYR),' IYRCNT=',IYRCNT

      ENDIF
C
C CALCULATE BUDWORM SURVIVAL FOR EGGS THROUGH EMERGING L2S
C IF THERE IS LESS THAN 1.0 BUDWORM IN THE STAND, THEN RETURN
C
      TOTL2S=EGGS*FWSURV*WCOLDW
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: TOTL2S=',TOTL2S
      IF (TOTL2S.LT.1.0) GO TO 9000                                  ! RETURN
C
      DO 34 IH=1,6
   34 IDONE(IH)=0
C
C DISTRIBUTE EMERGING L2'S TO FOLIAGE BASED ON AMOUNTS OF NEW
C FOLIAGE WEIGHTED BY RELATIVE PHENOLOGY (PHENOL, BASED ON BECKWITH
C AND KEMP (1984)).
C

      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: POTNEW=',POTNEW

      DO 100 IC=1,9
      ICROWN=MOD(IC,3)
      ISIZE=(IC/3)+1
      IF (ICROWN.EQ.0) THEN
        ICROWN=3
        ISIZE=ISIZE-1
      ENDIF

      DO 100 IH=1,6
C
      IF (POTNEW(IC,IH).LT.1.0) GO TO 100
      TEMPX=(POTNEW(IC,IH)*PHENOL(ICROWN,IH)/WTNFOL)
      POTBW=TOTL2S*TEMPX
c      POTBW=TOTL2S*(POTNEW(IC,IH)*PHENOL(ICROWN,IH)/WTNFOL)
C
C  SAVE INITIAL NUMBER OF EGGS BY TREE SIZE CLASS FOR OUTPUT
C    ALSO POTENTIAL NEW & TOTAL FOLIAGE
C
      OUT2(IH,ISIZE,1)=OUT2(IH,ISIZE,1)+(EGGS*POTNEW(IC,IH)/
     *   TOTALN)
      OUT2(IH,ISIZE,6)=OUT2(IH,ISIZE,6)+POTNEW(IC,IH)
      OUT2(IH,ISIZE,7)=OUT2(IH,ISIZE,7)+OLDFOL(IC,IH)+POTNEW(IC,IH)
      OUT3(IC,IH,1)=EGGS*POTNEW(IC,IH)/TOTALN
      OUT3(IC,IH,10)=POTNEW(IC,IH)
      OUT3(IC,IH,11)=OLDFOL(IC,IH)+POTNEW(IC,IH)
C
C  CALCULATE RELATIVE SYNCHRONY BETWEEN HOST & BUDWORM. DFLUSH =
C     NUMBER OF DAYS FROM L2 EMERGENCE TO FIRST BUDFLUSH (CALC.
C     ACCORDING TO THOMSON ET AL 1984).  DFLUSH IS THEN MODIFIED
C     TO REFLECT PHENOLOGY OF EACH HOST RELATIVE TO DF (STORED
C     IN RPHEN).  A SLIP FUNCTION IS USED TO CONVERT ELAPSED DAYS
C     (DFLUSH) TO A LARVAL SURVIVAL RATE (DATA-FREE ASSUMPTION!).
C
      IF (IDONE(IH).EQ.0) THEN
        IDONE(IH)=1
        DFLUSH=DFLUSH*RPHEN(IH)
        IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: DFLUSH= ',DFLUSH

        SYNCH(IH)=BWESLP(DFLUSH,SYNCHX,SYNCHY,6)

        IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: SYNCH(IH)= ',SYNCH(IH)

        IF (SYNCH(IH).GE.0.90.OR.SYNCH(IH).LE.0.40) THEN
           IF (LP4) THEN
             NEVENT=NEVENT+1
             IF (NEVENT.GT.250) THEN
               WRITE (JOBWP4,8250)
               LP4=.FALSE.
             ELSE
               IEVENT(NEVENT,1)=IYRCUR
               IEVENT(NEVENT,2)=IH
               IEVENT(NEVENT,3)=0
               ICODE=9
               IF (SYNCH(IH).LE.0.40) ICODE=10
               IEVENT(NEVENT,4)=ICODE
C              weather year is reported only if RAWS data is in use
               IF (IWSRC .EQ. 3) THEN
                 IEVENT(NEVENT,5)=BWPRMS(11,IWYR)
               ELSE
                 IEVENT(NEVENT,5)=0
               ENDIF
             ENDIF
           ENDIF
           IF (SYNCH(IH).GE.0.90) IOUT6A(2)='100'
           IF (SYNCH(IH).LE.0.40) IOUT6A(1)='100'
        ENDIF
      ENDIF
C
C  CALCULATE BUDWORM SURVIVAL WHEN SEARCHING FOR FEEDING SITES
C
      BW(IC,IH)=POTBW*SYNCH(IH)*WRAIND*WHOTF
      IF (DEBUG) THEN
        WRITE (JOSTND,*) 'IN BWELIT: IC,IH,BW(IC,IH)=',IC,IH,BW(IC,IH)
        WRITE (JOSTND,*) '           POTBW,SYNCH(IH)=',POTBW,SYNCH(IH)
        WRITE (JOSTND,*) '           WRAIND,WHOTF=',WRAIND,WHOTF
      ENDIF
      OUT3(IC,IH,2)=OUT3(IC,IH,1)-BW(IC,IH)
C
C  CALCULATE % SHOOT ELONGATION AT MID-L4 BASED ON SHOOT GROWTH
C  MODELS OF BECKWITH & KEMP (1984)FOREST SCIENCE 30(3):743-746
C  AS SUMMARIZED IN SHEEHAN ET AL. (1989) TABLE 14.  GF PARAM.S
C  ARE USED FOR WF AND SAF, DF PARAM.S ARE USED FOR ES AND WL.
C  SET FOLIAGE PRESENT BASED ON % SHOOT ELONGATION.
C
C  TREEDD = DEGREE-DAYS ABOVE 5.5 C ACCUMULATED AT L4
C    FOR SMALL TREES (LEVELS 1-3), INCREASE DD EXPERIENCED BY 10%
C    (SUGGESTION FROM BC FOLKS - TEST FOR SENSITIVITY LATER)
C
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: TREEDD= ',TREEDD,
     *  ' A1, A2, A3, A4=',A1(IC,IH),A2(IC,IH),A3(IC,IH),A4(IC,IH)

      IF (IC.GE.4) THEN
        SHOOTL=A4(IC,IH)+(A1(IC,IH)/(1.0+EXP(A2(IC,IH)+
     *   (A3(IC,IH)*TREEDD))))
      ELSE
        X=TREEDD*1.1
        IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: X= ',X
        SHOOTL=A4(IC,IH)+(A1(IC,IH)/(1.0+EXP(A2(IC,IH)+
     *   (A3(IC,IH)*X))))
      ENDIF
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: SHOOTL= ',SHOOTL
      PEXPAN(IC,IH)=((SHOOTL-GMIN(IC,IH))/
     *   (GMAX(IC,IH)-GMIN(IC,IH)))
        ACTNEW(IC,IH)=POTNEW(IC,IH)*PEXPAN(IC,IH)
C
C  SAVE INITIAL FOLIAGE & BW FOR OUTPUT TABLES (P1)
C
      OUT1(IC,IH,10)=ACTNEW(IC,IH)
      OUT1(IC,IH,11)=OLDFOL(IC,IH)
      OUT1(IC,IH,1)=BW(IC,IH)
C
C CALCULATE SURVIVAL OF SMALL LARVAE
C
      GODISP=0.0
      CALL BWEDIE (1,IC,IH,EATFOL,GODISP,SPRDIE,DEADL)
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: EATFOL.1= ',EATFOL
C
C  FEED THOSE SURVIVING SMALL LARVAE
C
      POTCLP=(BW(IC,IH)*EATEN(1,IH)/(1.0-WASTED(1)))+EATFOL
      IF (POTCLP.LE.ACTNEW(IC,IH)) THEN
         ACTNEW(IC,IH)=ACTNEW(IC,IH)-POTCLP
C
C        IF NO BUDWORMS ARE LEFT, REMOVE FOLIAGE EATEN BY LARVAE THAT
C        LATER DIED & THEN GO ON TO NEXT CROWN THIRD
C
      ELSEIF (BW(IC,IH).LT.1.0) THEN
         ACTNEW(IC,IH)=ACTNEW(IC,IH)-EATFOL
         IF (ACTNEW(IC,IH).LT.0.0) ACTNEW(IC,IH)=0.0
C
C        IF THERE STILL ISN'T ENOUGH NEW FOLIAGE FOR EVERYONE,
C        MORE LARVAE MUST STARVE!
C        SENT A NOTE TO THE SPECIAL EVENTS TABLE
C
      ELSE
        PRSTRV=OUT1(IC,IH,4)/(OUT1(IC,IH,4)+BW(IC,IH))
         IF (EATFOL.GT.(ACTNEW(IC,IH)*0.9)) EATFOL=EATFOL*PRSTRV
         BWNEW=(ACTNEW(IC,IH)-EATFOL)*(1.0-WASTED(1))/EATEN(1,IH)
         IF (BWNEW.LT.0.0) BWNEW=0.0
         STARVE=BW(IC,IH)-BWNEW
         BW(IC,IH)=BWNEW
         OUT1(IC,IH,4)=OUT1(IC,IH,4)+STARVE
         OUT3(IC,IH,3)=OUT3(IC,IH,3)+STARVE
         IF (LP4) THEN
           NEVENT=NEVENT+1
           IF (NEVENT.GT.250) THEN
             WRITE (JOBWP4,8250)
 8250        FORMAT ('********   ERROR - WSBW: MORE THAN 250 ENTRIES!')
             LP4=.FALSE.
           ELSE
             IEVENT(NEVENT,1)=IYRCUR
             IEVENT(NEVENT,2)=IH
             IEVENT(NEVENT,3)=IC
             IEVENT(NEVENT,4)=3
C            weather year is reported only if RAWS data is in use
             IF (IWSRC .EQ. 3) THEN
               IEVENT(NEVENT,5)=BWPRMS(11,IWYR)
             ELSE
               IEVENT(NEVENT,5)=0
             ENDIF
           ENDIF
         ENDIF
         ACTNEW(IC,IH)=0.0
      ENDIF
C
C  CALC. CURRENT DEFOL. & SAVE FOR OUTPUT TABLE (P1)
C
      IF (OUT1(IC,IH,10).LE.0.0) THEN
         OUT1(IC,IH,12)=-1.0
      ELSE
         OUT1(IC,IH,12)=100.0*(1.0-(ACTNEW(IC,IH)/OUT1(IC,IH,10)))
      ENDIF
      IF (OUT1(IC,IH,11).LE.0.0) THEN
         OUT1(IC,IH,13)=-1.0
      ELSE
         OUT1(IC,IH,13)=0.0
      ENDIF
C
  100 CONTINUE

      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: ACTNEW= ',ACTNEW
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: BW= ',BW
C
C  CALL OUTPUT TABLE P1 TO REPORT SMALL LARVAL INFO
C
      ISTAGE=1
      IF (LP1) CALL BWEP1(ISTAGE,IYRCUR)
C
C START DEALING WITH LARGE LARVAE (MID-L4 THROUGH L6)
C
      TOTFN=0.0
      TOTFOL=0.0
      BWDISP=0.0

      DO 120 IC=1,9
      DO 120 IH=1,6
C
C CALC. FOLIAGE POTENTIALLY PRESENT PRIOR TO L6 FEEDING
C
      IF (POTNEW(IC,IH).LT.1.0) GO TO 120
      ACTNEW(IC,IH)=ACTNEW(IC,IH)+((1.0-PEXPAN(IC,IH))*POTNEW(IC,IH))
C
C SAVE INITIAL FOLIAGE & BW FOR OUTPUT TABLE (P1)
C
      OUT1(IC,IH,10)=ACTNEW(IC,IH)
      OUT1(IC,IH,11)=OLDFOL(IC,IH)
      OUT1(IC,IH,1)=BW(IC,IH)
C
C SUM THE AMOUNT OF FOLIAGE THAT BW WOULD AFFECT IF ALL ATE NEW FOL.
C THE NUMBER OF BW THAT DON'T GET TO EAT NEW FOLIAGE IS STORED IN
C BWDISP. ALSO, CALC. TOTAL NEW FOLIAGE (TOTALN) AND TOTAL
C FOLIAGE (TOTALF) IN CASE LARVAE DO DISPERSE. WEIGHT THESE FOLIAGE
C TOTALS BY THE DIRECTIONAL PREFERENCE OF DISPERSING LARVAE (DISPDR)
C
      POTCLP=BW(IC,IH)*EATEN(2,IH)/(1.0-WASTED(2))
      TOTFN=TOTFN+(ACTNEW(IC,IH)*DISPDR(IC))
      TOTFOL=TOTFOL+((ACTNEW(IC,IH)+OLDFOL(IC,IH))*DISPDR(IC))
      IF (POTCLP.GT.ACTNEW(IC,IH)) THEN
         BWNEW=ACTNEW(IC,IH)*(1.0-WASTED(2))/EATEN(2,IH)
         RATIO=1.0
         IF (BW(IC,IH).GE.1.0) RATIO=BWNEW/BW(IC,IH)
         IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: RATIO= ',RATIO
         IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: DISPX(2)= ',DISPX
         IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: DISPY(2)= ',DISPY
         PDISP=BWESLP(RATIO,DISPX,DISPY,2)
         IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: PDISP= ',PDISP
         IF (PDISP.GT.0.0) THEN
            DISP(IC,IH)=BW(IC,IH)*PDISP
            BWDISP=BWDISP+DISP(IC,IH)
            BW(IC,IH)=BW(IC,IH)-DISP(IC,IH)
            OUT1(IC,IH,2)=-DISP(IC,IH)
         ENDIF
         IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: RATIO= ',RATIO
      ENDIF
C
  120 CONTINUE
C
C     IF THERE ARE NO HOST TREES, DISPERSAL MORTALITY WILL BE 1.0
C
      IF (HOSTST .EQ. 0.0) THEN
      	 DISPMR=1.0
      ELSE
         DISPMR=BWESLP(HOSTST,DISPMX,DISPMY,4)
      ENDIF

      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: DISPMR= ',DISPMR,
     *           ' HOSTST = ',HOSTST
C
      DO 140 IC=1,9
      DO 140 IH=1,6
      RATNEW(IC,IH)=1.0
      FEDOLD(IC,IH)=0.0
      EARLYP(IC,IH)=0.0
      IF (POTNEW(IC,IH).LT.1.0) GO TO 140
C
C  IF ANY LARVAE DISPERSED, ADD THEM BACK IN
C
      IF (BWDISP.GT.0.0) THEN
         IF (TOTFN.GT.1.0) THEN
            DISPIN=BWDISP*ACTNEW(IC,IH)*DISPDR(IC)/TOTFN
         ELSEIF (TOTFOL.GT.1.0) THEN
            DISPIN=BWDISP*(ACTNEW(IC,IH)+OLDFOL(IC,IH))*
     *            DISPDR(IC)/TOTFOL
         ELSE
            WRITE (JOWSBW,125)
  125       FORMAT ('YIKE! RAN OUT OF ALL FOLIAGE!!! DO SOMETHING!')
         ENDIF
         BW(IC,IH)=BW(IC,IH)+(DISPIN*(1.0-DISPMR))
         OUT1(IC,IH,2)=OUT1(IC,IH,2)+(DISPIN*(1.0-DISPMR))
         OUT1(IC,IH,3)=DISPIN*DISPMR
         OUT3(IC,IH,5)=OUT3(IC,IH,5)+(DISPIN*DISPMR)
      ENDIF

      IF (BW(IC,IH).LT.1.0) GO TO 140
C
C CALCULATE SURVIVAL OF LARGE LARVAE
C
      GODISP=OUT1(IC,IH,3)
      CALL BWEDIE(2,IC,IH,EATFOL,GODISP,SPRDIE,DEADL)
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: EATFOL.2= ',EATFOL
C
C  CALC. LARGE LARVAE FEEDING
C
C  RECALC. POTCLP - BW PROBABLY HAS CHANGED
C  IF ENOUGH NEW FOLIAGE IS PRESENT, ALL LARVAE EAT THAT.
C  OTHERWISE, SOME LARVAE FEED ON NEW FOLIAGE, OTHERS FEED ON
C  OLDER FOLIAGE, PUPATE EARLY (& PRODUCE FEWER EGGS).
C  STARVING LARVAE HAVE ALREADY BEEN KILLED OFF...
C
      IF (BW(IC,IH).LT.1.0) GO TO 130
C
C  CALC. AMOUNT OF FOLIAGE CLIPPED BY LARVAE BEFORE THEY DIED.  DEADL
C  = NO. OF LARVAE THAT DIED, SPRDIE = PROP. OF THOSE LARVAE THAT
C  WERE KILLED BY INSECTICIDE, DEVEL= PROP. OF FOLIAGE CONSUMED PER
C  LARGE LARVA THAT IS EATEN BY LARVAE THAT LATER DIED.
C  ASSUME THAT ON AVERAGE, LARVAE       DIED AT MIDPOINT
C   OF LARGE LARVAL PERIOD (441 DD), WHICH IS CLOSE TO
C  THEN END OF L5S (437 DD); DEVEL THEREFORE = (.5* L4 AMT CONSUMED +
C  L5 AMT CONSUMED) / TOTAL AMT CONSUMED PER LARGE LARVA
C  DEVELS(INSTSP) = AMT OF FOLIAGE CONSUMED BY LARVAE
C  THAT WERE LATER KILLED BY SPRAYING AT PEAK INSTAR INSTSP (1=PEAK L4,
C  DEVELS= 0.0; 2=PEAK L5, DEVELS=.20 OF TOTAL; 3=PEAK L6, DEVELS=.69
C  OF TOTAL AMOUNT CONSUMED BY LARGE LARVAE).
C
      DEDEAT=((DEVEL*(1.0-SPRDIE)*DEADL)+(DEVELS(INSTSP)*SPRDIE
     *   *DEADL))*EATEN(2,IH)/(1.0-WASTED(2))
C
C  IF NEARLY ALL OF THE FOLIAGE WOULD BE EATEN BY LARVAE THAT
C  LATER DIED, DECREASE THE AMOUNT EATEN BY DYING LARVAE SLIGHTLY
C  SO THAT SOME FOLIAGE MIGHT REMAIN FOR SURVIVING LARVAE
C
      PRSTRV=DEADL/(DEADL+BW(IC,IH))
      IF (DEDEAT.GT.(ACTNEW(IC,IH)*0.9)) DEDEAT=DEDEAT*PRSTRV
C
      POTCLP=(BW(IC,IH)*EATEN(2,IH)/(1.0-WASTED(2)))+DEDEAT
      IF (ACTNEW(IC,IH).GT.POTCLP) THEN
         ACTNEW(IC,IH)=ACTNEW(IC,IH)-POTCLP
      ELSE
         BWNEW=(ACTNEW(IC,IH)-DEDEAT)*(1.0-WASTED(2))/EATEN(2,IH)
         IF (BWNEW.LT.0.0) BWNEW=0.0
         ACTNEW(IC,IH)=0.0
         RATNEW(IC,IH)=BWNEW/BW(IC,IH)
         IF (RATNEW(IC,IH).GT.1.0) RATNEW(IC,IH)=1.0
         FEDOLD(IC,IH)=BWESLP(RATNEW(IC,IH),OLDX,OLDY,3)
         EARLYP(IC,IH)=1.0-RATNEW(IC,IH)-FEDOLD(IC,IH)
         X=RATNEW(IC,IH)+EARLYP(IC,IH)+FEDOLD(IC,IH)
         IF (X.NE.1.0) THEN
           RATNEW(IC,IH)=RATNEW(IC,IH)-(RATNEW(IC,IH)*(X-1.0)/X)
           EARLYP(IC,IH)=EARLYP(IC,IH)-(EARLYP(IC,IH)*(X-1.0)/X)
           FEDOLD(IC,IH)=FEDOLD(IC,IH)-(FEDOLD(IC,IH)*(X-1.0)/X)
         ENDIF
      ENDIF
      OUT1(IC,IH,15)=100.0*RATNEW(IC,IH)
      OUT1(IC,IH,16)=100.0*FEDOLD(IC,IH)
      OUT1(IC,IH,17)=100.0*EARLYP(IC,IH)
C
C CALCULATE DEFOLIATION.  IF BW FED ON OLDER FOLIAGE, THEN
C CALC. THE TOTAL AMT. OF OLDER FOLIAGE EATEN & DISTRIBUTE
C DEFOLIATION AMONG FOLIAGE AGE CLASSES IN PROPORTION TO THE
C RELATIVE AMOUNTS OF FOLIAGE PRESENT IN EACH AGE CLASS.
C
  130 CONTINUE
      DEFNEW=100.0*(1.0-(ACTNEW(IC,IH)/POTNEW(IC,IH)))
      OUT1(IC,IH,12)=DEFNEW
      FNEW(IC,IH)=FNEW(IC,IH)*(1.0-(DEFNEW/100.0))
      DEFOLD=0.0
      OUT1(IC,IH,13)=DEFOLD
      IF (FEDOLD(IC,IH).NE.0) THEN
         AMOUNT=BW(IC,IH)*FEDOLD(IC,IH)*EATEN(2,IH)/(1.0-WASTO)
         AVAILO=OLDFOL(IC,IH)*OLDMAX
         IF (AMOUNT.GE.AVAILO) THEN
            BWOLD=AVAILO*(1.0-WASTO)/EATEN(2,IH)
            OLDFOL(IC,IH)=OLDFOL(IC,IH)*(1.0-OLDMAX)
            DEFOLD=100.0*OLDMAX
            X=BW(IC,IH)-BWOLD
            IF (X.LT.0.0) X=BW(IC,IH)
            OUT1(IC,IH,4)=OUT1(IC,IH,4)+X
            OUT3(IC,IH,5)=OUT3(IC,IH,5)+X
            BW(IC,IH)=BW(IC,IH)-X
         ELSE
            DEFOLD=100.0*AMOUNT/OLDFOL(IC,IH)
            OLDFOL(IC,IH)=OLDFOL(IC,IH)-AMOUNT
         ENDIF
         OUT1(IC,IH,13)=DEFOLD
         FOLD1(IC,IH)=FOLD1(IC,IH)*(1.0-(DEFOLD/100.0))
         FOLD2(IC,IH)=FOLD2(IC,IH)*(1.0-(DEFOLD/100.0))
         FREM(IC,IH)=FREM(IC,IH)*(1.0-(DEFOLD/100.0))
      ENDIF
C
C  SUM THE TOTAL ACTUAL NEW FOLIAGE (SACTN) AND POTENTIAL NEW
C  FOLIAGE (SPOTN) -- WILL BE USED LATER TO CALCULATE % DEFOLIATION
C  BY HOST (WHICH IS IN TURN MAY BE USED TO CHANGE PARASITISM RATES
C  AND FOLIAGE QUALITY EFFECTS ON LARVAL DEVELOPMENT AND PUPAL WTS.).
C
      SACTN(IH)=SACTN(IH)+ACTNEW(IC,IH)
      SPOTN(IH)=SPOTN(IH)+POTNEW(IC,IH)
C
  140 CONTINUE

      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: BW=',BW
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: SACTN=',SACTN
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: SPOTN=',SPOTN
C
C  CALC. % DEFOLIATION BY HOST; IF >20%, INCREMENT DEFYRS(IH)
C  ALSO CALC. DEFLYR - DEFOL. WT'D BY SPOTN (USED AS TRIGGER FOR INSECT.APP.
C  SAVE THESE DEFOL.S IF LP3 = TRUE (PRINT DEFOL. GRAPHS)
C
      SUMPOT=0.0
      DEFLYR=0.0
      DO 145 IH=1,5
      DEFOL=0.0
      IF (SPOTN(IH).GT.0.0) DEFOL=100.0*(SPOTN(IH)-SACTN(IH))/SPOTN(IH)
      IF (DEFOL.GT.20.0) DEFYRS(IH)=DEFYRS(IH)+1.0
      IF (IDEFPR.EQ.1.AND.IDEFSP(IH).EQ.1) IDEF(IBUDYR,IH)=NINT(DEFOL)
      SUMPOT=SUMPOT+SPOTN(IH)
      DEFLYR=DEFLYR+(DEFOL*SPOTN(IH))
  145 CONTINUE
      IF (DEBUG) WRITE (JOSTND,*)
     &  'IN BWELIT: DEFLYR, SUMPOT=',DEFLYR,SUMPOT
      IF (SUMPOT.GT.0.0) THEN
        DEFLYR=DEFLYR/SUMPOT
      ELSE
        DEFLYR=0.0
      ENDIF
      IF (IDEFPR.EQ.2) IDEF(IBUDYR,NUMCOL)=DEFLYR
      IF (IDEFPR.NE.0) WRITE (JOBWP3,150) IYRCUR,(IDEF(IBUDYR,N),
     *   N=1,NUMCOL)
  150 FORMAT (I4,4X,5(I4,6X))

C
C  IF APPROPRIATE, INCREMENT THE COUNTER FOR CONSECUTIVE YRS OF LOW DEFOL
C
      IF (DEFLYR.LE.10.0) THEN
         LOWYRS=LOWYRS+1
      ELSE
         LOWYRS=0
      ENDIF
C
C  PRINT P1 OUTPUT TABLE FOR LARGE LARVAE, STORE INIT. BW FOR NEXT STG
C
      ISTAGE=2
      IF (LP1) CALL BWEP1 (ISTAGE,IYRCUR)
C
      EGGS=0.0
      DO 160 IC=1,9
C
      ICROWN=MOD(IC,3)
      ISIZE=(IC/3)+1
      IF (ICROWN.EQ.0) ISIZE=ISIZE-1
C
      DO 160 IH=1,6
      OUT2(IH,ISIZE,4)=OUT2(IH,ISIZE,4)+ACTNEW(IC,IH)
      OUT2(IH,ISIZE,5)=OUT2(IH,ISIZE,5)+FOLD1(IC,IH)+FOLD2(IC,IH)+
     *   FREM(IC,IH)+ACTNEW(IC,IH)
      OUT3(IC,IH,8)=FNEW(IC,IH)
      OUT3(IC,IH,9)=FNEW(IC,IH)+FOLD1(IC,IH)+FOLD2(IC,IH)+FREM(IC,IH)
      IF (BW(IC,IH).LT.1.0) GO TO 160
      OUT1(IC,IH,1)=BW(IC,IH)
C
C  CALC. PUPAL SURVIVAL
C
      GODISP=0.0
      CALL BWEDIE(3,IC,IH,EATFOL,GODISP,SPRDIE,DEADL)
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWELIT: EATFOL.3= ',EATFOL
C
C  CALC. INITIAL NO. OF EGGS LAID IN STAND OF ORIGIN &
C  "DISPERSING" EGGS.  START BY CALCULATING THE MEAN
C  FEMALE PUPAL WEIGHT (=AMT.FOLIAGE EATEN PER LARVA *
C  ECI (VARIES WITH HOST & % OF TOTAL FOLIAGE EATEN THAT IS NEW) *
C  FRESH-TO-DRY PUPAL WT. CONVERSION). CONVERT PUPAL WEIGHT FROM
C  G TO MG.
C
C      EFFIC=(RATNEW(IC,IH)*ECI(1,IH))+((1.0-RATNEW(IC,IH))*ECI(2,IH))
      FOLQL=BWESLP(DEFYRS(IH),FOLWTX,FOLWTY,4)
      EPINDX=BWESLP(EARLYP(IC,IH),EWTX,EWTY,4)
      DRYWT=(RATNEW(IC,IH)*AVEAMT(IH)*ECI(1,IH))+
     *      (FEDOLD(IC,IH)*AVEAMT(IH)*ECI(2,IH))+
     *      (EARLYP(IC,IH)*AVEAMT(IH)*ECI(1,IH)*EPINDX)
      PUPAWT=DRYWT*FRESHC(IH)*1000.*FOLQL
      OUT3(IC,IH,15)=PUPAWT
      FEMS=BW(IC,IH)*SRATIO*PMATED
      OUT3(IC,IH,14)=FEMS
      EGGFEM=(PUPAWT*EGG1(IH))+EGG2(IH)
      OUT3(IC,IH,16)=EGGFEM
C
C TOTAL NUMBER OF EGGS PRODUCED IN STAND = # FEMALES * # EGGS/FEMALE
C   * SURVIVAL RATE OF NEWLY EMERGED ADULTS (MORT. RATE = ADMORT -->
C   REFLECTS THOSE EATEN BY NEs BEFORE EGGS LAID, INCLEMENT WEATHER, ETC.
C   EGGNEW = TOTAL NUMBER OF EGGS PRODUCED, EGSTAY = EGGS THAT STAY IN
C   THIS STAND, EGDISP = EGGS THAT MAY DISPERSE AMONG STANDS
C   EGGS = TOTAL EGGS THAT WILL BE LAID IN THIS STAND (ACCUMULATES LOCAL
C   EGGS NOW, DISPERSING EGGS WILL BE ADDED LATER AFTER ALL STANDS ARE
C   PROCESSED).
C
      EGGNEW=FEMS*EGGFEM*(1.0-ADMORT)
      EGSTAY=FEMS*(1.0-ADMORT)*EPMASS
      EGGS=EGGS+EGSTAY
      EGDISP=EGGNEW-EGSTAY
C
C FOR NOW (SINGLE STAND VERSION), ADD DISPERSING EGGS BACK TO "EGGS"
C  LATER, WILL NEED TO DISPERSE THESE EGGS AMONG STANDS AFTER EACH
C  STAND HAS BEEN PROCESSED FOR A GIVEN YEAR.
C
      EGGS=EGGS+EGDISP
C
C  SAVE NO. OF EGGS PRODUCED BY TREE SIZE CLASS FOR OUTPUT
C  ALSO SAVE NO. OF ADULTS
C
      OUT2(IH,ISIZE,2)=OUT2(IH,ISIZE,2)+EGGNEW
      OUT2(IH,ISIZE,8)=OUT2(IH,ISIZE,8)+BW(IC,IH)
      OUT3(IC,IH,13)=BW(IC,IH)
      OUT3(IC,IH,12)=EGGNEW
  160 CONTINUE
C
C PRINT OUTPUT TABLES P1 AND P2
C
      ISTAGE=3
      IF (LP1) CALL BWEP1(ISTAGE,IYRCUR)
      IF (LP5 .OR. LP6 .OR. LP2 .OR. LP7) CALL BWEP3
C
 9000 CONTINUE
      IF (DEBUG) WRITE (JOSTND,*) 'EXIT BWELIT: ICYC = ',ICYC
      RETURN
      END
