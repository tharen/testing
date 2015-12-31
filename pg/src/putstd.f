      SUBROUTINE PUTSTD 
      IMPLICIT NONE
C----------
C  $Id$
C----------
C
C     STASH A STAND TO THE MASS STORAGE
C
C   Local variable definitions:
C     MXI      Maximum number of integer scalars to be written.
C     MXL      Maximum number of logical scalars to be written.
C     MXR      Maximum number of real scalars to be written.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PPDNCM.F77'
C
C
      INCLUDE 'ESPARM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'CALCOM.F77'
C
C
      INCLUDE 'CALDEN.F77'
C
C
      INCLUDE 'ECON.F77'
C
C
      INCLUDE 'ESHAP.F77'
C
C
      INCLUDE 'ESHAP2.F77'
C
C
      INCLUDE 'ESCOMN.F77'
C
C
      INCLUDE 'ESCOM2.F77'
C
C
      INCLUDE 'ESTCOR.F77'
C
C
      INCLUDE 'ESTREE.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'OPCOM.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'VOLSTD.F77'
C
C
      INCLUDE 'ESRNCM.F77'
C
C
      INCLUDE 'RANCOM.F77'
C
C
      INCLUDE 'DBSTK.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
      INCLUDE 'SUMTAB.F77'
C
C
      INCLUDE 'SSTGMC.F77'
C
C
      INCLUDE 'STDSTK.F77'
C
C
      INCLUDE 'SVDATA.F77'
C
C
      INCLUDE 'SVDEAD.F77'
C
C
      INCLUDE 'SVRCOM.F77'
C
C
      INCLUDE 'CWDCOM.F77'
C
C
      INCLUDE 'FVSSTDCM.F77'
C
C
      INCLUDE 'GGCOM.F77'
C
C
      INCLUDE 'SCREEN.F77'
C
C
COMMONS
C
C     WRITE ALL INTEGER VARIABLES WITH IFWRIT, LOGICAL VARIABLES
C     WITH LFWRIT, AND REAL VARIABLES WITH BFWRIT.  ONE EXCEPTION
C     IS IOSUM, WHICH MUST BE LONG INTEGER, AND IS WRITTEN WITH
C     BFWRIT VIA AN EQUIVALENCE TO ROSUM.  THE OTHER EXCEPTIONS ARE
C     THE RANDOM NUMBER SEEDS, WHICH ARE EQUIVALENCED TO REAL ARRAYS
C     OF LENGTH 2.
C
      INTEGER MXL,MXR,MXI,IRECLN
      PARAMETER (MXR=130,MXL=40,MXI=119,IRECLN=1024)
      INTEGER ILIMIT,IPNT,K,I,II
      INTEGER INTS(MXI)
      LOGICAL LOGICS(MXL),LCVGO,LMORED,LRR1,LRR2,LFM,LBWE,LCLM,LWRD,LZ
      REAL REALS(MXR), ROSUM(20,MAXCY1),
     >          RSEED(2), ESSEED(2), RDTREE(MAXTRE),
     >          SVSED0(2),SVSED1(2)
      EQUIVALENCE (ROSUM,IOSUM),(RSEED,S0),(ESSEED,ESS0),(WK6,REALS),
     >            (WK6,LOGICS),(WK6,INTS),(IDTREE,RDTREE),
     >            (SVSED0,SVS0),(SVSED1,SVS1)
C
      if (itable(2) .eq. 0) then
        itable(2) = 1
        print *,"FVS turned off the example tree table output."
      endif      
      ILIMIT=IRECLN
C
C     STORE THE INTEGER SCALARS IN THE ARRAY INTS.
C
      INTS ( 1) =   IAGE
      INTS ( 2) =   IASPEC
      INTS ( 3) =   IBLK
      INTS ( 4) =   ICACT
      INTS ( 5) =   ICFLAG
      INTS ( 6) =   ICL1
      INTS ( 7) =   ICL2
      INTS ( 8) =   ICL3
      INTS ( 9) =   ICL4
      INTS (10) =   ICL5
      INTS (11) =   ICL6
      INTS (12) =   ICOD
      INTS (13) =   ICRHAB
      INTS (14) =   ICYC
      INTS (15) =   IDG
      INTS (16) =   IDSDAT
      INTS (17) =   IEPT
      INTS (18) =   IEVA
      INTS (19) =   IEVT
      INTS (20) =   IFINT
      INTS (21) =   IFINTH
      INTS (22) =   IFO
      INTS (23) =   IFOR
      INTS (24) =   IFST
      INTS (25) =   IGL
      INTS (26) =   IHAB
      INTS (27) =   IHTG
      INTS (28) =   IHTYPE
      INTS (29) =   IMG1
      INTS (30) =   IMG2
      INTS (31) =   IMGL
      INTS (32) =   IMPL
      INTS (33) =   INADV
      INTS (34) =   IPHASE
      INTS (35) =   IPHY
      INTS (36) =   IPINFO
      INTS (37) =   IPREP
      INTS (38) =   IPRINT
      INTS (39) =   IPTINV
      INTS (40) =   IREC1
      INTS (41) =   IREC2
      INTS (42) =   IRECNT
      INTS (43) =   IRECRD
      INTS (44) =   IRHHAB
      INTS (45) =   ISISP
      INTS (46) =   ISLOP
      INTS (47) =   ISMALL
      INTS (48) =   ISPCCF
      INTS (49) =   ISPDSQ
      INTS (50) =   ISPFOR
      INTS (51) =   ISPHAB
      INTS (52) =   ISTDAT
      INTS (53) =   ITOP        ! DBSTK common
      INTS (54) =   ITOPRM
      INTS (55) =   ITRN
      INTS (56) =   ITRNRM
      INTS (57) =   ITST5
      INTS (58) =   ITYPE
      INTS (59) =   IYRLRM
      INTS (60) =   KDTOLD
      INTS (61) =   KODFOR
      INTS (62) =   KODTYP
      INTS (63) =   LENSLS
      INTS (64) =   LOAD
      INTS (65) =   LSTKNT
      INTS (66) =   METH
      INTS (67) =   MINREP
      INTS (68) =   MODE
      INTS (69) =   MANAGD
      INTS (70) =   NCYC
      INTS (71) =   NNID
      INTS (72) =   NONSTK
      INTS (73) =   NPTIDS
      INTS (74) =   NSTKNT
      INTS (75) =   NTALLY
      INTS (76) =   NUMSP
      INTS (77) =   IMODTY
      INTS (78) =   IPHREG
      INTS (79) =   IFORTP
      INTS (80) =   ISTCL
      INTS (81) =   ISZCL
      INTS (82) =   ISTRCL
      INTS (83) =   IRREF
      INTS (84) =   NDEAD
      INTS (85) =   ICOLIDX
      INTS (86) =   IDPLOTS
      INTS (87) =   IGRID
      INTS (88) =   ILYEAR
      INTS (89) =   IRPOLES
      INTS (90) =   JSVOUT
      INTS (91) =   JSVPIC
      INTS (92) =   NSVOBJ
      INTS (93) =   IPLGEM
      INTS (94) =   IMORTCNT
      INTS (95) =   ISVINV
      INTS (96) =   ICNTY
      INTS (97) =   ISTATE
      INTS (98) =   ICAGE
      INTS (99) =   MAIFLG
      INTS(100) =   NEWSTD
      INTS(101) =   ISEQDN
      INTS(102) =   IMETRIC
      INTS(103) =   NSPGRP
      INTS(104) =   ITHNPI
      INTS(105) =   ITHNPN
      INTS(106) =   NCALHT
      INTS(107) =   ITHNPA
      INTS(108) =   ISILFT
      INTS(109) =   NSITET
      INTS(110) =   ILGNUM
      INTS(111) =   NCWD
      INTS(112) =   MFLMSB
      INTS(113) =   JSPINDEF
      INTS(114) =   KOLIST
      CALL GETNRPTS(I)
      INTS(115) = I
      INTS(116) = IGFOR
      INTS(117) = NPTGRP
      INTS(118) =   MAXTOP      ! DBSTK common
      INTS(119) =   MAXLEN      ! DBSTK common
C
C     BEGIN THE WRITE TO THE DIRECT ACCESS DATA FILE, AND WRITE THE
C     INTEGER SCALARS.
C
      CALL IFWRIT (WK3,IPNT,ILIMIT,INTS,MXI,1)

C
C     WRITE THE INTEGER ARRAYS.
C
      CALL IFWRIT (WK3,IPNT,ILIMIT,DEFECT, ITRN,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IABFLG,MAXSP,   2)
      K=IMGL-1
      DO I=1,5
        CALL IFWRIT (WK3,IPNT,ILIMIT,IACT(1,I),K,    2)
      ENDDO
      CALL IFWRIT (WK3,IPNT,ILIMIT,IDATE, K,       2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IOPCYC,K,       2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IOPSRT,K,       2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISEQ,  K,       2)
      K=MAXACT-IEPT+1
      DO I=1,5
        CALL IFWRIT (WK3,IPNT,ILIMIT,IACT(IEPT,I),K, 2)
      ENDDO
      CALL IFWRIT (WK3,IPNT,ILIMIT,IDATE(IEPT), K, 2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISEQ(IEPT),  K, 2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IALN,   3,      2)
      K=IEVA-1
      IF (K.GT.0) THEN
         DO 10 I=1,6
         CALL IFWRIT (WK3,IPNT,ILIMIT,IEVACT(1,I),K,  2)
   10    CONTINUE
         CALL IFWRIT (WK3,IPNT,ILIMIT,LENAGL,K,       2)
      ENDIF
      CALL IFWRIT (WK3,IPNT,ILIMIT,IEVCOD,ICOD-1,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IEVNTS(1,1),IEVT-1,2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IEVNTS(1,2),IEVT-1,2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IEVNTS(1,3),IEVT-1,2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IMC,   ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IMGPTS(1,1),NCYC,2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IMGPTS(1,2),NCYC,2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IBEGIN,MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IBTAVH,ICYC+1,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IBTCCF,ICYC+1,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IBTRAN,MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ICTRAN,MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ICR,   ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IDTREE,ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IESTAT,ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IND,   ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IND1,  ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IND2,  ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,INS,   6,       2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IOICR, 6,       2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IOLDBA,ICYC+1,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IORDER,MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IPHAB, IPTINV,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IPHYS, IPTINV,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IPPREP,MAXPLT,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IPTIDS,IPTINV,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IPVEC, IPTINV,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IREF,  MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISCT,  MAXSP*2, 2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISDI,  ICYC+1,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISDIAT,ICYC+1,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISP,   ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISPECL,ITRN,    2)
      DO 12 I=1,30
      DO 11 II=1,52
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISPGRP(I,II),1, 2)
   11 CONTINUE
   12 CONTINUE
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISTAGF,MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ITRE,  ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ITRUNC,ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IY, MAXCY1,     2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,KOUNT, MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,KPTR,  MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,KUTKOD, ITRN,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,MAXSDI, MAXSP,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,METHC, MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,METHB, MAXSP,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,NBFDEF,ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,NCFDEF,ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,NORMHT,ITRN,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,NSTORE,MAXPLT,  2)
C
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISNSP, NDEAD,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IYRCOD,NDEAD,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ISTATUS,NDEAD,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IOBJTP,NSVOBJ,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,IS2F,  NSVOBJ,  2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,OIDTRE,NDEAD,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,JSPIN,MAXSP,    2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,ITABLE,7,       2)
      DO 14 I=1,30
      DO 13 II=1,52
      CALL IFWRIT (WK3,IPNT,ILIMIT,IPTGRP(I,II),1, 2)
   13 CONTINUE
   14 CONTINUE
C
C     STORE THE LOGICAL SCALARS IN THE ARRAY LOGICS.
C
      LOGICS ( 1) = LAUTAL
      LOGICS ( 2) = LAUTON
      LOGICS ( 3) = LBKDEN
      LOGICS ( 4) = LBSETS
      LOGICS ( 5) = LBVOLS
      CALL CVGO (LCVGO)
      LOGICS ( 6) = LCVGO
      LOGICS ( 7) = LCVOLS
      LOGICS ( 8) = LDCOR2
      LOGICS ( 9) = LDUBDG
      LOGICS (10) = LECBUG
      LOGICS (11) = LECON
      LOGICS (12) = LEVUSE
      LOGICS (13) = LFIXSD
      LOGICS (14) = LFLAG
      LOGICS (15) = LHCOR2
      LOGICS (16) = LINGRW
      LOGICS (17) = LMORT
      LOGICS (18) = LNEDNS
      LOGICS (19) = LOPEVN
      LOGICS (20) = LRCOR2
      LOGICS (21) = LSITE
      LOGICS (22) = LSTART
      LOGICS (23) = LSTATS
      LOGICS (24) = LSPRUT
      LOGICS (25) = LSUMRY
      LOGICS (26) = LTRIP
      LOGICS (27) = MORDAT
      LOGICS (28) = NOTRIP
      LOGICS (29) = LCALC
      LOGICS (30) = LFLAGV
      LOGICS (31) = LBAMAX
      LOGICS (32) = LPRNT
      LOGICS (33) = LFIA
      LOGICS (34) = LZEIDE
      LOGICS (35) = LFIRE
      CALL FMATV (LFM)
      LOGICS (36) = LFM
      LOGICS (37) = FSTOPEN
      CALL CLACTV (LCLM)
      LOGICS (38) = LCLM
      CALL RDATV (LWRD,LZ)
      LOGICS (39) = LWRD
      LOGICS (40) = LSCRN
C
C     WRITE THE LOGICAL SCALARS.
C
      CALL LFWRIT (WK3,IPNT,ILIMIT,LOGICS,MXL,2)
C
C     WRITE THE LOGICAL ARRAYS.
C
      CALL LFWRIT (WK3,IPNT,ILIMIT,LDGCAL,MAXSP,   2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LHTDRG,MAXSP,   2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LHTCAL,MAXSP,   2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LTSTV4,MXTST4,  2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LTSTV5, ITST5,  2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LSPCWE,MAXSP,   2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LREG  ,MXLREG,  2)
      CALL LFWRIT (WK3,IPNT,ILIMIT,LEAVESP,MAXSP,  2)
C
C     STORE THE REAL SCALARS IN THE ARRAY REALS.
C
      REALS ( 1) = AHAT
      REALS ( 2) = ALPHA
      REALS ( 3) = ASPECT
      REALS ( 4) = ATAVD
      REALS ( 5) = ATAVH
      REALS ( 6) = ATBA
      REALS ( 7) = ATCCF
      REALS ( 8) = ATSDIX
      REALS ( 9) = ATTPA
      REALS (10) = AUTMAX
      REALS (11) = AUTMIN
      REALS (12) = AUTEFF
      REALS (13) = AVH
      REALS (14) = BA
      REALS (15) = BAA
      REALS (16) = BAALN
      REALS (17) = BAASQ
      REALS (18) = BAF
      REALS (19) = BAMAX
      REALS (20) = BAMIN
      REALS (21) = BFMIN
      REALS (22) = BHAT
      REALS (23) = BJPHI
      REALS (24) = BJTHET
      REALS (25) = BRK
      REALS (26) = BTSDIX
      REALS (27) = BWAF
      REALS (28) = BWB4
      REALS (29) = CCMIN
      REALS (30) = CEPMRT
      REALS (31) = CFMIN
      REALS (32) = CONFID
      REALS (33) = COVMLT
      REALS (34) = COVYR
      REALS (35) = D0
      REALS (36) = D0MULT
      REALS (37) = DBHDOM
      REALS (38) = DGSD
      REALS (39) = EFF
      REALS (40) = ELEV
      REALS (41) = ELEVSQ
      REALS (42) = ESA
      REALS (43) = ESB
      REALS (44) = ESDRAW
      REALS (45) = FINT
      REALS (46) = FINTH
      REALS (47) = FINTM
      REALS (48) = FPA
      REALS (49) = GAPPCT
      REALS (50) = GROSPC
      REALS (51) = H2COF
      REALS (52) = HDGCOF
      REALS (53) = HGHCH
      REALS (54) = OLDAVH
      REALS (55) = OLDBA
      REALS (56) = OLDFNT
      REALS (57) = OLDTIM
      REALS (58) = OLDTPA
      REALS (59) = ORMSQD
      REALS (60) = PBURN
      REALS (61) = PCTSMX
      REALS (62) = PDCCFN
      REALS (63) = PDBAN
      REALS (64) = PI
      REALS (65) = PMECH
      REALS (66) = PMSDIL
      REALS (67) = PMSDIU
      REALS (68) = POTEN
      REALS (69) = REGCH
      REALS (70) = REGNBK
      REALS (71) = REGT
      REALS (72) = RELDEN
      REALS (73) = RELDM1
      REALS (74) = RMAI
      REALS (75) = RMSQD
      REALS (76) = SAMWT
      REALS (77) = SAWDBH
      REALS (78) = SDIAC
      REALS (79) = SDIBC
      REALS (80) = SDIMAX
      REALS (81) = SLO
      REALS (82) = SLOPE
      REALS (83) = SLPMRT
      REALS (84) = SPCLWT
      REALS (85) = SQBWAF
      REALS (86) = SQREGT
      REALS (87) = SSDBH
      REALS (88) = STOADJ
      REALS (89) = SUMPRB
      REALS (90) = TCFMIN
      REALS (91) = TCWT
      REALS (92) = TFPA
      REALS (93) = THRES1
      REALS (94) = THRES2
      REALS (95) = TIME
      REALS (96) = TLAT
      REALS (97) = TPACRE
      REALS (98) = TPAMIN
      REALS (99) = TPAMRT
      REALS(100) = TPROB
      REALS(101) = TRM
      REALS(102) = VMLT
      REALS(103) = VMLTYR
      REALS(104) = XCOS
      REALS(105) = XCOSAS
      REALS(106) = XSIN
      REALS(107) = XSINAS
      REALS(108) = XTES
      REALS(109) = YR
      REALS(110) = ZBURN
      REALS(111) = ZMECH
      REALS(112) = SVSS
      REALS(113) = TLONG
      REALS(114) = TOTREM
      REALS(115) = AGELST
      REALS(116) = PBAWT
      REALS(117) = PCCFWT
      REALS(118) = FNMIN
      REALS(119) = QMDMSB
      REALS(120) = SLPMSB
      REALS(121) = CEPMSB
      REALS(122) = PTPAWT
      REALS(123) = EFFMSB
      REALS(124) = DLOMSB
      REALS(125) = DHIMSB
      REALS(126) = SDIAC2
      REALS(127) = SDIBC2
      REALS(128) = DBHZEIDE
      REALS(129) = DBHSTAGE
      REALS(130) = DR016
C
C     WRITE THE REAL SCALARS.
C
      CALL BFWRIT (WK3,IPNT,ILIMIT,REALS,MXR,2)

C
C     WRITE THE REAL ARRAYS.
C
      CALL BFWRIT (WK3,IPNT,ILIMIT,AA,     MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ABIRTH, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ACCFSP, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ATTEN,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BAAA,   IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BAAINV, IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BARANK, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB,     MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB0 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB1 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB2 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB3 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB4 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB5 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB6 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB7 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB8 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB9 ,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB10,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB11,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB12,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BB13,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,B0ACCF, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,B1ACCF, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,B0BCCF, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,B1BCCF, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,B0ASTD, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,B1BSTD, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BCCFSP, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BCYMAI, MAXCY1,    2)
      DO 15 I=1,MAXSP
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFDEFT(1,I),9,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFVEQL(1,I),7,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFVEQS(1,I),7,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CFDEFT(1,I),9,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CFVEQL(1,I),7,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CFVEQS(1,I),7,     2)
   15 CONTINUE
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFLA0,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFLA1,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFMIND, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFSTMP, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFTOPD, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BFV,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BJRHO,  40,        2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BKRAT,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,BTRAN,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CFLA0,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CFLA1,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CFV,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,COR,    MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,COR2,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CRCON,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CRWDTH, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CTRAN,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DBH,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DBHIO,  6,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DBHMIN, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DG,     ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DGCCF,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DGCON,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DGDSQ,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DGIO,   6,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,DIFH,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ESB1,   MAXPLT,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ESSEED, 2,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,FL,     MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,FM,     MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,FRMCLS, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,FU,     MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,GMULT,  2,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HCOR,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HCOR2,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HSIG,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HT,     ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HT1,    MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HT2,    MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HTT1, MAXSP*9,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HTT2, MAXSP*9,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HTADJ,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HTCON,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HTG,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HTIO,   6,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,LOGDIA(1,1),21,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,LOGDIA(1,2),21,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,LOGDIA(1,3),21,    2)
      DO 17 I=1,20
      CALL BFWRIT (WK3,IPNT,ILIMIT,LOGVOL(1,I),7,     2)
   17 CONTINUE
      CALL BFWRIT (WK3,IPNT,ILIMIT,OACC,   7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OBFCUR, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OBFREM, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OCVCUR, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OCVREM, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OLDPCT, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OLDRN,  ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OMCCUR, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OMCREM, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OMORT,  7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ONTCUR, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ONTREM, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ONTRES, 7,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPAC,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPBR,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPBV,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPCT,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPCV,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPMC,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPMO,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPMR,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPRT,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPTT,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSPTV,  4,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OVER, IPTINV*MAXSP,2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PARMS,  IMPL-1,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PARMS(ITOPRM), MAXPRM-ITOPRM+1, 2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PASP,   IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PCCF,   IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PCT,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PCTIO,  6,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PNN,    MAXPLT,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PRBIO,  6,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PADV,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PSUB,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PTBAA,  IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PTBALT, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PTPA,   IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PXCS,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SUMPX,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SUMPI,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PLPROB, IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PLTSIZ, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PROB,   ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PROB1,  MAXPLT,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PSLO,   IPTINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PTOCFV, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PMRCFV, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PMRBFV, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,PDBH,   ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,QDBHAT, ICYC+1,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,QSDBT,  ICYC+1,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,RCOR2,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,RDTREE, ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,REIN,   2,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,RELDSP, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,RHCON,  MAXSP,     2)
      K=ICYC+1
      DO 20 I=1,K
      CALL BFWRIT (WK3,IPNT,ILIMIT,ROSUM(1,I),20,     2)
   20 CONTINUE
      CALL BFWRIT (WK3,IPNT,ILIMIT,RSEED,   2,        2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SDIDEF, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SIGMA,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SIGMAR, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SITEAR, MAXSP,     2)
      DO 22 I=1,MAXSP
      DO 21 II=1,4
      CALL BFWRIT (WK3,IPNT,ILIMIT,SIZCAP(I,II),1,    2)
   21 CONTINUE
   22 CONTINUE
      CALL BFWRIT (WK3,IPNT,ILIMIT,SMCON,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,STMP,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SUMPRE, 5,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,TOPD,   MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,TSTV1,  50,        2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,TSTV2,  30,        2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,TSTV3,  20,        2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,TSTV4,  MXTST4,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,TSTV5,  ITST5,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,VARDG,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,WCI,    MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,WK1,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,WK2,    ITRN,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XDMULT, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XESMLT, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XHMULT, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XMDIA1, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XMDIA2, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XMMULT, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XRDMLT, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XRHMLT, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ZRAND,  ITRN,      2)
C
      CALL BFWRIT (WK3,IPNT,ILIMIT,SVSED0, 2,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SVSED1, 2,         2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CRNDIA, NDEAD,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CRNRTO, NDEAD,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OLEN,   NDEAD,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,ODIA,   NDEAD,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,FALLDIR,NDEAD,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,YHFHTS, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,YHFHTH, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,HRATE,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,XSLOC,  NSVOBJ,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,YSLOC,  NSVOBJ,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,X1R1S,  ISVINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,X2R2S,  ISVINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,Y1A1S,  ISVINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,Y2A2S,  ISVINV,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDS0,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDS1,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDS2,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDS3,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDL0,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDL1,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDL2,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWDL3,  MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CWTDBH, MAXSP,     2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,OSTRST, 33*2,      2)
C
      IF (NDEAD .GT. 0) THEN

        CALL BFWRIT (WK3,IPNT,ILIMIT,PBFALL, NDEAD,     2)
        CALL BFWRIT (WK3,IPNT,ILIMIT,SNGDIA, NDEAD,     2)
        CALL BFWRIT (WK3,IPNT,ILIMIT,SNGLEN, NDEAD,     2)
        DO I=1,3
          CALL BFWRIT (WK3,IPNT,ILIMIT,SPROBS(1,I),NDEAD, 2)
        ENDDO
        DO I=0,3
          CALL BFWRIT (WK3,IPNT,ILIMIT,SNGCNWT(1,I),NDEAD, 2)
        ENDDO
      ENDIF

      IF (NCWD .GT. 0) THEN

        CALL BFWRIT (WK3,IPNT,ILIMIT,CWDDIA, NCWD,      2)
        CALL BFWRIT (WK3,IPNT,ILIMIT,CWDLEN, NCWD,      2)
        CALL BFWRIT (WK3,IPNT,ILIMIT,CWDPIL, NCWD,      2)
        CALL BFWRIT (WK3,IPNT,ILIMIT,CWDDIR, NCWD,      2)
        CALL BFWRIT (WK3,IPNT,ILIMIT,CWDWT,  NCWD,      2)
      ENDIF
      CALL BFWRIT (WK3,IPNT,ILIMIT,PHT,    MAXTRE,    2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SITETR, MAXSTR*6,  2)

C
C     WRITE THE VARIANT SPECIFIC VARIABLES.
C
      CALL VARPUT (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)

C
C     WRITE THE COVER VARIABLES...IF THE COVER MODEL IS BEING USED
C     IN THIS STAND.
C
      IF (LCVGO) CALL CVPUT (WK3,IPNT,ILIMIT,ICYC,ITRN)

C
C     WRITE THE MISTLETOE DATA...IF THE MISTLETOE MODEL LINKED TO
C     TO THE SYSTEM (WHICH IS GENERALLY TRUE FOR MOST VARIANTS).
C
      CALL MISACT (LMORED)
      IF (LMORED) CALL MSPPPT (WK3,IPNT,ILIMIT)

C
C     WRITE THE ROOT DISEASE & STEM RUST DATA...IF THE QUICK RR MODEL
C     IS LINKED TO TO THE SYSTEM (WHICH IT IS FOR THE WESTWIDE PINE
C     BEETLE MODEL).
C
 !      CALL RRATV (LRR1, LRR2)
 !      IF (LRR1) CALL RRPPPT (WK3,IPNT,ILIMIT)
C
C     WRITE THE WESTERN ROOT DISEASE MODEL INFORMATION
C
      IF (LWRD) CALL RDPPPT (WK3,IPNT,ILIMIT)

C
C     WRITE THE WESTWIDE PINE BEETLE MODEL STAND-LEVEL DATA THAT
C     IS NEEDED.
C
 !      CALL BMPPPT (IPNT,ILIMIT)
C
C     WRITE THE GENDEFOL/BUDWORM MODEL NUMERIC VARIABLES, IF ACTIVE.
C
 !     CALL BWEPPATV (LBWE)
 !     IF (LBWE) CALL BWEPPPT (WK3,IPNT,ILIMIT,1)
C
C     WRITE THE FIRE MODEL VARIABLES
C
      IF (LFM) CALL FMPPPUT (WK3,IPNT,ILIMIT)

C
C     WRITE THE ECONOMIC MODEL VARIABLES
C
      CALL ECNPUT (WK3,IPNT,ILIMIT)

C
C     WRITE THE DATABASE VARIABLES
C
      CALL DBSPPPUT (WK3,IPNT,ILIMIT)

C
C     WRITE THE CLIMATE-FVS VARIABLES
C
      CALL CLPUT (WK3,IPNT,ILIMIT)

C
C     WRITE THE LAST REAL VARIABLE.
C
      CALL BFWRIT (WK3,IPNT,ILIMIT,XSTORE, MAXPLT,    3)

C
C     CALL CHPUT TO STORE THE CHARACTER DATA
C
      CALL CHPUT
C
      RETURN
      END
