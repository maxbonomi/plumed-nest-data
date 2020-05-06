#!/bin/bash

# Name of the job
#SBATCH -J RMSD_MATRIX
#SBATCH -N1
#SBATCH --ntasks-per-node=1
#SBATCH --array=0-127

#### THIS NEED TO BE CHANGED TO YOUR CLUSTER SPECS 
# load necessary modules
module purge
module use /c6/shared/modulefiles/
module add gcc/6.3.1-devtoolset-6
module add cuda/10.0.130_410.48
module add openmpi/2.1.2
module add slurm
module add java/oracle/jre/1.8.0_101
module add anaconda3/2018.12
module add autoconf/2.69

# activate conda environment
. /c6/shared/anaconda3/2018.12/etc/profile.d/conda.sh
conda activate mdaenv 

# load gromacs
source ~/bin/gromacs-2019.6-AVX_256/bin/GMXRC

### NO NEED TO CHANGE BELOW
# trajectory file
traj=../3.1-ASSEMBLE-XTC/traj_all_PBC.xtc

# count number of frames
nframes=`gmx_mpi check -f ${traj} |& grep Step | awk '{print $2}'`
# total number of entries in rmsd matrix
nentries=`echo ${nframes} | awk '{printf "%d\n",$1*($1-1)/2}'`
# number of entries per task - rounded up
ntask=`echo ${nentries} | awk '{printf "%d\n",$1/128+1}'`
# id of the job
id=$SLURM_ARRAY_TASK_ID
# range of entries for rmsd calculation
i0=$(( $id * $ntask ))
i1=$(( $i0 + $ntask ))
# check if over limit, and reset
if [ $i1 -gt $nentries ]; then i1=$nentries; fi

# go
python get_rmsd_matrix.py ../../0-TOPO/step5_charmm2gmx.pdb $traj 5.0 RMSD.$id $i0 $i1
