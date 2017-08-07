module Random
implicit none

  public :: rnorm,      &
            init_random_seed

contains

	subroutine check(status)
		use netcdf
		integer, intent (in) :: status
    
    		if(status /= nf90_noerr) then 
      			print*, trim(nf90_strerror(status))
      			stop "Stopped"
    		end if
	end subroutine check

subroutine rnorm(fn_val)
	real, intent(out) :: fn_val
	real :: u, sum
	real      :: v, sln
	real, parameter :: one = 1.0, vsmall = TINY( one )

  DO
    CALL RANDOM_NUMBER( u )
    CALL RANDOM_NUMBER( v )
    u = SCALE( u, 1 ) - one
    v = SCALE( v, 1 ) - one
    sum = u*u + v*v + vsmall         ! vsmall added to prevent LOG(zero) / zero
    IF(sum < one) EXIT
  END DO
  sln = SQRT(- SCALE( LOG(sum), 1 ) / sum)
  fn_val = u*sln

end subroutine rnorm


!!! Subroutine form gcc.gnu.org
        subroutine init_random_seed()
#ifdef IFORT
        USE IFPORT
#endif

            integer, allocatable :: seeds(:)
            integer :: i, n, dt(8), pid, t(2), s
            integer(8) :: count, tms
          
            call random_seed(size = n)
            allocate(seeds(n))
               call system_clock(count)
               if (count /= 0) then
                  t = transfer(count, t)
               else
                  call date_and_time(values=dt)
                  tms = (dt(1) - 1970) * 365_8 * 24 * 60 * 60 * 1000 &
                       + dt(2) * 31_8 * 24 * 60 * 60 * 1000 &
                       + dt(3) * 24 * 60 * 60 * 60 * 1000 &
                       + dt(5) * 60 * 60 * 1000 &
                       + dt(6) * 60 * 1000 + dt(7) * 1000 &
                       + dt(8)
                  t = transfer(tms, t)
               end if
               s = ieor(t(1), t(2))
               pid = getpid() + 1099279 ! Add a prime
               s = ieor(s, pid)
               if (n >= 3) then
                  seeds(1) = t(1) + 36269
                  seeds(2) = t(2) + 72551
                  seeds(3) = pid
                  if (n > 3) then
                     seeds(4:) = s + 37 * (/ (i, i = 0, n - 4) /)
                  end if
               else
                  seeds = s + 37 * (/ (i, i = 0, n - 1 ) /)
               end if
!            end if
            call random_seed(put=seeds)
          end subroutine init_random_seed

         
! This simple PRNG might not be good enough for real work, but is
! sufficient for seeding a better PRNG.
subroutine lcgf(s,lcg)
	use iso_fortran_env, only: int64
    integer, intent(out) :: lcg
    integer(int64), intent(in) :: s
    integer(int64) :: sv
    if (s == 0) then
    	sv = 104729
    else
        sv = mod(s, 4294967296_int64)
    end if
    sv = mod(sv * 279470273_int64, 4294967291_int64)
    lcg = int(mod(sv, int(huge(0), int64)), kind(0))
end subroutine lcgf

end module Random
