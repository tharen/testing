      SUBROUTINE BWEDAM (TOTP,TOTR,AVPRBO)
      IMPLICIT NONE
C----------
C  **BWEDAM             DATE OF LAST REVISION:  06/17/13
C----------
C
C     ANNUAL FOLIAGE DAMAGE MODEL.
C
C     PART OF THE WESTERN SPRUCE BUDWORM MODEL.
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JANUARY 1984
C     TOP KILL LOGIC ADDED MARCH 1989.
C
C     CALLED FROM :
C
C       BWEDR - DRIVE THE BUDWORM MODEL FOR ONE STAND IN ONE YEAR.
C
C     PARAMETERS :
C
C     TOTP   - TOTAL POTENTIAL FOLIAGE, INPUT
C     TOTR   - TOTAL REMAINING FOLIAGE, INPUT
C     AVPRBO - AVERAGE PROPORTION RETAINED BIOMASS, OUTPUT
C
C Revision History:
C   18-MAY-2000 Lance R. David (FHTET)
C      .Previous noted dates of change 06/10/91 and 7/29/96 KA Sheehan.
C      .Added debug handling. Debug is the only reason PRGPRM.F77 
C       and CONTROL.F77 FVS common files are included.
C   16-OCT-2006 Lance R. David (FHTET)
C      .Added stand ID to Damage report header.
C   14-JUL-2010 Lance R. David (FMSC)
C       Added IMPLICIT NONE and declared variables as needed.
C----------------------------------------------------------------------
C
COMMONS
C
      INCLUDE 'PRGPRM.F77'
      INCLUDE 'CONTRL.F77'
      INCLUDE 'PLOT.F77'
      INCLUDE 'BWESTD.F77'
      INCLUDE 'BWECOM.F77'
C
COMMONS
C
      CHARACTER*4 ISZC(3),ISPC(6)
      LOGICAL DEBUG
      INTEGER I, ICROWN, IFIFTH, IHOST, INRUN, ISZI 
      REAL AVPRBO(6,3,2), CU, DIV, RDDS, RHTG, STHTGR(6), STREES,
     &     TOTP(6,3), TOTR(6,3), XFIFTH, XMULT

      DATA ISZC/'SMAL','MED','LARG'/
      DATA ISPC/'WF','DF','GF','AF','ES','WL'/
      DATA STHTGR/-2.3661,-2.4757,-2.0008,-2.3661,-2.9171,0.0/
C
C     ********************** EXECUTION BEGINS **************************
C

C
C.... Check for DEBUG
C
      CALL DBCHK(DEBUG,'BWEDAM',6,ICYC)

      IF (DEBUG) WRITE (JOSTND,*) 'ENTER BWEDAM: ICYC = ',ICYC
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWEDAM: TOTP = ',TOTP
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWEDAM: TOTR = ',TOTR
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWEDAM: AVPRBO = ',AVPRBO

C     CHECK THE TREES PER ACRE ARRAY, IF THERE ARE NO TREES, THEN:
C     BRANCH TO EXIT.
C
      STREES=0.0
      DO 20 IHOST=1,6
      IF (IFHOST(IHOST).NE.1) GOTO 20
      DO 10 ISZI=1,3
      STREES=STREES+BWTPHA(IHOST,ISZI)
   10 CONTINUE
   20 CONTINUE
      IF (STREES .EQ. 0.0) GOTO 350
C
C     UPDATE THE YEAR POINTER FOR THE CUMULATIVE AND AVERAGE CURRENT
C     DEFOLIATION ARRAYS.  THIS UPDATING LOOKS TRICKY...IT IS DESIGNED
C     TO ALLOW CUMDEF AND APRBYR TO HOLD THE LAST 5 YEARS OF CUMULATIVE
C     DEFOLIATION AT ONE TIME.  THE ORDER, HOWEVER IS NOT IMPORTANT AND
C     THEREFORE NOT MAINTAINED.
C
      IF (NCUMYR.LT.5) THEN
         NCUMYR=NCUMYR+1
         ICUMYR=NCUMYR
      ELSE
         ICUMYR=ICUMYR+1
         IF (ICUMYR.GT.5) ICUMYR=1
      ENDIF
C
C     DO FOR ALL HOSTS
C
      DO 50 IHOST=1,6
      IF (IFHOST(IHOST).EQ.0) GOTO 50
      DO 30 ISZI=1,3
      IF (BWTPHA(IHOST,ISZI).LE.0.0) GOTO 30
C
C     COMPUTE THE CUMULATIVE DEFOLIATION FOR THE YEAR, LOAD INTO THE
C     APPROPRIATE SECTION OF CUMDEF FOR THIS YEAR.
C
      DIV=TOTP(IHOST,ISZI)
      CU=0.
      IF (DIV.GT..00001) CU=100.-((TOTR(IHOST,ISZI)/DIV)*100.)
      IF (CU.LT.0.0) CU=0.0
      CUMDEF(IHOST,ISZI,ICUMYR)=CU
C
C     COMPUTE THE AVERAGE PROPORTION OF RETAINED BIOMASS ARRAY (PRBIO).
C     NOTE THAT ITYPE=1 IS THE TOP OF THE TREES ONLY, ITYPE=2 IS
C     THE WHOLE TREE.
C
      APRBYR(IHOST,ISZI,1,ICUMYR)=PRBIO(IHOST,3*ISZI-2,1)
      APRBYR(IHOST,ISZI,2,ICUMYR)=0.
   30 CONTINUE
      DO 40 ICROWN=1,9
      ISZI=(ICROWN+2)/3
      IF (BWTPHA(IHOST,ISZI).LE.0.0) GOTO 40
      APRBYR(IHOST,ISZI,2,ICUMYR)=APRBYR(IHOST,ISZI,2,ICUMYR)+
     >                     (PRBIO(IHOST,ICROWN,1)*.3333333)
   40 CONTINUE
   50 CONTINUE
C
C     COMPUTE THE CUMULATIVE (5-YR MAX) DEFOLIATION TO DATE
C     AND AVERAGE THE PROPORTION OF RETAINED BIOMASS (CDEF AND
C     AVPRBO ARE INITIALIZED ZERO IN CALLING ROUTINE).
C
      DO 90 IHOST=1,6
      IF (IFHOST(IHOST).EQ.0) GOTO 90
      DO 80 ISZI=1,3
      IF (BWTPHA(IHOST,ISZI).LE.0.0) GOTO 80
      XMULT=1./FLOAT(NCUMYR)
      DO 70 I=1,NCUMYR
      CDEF(IHOST,ISZI)=CDEF(IHOST,ISZI)+CUMDEF(IHOST,ISZI,I)
      DO 70 ITYPE=1,2
      AVPRBO(IHOST,ISZI,ITYPE)=AVPRBO(IHOST,ISZI,ITYPE)
     >                 + (APRBYR(IHOST,ISZI,ITYPE,I)*XMULT)
   70 CONTINUE
   80 CONTINUE
   90 CONTINUE
C
C     COMPUTE THE MAXIMUM AVERAGE DEFOLIATION.  THIS IS COMPUTED
C     IF THE AVERAGE HAS BEEN COMPUTED FOR 4 OR MORE YEARS.  THESE
C     DATA ARE USED IN THE TOPKILLING MODELS.
C
      IF (NCUMYR.GE.4) THEN
         DO 190 IHOST=1,6
         IF (IFHOST(IHOST).EQ.0) GOTO 190
         DO 180 ISZI=1,3
         IF (BWTPHA(IHOST,ISZI).LE.0.0) GOTO 180
         IF (AVYRMX(IHOST,ISZI).LT. 1.-AVPRBO(IHOST,ISZI,1))
     >      AVYRMX(IHOST,ISZI)=1.-AVPRBO(IHOST,ISZI,1)
  180    CONTINUE
  190    CONTINUE
      ENDIF
C
C     COMPUTE PROPORTIONAL DDS AND HTG.
C
C     FOR THE MEDIUM AND LARGE TREES, THE RDDS AND RHTG MODELS
C     CAME FROM:  NICHOLS, TOM. 1984. FINAL REPORT FOR PERSONAL
C     CONTRACT WESTERN SPRUCE BUDWORM IMPACT MODEL CALIBRATIONS.
C     SUBMITTED TO CANUSA/SPRUCE BUDWORMS PROGRAM-WEST.  MARCH 10 1984.
C
C     SEE NICHOLS FOREST SCIENCE 34(1):236-242 AND 34(2):496-504.
C
C     FOR THE SMALL TREES, THE RHTG MODEL CAME FROM DENNIS FERGUSON.
C     SEE FERGUSON (1988) USDA RESEARCH PAPER INT-393.
C     THIS MODEL MAY ONLY BE APPLIED ON 5-YR INTERVALS...SO STICK TO
C     5-YR CHUNKS UNLESS YOU NEED A LITTLE AT THE END FOR THE LAST
C     FEW YEARS OF A CYCLE.  THIS IS ACCOMPLISHED BY COMPUTING XFIFTH
C     TO SCALL THE PROPORTION OF HEIGHT GROWTH FOR SMALL TREES.
C
      XFIFTH=0.0
      INRUN=IYRCUR-IBWYR1+1
      IFIFTH=MOD(INRUN,5)
      IF (IFIFTH.EQ.0) XFIFTH=5.0/BWFINT
      IF (IFIFTH.NE.0 .AND. IYRCUR.EQ.IBWYR2)
     >       XFIFTH=FLOAT(IFIFTH)/BWFINT
C
      DO 240 IHOST=1,6
      IF (IFHOST(IHOST).EQ.0) GOTO 240
      DO 230 ISZI=1,3
      IF (BWTPHA(IHOST,ISZI).LE.0.0) GOTO 230
      RDDS=.083861*(AVPRBO(IHOST,ISZI,2)*100.)**(.4725+.07*
     >     RDDSM1(IHOST,ISZI))*RDDSM1(IHOST,ISZI)**.3241
      IF (RDDS.GT.1.) RDDS=1.0
      RDDSM1(IHOST,ISZI)=RDDS
      RHTG=.193013*(AVPRBO(IHOST,ISZI,1)*100.)**(.3814-.0212*
     >     RHTGM1(IHOST,ISZI))*RHTGM1(IHOST,ISZI)**.5509
      IF (RHTG.GT.1.) RHTG=1.0
      RHTGM1(IHOST,ISZI)=RHTG
      PEDDS(IHOST,ISZI)=PEDDS(IHOST,ISZI)+(RDDS/BWFINT)
C
C     IF THE TREE SIZE IS MEDIUM OR LARGE, USE NICHOLS MODEL
C
      IF (ISZI.GT.1) THEN
         PEHTG(IHOST,ISZI)=PEHTG(IHOST,ISZI)+(RHTG/BWFINT)
      ELSE
C
C        THE TREE IS SMALL, COMPUTE HEIGHT GROWTH REDUCTION USING
C        DENNIS FERGUSON'S MODEL.
C
         RHTG=1.0
         IF (AVPRBO(IHOST,ISZI,2).LT. 0.98) RHTG=EXP(STHTGR(IHOST)*
     >                                    (1.0-AVPRBO(IHOST,ISZI,1)))
         PEHTG(IHOST,ISZI) = PEHTG(IHOST,ISZI) + (RHTG*XFIFTH)
      ENDIF
C
C     SAVE THE MAX CUM DEFOLIATION.  MUST BE GE 5 YRS INTO THE RUN
C     OR ON THE LAST YEAR OF THE RUN.
C
      IF (INRUN.GE.5 .OR. IYRCUR .EQ. IBWYR2) THEN
         IF (BWMXCD(IHOST,ISZI).LT.CDEF(IHOST,ISZI))
     >       BWMXCD(IHOST,ISZI) =  CDEF(IHOST,ISZI)
      ENDIF
  230 CONTINUE
  240 CONTINUE
C
C     WRITE DAMAGE VALUES.
C     ONLY WRITE THE DAMAGE VALUES IF:
C        THEY ARE REQUESTED,
C        THE PROJECTION IS AT THE END OF A CYCLE OR PERIOD, AND
C        THE PROJECTION HAS LASTED A MULTIPLE OF 5 YEARS.
C
      IF (.NOT.LBWDAM) GOTO 350
      IF (IFIFTH.NE.0 .AND. IYRCUR.NE.IBWYR2) GOTO 350
      IF (LBWDAM)  WRITE (JOWSBW,250) IYRCUR,NPLT,INRUN
  250 FORMAT (/'DAMAGE: ',I4,'; ',A26,'; PERIOD LENGTH TO DATE: ',
     >        I2,'-YEARS'/,47('-'),'  NEW-FOLIAGE DEFOLIATION'
     >        /T13,'PROPORTION OF EXPECTED',T50,
     >        'PERIOD AVERAGE  5-YR MAX'/T13,'PERIODIC GROWTH',T37,
     >        'MAXIMUM',T50,14('-'),'  AVERAGE'/T7,'TREE  ',22('-'),
     >        T37,'CUMULATIVE',T50,'TOP',T59,'WHOLE',T66,'TOP'/
     >        ' HOST  SIZE  DIAMETER',T29,'HEIGHT  DEFOLIATION',T50,
     >        'THIRD',T59,'TREE   THIRD'/'----  ----  --------',
     >        T29,'------  -----------  -------  -----  --------')
C
C     COMPUTE A SCALING VALUE (XMULT) APPROPREATE TO SCALE THE RATES
C     STORED IN PEDDS, PEHTG, AND BWMXCD TO END-OF-PERIOD VALUES.
C     (THIS IS DONE JUST FOR REPORTING PURPOSES).
C
      XMULT=BWFINT/FLOAT(INRUN)
C
C     WRITE THE BODY OF THE OUTPUT TABLE.
C
      DO 310 IHOST=1,6
      IF (IFHOST(IHOST).EQ.0) GOTO 310
      DO 300 ISZI=1,3
      IF (BWTPHA(IHOST,ISZI).LE.0.0) GOTO 300
      RDDS=PEDDS(IHOST,ISZI)*XMULT
      RHTG=PEHTG(IHOST,ISZI)*XMULT
      IF (LBWDAM) WRITE (JOWSBW,290) ISPC(IHOST),ISZC(ISZI),RDDS,
     >       RHTG,BWMXCD(IHOST,ISZI),(1.-AVPRBO(IHOST,ISZI,I),I=1,2),
     >       AVYRMX(IHOST,ISZI)
  290 FORMAT (1X,A2,3X,A4,T14,F6.3,T29,F6.3,T38,F7.1,T49,F6.3,T58,
     >        F6.3,T66,F6.3)
  300 CONTINUE
  310 CONTINUE
  350 CONTINUE

      IF (DEBUG) WRITE (JOSTND,*) 'IN BWEDAM: AVYRMX = ',AVYRMX
      IF (DEBUG) WRITE (JOSTND,*) 'IN BWEDAM: AVPRBO = ',AVPRBO
      IF (DEBUG) WRITE (JOSTND,*) 'EXIT BWEDAM: ICYC= ',ICYC

      RETURN
      END
