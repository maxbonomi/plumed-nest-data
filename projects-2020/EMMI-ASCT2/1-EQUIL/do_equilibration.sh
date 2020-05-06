# topology dir
TOP=../0-TOPO/
# set path to GROMACS gmx/gmx_mpi
EXE=gmx_mpi

# NOTE: adapt this to run on your cluster (mpi stuff...)
# First minimization 
# step6.0
$EXE grompp -f step6.0_minimization.mdp -o step6.0_minimization.tpr -c ${TOP}/step5_charmm2gmx.pdb -r ${TOP}/step5_charmm2gmx.pdb -p ${TOP}/topol.top
$EXE mdrun -v -deffnm step6.0_minimization

# Equilibration steps: step6.1 to step6.6
for cnt in `seq 1 6`
do
    if [ ${cnt} -eq 1 ]; then 
        $EXE grompp -f step6.${cnt}_equilibration.mdp -o step6.${cnt}_equilibration.tpr -c step6.0_minimization.gro -r ${TOP}/step5_charmm2gmx.pdb -n ${TOP}/index.ndx -p ${TOP}/topol.top 
        $EXE mdrun -v -deffnm step6.${cnt}_equilibration
    else
        pcnt=$(( $cnt - 1 ))
        $EXE grompp -f step6.${cnt}_equilibration.mdp -o step6.${cnt}_equilibration.tpr -c step6.${pcnt}_equilibration.gro -r ${TOP}/step5_charmm2gmx.pdb -n ${TOP}/index.ndx -p ${TOP}/topol.top
        $EXE mdrun -v -deffnm step6.${cnt}_equilibration
    fi 
done
