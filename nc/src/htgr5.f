      SUBROUTINE HTGR5(ISP,SSITE,BAA,YHTG,RELHT,CR,H)
      use contrl_mod
      use prgprm_mod
      implicit none
C----------
C  **HTGR5--NC   DATE OF LAST REVISION:  04/03/08
C----------
C
C SUBROUTINE TO CALCULATE 5-YEAR HEIGHT GROWTH
C SPECIES INDEX 1-OC, 2-WP, 3-DF, 4-WF, 5-M , 6-IC, 7-BO,
C               8-TO, 9-RF, 10-PP, 11-OTHER
C
C----------
      REAL HRELHT(11),HCRSQ(11),HHT(11),HBA(11),HSITE(11),HCON(11)
      REAL H,CR,RELHT,YHTG,BAA,SSITE,HTGR
      INTEGER IMETH(11),ISP
      DATA HRELHT/11*4.292/
      DATA HCRSQ/11*0.0566/
      DATA HHT/11*0.1699/
      DATA HBA/4*-0.00828,-0.54648,-0.00828,-0.78296,-0.58984,
     &    2*-0.00828,-0.54984/
      DATA HSITE/11*0.00768/
      DATA IMETH/1,1,1,1,2,1,2,2,1,1,2/
      DATA HCON/4*-2.193,3.560,-2.193,3.817,3.385,2*-2.193,
     &   3.385/
C
      IF(IMETH(ISP) .EQ. 2) GO TO 100
      HTGR=HCON(ISP) + RELHT*HRELHT(ISP) + HCRSQ(ISP)*CR*CR
     &    + HHT(ISP) * H + HBA(ISP)*BAA + HSITE(ISP)*SSITE
      GO TO 300
  100 CONTINUE
      IF(BAA .LE. 5.0)BAA=5.0
      HTGR = EXP(HCON(ISP) + HBA(ISP)*ALOG(BAA))
C----------
C  ROUTINE FOR HARDWOODS
C----------
  300 CONTINUE
      IF(HTGR .LE. 0.0)HTGR = 0.01
      YHTG=HTGR
      RETURN
      END
