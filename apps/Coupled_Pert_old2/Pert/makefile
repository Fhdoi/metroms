# makefile3 : letʼs use some makefile variables
objects = func2D.F90 qmpi.F90 my_Random.F90 m_zeroin.F90 m_cmplx2real.F90 m_pseudo2D.F90 Gen_pseudo.F90
FC = mpif90 
Lib = -lnetcdff -lnetcdf -llapack -lblas -lfftw3
Inc = 

# Se litt nærmere på hva jeg trenger her
FFLAGS = -fpic -mcmodel=large -r8 -CB -fpp -D IFORT

LKF : $(objects)
	$(FC) -o Gpse $(objects) $(Inc) $(Lib) $(FFLAGS) 
%.o : %.f90
	$(FC) ${FFLAGS} -c $< $(Inc) $(Lib) $(FFLAGS) 

%.o : %.F90
	$(FC) ${FFLAGS} -c $< $(Inc) $(Lib) $(FFLAGS)

clean:
	rm -f *.o *.mod *.MOD
veryclean: clean
	rm -f Gpse *.out *~ *.dat *.uf *.nc
