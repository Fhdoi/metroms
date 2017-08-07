module m_pseudo2D
implicit none

#ifdef AIX
   integer :: naux1,naux2,naux3,nn,s1
   double precision, dimension(:), allocatable,save :: aux1,aux2,aux3
#endif


contains
subroutine pseudo2D(Amat,nx,ny,lde,rh,n1,n2)
#if defined (QMPI)
   use qmpi, only: master, stop_mpi
#else
   use qmpi_fake
#endif

! This routine calculates the pseudo random filds using
! the procedure outlined in Evensen (1994) \cite{eve94a}.

   use m_zeroin
   implicit none
   integer, intent(in) :: nx,ny           ! horizontal dimensions
   integer, intent(in) :: lde             ! number of fields stored at the time
   double precision, intent(out)   :: Amat(nx,ny,lde) ! generated random fields
   real, intent(in)    :: rh              ! Horizontal decorrelation length
   integer, intent(in) :: n1,n2           ! horizontal dimensions in fft grid

   integer*8, save :: plan
   real*8 :: fftwy(n1,n2)
   include 'fftw3.f'


   real, save ::  rh_save=0.0  ! saving rh used in preprocessing.  Allow for new call to
                               ! zeroin if rh changes.

   real, save :: sigma,sigma2
   real, save :: c
   integer, save :: n1_save=0
   integer, save :: n2_save=0


   integer l,p,j,m,i
   real kappa2,lambda2,kappa,lambda
   real pi2,deltak,accum
   real a1,b1,tol,fval

   double precision, allocatable    :: fampl(:,:,:)
   double precision, allocatable    :: phi(:,:)
   double precision, allocatable    :: y(:,:)   ! Physical field
   double complex, allocatable 	 	:: x(:,:)   ! Fourier amplitudes

   real, parameter :: dx=1.0
   real, parameter :: pi=3.141592653589

   real, external :: func2D

   
   if (lde < 1)    stop 'pseudo2D: error lde < 1'
   if (rh <= 0.0)  stop 'pseudo2D: error, rh <= 0.0'
   if (n1 < nx)    stop 'pseudo2D: n1 < nx'
   if (n2 < ny)    stop 'pseudo2D: n2 < ny'

   allocate(fampl(0:n1/2,-n2/2:n2/2,2))
   allocate(phi(0:n1/2,-n2/2:n2/2))

   allocate(y(0:n1+1,0:n2-1))
   allocate(x(0:n1/2,0:n2-1))


   pi2=2.0*pi
   deltak=pi2**2/(real(n1*n2)*dx*dx)
   kappa=pi2/(real(n1)*dx)
   kappa2=kappa**2
   lambda=pi2/(real(n2)*dx)
   lambda2=lambda**2

	!write(*,*), pi2, deltak,kappa,kappa2,lambda,lambda2
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Initialization.
   if (rh /= rh_save .or. n1 /= n1_save .or. n2 /= n2_save) then
      rh_save=rh
      n1_save=n1
      n2_save=n2


      if (master) then
         print *,'Using FFTW for fourier transform'
         print *,'Feel the power of the Fastest Fourier Transform in the West!'
      end if


      rh_save=rh
      if (master) print '(a,2f6.2)','pseudo2D: Solving for sigma',rh,dx
      a1=0.1e-07
      b1=0.1e-06
      tol=0.1e-10
      if (master) print *,'pseudo2D: Go into  zeroin'
      call zeroin(func2D,sigma,a1,b1,tol,rh,dx,fval,n1,n2)
      if (master) print *,'pseudo2D: Leaving  zeroin'

      sigma2=sigma**2
      accum=0.0
      do p=-n2/2+1,n2/2
      do l=-n1/2+1,n1/2

      accum=accum+exp(-2.0*(kappa2*real(l*l)+lambda2*real(p*p))/sigma2)

      enddo
      enddo
      if (master) print*,'pseudo2D: Leving do loop'

      c=sqrt(1.0/(deltak*accum))

      if (master) print *,'pseudo2D: sigma  ',sigma
      if (master) print *,'pseudo2D: c=     ',c
   endif
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	 
   do j=1,lde
      ! Calculating the random wave phases
      call random_number(phi)
      phi=pi2*phi

      ! Calculating the wave amplitues
      do p=-n2/2,n2/2
      do l=0,n1/2 

         fampl(l,p,1)=&
            exp(-(kappa2*real(l*l)+lambda2*real(p*p))/sigma2)*&
            cos(phi(l,p))*sqrt(deltak)*c
         fampl(l,p,2)=&
            exp(-(kappa2*real(l*l)+lambda2*real(p*p))/sigma2)*&
            sin(phi(l,p))*sqrt(deltak)*c

      enddo
      enddo
      fampl(0,0,2)=0.0

	 
      do p=0,n2/2-1
         x(:,p)=cmplx(fampl(:,p,1),fampl(:,p,2))
      enddo

      do p=n2/2,n2-1
         x(:,p)=cmplx(fampl(:,-n2+p,1),fampl(:,-n2+p,2))
      enddo

      !print *,'IA32 fft ...',nx,ny,n1,n2
      call dfftw_plan_dft_c2r_2d(plan,n1,n2,x,fftwy,FFTW_ESTIMATE)
      !write(*,*), x
	  !Here it crashes
	  call dfftw_execute(plan)
      call dfftw_destroy_plan(plan)
      !print *,'IA32 fft done...'
      y(0:n1-1 ,0:n2-1)=fftwy(1:n1,1:n2)
      y(n1:n1+1,0:n2-1)=fftwy(1:2 ,1:n2)


      do m=1,ny
      do i=1,nx
         Amat(i,m,j)=y(i-1,m-1)
      enddo
      enddo


   enddo


   deallocate(fampl, phi, y, x)


end subroutine pseudo2D
end module m_pseudo2D
