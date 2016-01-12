      FUNCTION BRATIO(IS,D,H)
      use prgprm_mod
      implicit none
C----------
C  **BRATIO--EC   DATE OF LAST REVISION:  09/09/13
C----------
C FUNCTION TO COMPUTE BARK RATIOS AS A FUNCTION OF DIAMETER AND SPECIES.
C REPLACES ARRAY BKRAT IN BLKDAT.
C----------
C  COMMONS
C
C  COMMONS
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE EC VARIANT:
C      USE 6(GF) FOR 16(WF)
C      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
C
C  FROM THE WC VARIANT:
C      USE 19(WH) FOR 11(WH)
C      USE 33(PY) FOR 13(PY)
C      USE 31(WB) FOR 14(WB)
C      USE  7(NF) FOR 15(NF)
C      USE 30(LL) FOR 17(LL)
C      USE  8(YC) FOR 18(YC)
C      USE 29(WJ) FOR 19(WJ)
C      USE 21(BM) FOR 20(BM) AND 21(VN)
C      USE 22(RA) FOR 22(RA)
C      USE 24(PB) FOR 23(PB)
C      USE 25(GC) FOR 24(GC)
C      USE 34(DG) FOR 25(DG)
C      USE 26(AS) FOR 26(AS) AND 32(OH)
C      USE 27(CW) FOR 27(CW)
C      USE 28(WO) FOR 28(WO)
C      USE 36(CH) FOR 29(PL)
C      USE 37(WI) FOR 30(WI)
C----------
      REAL BARK1(MAXSP),BARK2(MAXSP),H,D,BRATIO,TEMD,DIB
      INTEGER IS
C
      DATA BARK1/
     &    0.964,     0.851,     0.844,     0.903,     0.950,
     &    0.903,     0.963,     0.956,     0.903,     0.889,
     &  0.93371,     0.934,   0.93329,   0.93329,  0.904973,
     &    0.903,       0.9,  0.837291,   0.94967,    0.0836,
     &   0.0836,  0.075256,    0.0836,   0.15565,  0.075256,
     & 0.075256,  0.075256,    0.8558,  0.075256,  0.075256,
     &    0.934,  0.075256/
C
      DATA BARK2/
     &       1.,        1.,        1.,        1.,        1.,
     &       1.,        1.,        1.,        1.,        1.,
     &       1.,        1.,        1.,        1.,        1.,
     &       1.,        1.,        1.,        1.,   0.94782,
     &  0.94782,   0.94967,   0.94782,   0.90182,   0.94967,
     &  0.94967,   0.94967,    1.0213,   0.94967,   0.94967,
     &       1.,   0.94967/
C----------
      SELECT CASE (IS)
C----------
C  ORIGINAL EC VARIANT SPECIES (WP,WL,DF,SF,RC,GF,LP,ES,AF,PP,OS)
C  THOSE SPECIES USING EC COEFFICIENTS (WF,VN)
C----------
      CASE(1:10,12,16,31)
        BRATIO=BARK1(IS)
C----------
C  THOSE SPECIES USING WC COEFFICIENTS
C  WH, MH, PY, WB, NF, LL, YC, WJ
C----------
      CASE(11,13:15,17:19)
        BRATIO=BARK1(IS)
C----------
C  THOSE SPECIES USING WC COEFFICIENTS; DIB = a + b*DOB
C  BM, VN, RA, PB, GC, DG, AS, CW, PL, WI, OH
C----------
      CASE(20:27,29:30,32)
        IF (D .GT. 0) THEN
          DIB=BARK1(IS) + BARK2(IS)*D
          BRATIO=DIB/D
        ELSE
          BRATIO = 0.99
        ENDIF
        IF(BRATIO .GT. 0.99) BRATIO=0.99
        IF(BRATIO .LT. 0.80) BRATIO=0.80
C----------
C  THOSE SPECIES USING WC COEFFICIENTS; DIB = a * DOB ** b
C  WO
C----------
      CASE(28)
        IF (D .GT. 0) THEN
          DIB=BARK1(IS)*D**BARK2(IS)
          BRATIO=DIB/D
        ELSE
          BRATIO = 0.99
        ENDIF
        IF(BRATIO .GT. 0.99) BRATIO=0.99
        IF(BRATIO .LT. 0.80) BRATIO=0.80
      END SELECT
C
      RETURN
      END

