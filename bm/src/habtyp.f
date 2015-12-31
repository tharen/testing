      SUBROUTINE HABTYP (KARD2,ARRAY2)
      IMPLICIT NONE
C----------
C  **HABTYP--BM   DATE OF LAST REVISION:  03/01/11
C----------
C
C     TRANSLATES HABITAT TYPE  CODE INTO A SUBSCRIPT, ITYPE, AND IF
C     KODTYP IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
      INTEGER NPA,I,IHB
      PARAMETER (NPA=92)
      REAL ARRAY2
      CHARACTER*10 KARD2
      CHARACTER*8 PCOML(NPA)
      LOGICAL DEBUG
      LOGICAL LPVCOD,LPVREF,LPVXXX
C----------
      DATA (PCOML(I),I=1,75) /
C 1-25
     &'CAG111  ','CAG4    ','CDG111  ','CDG112  ','CDG121  ',
     &'CDS611  ','CDS622  ','CDS623  ','CDS624  ','CDS634  ',
     &'CDS711  ','CDS722  ','CDS821  ','CEF221  ','CEF311  ',
     &'CEF331  ','CEF411  ','CEM111  ','CEM221  ','CEM222  ',
     &'CEM311  ','CEM312  ','CES131  ','CES221  ','CES311  ',
C 26-50
     &'CES314  ','CES315  ','CES411  ','CES414  ','CES415  ',
     &'CLF211  ','CLG211  ','CLM112  ','CLM113  ','CLM114  ',
     &'CLM312  ','CLM313  ','CLM314  ','CLM911  ','CLS411  ',
     &'CLS415  ','CLS416  ','CLS5    ','CLS511  ','CLS515  ',
     &'CLS6    ','CMS131  ','CMS231  ','CPG111  ','CPG112  ',
C 51-75
     &'CPG131  ','CPG132  ','CPG221  ','CPG222  ','CPM111  ',
     &'CPS131  ','CPS221  ','CPS222  ','CPS226  ','CPS232  ',
     &'CPS233  ','CPS234  ','CPS511  ','CPS522  ','CPS523  ',
     &'CPS524  ','CPS525  ','CWC811  ','CWC812  ','CWF311  ',
     &'CWF312  ','CWF421  ','CWF431  ','CWF512  ','CWF611  '/
      DATA (PCOML(I),I=76,NPA) /
C 76-92
     &'CWF612  ','CWG111  ','CWG112  ','CWG113  ','CWG211  ',
     &'CWS211  ','CWS212  ','CWS321  ','CWS322  ','CWS412  ',
     &'CWS541  ','CWS811  ','CWS812  ','CWS912  ','HQM121  ',
     &'HQM411  ','HQS221  '/
C
      LPVREF=.FALSE.
      LPVCOD=.FALSE.
      LPVXXX=.FALSE.
C----------
C  IF REFERENCE CODE IS NON-ZERO THEN MAP PV CODE/REF. CODE TO
C  FVS HABITAT TYPE/ECOCLASS CODE. THEN PROCESS FVS CODE
C----------
      IF(CPVREF.NE.'          ') THEN
        CALL PVREF6(KARD2,ARRAY2,LPVCOD,LPVREF)
        ICL5=0
        IF((LPVCOD.AND.LPVREF).AND.
     &      (KARD2.EQ.'          '))THEN
          CALL ERRGRO(.TRUE.,34)
          ITYPE=79
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.(.NOT.LPVREF))THEN
          CALL ERRGRO(.TRUE.,33)
          CALL ERRGRO(.TRUE.,32)
          ITYPE=79
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVREF).AND.LPVCOD)THEN
          CALL ERRGRO(.TRUE.,32)
          ITYPE=79
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.LPVREF)THEN
          CALL ERRGRO(.TRUE.,33)
          ITYPE=79
          LPVXXX=.TRUE.
          GO TO 30
        ENDIF
      ENDIF
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HABTYP',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,*)
     &'ENTERING HABTYP CYCLE,KODTYP,KODFOR,KARD2,ARRAY2= ',
     &ICYC,KODTYP,KODFOR,KARD2,ARRAY2
C----------
C  DECODE HABITAT TYPE/PLANT ASSOCIATION FIELD.
C----------
      CALL HBDECD (KODTYP,PCOML(1),NPA,ARRAY2,KARD2)
      IF(DEBUG)WRITE(JOSTND,*)'AFTER HAB DECODE,KODTYP= ',KODTYP
      IF (KODTYP .LE. 0) GO TO 20
C
      PCOM = PCOML(KODTYP)
      ITYPE=KODTYP
      IF(LSTART)WRITE(JOSTND,10) PCOM
   10 FORMAT(/,T12,'PLANT ASSOCIATION CODE USED IN THIS',
     &' PROJECTION IS ',A8)
      GO TO 40
C----------
C  NO MATCH WAS FOUND, TREAT IT AS A SEQUENCE NUMBER.
C----------
   20 CONTINUE
      IF(DEBUG)WRITE(JOSTND,*)'EXAMINING FOR INDEX, ARRAY2= ',ARRAY2
      IHB = IFIX(ARRAY2)
      IF(IHB.GT.0 .AND. IHB.LE.NPA)THEN
        KODTYP=IHB
        ITYPE=IHB
        PCOM = PCOML(KODTYP)
        GO TO 40
      ELSE
C----------
C  DEFAULT CONDITIONS --- PA = CWG113
C----------
        ITYPE=79
        GO TO 30
      ENDIF
C
   30 CONTINUE
      IF(.NOT.LPVXXX)CALL ERRGRO(.TRUE.,14)
      KODTYP=ITYPE
      PCOM = PCOML(KODTYP)
      IF(LSTART)WRITE(JOSTND,10) PCOM
C
   40 CONTINUE
      ICL5=KODTYP
      KARD2=PCOM
C
      IF(DEBUG)WRITE(JOSTND,*)'LEAVING HABTYP KODTYP,ITYPE,ICL5,KARD2',
     &' PCOM =',KODTYP,ITYPE,ICL5,KARD2,PCOM
      RETURN
      END
