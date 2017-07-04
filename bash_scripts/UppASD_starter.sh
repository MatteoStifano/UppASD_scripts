#DESCRIPTION:
#This script modifies the input files and run the UppASD

#specify directory
dir="/UppASD_scripts"

#define J
j=$(printf '%.9f' "$(echo "0.002127162"|bc -l)")


#define input parameters------------------------------------------------
n=100			          #atoms per side
damping=0.1					#damping parameter
Nstep=1  				    #number of time steps
timestep=1 					#time step value (in picosecond)
trottaj_step=2   		#trottaj_step value
k_over_j=0.005		  #K/J
d_over_j=0.065	    #D/J
#-----------------------------------------------------------------------



#modify input files ---------------------------------------------------------------------
sed -i "2s/.*/ncell     $n        $n	       1  /" $dir/input_files/inpsd.dat
sed -i "25s/.*/damping      	$damping  /" $dir/input_files/inpsd.dat
sed -i "26s/.*/Nstep     	$Nstep  /" $dir/input_files/inpsd.dat
sed -i "27s/.*/timestep  	${timestep}E-12/" $dir/input_files/inpsd.dat
sed -i "31s/.*/tottraj_step   	$trottaj_step/" $dir/input_files/inpsd.dat

k=$(awk "BEGIN {print (${k_over_j})*(${j})}")
sed -i "1s/.*/1   1  -${k}   0.000   0.0   0.0   1.0   0/" $dir/input_files/kfile

d=$(awk "BEGIN {print (${d_over_j})*(${j})}")
sed -i "1s/.*/1 1  1.0  0.0  0.0  0.0 -${d}  0.0/" $dir/input_files/dmfile
sed -i "2s/.*/1 1 -1.0  0.0  0.0  0.0  ${d}  0.0/" $dir/input_files/dmfile
sed -i "3s/.*/1 1  0.0  1.0  0.0  ${d}  0.0  0.0/" $dir/input_files/dmfile
sed -i "4s/.*/1 1  0.0 -1.0  0.0 -${d}  0.0  0.0/" $dir/input_files/dmfile
#-----------------------------------------------------------------------------------------


#run UppASD
$dir/source/sd inpsd.dat
