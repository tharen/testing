      SUBROUTINE OPSAME (MAE,MAELNK,IOUT,LDEB)
      use prgprm_mod
      implicit none
C----------
C  $Id$
C----------
C
C     CALLED FROM EVMON, DELETE ACTIVITY GROUPS THAT MIGHT CREATE
C     BRANCHES THAT HAVE IDENTICAL ACTIVITIES.
C
C     EVENT MONITOR ROUTINE..PART OF THE PROGNOSIS SYSTEM
C     N.L. CROOKSTON--FORESTRY SCIENCES LAB, MOSCOW, ID--JAN 1987.
C
C     MAE   = LENGTH OF MAELNK.
C     MAELNK= LIST OF ACTIVITY GROUPS THAT ARE ASSOCIATED WITH
C             AN EVENT THAT HAS MORE THAN ONE ACTIVITY GROUP
C             ASSOCIATED WITH IT.
C             (1,.)= POINTS TO THE ENTRY IN IEVACT, AGLSET, & LENAGL
C             (2,.)= POINTS TO THE ENTRY IN IEVNTS
C
      INCLUDE 'OPCOM.F77'
C
      INTEGER IOUT,MAE,IDEL,I1,J1,MF1,MF2,NMF,II,I2,J2,MS1,MS2,NMS
      INTEGER IA,IPF1,IPF2,IPS1,IPS2,NPF,NPS,IPF,KIDE,LNUNIN,I,KODE
      INTEGER MAELNK(2,50)
      LOGICAL LDEB
C
C     IF THE LENGTH OF MAELNK IS LE ONE, BRANCH TO RETURN
C
      IF (MAE.LE.1) GOTO 100
C
C     DO THROUGH THE ACTIVITY GROUPS, AND FLAG MEMBERS OF MEMLNK
C     FOR ACTIVITY GROUPS THAT SHOULD BE DROPPED.
C
      IDEL=0
      DO 50 I1=1,(MAE-1)
      J1=MAELNK(1,I1)
      IF (LDEB) WRITE (IOUT,'('' IN OPSAME: I1,J1='',2I4)') I1,J1
      IF (J1.EQ.0) GOTO 50
C
C     IF THE BRANCH WEIGHTING FACTOR MAY BE CHANGED, DO NOT DELETE.
C
      IF (IEVACT(J1,6).NE.0) GOTO 50
C
C     MF1 POINTS TO THE FIRST ACTIVITY IN THE ACTIVITY GROUP AND MF2
C     POINTS TO THE SECOND.  NMF IS THE NUMBER OF ACTIVITIES IN THE
C     GROUP.  MF1 IS LARGER THAN MF2 BECAUSE ACTIVITIES THAT DEPEND ON
C     EXPRESSIONS ARE STORED IN IACT FROM THE BOTTOM TO THE TOP.
C
      MF1=IEVACT(J1,4)
      MF2=IEVACT(J1,5)
      NMF=MF1-MF2+1
      II=I1+1
C
      DO 40 I2=II,MAE
      J2=MAELNK(1,I2)
      IF (LDEB) WRITE (IOUT,'('' IN OPSAME: I2,J2='',2I4)') I2,J2
      IF (J2.EQ.0) GOTO 40
C
C     IF THE BRANCH WEIGHTING FACTOR MAY BE CHANGED, DO NOT DELETE.
C
      IF (IEVACT(J2,6).NE.0) GOTO 40
      MS1=IEVACT(J2,4)
C
C     IF BOTH GROUPS ARE EMPTY SETS, THEY ARE CONSIDERED EQUAL.
C
      IF (MF1.EQ.0 .AND. MS1.EQ.0) GOTO 35
      MS2=IEVACT(J2,5)
      NMS=MS1-MS2+1
C
C     IF THE NUMBER OF ACTIVITIES IN THE GROUP DIFFERS, THE GROUP IS
C     UNIQUE.  BRANCH TO THE NEXT GROUP.
C
      IF (NMF.NE.NMS) GOTO 40
C
C     GO THROUGH THE ACTIVITIES ONE-BY-ONE.  IF AN ACTIVITY CODE
C     OR A PARAMETER DIFFERS, THE GROUP IS UNIQUE.  IF THE ORDER
C     OF THE ACTIVITIES DIFFERS, THE GROUP IS ALSO UNIQUE.
C
      MF1=MF1+1
      MS1=MS1+1
      DO 30 IA=1,NMF
      MF1=MF1-1
      MS1=MS1-1
      IF (IACT(MF1,1).NE.IACT(MS1,1)) GOTO 40
      IPF1=IACT(MF1,2)
      IF (IPF1.LT.0) GOTO 40
      IPF2=IACT(MF1,3)
      IPS1=IACT(MS1,2)
      IF (IPS1.LT.0) GOTO 40
      IPS2=IACT(MS1,3)
      NPF=IPF2-IPF1+1
      NPS=IPS2-IPS1+1
      IF (NPF.NE.NPS) GOTO 40
      IF (NPF.EQ.0) GOTO 30
      IPS1=IPS1-1
      DO 20 IPF=IPF1,IPF2
      IPS1=IPS1+1
      IF (PARMS(IPF).NE.PARMS(IPS1)) GOTO 40
   20 CONTINUE
   30 CONTINUE
   35 CONTINUE
      IF (LDEB) WRITE (IOUT,'('' IN OPSAME: LBSETS='',L2)') LBSETS
C
C     ALL OF THE ACTIVITIES MATCH IN ORDER AND PARAMETERS.  THE
C     ACTIVITY GROUP MAY BE DELETED.  IF LABEL PROCESSING IS BEING
C     DONE, COMBINE THE ACTIVITY GROUP LABEL SET FOR THE DELETED
C     GROUP WITH THE SET USED FOR THE KEPT ONE.
C
      IF (LBSETS) THEN
         IF (LDEB) THEN
            WRITE (IOUT,'('' IN OPSAME: AGLSET(J1)='',A)') AGLSET(J1)
     >             (1:LENAGL(J1))
            WRITE (IOUT,'('' IN OPSAME: AGLSET(J2)='',A)') AGLSET(J2)
     >             (1:LENAGL(J2))
         ENDIF
         CALL LBUNIN (LENAGL(J1),AGLSET(J1),LENAGL(J2),AGLSET(J2),
     >                LNUNIN,WKSTR1,KODE)
C
C        IF THE UNION IS TOO LONG, (KODE=1) THEN DO NOT DELETE THE
C        ACTIVITY GROUP, SIMPLY CARRY IT ALONG TO AVOID AN INCORRECT
C        ACTIVITY GROUP LABEL.
C
         IF (KODE.GT.0) GOTO 40
C
C        SET THE ACTIVITY GROUP LABEL FOR GROUP J1 EQUAL TO THE UNION
C
         LENAGL(J1)=LNUNIN
         AGLSET(J1)=WKSTR1
      ENDIF
C
C     DELETE ACTIVITY GROUP J2
C
      MAELNK(1,I2)=0
      IDEL=IDEL+1
      IF (LDEB) WRITE (IOUT,'('' IN OPSAME: AGLSET(J1)='',A)')
     >          AGLSET(J1)(1:LENAGL(J1))
      IF (LDEB) WRITE (IOUT,'('' IN OPSAME: KODE,IDEL='',2I4)')
     >          KODE,IDEL
   40 CONTINUE
   50 CONTINUE
C
C     IF NO ACTIVITY GROUPS ARE DELETED, RETURN.
C
      IF (IDEL.EQ.0) GOTO 100
C
C     IF ALL OF THE ACTIVIY GROUPS HAVE BEEN DELETED, RETURN.
C
      IF (IDEL.EQ.MAE) THEN
         MAE=0
         GOTO 100
      ENDIF
C
C     IF SOME HAVE BEEN DELETED, COMPRESS THE LIST MAELNK.
C
      IDEL=0
      DO 60 I=1,MAE
      IF (MAELNK(1,I).GT.0) THEN
         IDEL=IDEL+1
         MAELNK(1,IDEL)=MAELNK(1,I)
         MAELNK(2,IDEL)=MAELNK(2,I)
      ENDIF
   60 CONTINUE
      MAE=IDEL
C
  100 CONTINUE
      RETURN
      END
