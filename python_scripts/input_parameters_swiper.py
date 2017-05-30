#DESCRIPTION:
#This script is meant to be run by 'input_parameters_swiper.sh' script.
#It stores the values of the final total energy and the DM parameter used during the simulation in a .dat file.
#Such file name is different for different values of anisotropy.

import numpy as np
import matplotlib.pyplot as pl
import os
import sys

d=float(sys.argv[1])
k=float(sys.argv[2])

#specify directory
directory="/UppASD_scripts"

os.chdir("%s/input_files" %(directory))
data = np.loadtxt('totenergy.test2d00.out')
energy = data[-1,1] #get the last element of the second column of data (final total energy)

os.chdir("%s/data/energy_equilibrium_files" %(directory))
#write on file
with open(str("energy_equilibrium_k_%.4fJ.dat" %k), "a") as f:
    f.write(str(d) + '\t' + str(energy) + '\n')
f.close()



