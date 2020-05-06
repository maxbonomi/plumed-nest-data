# To run the gromos clustering on the pre-calculated RMSD matrices, you need first
# to compile gromos_clustering.cpp. If you have GNU C++ compiler, you can do:

g++ -O3 gromos_clustering.cpp -o gromos_clustering.x

# Once you have the executable, clustering is done as follows. 
# This assumes you have calculated 128 RMSD matrices in ../3.2-RMSD-MATRIX

# GROMACS executable - update to your path or gmx_mpi
GMX=gmx
# trajectory file
traj=../3.1-ASSEMBLE-XTC/traj_all_PBC.xtc
# count number of frames
nframes=`${GMX} check -f ${traj} |& grep Step | awk '{print $2}'`
# rmsd matrix prefix
RMSD_MATRIX=../3.2-RMSD-MATRIX/RMSD
# cutoff [Ang]
CUT=2.5

# do clustering 
./gromos_clustering.x $RMSD_MATRIX 128 $CUT $nframes

# Output of gromos_clustering
# NOTE: Numbering scheme for clusters and frame IDs starts from 0!
# You will obtain two output files:
# - log.dat: information about the cluster founds: population, and cluster center.
# - trajectory.dat: cluster assignement for each frame of the original trajectory.
