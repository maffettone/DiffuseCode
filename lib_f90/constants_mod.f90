MODULE constants_mod
!
IMPLICIT NONE
SAVE
!
INTEGER, PARAMETER :: IS_UNKNOWN = -1
INTEGER, PARAMETER :: IS_SCAL    =  0
INTEGER, PARAMETER :: IS_VEC     =  1
INTEGER, PARAMETER :: IS_ARR     =  2
!
INTEGER, PARAMETER :: IS_INTE =  0
INTEGER, PARAMETER :: IS_REAL =  1
INTEGER, PARAMETER :: IS_CHAR =  2
!
INTEGER, PARAMETER :: IS_WRITE =  0   ! Read/write
INTEGER, PARAMETER :: IS_READ  =  1   ! Read only
!
END MODULE constants_mod
