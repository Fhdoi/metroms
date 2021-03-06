#!/usr/bin/env bash
#SBATCH --job-name=RUN_sst
#SBATCH -A nn9348k
#SBATCH --ntasks=32
#SBATCH --mem=29000MB
#SBATCH --time 0-20:00:00
#SBATCH --mail-type=ALL
# #SBATCH --partition=gaussian

cd $SLURM_SUBMIT_DIR

#datstamp=`date +%Y_%m_%d_%H_%M`
#exec 1>/work/$USER/tmproms/run/arctic-20km/run.log_${datstamp} 2>&1
# Load modules needed
source myenv.bash
cp /home/sfr009/metroms/apps/common/python/* .

module purge
module load intel/13.4
module load netCDF/4.2.1.1-intel-13.4
module load OpenMPI/1.8.1-intel-13.4
module load imkl/11.0.0
module load FFTW/3.3.3
module load Python/2.7.3
#
mpirun -np 20 /global/work/sfr009/Coupled_Pert/EnKF_ROCE/LEnKF
#python Ensemble_arctic20km.py
#python sample_arctic20km.py
