########################################################################
# Python-modules:
########################################################################
import numpy as np
import os
import Constants
from shutil import copyfile, move
from datetime import datetime, timedelta, date
########################################################################
# METROMS-modules:
########################################################################
from GlobalParams import *
from Params import *
from ModelRun import *
import Perturb
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

start_date = datetime(2010,1,01,00)
#end_date   = datetime(2010,01,11,00)

new_end = date.fromordinal(date.toordinal(start_date) +interval)
end_date = datetime(new_end.year, new_end.month, new_end.day,00)


Max_ens=10
run='Coupled_Results/Coupled_Pert'
orig_folder='/global/work/sfr009/Coupled_Pert/tmproms/run/arctic-20km/'
ice_folder='/global/work/sfr009/Coupled_Pert/tmproms/run/arctic-20km/cice/rundir/restart/'
dest_folder='/global/work/sfr009/'+run+'/'
obs_folder='/global/work/sfr009/OSISAF/'


if os.path.isdir(dest_folder) is False:
	os.mkdir( dest_folder, 0755 );
	print "Path is created"


for periods in range(2,3):
	copyfile(ice_folder+'ice.restart_file', ice_folder+'ice.restart_file_org')
	for Ens in range(1,Max_ens+1):
                if Ens < 10:
                        member = '00' + str(Ens)
                elif Ens > 9 and Ens < 100:
                        member = '0' + str(Ens)
                else:
                        member = str(Ens)
		#Perturb.perturbF(date.toordinal(start_date),start_date.year,Ens)
		# If not first period, get restart files from assimilation folder
		if periods > 1:


			if start_date.month >= 10 and start_date.day >= 10:
				date_string1 = str(start_date.year) + '-' + str(start_date.month) + '-' + str(start_date.day) + '-00000'
			elif start_date.month < 10 and start_date.day >= 10:
				date_string1 = str(start_date.year) + '-0' + str(start_date.month) + '-' + str(start_date.day) + '-00000'
			elif start_date.month >= 10 and start_date.day < 10:
				date_string1 = str(start_date.year) + '-' + str(start_date.month) + '-0' + str(start_date.day) + '-00000'
			else:
				date_string1 = str(start_date.year) + '-0' + str(start_date.month) + '-0' + str(start_date.day) + '-00000'

			print start_date.day
			print start_date.month
			print date_string1
			copyfile(dest_folder + 'ocean.' + date_string1  + '_' + member + '.nc', orig_folder+'ocean_ini.nc')
			copyfile( dest_folder+'iced.' + date_string1  + '_' + member + '.nc', ice_folder+'iced.' + date_string1 + '.nc')
		

		a20params=Params(app,xcpu,ycpu,start_date,end_date,nrrec=-1,cicecpu=icecpu,restart=False)
		modelrun=ModelRun(a20params)

		modelrun.preprocess()
		modelrun.run_roms(Constants.MPI,Constants.NODEBUG,Constants.MET64) #24h hindcast
		#modelrun.run_roms(Constants.DRY,Constants.NODEBUG,Constants.MET64) #24h hindcast
		modelrun.postprocess()


		if end_date.month >= 10 and end_date.day >= 10:
			date_string2 = str(end_date.year) + '-' + str(end_date.month) + '-' + str(end_date.day) + '-00000'
		elif end_date.month < 10 and end_date.day >= 10:
			date_string2 = str(end_date.year) + '-0' + str(end_date.month) + '-' + str(end_date.day) + '-00000'
		elif end_date.month >= 10 and end_date.day < 10:
			date_string2 = str(end_date.year) + '-' + str(end_date.month) + '-0' + str(end_date.day) + '-00000'
		else:
			date_string2 = str(end_date.year) + '-0' + str(end_date.month) + '-0' + str(end_date.day) + '-00000'
		
		
		#print orig_folder+'ocean_his_0001.nc'
		#print dest_folder + 'ocean.' + date_string2  +str(Ens) + '.nc'

		os.rename(orig_folder+'ocean_rst.nc', dest_folder + 'ocean.' + date_string2  + '_' + member + '.nc')

		
		os.rename(ice_folder+'iced.' + date_string2 + '.nc', dest_folder+'iced.' + date_string2  + '_' + member + '.nc')
		
		copyfile(ice_folder+'ice.restart_file', dest_folder+'ice.restart_file') #copy ice.restart_file
		if Ens<Max_ens:
			copyfile(ice_folder+'ice.restart_file_org', ice_folder+'ice.restart_file')

		        # Move history files to results folder
        	source=source=orig_folder+'cice/rundir/history/'
        	dest=dest_folder+'History/Ens'+str(Ens)+'/'
        	files = os.listdir(source)
        	for f in files:
                	move(source+f,dest+f)

	# Rename restart files
        for Ens in range(1,Max_ens+1):
        	if Ens < 10:
			member = '00' + str(Ens)
		elif Ens > 9 and Ens < 100:
			member = '0' + str(Ens)
		else:
			member = str(Ens)
		os.rename(dest_folder + 'ocean.' + date_string2  + '_' + member + '.nc', dest_folder + 'ocean_mem' + member + '.nc')
                os.rename(dest_folder + 'iced.' + date_string2  + '_' + member + '.nc', dest_folder + 'iced_mem' + member + '.nc')

	# Copy observations
	os.rename(obs_folder + 'osisaf.' + date_string2 + '.nc', obs_folder + 'this_day.nc')

	# Assimilate
	os.chdir('/global/work/sfr009/Coupled_Pert/Assim_enkf-c/')
	os.system('./assimilate')
	os.chdir('/home/sfr009/metroms/apps/Coupled_Pert')

	# Copy observations back
	os.rename(obs_folder + 'this_day.nc', obs_folder + 'osisaf.' + date_string2 + '.nc')

	# Copy restart files bac
	for Ens in range(1,Max_ens+1):
		if Ens < 10:
			member = '00' + str(Ens)
		elif Ens > 9 and Ens < 100:
			member = '0' + str(Ens)
		else:
			member = str(Ens)
		os.rename(dest_folder + 'ocean_mem' + member + '.nc',dest_folder + 'ocean.' + date_string2  + '_' + member + '.nc')
		os.rename(dest_folder + 'iced_mem' + member + '.nc',dest_folder + 'iced.' + date_string2  + '_' + member + '.nc')
	# New dates for next periods
	new_start = date.fromordinal(date.toordinal(start_date) +interval)
	new_end = date.fromordinal(date.toordinal(end_date) +interval)

	start_date = datetime(new_start.year, new_start.month, new_start.day,00)
	end_date = datetime(new_end.year, new_end.month, new_end.day,00)

	


	
