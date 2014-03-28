! Copied from http://git.mcs.anl.gov/MCT.git/blob_plain/HEAD:/examples/climate_concur1

      program master

      implicit none

      include "mpif.h"

      character(len=*), parameter :: mastername='master.F90'

      integer, parameter :: ncomps = 2   ! Must know total number of
                                         ! components in coupled system

      integer, parameter :: AtmID = 1    ! pick an id for the atmosphere
      integer, parameter :: CplID = 2    ! pick an id for the coupler




! MPI variables
      integer :: splitcomm, rank, nprocs,compid, myID, ierr,color
      integer :: anprocs,cnprocs

!-----------------------------------------------------------------------
! The Main program.
! We are implementing a single-executable, concurrent-execution system.
!
! This small main program carves up MPI_COMM_WORLD and then starts
! each component on its own processor set.

      ! Initialize MPI
      call MPI_INIT(ierr)

      ! Get basic MPI information
      call MPI_COMM_SIZE(MPI_COMM_WORLD,nprocs,ierr)
      call MPI_COMM_RANK(MPI_COMM_WORLD,rank,ierr)

      ! Create MPI communicators for each component
      !
      ! each component will run on half the processors
      !
      ! set color
      if (rank .lt. nprocs/2) then
        color = 0
      else
        color = 1
      endif


      ! Split MPI_COMM_WORLD into communicators for each component.
      call MPI_COMM_SPLIT(MPI_COMM_WORLD,color,0,splitcomm,ierr)


      ! Start the components
      select case (color)
         case(0)
            call model(splitcomm,ncomps,AtmID)
         case(1)
            call coupler(splitcomm,ncomps,CplID)
         case default
            print *, "color error, color = ", color
      end select

      ! Components are done
      call MPI_FINALIZE(ierr)


    end program master
