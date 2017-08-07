module m_cmplx2real
contains
subroutine cmplx2real (x,y,n)

integer i,n
real    y(*)
complex x(*)

do i=1,n
 y(2*i-1)=real(x(i))
 y(2*i)=aimag(x(i))
end do

end subroutine cmplx2real
end module m_cmplx2real
