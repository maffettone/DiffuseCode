MODULE refine_add_param_mod
!
IMPLICIT NONE
!
CONTAINS
!
!*******************************************************************************
!
SUBROUTINE refine_add_param(line, length)
!
!  Add a new parameter. values of existing parameters a updated
!
USE refine_allocate_appl
USE refine_params_mod
!
USE errlist_mod
USE define_variable_mod
USE get_params_mod
USE ber_params_mod
USE calc_expr_mod
USE take_param_mod
!
IMPLICIT NONE
!
CHARACTER(LEN=*), INTENT(INOUT) :: line
INTEGER         , INTENT(INOUT) :: length
!
LOGICAL, PARAMETER :: IS_DIFFEV = .TRUE.
INTEGER, PARAMETER :: MAXW = 20
!
CHARACTER(LEN=1024), DIMENSION(MAXW) :: cpara
INTEGER            , DIMENSION(MAXW) :: lpara
!REAL               , DIMENSION(MAXW) :: werte
!
INTEGER                              :: n_params    ! temp number of parameters
INTEGER                              :: ianz, iianz
INTEGER                              :: i, j
LOGICAL                              :: is_new = .FALSE.  ! is a new parameter name
!
CHARACTER(LEN=1024)                  :: string
CHARACTER(LEN=  16)                  :: pname
INTEGER                              :: lpname
INTEGER                              :: laenge
INTEGER                              :: indxg
INTEGER                              :: ipar         ! enty number for this parameter
!
LOGICAL                              :: lrefine
!
REAL                                 :: range_low    ! template for parameter
REAL                                 :: range_high   ! ranges 
!
INTEGER, PARAMETER :: MAXF=2
CHARACTER(LEN=1024), DIMENSION(MAXF) :: ccpara
INTEGER            , DIMENSION(MAXF) :: llpara
REAL               , DIMENSION(MAXF) :: wwerte
!
INTEGER, PARAMETER :: NOPTIONAL = 3
INTEGER, PARAMETER :: OVALUE    = 1
INTEGER, PARAMETER :: OSTATUS   = 2
INTEGER, PARAMETER :: ORANGE    = 3
CHARACTER(LEN=1024), DIMENSION(NOPTIONAL) :: oname   !Optional parameter names
CHARACTER(LEN=1024), DIMENSION(NOPTIONAL) :: opara   !Optional parameter strings returned
INTEGER            , DIMENSION(NOPTIONAL) :: loname  !Lenght opt. para name
INTEGER            , DIMENSION(NOPTIONAL) :: lopara  !Lenght opt. para name returned
LOGICAL            , DIMENSION(NOPTIONAL) :: lpresent  !opt. para present
REAL               , DIMENSION(NOPTIONAL) :: owerte   ! Calculated values
INTEGER, PARAMETER                        :: ncalc = 0 ! Number of values to calculate
!
DATA oname  / 'value ' , 'status'  ,  'range' /
DATA loname /  5       ,  6        ,   5      /
opara  =  (/ '-1.00000', '0.000000',  '0.000000'/)   ! Always provide fresh default values
lopara =  (/  8        ,  8        ,   8        /)
owerte =  (/  -1.0     ,  0.0      ,   0.0      /)
!
CALL get_params(line, ianz, cpara, lpara, MAXW, length)
!
CALL get_optional(ianz, MAXW, cpara, lpara, NOPTIONAL,  ncalc, &
                  oname, loname, opara, lopara, lpresent, owerte)
IF(ier_num/=0) RETURN
!
IF(ianz/=1) THEN
   ier_num = -6
   ier_typ = ER_FORT
   RETURN
ENDIF
!
pname  = ' '
pname  = cpara(1)(1:MIN(lpara(1),LEN(pname)))
lpname = MIN(lpara(1),LEN(pname))
cpara(1) = '0'
lpara(1) = 1
!
string = 'real, '//pname
laenge = 6+lpname
CALL define_variable(string, laenge, IS_DIFFEV)           ! Define as user variable
IF(ier_num/=0) THEN
   ier_msg(1) = 'Could not define variable name'
   RETURN
ENDIF
!
! Set starting value for parameter, if 'value:' was given
!
IF(lpresent(OVALUE)) THEN
   IF(opara(OVALUE)/='current') THEN                      ! User did not specify "current"
      WRITE(string,'(a,a,a)') pname(1:lpname), ' = ', opara(OVALUE)(1:lopara(OVALUE))
      indxg = lpname + 2
      CALL do_math (string, indxg, length)
      IF(ier_num/=0) THEN
         ier_msg(1) = 'Could not set parameter value'
         RETURN
      ENDIF
   ENDIF
ENDIF
!
! Set parameter ranges, if 'range:' was given
!
range_low  = +1.0
range_high = -1.0
IF(lpresent(ORANGE)) THEN
   IF(opara(ORANGE)(1:1) == '[' .AND. opara(ORANGE)(lopara(ORANGE):lopara(ORANGE)) == ']') THEN
      string = opara(ORANGE)(2:lopara(ORANGE)-1)
      length = lopara(ORANGE)-2
      ccpara(:) = ' '
      llpara(:) = 0
      wwerte(:) = 0.0
      CALL get_params (string, iianz, ccpara, llpara, MAXF, length)
      IF(ier_num /= 0) THEN
         ier_msg(1) = 'Incorrect ''range:[]'' parameter'
         RETURN
      ENDIF
      CALL ber_params (iianz, ccpara, llpara, wwerte, MAXF)
      IF(ier_num /= 0) THEN
         ier_msg(1) = 'Incorrect ''range:[]'' parameter'
!        ier_msg(2) = 'Variables can only be arrays with'
!        ier_msg(3) = 'one or two dimensions '
         RETURN
      ENDIF
      IF(iianz==2) THEN
         range_low  = wwerte(1)
         range_high = wwerte(2)
      ELSE
         ier_num = -6
         ier_typ = ER_FORT
         ier_msg(1) = 'Incorrect ''range:[]'' parameter'
         RETURN
      ENDIF
   ELSE
      ier_msg(1) = 'Incorrect ''range:[]'' parameter'
      RETURN
   ENDIF
ENDIF
!
! A parameter is added to the list of refined parameters only if
! the status is set to 'refine' or 'free'. Otherwise it is omited
! from the list of parameters.
! Fixed parameters are addedc to the list refine_fixed instead.
!
lrefine = .TRUE.
IF(lpresent(OSTATUS)) THEN
  IF(opara(OSTATUS)=='refine' .OR. opara(OSTATUS)=='free') THEN
      lrefine = .TRUE.
   ELSEIF(opara(OSTATUS)=='fix' .OR. opara(OSTATUS)=='fixed') THEN
      lrefine = .FALSE.
   ELSE
      ier_num = -6
      ier_typ = ER_FORT
      ier_msg(1) = 'Unknown keyword for ''status:'' '
      RETURN
   ENDIF
ELSE
   lrefine = .TRUE.
ENDIF
!
ipar = 1
IF(lrefine) THEN
   is_new = .TRUE.
   old: DO i=1, refine_par_n
      IF(pname == refine_params(i)) THEN        ! Found old parameter name
         ipar = i
         is_new = .FALSE.
         EXIT old
      ENDIF
   ENDDO old
!
   IF(is_new) THEN                              ! New parameter, add to list
      IF(refine_par_n==REF_MAXPARAM) THEN
         n_params = REF_MAXPARAM + 10
         CALL alloc_params(n_params)
      ENDIF
      refine_par_n = refine_par_n + 1
      refine_params(refine_par_n)   = pname
      ipar = refine_par_n
   ENDIF
   refine_range(ipar,1) = range_low
   refine_range(ipar,2) = range_high
!
   fixed: DO i=1, refine_fix_n                 ! Remove from fixed list
      IF(pname == refine_fixed(i)) THEN        ! Found old parameter name
         DO j=i+1, refine_fix_n
            refine_fixed(j-1) = refine_fixed(j)
         ENDDO
         refine_fix_n = refine_fix_n - 1
         EXIT fixed
      ENDIF
   ENDDO fixed
ELSE
   is_new = .TRUE.
   old_f: DO i=1, refine_fix_n
      IF(pname == refine_fixed(i)) THEN        ! Found old parameter name
         ipar = i
         is_new = .FALSE.
         EXIT old_f
      ENDIF
   ENDDO old_f
!
   IF(is_new) THEN                              ! New parameter, add to list
      IF(refine_fix_n==REF_MAXPARAM_FIX) THEN
         n_params = REF_MAXPARAM_FIX + 10
         CALL alloc_params_fix(n_params)
      ENDIF
      refine_fix_n = refine_fix_n + 1
      refine_fixed(refine_fix_n)   = pname
   ENDIF
ENDIF
!
!
END SUBROUTINE refine_add_param
!
!*******************************************************************************
!
END MODULE refine_add_param_mod
