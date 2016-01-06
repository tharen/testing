      SUBROUTINE EVTSTV (IUSERV)
      use plot_mod
      use arrays_mod
      use contrl_mod
      use outcom_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     CALLED FROM EVMON, LOADS AND MAINTAINS THE TEST VARIABLE TABLES.
C
C     EVENT MONITOR ROUTINE - NL CROOKSTON - AUG 1982 - MOSCOW, ID
C
C     IUSERV=0 FOR NORMAL CALLS AND 1 WHEN THIS ROUTINE IS BEING ASKED
C            TO JUST COMPUTE THE USER DEFINED VARIABLES. IF GT 1, THEN
C            THIS IS A YEAR AND USER DEFINED VARIABLES ONLY SCHEDULED
C            EXACTLY FOR THE YEAR ARE COMPUTED.
C            IF LT 0, THEN ONLY DEFINE TYPE 1 VARIABLES.
C
C     ENTRY POINTS:
C     EVTSTV CALLED BY EVMON, AS STATED ABOVE.
C     EVSET4 CALLED BY VARIOUS ROUTINES TO SAVE SPECIFIC VARIABLES.
C     EVUST4 CALLED BY VARIOUS ROUTINES TO SET THE STATUS OF A
C            VARIABLE TO UNSET.
C     EVGET4 CALLED TO GET THE VALUE OF A STORED VARIABLE.
C
      INCLUDE 'OPCOM.F77'
C
      INCLUDE 'SUMTAB.F77'
C
      LOGICAL LDEB,LDEB2,LSET
      CHARACTER VVER*7
      INTEGER MYACT(3)
      REAL PRM(3)
      INTEGER IUSERV,I,IDMR,NTODO,ITODO,NP,IACTK,IDAT,ITS5,LOCOD,IRC
      INTEGER ISET,IVAL
      REAL VSET,VALUE,X,TADWBA,CURVOL,ZERO,AGE,DMRSUM,PRBSUM,FINDX,CRD
C
      DATA MYACT/33,101,102/
C
C     SEE IF WE NEED WRITE DEBUG.
C
      CALL DBCHK (LDEB,'EVTSTV',6,ICYC)
C
C     THE VARIABLES FOR EACH GROUP ARE DEFINED AS FOLLOWS:
C
C     GROUP 1, SET IN PHASE 1 AND ALWAYS KNOWN.
C
C     101 YEAR      BEGINNING CYCLE YEAR.
C     102 AGE       AGE AT CYCLE BEGINNING YEAR.
C     103 BTPA      BEFORE THIN TREES PER ACRE
C     104 BTCUFT    BEFORE THIN TOTAL CUFT
C     105 BMCUFT    BEFORE THIN MERCH CUFT
C     106 BBDFT     BEFORE THIN BD FOOT VOL
C     107 BBA       BEFORE THIN BASAL AREA
C     108 BCCF      BEFORE THIN CCF
C     109 BTOPHT    BEFORE THIN AVERAGE DOM HT
C     110 BADBH     BEFORE THIN QUADRATIC MEAN DBH
C     111 YES       A CONSTANT EQUAL TO 1.
C     112 NO        A CONSTANT EQUAL TO 0.
C     113 CYCLE     CYCLE NUMBER.
C     114 NUMTREES  NUMBER OF TREE RECORDS.
C     115 BSDIMAX   BEFORE THIN SDI MAX
C     116 BSDI      BEFORE CUT STAND DENSITY INDEX.
C     117 BRDEN     BEFORE CUT RELATIVE DENSITY (CURTIS)
C     118 BRDEN2    BEFORE CUT RELATIVE DENSITY (SILVAH)
C
C     126 HABTYPE   STAND HABITAT TYPE AS USED BY THE MODEL.
C     127 SLOPE     STAND SLOPE CODE (RECODED FROM INPUT).
C     128 ASPECT    STAND ASPECT CODE (RECODED FROM INPUT, CONVERTED
C                   TO RADIANS IN TRNASP.F AND INTO DEGREES(IASPEC)HERE.
C     129 ELEV      STAND ELEV CODE (RECODED FROM INPUT).
C     130 SAMPWT    STAND SAMPLING WEIGHT.
C     131 INVYEAR   INVENTORY YEAR.
C     132 CENDYEAR  END YEAR OF CURRENT CYCLE.
C     133 EVPHASE   EVENT MONITOR PHASE NUMBER.
C     134 SMR       STAND MISTLETOE RATING
C     135 SITE      STAND SITE INDEX FOR SITE SPECIES
C     136 CUT       0, BEFORE CUT OR IF STAND IS NOT CUT, 1 IF
C                   STAND IS CUT (CAN ONLY BE 1.0 AFTER CUTS, PHASE 2).
C     137 LAT       STAND LATITUDE (RECORDED FROM INPUT).
C     138 LONG      STAND LONGITUDE (RECORDED FROM INPUT).
C     139 STATE     STAND LOCATION, STATE (RECORDED FROM INPUT)
C     140 COUNTY    STAND LOCATION, COUNTY (RECORDED FROM INPUT)
C     141 FORTYP    FOREST TYPE CODE BASED ON FIA NATIONAL ALGORITHM
C     142 SIZCLS    STAND SIZE CLASS BASED ON FIA NATIONAL ALGORITHM
C     143 STKCLS    STOCKING CLASS BASED ON FIA NAIONAL ALGORITHM
C     144 PROPSTK   PROPORTION OF THE STAND CONSIDERED STOCKABLE
C     145 MAI       MEAN ANNUAL INCREMENT, BEGINNING OF CYCLE
C     146 AGECMP    STAND AGE COMPUTED FROM SIZE CLASS AND ABIRTH
C     147 BDBHWTBA  BEFORE CUT AVERAGE DBH OF OVERSTORY TREES (FOR INFORMS)
C     148 SILVAHFT  FOREST TYPE ACCORDING TO SILVAH DEFINITIONS
C     149 FISHERIN  R5 FISHER HABITAT SUITABILITY INDEX
C     150 BSDI2     ZEIDE SUMMATION BEFORE CUT STAND DENSITY INDEX.
C
C     GROUP 2, SET IN PHASE 2, AFTER THIN.
C
C     201 ATPA      AFTER THIN TREES PER ACRE
C     202 ATCUFT    AFTER THIN TOTAL CUFT
C     203 AMCUFT    AFTER THIN MERCH CUFT
C     204 ABDFT     AFTER THIN BOARD FOOT VOL.
C     205 ABA       AFTER THIN BASAL AREA
C     206 ACCF      AFTER THIN CCF
C     207 ATOPHT    AFTER THIN AVERAGE DOM HT
C     208 AADBH     AFTER THIN QUADRATIC MEAN DBH.
C     209 RTPA      REMOVED TREES PER ACRE
C     210 RTCUFT    REMOVED TOTAL CUFT
C     211 RMCUFT    REMOVED MERCH CUFT
C     212 RBDFT     REMOVED BDFT
C     213 ASDIMAX   AFTER THIN SDI MAX
C     214 ASDI      AFTER THIN STAND DENSITY INDEX
C     215 ARDEN     AFTER THIN RELATIVE DENSITY (CURTIS)
C     216 ADBHWTBA  AFTER CUT AVERAGE DBH OF OVERSTORY TREES (FOR INFORMS)
C     217 ARDEN2    AFTER THIN RELATIVE DENSITY (SILVAH)
C     218 ASDI2     ZEIDE SUMMATION AFTER THIN STAND DENSITY INDEX
C
C     GROUP 3, THOSE KNOWN AFTER CYCLE 1.
C
C     301 ACC       ACCREATION FROM LAST CYCLE
C     302 MORT      MORTALITY FROM LAST CYCLE
C     303 PAI       PERIODIC ANNUAL INCREMENT, BEGINNING OF CYCLE
C     304 VACANT SPOT --- USED TO BE MAI WHICH IS NOW A TYPE 1 VARIABLE
C     305 DTPA      DELTA TPA, CHANGE IN TREES PER ACRE FROM LAST CYCLE
C     306 DTPA%     DELTA TPA IN PERCENT
C     307 DBA       DELTA BASAL AREA
C     308 DBA%      DELTA BA IN PERCENT
C     309 DCCF      DELTA CCF
C     310 DCCF%     DELTA CCF IN PERCENT
C
C     GROUP 4, THOSE KNOWN WHEN THE SETTING ROUTINE SAYS SO, AND
C     NOT KNOWN THE REST OF THE TIME.
C
C     401 TM%STND   PERCENT STAND DEFOLIATION CAUSED BY TUSSOCK MOTH
C     402 TM%DF     PERCENT DOUGLAS-FIR DEF. CAUSED BY TM
C     403 TM%GF     PERCENT GRAND FIR DEF. CAUSED BY TM
C     404 MPBTPAK   TREES PER ACRE KILLED BY MOUNTAIN PINE BEETLE (MP)
C     405 BW%STND   PERCENT STAND DEFOLIATION CAUSED BY BUDWORM (BW)
C     406 MPBPROB   PROBABILITY OF MPB OUTBREAK
C     407-415       PPE
C     416 BSCLASS   BEFORE THIN STRUCTURAL CLASS (MUST HAVE STRCLASS ON)
C     417 ASCLASS   AFTER THIN STRUCTURAL CLASS (MUST HAVE STRCLASS ON)
C     418 BSTRDBH   BEFORE THIN DBH OF UPPERMOST STRATUM (STRCLASS ON)
C     419 ASTRDBH   AFTER THIN DBH OF UPPERMOST STRATUM (STRCLASS ON)
C     420 FIRE      0 IF STAND HAS NO FIRE, 1 IF FIRE OCCURS (FM)
C     421 MINSOIL   PERCENTAGE OF MINERAL SOIL EXPOSURE; -1 INITIALLY (FM)
C     422 CROWNIDX  CROWNING INDEX FROM POTENTIAL FIRE REPT (FM)
C     423 FIREYEAR  CALENDAR YEAR OF LAST FIRE; -1 INITIALLY (FM)
C     424 BCANCOV   BEFORE THIN CANOPY COVER (STRCLASS ON)
C     425 ACANCOV   AFTER THIN CANOPY COVER (STRCLASS ON)
C     426 CRBASEHT  CROWN BASE HT FROM POTENTIAL FIRE REPT (FM)
C     427 TORCHIDX  TORCHING INDEX FROM POTENTIAL FIRE REPT (FM)
C     428 CRBULKDN  CROWN BULK DENSITY FROM POTENTIAL FIRE REPT (FM)
C     430 DISCCOST  DISCOUNTED TOTAL ACCUMULATED COSTS (ECON)
C     431 DISCREVN  DISCOUNTED TOTAL ACCUMULATED REVENUES (ECON)
C     432 FORSTVAL  PRESENT VALUE OF FOREST, LAND AND TREES (ECON)
C     433 HARVCOST  UNDISCOUNTED TOTAL HARVEST COSTS (ECON)
C     434 HARVREVN  UNDISCOUNTED TOTAL HARVEST REVENUES (ECON)
C     435 IRR       INTERNAL RATE OF RETURN (ECON)
C     436 PCTCOST   UNDISCOUNTED TOTAL PRE-COMMERCIAL THINNING COSTS (ECON)
C     437 PNV       PRESENT NET VALUE (ECON)
C     438 RPRODVAL  PRESENT VALUE OF TREES OR REPRODUCTION (ECON)
C     439 SEV       COMPUTED SOIL EXPECTATION VALUE (ECON)
C     440 BMAXHS    BEFORE THIN TALLEST HT, UPPERMOST STRATUM (STRCLASS)
C     441 AMAXHS    AFTER THIN TALLEST HT, UPPERMOST STRATUM  (STRCLASS)
C     442 BMINHS    BEFORE THIN SHORTEST HT, UPPERMOST STRATUM(STRCLASS)
C     443 AMINHS    AFTER THIN SHORTEST HT, UPPERMOST STRATUM (STRCLASS)
C     444 BNUMSS    BEFORE THIN TOTAL NUMBER OF STRATUM       (STRCLASS)
C     445 ANUMSS    AFTER THIN TOTAL NUMBER OF STRATUM        (STRCLASS)
C     446 DISCRATE  DISCOUNT RATE (ECON)
C     447 UNDISCST  UNDISCOUNTED TOTAL ACCUMULATED COSTS (ECON)
C     448 UNDISRVN  UNDISCOUNTED TOTAL ACCUMULATED REVENUES (ECON)
C     449 ECCUFT    CUBIC FEET VALUED BY ECON (ECON)
C     450 ECBDFT    BOARD FEET VALUED BY ECON (ECON)
C
C     SEE THE PPE HARVEST ROUTINES FOR "SELECTED" (ITEM 9) AND
C     PPLDEV FOR ITEMS 10 TO 16.
C
C     GROUP 5 ARE USER DEFINED.
C
      IF (LDEB) WRITE (JOSTND,1) IUSERV,ICYC
    1 FORMAT (' IN EVTSTV,IUSERV=',I4,' ICYC=',I4)
      IF (IUSERV.GE.1) GOTO 20
C
C     LOAD VARIABLES IN GROUP ONE, THOSE SET IN PHASE 1 AND ALWAYS KNOWN
C
      IF (IUSERV.LT.0) THEN
        IPHASE=1
        BTSDIX=0
        SDIBC=0
        SDIBC2=0
      ELSE
        IF (IPHASE.GT.1) GOTO 10
      ENDIF
      IF (LDEB) WRITE (JOSTND,91) IPHASE,ICYC
   91 FORMAT (' IN EVTSTV,IPHASE,ICYC=',2I4)
      TSTV1(1)=IY(MAX(1,ICYC))
      TSTV1(2)=IAGE+IY(MAX(1,ICYC))-IY(1)
      IF(LDEB)WRITE(JOSTND,*)' ICYC,IAGE,IY(ICYC),IY(1),TSTV102= ',
     &ICYC,IAGE,IY(MAX(1,ICYC)),IY(1),TSTV1(2)
      TSTV1(3)=TPROB/GROSPC
      TSTV1(4)=OCVCUR(7)/GROSPC
      TSTV1(5)=OMCCUR(7)/GROSPC
      TSTV1(6)=OBFCUR(7)/GROSPC
      TSTV1(7)=BA/GROSPC
      TSTV1(8)=RELDEN
      TSTV1(9)=AVH
      TSTV1(10)=RMSQD
      TSTV1(11)=1.0
      TSTV1(12)=0.0
      TSTV1(13)=ICYC
      TSTV1(14)=ITRN
      TSTV1(15)=BTSDIX
      TSTV1(16)=SDIBC
      IF(RMSQD .EQ. 0.)THEN
        TSTV1(17)=0.
      ELSE
        TSTV1(17)=TSTV1(7)/(TSTV1(10)**0.5)
      ENDIF
      CALL RDCLS2(0,0.,999.,1,CRD,0)
      TSTV1(18)=CRD/GROSPC
      DO 6 I=1,MAXSP
      BCCFSP(I)=RELDSP(I)
    6 CONTINUE
      IF (ICYC.LE.1) THEN
         TSTV1(27)=ISLOP
         TSTV1(28)=IASPEC
         TSTV1(29)=ELEV*100.
         TSTV1(30)=SAMWT
         TSTV1(31)=IY(1)
         TSTV1(37)=TLAT
         TSTV1(38)=TLONG
         TSTV1(39)=ISTATE
         TSTV1(40)=ICNTY
      ENDIF
      TSTV1(26)=ICL5
      TSTV1(32)=IY(MAX(1,ICYC)+1)-1
      TSTV1(33)=IPHASE
      TSTV1(34)=0.0
      TSTV1(41)=IFORTP
      TSTV1(42)=ISZCL
      TSTV1(43)=ISTCL
      TSTV1(44)=1./GROSPC
      TSTV1(45)=0. !initialize so debug output is consistent.
      TSTV1(46)=ICAGE
      TSTV1(47)=0. !initialize so debug output is consistent.
      TSTV1(48)=ISILFT
      CALL FISHER(FINDX)
      TSTV1(49)=FINDX
      TSTV1(50)=SDIBC2
      IF(ITRN .GE. 1) THEN
        PRBSUM=0.
        DMRSUM=0.
        DO 7 I=1,ITRN
        CALL MISGET (I,IDMR)
        PRBSUM=PRBSUM+PROB(I)
        DMRSUM=DMRSUM+FLOAT(IDMR)*PROB(I)
    7   CONTINUE
        IF(PRBSUM .LT. 0.000001)THEN
          TSTV1(34)=0.
        ELSE
          TSTV1(34)=DMRSUM/PRBSUM
        ENDIF
      ENDIF
      IF (ISISP.GT.0) THEN
         TSTV1(35)=STNDSI
      ELSE
         TSTV1(35)=0.0
      ENDIF
      TSTV1(36)=0.
      IF (LDEB) WRITE (JOSTND,92) (I,TSTV1(I),I=1,50)
   92 FORMAT (' TSTV1='/10(I3,E11.3))
      IF (IUSERV.LT.0) RETURN
C----------
C  MAI LOGIC
C  MAIFLG IS 1 WHEN: 1) INITIAL STAND AGE IS 0 AND INITIAL TPA IS NOT 0,
C  OR 2) STAND AGE GETS RESET TO 0 AND THE STAND WAS NOT CLEARCUT.
C  NEWSTD IS 1 WHEN A NEW STAND IS INITIATED SUCH AS AFTER CLEARCUTTING
C  OR IN A BARE GROUND PLANT SCENARIO.
C  IF MAIFLG IS 1 AND NEWSTD IS 0, THE MAI CALCULATION IS SHUT OFF.
C
C  LOAD CYCLE 1 MAI VALUE FOR THE SUMMARY TABLE OUTPUT
C
      CALL VARVER (VVER)
      IF(ICYC.EQ.1) THEN
        IF(TSTV1(2).GT.0.)THEN
          IF((VVER(:2) .EQ. 'CS') .OR. (VVER(:2) .EQ. 'LS') .OR.
     1      (VVER(:2) .EQ. 'NE') .OR. (VVER(:2) .EQ. 'OZ') .OR.
     2      (VVER(:2) .EQ. 'SE') .OR. (VVER(:2) .EQ. 'SN')) THEN
            BCYMAI(ICYC)=IOSUM(4,ICYC)/TSTV1(2)
          ELSE
            BCYMAI(ICYC)=IOSUM(5,ICYC)/TSTV1(2)
          ENDIF
        ELSE
          BCYMAI(ICYC)=0.
C
C  AGE AT BEGINNING IS 0. IF TPA IS ALSO ZERO, SET NEW STAND FLAG TO 1,
C  IF TPA IS NOT ZERO, SET MAIFLG TO 1 TO SHUT OFF MAI CALCULATION.
C
          IF(TSTV1(3).EQ.0.)THEN
            NEWSTD=1
          ELSE
            MAIFLG=1
          ENDIF
        ENDIF
        TSTV1(45)=BCYMAI(ICYC)
        AGELST=TSTV1(2)
C
C  LOAD MAI FOR CYCLES 2 AND BEYOND. ZERO IS A VARIABLE TO TEST WHETHER
C  THE AGE HAS BEEN RESET TO ZERO. IN THIS CASE, START THE REMOVALS
C  ACCUMULATION OVER.
C
      ELSE
        AGE = TSTV1(2)
        ZERO = AGE - (IY(ICYC)-IY(ICYC-1))
        IF(AGE .LT. AGELST) TOTREM = 0.0
        IF(LDEB)WRITE(JOSTND,*)' AGE,AGELST,TOTREM= ',AGE,AGELST,TOTREM
        IF(LDEB)WRITE(JOSTND,*)' ICYC,IAGE,MAIFLG,NEWSTD,VVER= ',
     &   ICYC,IAGE,MAIFLG,NEWSTD,VVER
C
C  IF AGE HAS BEEN RESET TO 0, OR INITIAL EXISTING STAND CAME IN WITH
C  A ZERO AGE, SET MAI TO ZERO. ALSO IF THE AGE WAS SET TO 0 AND A
C  CLEARCUT DID NOT HAPPEN, SET MAIFLG TO SHUT OFF MAI CALCULATIONS.
C
        IF(ZERO.EQ.0.0 .OR. (MAIFLG.EQ.1 .AND. NEWSTD.NE.1)) THEN
          BCYMAI(ICYC) = 0.
          IF(NEWSTD.EQ.0)MAIFLG = 1
          GO TO 11
        ENDIF
C
C  IN THE FOLLOWING CALCULATIONS, IF AGE WAS RESET DON'T INCLUDE LAST
C  CYCLES REMOVALS IN THE MAI CALCULATION.
C
        IF ((VVER(:2) .EQ. 'CS') .OR. (VVER(:2) .EQ. 'LS') .OR.
     1      (VVER(:2) .EQ. 'NE') .OR. (VVER(:2) .EQ. 'OZ') .OR.
     2      (VVER(:2) .EQ. 'SE') .OR. (VVER(:2) .EQ. 'SN')) THEN
          CURVOL=IOSUM(4,ICYC)
          IF(AGE .GT. AGELST)TOTREM=IOSUM(8,ICYC-1)+TOTREM
          BCYMAI(ICYC)=(TOTREM + CURVOL )/AGE
          IF(LDEB)WRITE(JOSTND,*)' CURVOL,TOTREM,AGE,BCYMAI= ',
     &     CURVOL,TOTREM,AGE,BCYMAI(ICYC)
        ELSE
          CURVOL=IOSUM(5,ICYC)
          IF(AGE .GT. AGELST)TOTREM=IOSUM(9,ICYC-1)+TOTREM
          BCYMAI(ICYC)=(TOTREM + CURVOL )/AGE
          IF(LDEB)WRITE(JOSTND,*)' CURVOL,TOTREM,AGE,BCYMAI= ',
     &     CURVOL,TOTREM,AGE,BCYMAI(ICYC)
        ENDIF
   11   CONTINUE
C
C  IF AFTER TREATMENT VALUES FROM PREVIOUS CYCLE SHOW A CLEARCUT,
C  SET NEW STAND FLAG AND START REMOVALS ACCUMULATION OVER.
C
        IF(LDEB)WRITE(JOSTND,*)' TSTV205,TSTV206,TSTV214,TSTV209= ',
     &   TSTV2(5),TSTV2(6),TSTV2(14),TSTV2(9)
        IF(TSTV2(5).EQ.0 .AND. TSTV2(6).EQ.0 .AND.
     *    TSTV2(14).EQ.0 .AND. TSTV2(9).GT.0) THEN
          NEWSTD = 1
          TOTREM = 0.0
        ENDIF
C
C  IF AGE WAS RESET TO ZERO AND TPA IS ZERO, SET NEW STAND FLAG.
C
        IF(ZERO .EQ. 0.0 .AND. TSTV1(3) .EQ. 0.0) NEWSTD=1
C
        TSTV1(45)=BCYMAI(ICYC)
        AGELST=AGE
      ENDIF
C
C  END OF MAI LOGIC
C----------
      TADWBA=0.
      DO 60 I=1,ITRN
      TADWBA = TADWBA + (DBH(I)**3.)*0.0054542*PROB(I)
   60 CONTINUE
      TSTV1(47)=0.
      IF(BA.GT.0.0 .AND. GROSPC.GT.0.0) TSTV1(47)=(TADWBA/BA)
C----------
C
C     IF PAST CYCLE 1, SET GROUP 3 VARIABLES, THOSE KNOWN IN PHASE 1,
C     ONLY AFTER CYCLE 1.
C
      IF (ICYC.LE.1) GOTO 20
      TSTV3(1)=IOSUM(15,ICYC-1)
      TSTV3(2)=IOSUM(16,ICYC-1)
      TSTV3(3)=TSTV3(1)-TSTV3(2)
      TSTV3(4)=0.
      TSTV3(5)=TPROB/GROSPC-FLOAT(IOSUM(3,ICYC-1))
      TSTV3(6)=0.
      X=FLOAT(IOSUM(3,ICYC-1))
      IF (X.GT.0.) TSTV3(6)=TPROB/GROSPC/X*100.
      TSTV3(7)=BA/GROSPC-FLOAT(IOLDBA(ICYC-1))
      TSTV3(8)=0.
      X=FLOAT(IOLDBA(ICYC-1))
      IF (X.GT.0.) TSTV3(8)=BA/GROSPC/X*100.
      TSTV3(9)=RELDEN/GROSPC-FLOAT(IBTCCF(ICYC-1))
      TSTV3(10)=0.
      X=FLOAT(IBTCCF(ICYC-1))
      IF (X.GT.0.) TSTV3(10)=RELDEN/GROSPC/X*100.
      IF (LDEB) WRITE (JOSTND,93) (TSTV3(I),I=1,10)
   93 FORMAT (' TSTV3(1/10)=',10E11.3)
      GOTO 20
   10 CONTINUE
C
C     LOAD PHASE...A GROUP 1 VARIABLE THAT CHANGES BETWEEN PHASES
C
      TSTV1(33)=IPHASE
      TSTV1(48)=ISILFT
      IF(ONTREM(7) .GT. 0.)THEN
        CALL FISHER(FINDX)
        TSTV1(49)=FINDX
      ENDIF
C
C     LOAD GROUP 2 VALUES, THOSE KNOWN AFTER THIN EVERY CYCLE.
C
      TSTV1(14)=ITRN
      IF (ONTREM(7).GT.0.0) TSTV1(36)=1.0
      TSTV2(1)=TPROB/GROSPC
      TSTV2(5)=BA/GROSPC
      TSTV2(6)=RELDEN
      TSTV2(7)=AVH
      TSTV2(8)=RMSQD
      TSTV2(9)=ONTREM(7)/GROSPC
      TSTV2(10)=OCVREM(7)/GROSPC
      TSTV2(11)=OMCREM(7)/GROSPC
      TSTV2(12)=OBFREM(7)/GROSPC
      DO 16 I=1,MAXSP
      ACCFSP(I)=RELDSP(I)
   16 CONTINUE
      TSTV2(13)=ATSDIX
      TSTV2(14)=SDIAC
      TSTV2(18)=SDIAC2
      IF(RMSQD .EQ. 0.)THEN
        TSTV2(15)=0.
      ELSE
        TSTV2(15)=TSTV2(5)/(TSTV2(8)**0.5)
      ENDIF
      TSTV2(2)=(OCVCUR(7)-OCVREM(7))/GROSPC
      TSTV2(3)=(OMCCUR(7)-OMCREM(7))/GROSPC
      TSTV2(4)=(OBFCUR(7)-OBFREM(7))/GROSPC
      IF (LDEB) WRITE (JOSTND,94) (TSTV2(I),I=1,14)
   94 FORMAT (' TSTV2=',10E11.3)
C
      TADWBA=0.
      DO 70 I=1,ITRN
      TADWBA = TADWBA + (DBH(I)**3.)*0.0054542*PROB(I)
   70 CONTINUE
      TSTV2(16)=0.
      IF(BA.GT.0.0 .AND. GROSPC.GT.0.0)TSTV2(16)=(TADWBA/BA)
      CALL RDCLS2(0,0.,999.,1,CRD,0)
      TSTV2(17)=CRD/GROSPC
C
C     LOAD GROUP 5 VARIABLES.
C
   20 CONTINUE
      IF (IUSERV.GT.1) IPHASE=2
C
C     FIND OUT IF ANY COMPUTE ACTIVITIES ARE SCHEDULED.
C
      CALL OPFIND (3,MYACT,NTODO)
      IF (LDEB) WRITE (JOSTND,21) NTODO
   21 FORMAT (/' IN EVTSTV; NTODO: ',I4)
C
C     BRANCH TO NEXT GROUP IF THERE ARE NONE.
C
      IF (NTODO.EQ.0) GOTO 50
C
C     SET UP THE DEBUG SWITCH FOR ALGEVL.
C
      CALL DBCHK (LDEB2,'ALGEVL',6,ICYC)
C
C     GET THE COMPUTE PARMS AND BE READY TO "DO" THEM.
C
      DO 30 ITODO=1,NTODO
      CALL OPGET(ITODO,3,IDAT,IACTK,NP,PRM)
      IF (IUSERV.GT.1 .AND. IUSERV.NE.IDAT) GOTO 30
      IF (LDEB) WRITE (JOSTND,25) ITODO,IACTK
   25 FORMAT(' IN EVTSTV: ITODO=',I4,' IACTK=',I4)
      IF (IACTK.LT.0) GOTO 30
      IF (IACTK.EQ.33) THEN
C
C        A POINTER TO THE OP CODE IS PRM(3) AND A POINTER TO THE ENTRY
C        IN TSTV5 IS PRM(2).
C
         ITS5 =IFIX(PRM(2))
         IF (ITS5.GT.500) ITS5=ITS5-500
         LOCOD=IFIX(PRM(3))
C
C        COMPUTE THE VALUE OF THE EXPRESSION.
C
         CALL ALGEVL (LREG,MXLREG,XREG,MXXREG,IEVCOD(LOCOD),
     >                MAXCOD-LOCOD+1,IY(1),IY(ICYC),LDEB2,JOSTND,IRC)
C
C        TAKE ACTION BASED ON THE RETURN CODE:
C        IRC=0: COMPUTATION OK, STORE ANSWER, SIGNAL ACTIVITY "DONE".
C        IRC=1: REFERENCE TO UNDEFINED VARIABLE, SET THIS VARIABLE
C               UNDEFINED, BRANCH TO NEXT.
C        IRC>1: SOME MAJOR PROBLEM, SET THIS VARIABLE UNDEFINED,
C               SIGNAL ACTIVITY "DELETED OR CANCELED", ISSUE ERROR MSG.
C
         IF (IRC.EQ.0) THEN
            TSTV5(ITS5)=XREG(1)
            LTSTV5(ITS5)=.TRUE.
            PARMS(IACT(IPTODO(ITODO),2))=XREG(1)
            I=IY(ICYC)
            IF (IUSERV.GT.1 .AND. IUSERV.EQ.IDAT) I=IUSERV
            CALL OPDONE (ITODO,I)
         ELSEIF (IRC.EQ.1) THEN
            LTSTV5(ITS5)=.FALSE.
         ELSE
            LTSTV5(ITS5)=.FALSE.
            CALL OPDEL1 (ITODO)
         ENDIF
         IF (LDEB) WRITE (JOSTND,26) ITS5,LOCOD,LTSTV5(ITS5),
     >                               TSTV5(ITS5),CTSTV5(ITS5),IRC
   26    FORMAT(' IN EVTSTV: ITS5=',I4,' LOCOD=',I4,' LTSTV5=',L2,
     >          ' TSTV5=',E15.7,' CTSTV5(ITS5)= ',A,' IRC=',I2)
      ELSE
C
C        INTERACT WITH THE DBS EXTENSION TO STORE AND GET DATA.
C
         CALL DBSEVM (ITODO,IACTK,IY(ICYC),JOSTND)
      ENDIF
   30 CONTINUE
   50 CONTINUE
      IF (IUSERV.EQ.1) RETURN
C
C     LOAD THE VARIABLES INTO THE EVENT MONITOR THAT PPE MUST LOAD.
C
      CALL PPLDEV
      RETURN
C
      ENTRY EVSET4 (ISET,VALUE)
      TSTV4(ISET)=VALUE
      LTSTV4(ISET)=.TRUE.
      RETURN
C
      ENTRY EVUST4 (ISET)
      LTSTV4(ISET)=.FALSE.
      RETURN
C
      ENTRY EVGET4 (IVAL,VSET,LSET)
      VSET = TSTV4(IVAL)
      LSET  = LTSTV4(IVAL)
      RETURN
      END

