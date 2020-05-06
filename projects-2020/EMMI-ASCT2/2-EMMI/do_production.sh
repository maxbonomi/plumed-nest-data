# 1) prepare replica directories
# Recent GROMACS versions require a separate directory for each metainference replica.
# You can create 16 directories [rep-00 to rep-15] with this bash command:

for i in `seq 0 15`; do j=`printf "%02d\n" $i`; mkdir rep-${j}; done

# 2) extract frames from equilibration trajectory
# You can use gmx trjconv and the option -sep to extract .gro files of the entire system from a trr file of the 
# last equilibration step.

echo 0 | gmx trjconv -f ../1-EQUIL/step6.6_equilibration.trr -s ../1-EQUIL/step6.6_equilibration.tpr -sep -o conf.gro 

# 3) create tpr files, one for each replica
# You can use gmx grompp with 16 randomly-extracted .gro files obtained at 2) + step7_production.mdp to create 16 tpr files.
# Put each tpr file in the corresponding rep-?? directory, name it topol.tpr, and put also a copy of the plumed.dat file 
# in each rep-?? directory. You can do all this using:

for i in `seq 0 15`
do
 j=`printf "%02d\n" $i`
 # create tpr file
 gmx grompp -f step7_production.mdp -c conf${i}.gro -n ../0-TOPO/index.ndx -o rep-${j}/topol.tpr 
 # copy master PLUMED input file to replica directory
 # Please check that relative paths to other needed files (relative to rep-?? directory!) are correct
 cp plumed.dat rep-${j}
done

# 4) run code
# Follow the procedure you normally use in your cluster. Each replica should run on a single node/CPU (on multiple cores!),
# as the EMMI restraint is currently parallelized only with OpenMP - not MPI. Use GPUs if you have them!

gmx_mpi mdrun -multidir rep-* -pin on -ntomp $OMP_NUM_THREADS -plumed plumed.dat -cpi -noappend

# 5) restart
# Use the normal GROMACS procedure (-cpi states files) + uncomment "RESTART" in the PLUMED input files.
