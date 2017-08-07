program Gen_pseudo


	use netcdf
	use m_pseudo2D
	use Random


      	real				:: rh = 200
	integer, parameter		:: nx = 322, ny= 242, dims = 5
	double precision		:: Amat(nx,ny), Amat3d(nx,ny,dims)
	integer				:: ncid, x_dimid, y_dimid, N_dimid, dimids(3), i
	integer				:: varid
	integer 			:: start(3), count(3)
	character(len=*),parameter 	:: AN_in = 'AN_2008_unlim.nc'
	character(len=*),parameter 	:: AN_ut = 'AN_2008_unlim_pert.nc'
	real, dimension(nx,ny,dims)	:: Tair1,C1,U1,V1,P1


	call check( nf90_create('Pseudo_fields.nc', NF90_CLOBBER, ncid) )
	call check( nf90_def_dim(ncid, "x", nx, x_dimid) )
	call check( nf90_def_dim(ncid, "y", ny, y_dimid) )
	call check( nf90_def_dim(ncid, "N",   5, N_dimid) )

	

	dimids =  (/ x_dimid, y_dimid, N_dimid /)

	call check( nf90_def_var(ncid, "Mat", NF90_REAL, dimids, varid) )

	call check( nf90_enddef(ncid) )


	n1 = ceiling(log(real(nx) + 2.*rh)/log(2.))
	n1 = 2**n1
	n2 = ceiling(log(real(ny) + 2.*rh)/log(2.))
	n2 = 2**n2

	do i = 1,5
		call init_random_seed()
		call pseudo2D(Amat,nx,ny,1,rh,n1,n2)
		Amat3d(:,:,i) = Amat(:,:)
	enddo

	start = (/ 1, 1, 1/)
	count = (/ nx, ny, dims/)


!	! read
!	call check( nf90_open(AN_in, nf90_nowrite, ncid) )
!	call check( nf90_inq_varid(ncid, 'Tair', varid) )
!	call check( nf90_get_var(ncid, varid, Tair1, start = start, count = count)) 

!	call check( nf90_inq_varid(ncid, 'cloud', varid) )
!	call check( nf90_get_var(ncid, varid, C1, start = start, count = count))

!	call check( nf90_inq_varid(ncid, 'Uwind', varid) )
!	call check( nf90_get_var(ncid, varid, U1, start = start, count = count))

!	call check( nf90_inq_varid(ncid, 'Vwind', varid) )
!	call check( nf90_get_var(ncid, varid, V1, start = start, count = count))
!	
!	print*, shape(Tair1)


!	call check( nf90_close(ncid) )


!	! write
!  	call check( nf90_open(AN_ut, nf90_write, ncid) )
!	call check( nf90_inq_varid(ncid, 'Tair', varid) )
!	call check( nf90_put_var(ncid, varid, Tair1(:,:,:), start = start, count = count) )	
!	call check( nf90_close(ncid) )


	




	call check( nf90_put_var(ncid, varid, Amat3d, start = start, count = count) )
	call check( nf90_close(ncid) )



end program Gen_pseudo
