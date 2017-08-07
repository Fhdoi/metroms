from netCDF4 import Dataset
from datetime import datetime, timedelta, date
import numpy as np
import time
import os

def perturbF(inn_d,year,ens):

	os.system('/home/sfr009/metroms/apps/Coupled_Pert/Pert/Gpse')

	t0 = time.time()
	Mat_file = '/home/sfr009/metroms/apps/Coupled_Pert/Pert/Pseudo_fields.nc'
	dir 	 = '/global/work/sfr009/Arctic-20km/ERA/'
	#dir 	 = ' '
	AN_in 	 = dir + 'AN_' + str(year) + '_unlim.nc'
	AN_ut 	 = dir + 'AN_' + str(year) + '_unlim_pert.nc'
	FC_in	 = dir + 'FC_' + str(year) + '_unlim.nc'
	FC_ut 	 = dir + 'FC_' + str(year) + '_unlim_pert.nc'

	ref_date = datetime(year,1,1,00)
	# Read pseudo random matrix
	M = Dataset(Mat_file, mode='r')
	Mat = M.variables['Mat'][:]
	M.close()
	d1 = (inn_d - date.toordinal(ref_date))*4
	d2 = d1+40
	print d1
	t1 = time.time()
	print t1-t0

	# Perturb AN variables
	A1 = Dataset(AN_in, mode='r')
	A2 = Dataset(AN_ut, mode='r+')

	Tair1 = A1.variables['Tair'][d1:d2,:,:]
	Tair2 = A2.variables['Tair']
	Tair2[d1:d2,:,:] = Tair1[:,:,:] + 10*Mat[0,:,:]

	t1 = time.time()
	print t1-t0

	C1 = A1.variables['cloud'][d1:d2,:,:]
	C2 = A2.variables['cloud']
	temp = C1[:,:,:] + 0.2*Mat[1,:,:]
	t1 = time.time()
	print t1-t0

	temp[temp > 1] = 1
	temp[temp < 0] = 0
	dims = temp.shape
	C2[d1:d2,:,:] = temp

	t1 = time.time()
	print t1-t0

	U1 = A1.variables['Uwind'][d1:d2,:,:]
	U2 = A2.variables['Uwind']
	U2[d1:d2,:,:] = U1[:,:,:] + Mat[2,:,:]

	t1 = time.time()
	print t1-t0

	V1 = A1.variables['Vwind'][d1:d2,:,:]
	V2 = A2.variables['Vwind']
	
	V2[d1:d2,:,:] = V1[:,:,:] + Mat[3,:,:]

	t1 = time.time()
	print t1-t0

	A1.close()
	A2.close()


	# Perturb FC variables
	F1 = Dataset(FC_in, mode='r')
	F2 = Dataset(FC_ut, mode='r+')

	P1 = F1.variables['rain'][d1:d2,:,:]
	P2 = F2.variables['rain']
	temp = P1[:,:,:] + 1.728*0.0001*Mat[4,:,:]
	t1 = time.time()
	print t1-t0

	dims = temp.shape
	temp[temp < 0] = 0

	P2[d1:d2,:,:] = temp

	t1 = time.time()
	print t1-t0

	F1.close()
	F2.close()

	str1 = 'cp /global/work/sfr009/Arctic-20km/ERA/FC_2010_unlim_pert.nc'
	str2 = '/global/work/sfr009/Arctic-20km/ERA/FC_2010_unlim_pert' +str(ens) +'.nc'
	os.system(str1 + ' ' +  str2)
