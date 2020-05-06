import MDAnalysis
import MDAnalysis.analysis.rms
import MDAnalysis.analysis.align
import numpy as np
import sys
import math

# initialize MDAnalysis
# load PDB
u = MDAnalysis.Universe(sys.argv[1])
# load XTC/DCD/TRR
u.load_new(sys.argv[2])
# selection for alignment/displacement: heavy atoms of residues with at least one atom within cutoff from ligand
# in at least one frame of the trajectory
CUTOFF_ = float(sys.argv[3])
# get all the atoms within cutoff + ligand atoms (heavy + hydrogens)
sel = 'resname LIG or around '+str(CUTOFF_)+' resname LIG'
# length of trajectory 
n = len(u.trajectory)
# cycle on trajectory and collect residues in CUTOFF
reslist = []
for i in range(0, n):
    # go to frame i
    u.trajectory[i]
    # get atoms
    rmsd_sel = u.select_atoms(sel)
    # extend residue list
    reslist += list(rmsd_sel.residues.resids)
# remove duplicate and order
reslist = sorted(list(set(reslist)))
# now create string for selection with list of residues in reslist
sel='resid '
for r in reslist:
    sel+=str(r)+" "
# now exclude hydrogens
sel+=' and not type H'
# do the selection 
rmsd_sel = u.select_atoms(sel)

# open output log file
log=open(sys.argv[4], "w")

# first and last frame
k0 = int(sys.argv[5])
k1 = int(sys.argv[6])

# cycle on pairs and write on a separate file
for k in range(k0, k1):
    # map one-dimensional index to two-dimensional indexes 
    i = int(n - 2 - math.floor(math.sqrt(-8*k + 4*n*(n-1)-7)/2.0 - 0.5))
    j = int(k + i + 1 - n*(n-1)/2 + (n-i)*((n-i)-1)/2) 
    # go to frame i
    u.trajectory[i]
    # copy positions
    A = rmsd_sel.positions.copy()
    # go to frame j
    u.trajectory[j]
    # copy positions
    B = rmsd_sel.positions.copy()
    # calculate RMSD after optimal alignment
    rmsd = MDAnalysis.analysis.rms.rmsd(A, B, superposition=True)
    # print on file
    log.write("%6d %6d %6.3f\n" % (i, j, rmsd)) 

# close file
log.close()
