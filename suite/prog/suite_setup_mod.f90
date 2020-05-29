MODULE suite_setup_mod
!
CONTAINS
SUBROUTINE setup_suite_start
!-
! This routine makes start up setup of DISCSU_SUITE
!+
USE appl_env_mod
USE lib_f90_default_mod
USE lib_init_mod
USE prompt_mod
!
pname             = 'suite'
pname_cap         = 'SUITE'
prompt            = pname
prompt_status     = PROMPT_ON
prompt_status_old = PROMPT_ON
!
!     Call initial default allocation
!
CALL lib_alloc_default
!                                                                       
!     Call initialization routine.                                      
!                                                                       
CALL init_sysarrays
!                                                                       
!     get envirmonment information                                      
! 
CALL appl_env (.TRUE.)
!
END SUBROUTINE setup_suite_start
!
!*****7*****************************************************************
SUBROUTINE setup_suite
!                                                                       
!     This routine makes inital setup of DISCUS_SUITE                         
!                                                                       
!USE allocate_appl
!USE blk_appl
!
USE appl_env_mod
USE cmdline_args_mod
USE gen_mpi_mod
USE prompt_mod
USE lib_f90_default_mod
USE random_state_mod
!
IMPLICIT none
!                                                                       
      include'date.inc'
CHARACTER(LEN=13)  :: is_debug
LOGICAL                        :: lend
INTEGER, PARAMETER  :: np = 1
!REAL, DIMENSION(np) :: werte = 0.0
INTEGER, DIMENSION(np) :: iwerte = 0
!                                                                       
lend              = .false.
blank             = ' '
pname             = 'suite'
pname_cap         = 'SUITE'
prompt            = pname
prompt_status     = PROMPT_ON
prompt_status_old = PROMPT_ON
!                                                                       
!ALL ini_ran (np, werte)
CALL ini_ran_ix (np, iwerte, 0)
!
!     Call initial default allocation
!
!CALL lib_alloc_default
!                                                                       
!     Call initialization routine.                                      
!                                                                       
!CALL initarrays
!CALL init_sysarrays
!                                                                       
!     get envirmonment information                                      
!                                                                       
!CALL appl_env (.TRUE., gen_mpi_myid)
!
!     Define terminal color scheme
!
CALL color_set_scheme (.TRUE.,   gen_mpi_myid)
!
IF(gen_mpi_myid==0) THEN
!                                                                       
!------ Write starting screen                                           
!                                                                       
IF(cdebug=='ON') THEN
   is_debug = 'DEBUG VERSION'
ELSE
   is_debug = '             '
ENDIF
version   = aktuell
WRITE ( *, 1000) version, is_debug, cdate
CALL write_appl_env (.TRUE., gen_mpi_myid)
ENDIF
!                                                                       
!     try to read default file                                          
!                                                                       
!CALL autodef
!                                                                       
!     Check for command line parameters                                 
!                                                                       
CALL cmdline_args(gen_mpi_myid)
!                                                                       
lsetup_done = .true.
!
!write(fname,2000) gen_mpi_myid
!2000 format('MEMORY.',I4.4) 
!open(101,file=fname, status='unknown')
!write(101,'(a)') '#INFO            vmpeak     vmsize     vmhwm    vmrss    vmpte'
!write(101,'(a)') '#'
!                                                                       
1000 FORMAT (/,                                                              &
     10x,59('*'),/,                                                          &
     10x,'*', 9x,'D I S C U S - S U I T E  Version ',a10, 5x,'*',/,          &
     10x,'*',22(' '),a13,22(' '),'*',/                                       &
     10x,'*         Created : ',a35,3x,'*',/,                                &
     10x,'*',57('-'),'*',/,                                                  &
     10x,'* (c) R.B. Neder  ','(reinhard.neder@fau.de)                 *',/, &
     10x,'* (c) T. Proffen  ','(tproffen@ornl.gov    )                 *',/, &
     10x,59('*'),/)
END SUBROUTINE setup_suite
!
!
END MODULE suite_setup_mod
