########################################################################
# Python-modules:
########################################################################
import numpy as np
import os
import Constants
from shutil import copyfile
from datetime import datetime, timedelta, date
########################################################################
# METROMS-modules:
########################################################################
from GlobalParams import *
from Params import *
from ModelRun import *
########################################################################
########################################################################
# Set cpus for ROMS:
xcpu=3
ycpu=8
# Set cpus for CICE:
icecpu=8
# Choose a predefined ROMS-application:
app='arctic-20km' # Arctic-20km
interval=10

start_date = datetime(2010,03,1,00)
end_date   = datetime(2010,03,11,00)

Max_ens=11
run='test_ensemble'
orig_folder='/global/work/sfr009/Free_ROCE/tmproms/run/arctic-20km/'
ice_folder='/global/work/sfr009/Free_ROCE/tmproms/run/arctic-20km/cice/rundir/restart/'
dest_folder='/global/work/sfr009/'+run+'/'

if os.path.isdir(dest_folder) is False:
	os.mkdir( dest_folder, 0755 );
	print "Path is created"


for periods in range(2,5):
	copyfile(ice_folder+'ice.restart_file', ice_folder+'ice.restart_file_org')
	for Ens in range(1,Max_ens):


		# If not first period, get restart files from assimilation folder
		if periods > 1:


			if start_date.month > 10 and start_date.day > 10:
				date_string1 = str(start_date.year) + '-' + str(start_date.month) + '-' + str(start_date.day) + '-00000'
			elif start_date.month < 10 and start_date.day > 10:
				date_string1 = str(start_date.year) + '-0' + str(start_date.month) + '-' + str(start_date.day) + '-00000'
			elif start_date.month > 10 and start_date.day < 10:
				date_string1 = str(start_date.year) + '-' + str(start_date.month) + '-0' + str(start_date.day) + '-00000'
			else:
				date_string1 = str(start_date.year) + '-0' + str(start_date.month) + '-0' + str(start_date.day) + '-00000'

			print start_date.day
			print start_date.month
			print date_string1
			copyfile(dest_folder + 'ocean.' + date_string1  + '_' + str(Ens) + '.nc', orig_folder+'ocean_ini.nc')
			copyfile( dest_folder+'iced.' + date_string1  + '_' + str(Ens) + '.nc', ice_folder+'iced.' + date_string1 + '.nc')
		

		a20params=Params(app,xcpu,ycpu,start_date,end_date,nrrec=-1,cicecpu=icecpu,restart=False)
		modelrun=ModelRun(a20params)

		modelrun.preprocess()
		modelrun.run_roms(Constants.MPI,Constants.NODEBUG,Constants.MET64) #24h hindcast
		#modelrun.run_roms(Constants.DRY,Constants.NODEBUG,Constants.MET64) #24h hindcast
		modelrun.postprocess()


		if end_date.month > 10 and end_date.day > 10:
			date_string2 = str(end_date.year) + '-' + str(end_date.month) + '-' + str(end_date.day) + '-00000'
		elif end_date.month < 10 and end_date.day > 10:
			date_string2 = str(end_date.year) + '-0' + str(end_date.month) + '-' + str(end_date.day) + '-00000'
		elif end_date.month > 10 and end_date.day < 10:
			date_string2 = str(end_date.year) + '-' + str(end_date.month) + '-0' + str(end_date.day) + '-00000'
		else:
			date_string2 = str(end_date.year) + '-0' + str(end_date.month) + '-0' + str(end_date.day) + '-00000'


		
		
		#print orig_folder+'ocean_his_0001.nc'
		#print dest_folder + 'ocean.' + date_string2  +str(Ens) + '.nc'
		

		os.rename(orig_folder+'ocean_rst.nc', dest_folder + 'ocean.' + date_string2  + '_' + str(Ens) + '.nc')


		os.rename(ice_folder+'iced.' + date_string2 + '.nc', dest_folder+'iced.' + date_string2  + '_' +str(Ens) + '.nc')
		
		copyfile(ice_folder+'ice.restart_file', dest_folder+'ice.restart_file') #copy ice.restart_file
		if Ens<Max_ens-1:
			copyfile(ice_folder+'ice.restart_file_org', ice_folder+'ice.restart_file')


	# Assimilate

	#mpirun./EnKF
	os.system("mpirun -np 10 /home/sfr009/EnKF_ROCE/LEnKF")
	#os.system("/home/sfr009/EnKF_ROCE/LEnKF")


	# New dates for next periods
	new_start = date.fromordinal(date.toordinal(start_date) +interval)
	new_end = date.fromordinal(date.toordinal(end_date) +interval)

	start_date = datetime(new_start.year, new_start.month, new_start.day,00)
	end_date = datetime(new_end.year, new_end.month, new_end.day,00)

	


	
