      SUBROUTINE VARPUT (WK3,IPNT,ILIMIT,REALS,LOGICS,INTS)
      use prgprm_mod
      use organon_mod
      implicit none
C----------
C  $Id: varput.f 874 2013-05-16 19:44:36Z drobinsonessa@gmail.com $
C----------
C
C     WRITE THE VARIANT SPECIFIC VARIABLES.
C
C     PART OF THE PARALLEL PROCESSING EXTENSION TO PROGNOSIS.
C----------
COMMONS
C----------
C     NOTE: THE ACTUAL STORAGE LIMIT FOR INTS, LOGICS, AND REALS
C     IS MAXTRE (SEE PRGPRM).
C
C     ALL VARIABLES ARE IN THE ORGANON.F77 COMMON BLOCK
C----------
      INTEGER ILIMIT,IPNT,MXL,MXI,MXR,I,II
      PARAMETER (MXL=3,MXI=8,MXR=9)
      LOGICAL LOGICS(MXL)
      REAL WK3(MAXTRE)
      INTEGER*4 INTS(MXI)
      REAL*4 REALS(MXR)
      INTEGER INTS2(1)
C----------
C     PUT THE INTEGER SCALARS USING IFWRIT, MXI + 1 OF THEM
C----------
      INTS( 1) = CYCLG
      INTS( 2) = VERSION
      INTS( 3) = NPTS
      INTS( 4) = NTREES1
      INTS( 5) = STAGE
      INTS( 6) = BHAGE
      INTS( 7) = NTREES2
      INTS( 8) = IERROR
      CALL IFWRIT (WK3, IPNT, ILIMIT, INTS, MXI, 2)
      INTS2( 1) = ITEST
      CALL IFWRIT (WK3, IPNT, ILIMIT,INTS2,   1, 2)
C----------
C     PUT THE INTEGER ARRAYS USING IFWRIT
C----------
      CALL IFWRIT (WK3,IPNT,ILIMIT, TREENO, 2000,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,   PTNO, 2000,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,SPECIES, 2000,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,   USER, 2000,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,   INDS,   30,   2)
      DO 11 I=1,2000
      DO 10 II=1,3
      CALL IFWRIT (WK3,IPNT,ILIMIT,PRAGE(I,II),1,   2)
   10 CONTINUE
   11 CONTINUE
      DO 16 I=1,2000
      DO 15 II=1,3
      CALL IFWRIT (WK3,IPNT,ILIMIT,BRCNT(I,II),1,   2)
   15 CONTINUE
   16 CONTINUE
      DO 21 I=1,2000
      DO 20 II=1,40
      CALL IFWRIT (WK3,IPNT,ILIMIT, BRHT(I,II),1,   2)
   20 CONTINUE
   21 CONTINUE
      DO 26 I=1,2000
      DO 25 II=1,40
      CALL IFWRIT (WK3,IPNT,ILIMIT,BRDIA(I,II),1,   2)
   25 CONTINUE
   26 CONTINUE
      DO 31 I=1,2000
      DO 30 II=1,40
      CALL IFWRIT (WK3,IPNT,ILIMIT,JCORE(I,II),1,   2)
   30 CONTINUE
   31 CONTINUE
      CALL IFWRIT (WK3,IPNT,ILIMIT,    NPR, 2000,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT, SERROR,   35,   2)
      DO 36 I=1,2000
      DO 35 II=1,6
      CALL IFWRIT (WK3,IPNT,ILIMIT,TERROR(I,II),1,   2)
   35 CONTINUE
   36 CONTINUE
      CALL IFWRIT (WK3,IPNT,ILIMIT, SWARNING,   9,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,TWARNING, 2000,   2)
      CALL IFWRIT (WK3,IPNT,ILIMIT,    IORG, 2000,   2)
C----------
C     PUT THE LOGICAL SCALARS USING LFWRIT, MXL OF THEM.
C----------
      LOGICS ( 1) = LORGANON
      LOGICS ( 2) = LORGVOLS
      LOGICS ( 3) = LORGPREP
      CALL LFWRIT (WK3, IPNT, ILIMIT, LOGICS, MXL, 2)
C----------
C     PUT THE REAL SCALARS USING BFWRIT, MXR OF THEM.
C----------
      REALS( 1) = SITE_1
      REALS( 2) = SITE_2
      REALS( 3) = MSDI_1
      REALS( 4) = MSDI_2
      REALS( 5) = MSDI_3
      REALS( 6) = BABT
      REALS( 7) = LOGTA
      REALS( 8) = LOGML
      REALS( 9) = LOGLL
      CALL BFWRIT (WK3, IPNT, ILIMIT, REALS, MXR, 2)
C----------
C     PUT THE REAL ARRAYS USING BFWRIT.
C----------
      CALL BFWRIT (WK3,IPNT,ILIMIT,  DBH1, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT, HT1OR, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,   CR1, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,EXPAN1, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT, SCR1B, 2000,      2)
      DO 51 I=1,3
      DO 50 II=1,18
      CALL BFWRIT (WK3,IPNT,ILIMIT,ACALIB(I,II),1,    2)
   50 CONTINUE
   51 CONTINUE
      CALL BFWRIT (WK3,IPNT,ILIMIT,    PN,    5,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,   YSF,    5,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,  BART,    5,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,   YST,    5,      2)
      DO 56 I=1,2000
      DO 55 II=1,3
      CALL BFWRIT (WK3,IPNT,ILIMIT,PRLH(I,II),1,    2)
   55 CONTINUE
   56 CONTINUE
      DO 61 I=1,2000
      DO 60 II=1,3
      CALL BFWRIT (WK3,IPNT,ILIMIT,PRDBH(I,II),1,    2)
   60 CONTINUE
   61 CONTINUE
      DO 66 I=1,2000
      DO 65 II=1,3
      CALL BFWRIT (WK3,IPNT,ILIMIT,PRHT(I,II),1,    2)
   65 CONTINUE
   66 CONTINUE
      DO 71 I=1,2000
      DO 70 II=1,3
      CALL BFWRIT (WK3,IPNT,ILIMIT,PRCR(I,II),1,    2)
   70 CONTINUE
   71 CONTINUE
      DO 76 I=1,2000
      DO 75 II=1,3
      CALL BFWRIT (WK3,IPNT,ILIMIT,PREXP(I,II),1,    2)
   75 CONTINUE
   76 CONTINUE
      CALL BFWRIT (WK3,IPNT,ILIMIT, MGEXP, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,  DGRO, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,  HGRO, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,MORTEXP, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,CRCHNG, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,SCRCHNG, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,  STOR,   30,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT, RVARS,   30,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,  DBH2, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT, HT2OR, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,   CR2, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT,EXPAN2, 2000,      2)
      CALL BFWRIT (WK3,IPNT,ILIMIT, SCR2B, 2000,      2)
C
      RETURN
      END

      SUBROUTINE VARCHPUT (CBUFF, IPNT, LNCBUF)
      use prgprm_mod
      implicit none
C----------
C     Put variant-specific character data
C----------


      INTEGER LNCBUF
      CHARACTER CBUFF(LNCBUF)
      INTEGER IPNT
      ! Stub for variants which need to get/put character data
      ! See /bc/varget.f and /bc/varput.f for examples of VARCHGET and VARCHPUT
      RETURN
      END
