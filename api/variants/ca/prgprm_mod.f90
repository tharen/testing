module prgprm_mod
    implicit none
    ! TODO: PRGPRM.F77 is deeply embedded.
    !CODE SEGMENT PRGPRM
    !----------
    !  **PRGPRM--CA    DATE OF LAST REVISION:  08/23/2012
    !----------
    !
    !     PARAMETERS FOR THE PROGNOSIS MODEL ARE:
    !
          INTEGER   MAXTRE,MAXTP1,MAXPLT,MAXSP,MAXCYC,MAXCY1,MAXSTR,MXFRCDS
          PARAMETER (MAXTRE=3000)
          PARAMETER (MAXTP1=MAXTRE+1)
          PARAMETER (MAXPLT=500)
          PARAMETER (MAXSP =49)
          PARAMETER (MAXCYC=40)
          PARAMETER (MAXCY1=MAXCYC+1)
          PARAMETER (MAXSTR=20)
          PARAMETER (MXFRCDS=20)
    !
    !     *** PARAMETERS OF OPTION PROCESSING ARE IN COMMON OPCOM ***
    !
    !     MAXTRE= THE MAX NUMBER OF TREE RECORDS THAT PROGNOSIS CAN PROCESS.
    !             NOTE: A REALISTIC MIN VALUE FOR THIS PARAMETER IS ABOUT
    !                   400.  IF THE ESTABLISHMENT EXTENSION IS NOT BEING
    !                   USED, A SOMEWHAT SMALLER VALUED MAY BE USED.  ALSO
    !                   NOTE THAT CHANGING THIS PARAMETER MAY CHANGE THE
    !                   MODELS BEHAVIOR.  THE NORMAL SETTING IS 1350.
    !     MAXTP1= THE MAX NUMBER OF TREE RECORDS PLUS 1.
    !     MAXPLT= THE MAX NUMBER OF INDIVIDUAL PLOTS THAT PROGNOSIS CAN
    !             PROCESS.
    !     MAXSP = THE MAX NUMBER OF SPECIES REPRESENTED IN THE MODEL.
    !     MAXCYC= THE MAX NUMBER OF CYCLES ALLOWED IN THE MODEL.
    !     MAXCY1= THE MAX NUMBER OF CYCLES PLUS 1.
    !     MAXSTR= MAXIMUM NUMBER OF SITE TREES.
    !     MXFRCDS=MAXIMUM FOREST CODES (ESCOMN).
    !-----END SEGMENT
end module prgprm_mod