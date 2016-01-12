      SUBROUTINE HABTYP (KARD2,ARRAY2)
      use contrl_mod
      use plot_mod
      use varcom_mod
      use prgprm_mod
      implicit none
C----------
C  **HABTYP--LS   DATE OF LAST REVISION:  01/25/2011
C----------
C
C     TRANSLATES HABITAT TYPE  CODE INTO A SUBSCRIPT, ITYPE, AND IF
C     KODTYP IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C----------
COMMONS
C----------
      INTEGER NPA,I,IHB
      PARAMETER (NPA=63)
      REAL ARRAY2
      CHARACTER*10 KARD2
      CHARACTER*8 LSNPC(NPA)
      LOGICAL DEBUG
      LOGICAL LPVCOD,LPVREF,LPVXXX
C----------
      DATA (LSNPC(I),I= 1,63)/
     & 'FDN12   ','FDN22   ','FDN32   ','FDN33   ','FDN43   ',
     & 'FDC12   ','FDC23   ','FDC24   ','FDC25   ','FDC34   ',
     & 'MHN35   ','MHN44   ','MHN45   ','MHN46   ','MHN47   ',
     & 'MHC26   ','MHC36   ','MHC37   ','MHC47   ','FFN57   ',
     & 'FFN67   ','WFN53   ','WFN55   ','WFN64   ','WFS57   ',
     & 'WFW54   ','FPN62   ','FPN63   ','FPN71   ','FPN72   ',
     & 'FPN73   ','FPN81   ','FPN82   ','FPS63   ','FPW63   ',
     & 'APN80   ','APN81   ','APN90   ','APN91   ','CTN11   ',
     & 'CTN12   ','CTN24   ','CTN32   ','CTN42   ','CTU22   ',
     & 'RON12   ','RON23   ','LKI32   ','LKI43   ','LKI54   ',
     & 'LKU32   ','LKU43   ','RVX32   ','RVX43   ','RVX54   ',
     & 'OPN81   ','OPN91   ','OPN92   ','OPN93   ','WMN82   ',
     & 'MRN83   ','MRN93   ','MRU94   '/
C
      LPVREF=.FALSE.
      LPVCOD=.FALSE.
      LPVXXX=.FALSE.
C-----------
C  CHECK FOR DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HABTYP',6,ICYC)
      IF(DEBUG) WRITE(JOSTND,*)
     &'ENTERING HABTYP CYCLE,KODTYP,KODFOR,KARD2,ARRAY2= ',
     &ICYC,KODTYP,KODFOR,KARD2,ARRAY2
C----------
C  IF REFERENCE CODE IS NON-ZERO THEN MAP PV CODE/REF. CODE TO
C  FVS HABITAT TYPE/ECOCLASS CODE. THEN PROCESS FVS CODE
C----------
      IF(CPVREF.NE.'          ') THEN
        CALL PVREF9(KARD2,ARRAY2,LPVCOD,LPVREF)
        ICL5=0
        IF(DEBUG)WRITE(JOSTND,*)'AFTER PVREF KARD2,ARRAY2= ',
     &  KARD2,ARRAY2
        IF((LPVCOD.AND.LPVREF).AND.
     &      (KARD2.EQ.'          '))THEN
          CALL ERRGRO(.TRUE.,34)
          ITYPE=1
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.(.NOT.LPVREF))THEN
          CALL ERRGRO(.TRUE.,33)
          CALL ERRGRO(.TRUE.,32)
          ITYPE=1
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVREF).AND.LPVCOD)THEN
          CALL ERRGRO(.TRUE.,32)
          ITYPE=1
          LPVXXX=.TRUE.
          GO TO 30
        ELSEIF((.NOT.LPVCOD).AND.LPVREF)THEN
          CALL ERRGRO(.TRUE.,33)
          ITYPE=1
          LPVXXX=.TRUE.
          GO TO 30
        ENDIF
      ENDIF
C----------
C  DECODE HABITAT TYPE/PLANT ASSOCIATION FIELD.
C----------
      CALL HBDECD (KODTYP,LSNPC(1),NPA,ARRAY2,KARD2)
      IF(DEBUG)WRITE(JOSTND,*)'AFTER HAB DECODE,KODTYP= ',KODTYP
      IF (KODTYP .LE. 0) GO TO 20
C
      PCOM = LSNPC(KODTYP)
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
        PCOM = LSNPC(KODTYP)
        GO TO 40
      ELSE
C----------
C  DEFAULT CONDITIONS --- PLANT COMMUNITY = FDn12
C----------
        ITYPE=1
        GO TO 30
      ENDIF
C
   30 CONTINUE
      IF(.NOT.LPVXXX)CALL ERRGRO(.TRUE.,14)
      KODTYP=ITYPE
      PCOM = LSNPC(KODTYP)
      IF(LSTART)WRITE(JOSTND,10) PCOM
C
   40 CONTINUE
      ICL5=KODTYP
      KARD2=PCOM
C
      IF(DEBUG)WRITE(JOSTND,*)'LEAVING HABTYP KODTYP,ITYPE,ICL5,KARD2',
     &' PCOM =',KODTYP,ITYPE,ICL5,KARD2,PCOM
C
      RETURN
      END
