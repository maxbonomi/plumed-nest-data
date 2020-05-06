# stride for writing xtc file [ps]
step=5

# 1) discard initial 20% of trajectory of each replica
# cycle on all directories
for dir in rep-*
do
 # go into replica dir
 cd $dir
 # cat together trajectories of various iterations
 gmx trjcat -f traj_comp.*.xtc -cat -o tmp.xtc
 # count number of frames
 nframes=`gmx check -f tmp.xtc |& grep Step | awk '{print $2}'`
 # set begin
 b=`echo ${nframes} ${step} | awk '{printf "%d\n",$1*$2*0.2}'`
 # discard 20% and (optionally) skip frames with the option -skip 
 gmx trjconv -f tmp.xtc -b $b -o traj_all.xtc 
 # clean
 rm tmp.xtc
done

# 2) cat together the trajectories of all replicas 
gmx trjcat -f rep-*/traj_all.xtc -cat -o tmp.xtc
# change timestep and starting time
gmx trjconv -f tmp.xtc -timestep 1 -t0 0 -o traj_all.xtc

# 3) run driver on global trajectory to fix PBCs
plumed driver --plumed plumed_driver.dat --mf_xtc traj_all.xtc

# 4) convert test.gro to xtc file
echo 0 | gmx trjconv -f test.gro -o traj_all_PBC.xtc -s ../../0-TOPO/step5_charmm2gmx.pdb -n ../../0-TOPO/index.ndx 

# 5) final clean
rm tmp.xtc traj_all.xtc test.gro rep-*/traj_all.xtc
