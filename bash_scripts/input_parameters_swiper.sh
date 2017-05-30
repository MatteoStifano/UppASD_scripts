#DESCRIPTION:
#This script modifies the input parameter values and run the UppASD for several values of the DMI parameter and anisotropy. 
#The final purpose is to compute a stability diagram (DM vs. anisotropy) for a given magnetic structure.

#specify directory
dir="/UppASD_scripts"

printf "\n***Bash script: UppASD input parameters swiper***\n\n"

#print time
printf "Starting time:\n"
date
printf "\n"

#erase previous data files
rm $dir/data/energy_equilibrium_files/*.dat
rm $dir/data/energy_time_evolution_files/*.dat
rm $dir/data/restart_files/*.dat

#J value
j=$(printf '%.9f' "$(echo "0.002127162"|bc -l)")

#define input parameters------------------------------------------------
n=100						#atoms per side
damping=0.1					#damping parameter
Nstep_1=2000					#number of time step first run
Nstep_2=1000					#number of time steps following runs
timestep=1 					#time step value (in picosecond)
trottaj_step_1=$Nstep_1    	 		#trottaj_step value first run
trottaj_step_2=$Nstep_2     			#trottaj_step value following runs
#-----------------------------------------------------------------------

#modify input files ----------------------------------------------------
sed -i "2s/.*/ncell     $n        $n	       1  /" $dir/input_files/inpsd.dat
sed -i "25s/.*/damping      	$damping  /" $dir/input_files/inpsd.dat
sed -i "27s/.*/timestep  	${timestep}E-12/" $dir/input_files/inpsd.dat
sed -i "31s/.*/tottraj_step   	$trottaj_step/" $dir/input_files/inpsd.dat
#-----------------------------------------------------------------------

#define k parameter values to swipe
k_over_j_max=0.005
k_over_j_min=0.005
k_over_j_step=0.005
loop_k=$(awk -v j="$j" -v k_over_j_max="$k_over_j_max" -v k_over_j_min="$k_over_j_min" -v k_over_j_step="$k_over_j_step" 'BEGIN{for(k=k_over_j_min*j;k<=k_over_j_max*j;k+=k_over_j_step*j)print k}')

for k in $loop_k #loop over k parameter values
do
		
	k_over_j=$(awk "BEGIN {printf \"%.4f\",${k}/(${j})}") #store k/j value
	printf "Anisotropy parameter value: %.4f J\n\n" $k_over_j
	sed -i "1s/.*/1   1  -${k}   0.000   0.0   0.0   1.0   0/" $dir/input_files/kfile 	#write k value on 'kfile'
		
	flag=0 #flag used to switch over total simulation time
		
	#define DM parameter values to swipe
	d_over_j_max=0.15
	d_over_j_min=0.05
	d_over_j_step=0.05
	loop_d=$(awk -v j="$j" -v d_over_j_max="$d_over_j_max" -v d_over_j_min="$d_over_j_min" -v d_over_j_step="$d_over_j_step" 'BEGIN{for(d=d_over_j_max*j;d>=d_over_j_min*j;d-=d_over_j_step*j)print d}')
		
	for d in $loop_d #loop over DM parameter values
	do
			
		d_over_j=$(awk "BEGIN {printf \"%.4f\",${d}/(${j})}") #store d/j value
		printf "DM parameter value: %.4f J\n" $d_over_j
			
		#write DM vectors values on 'dmfile'
		sed -i "1s/.*/1 1  1.0  0.0  0.0  0.0 -${d}  0.0/" $dir/input_files/dmfile
		sed -i "2s/.*/1 1 -1.0  0.0  0.0  0.0  ${d}  0.0/" $dir/input_files/dmfile
		sed -i "3s/.*/1 1  0.0  1.0  0.0  ${d}  0.0  0.0/" $dir/input_files/dmfile
		sed -i "4s/.*/1 1  0.0 -1.0  0.0 -${d}  0.0  0.0/" $dir/input_files/dmfile

					
		#total simulation time of first run different from following runs
		if [ $flag -eq 0 ]
		then
			Nstep=$Nstep_1   					#define total simulation time
			trottaj_step=$trottaj_step_1     	#define trottaj_step
			flag=1
		else
			Nstep=$Nstep_2	    				#define total simulation time
			trottaj_step=$trottaj_step_2	    #define trottaj_step
		fi
		
		#modify input file
		sed -i "26s/.*/Nstep     	$Nstep  /" $dir/input_files/inpsd.dat
		sed -i "31s/.*/tottraj_step   	$trottaj_step/" $dir/input_files/inpsd.dat

		#run UppASD
		cd $dir/input_files
		rm *.out
		../source/sd inpsd.dat > /dev/null
		
		#save current structure and use it for the following simulation
		cp restart.test2d00.out $dir/data/restart_files/restart_file_k_${k_over_j}J_d_${d_over_j}J_structure_${structure}.dat
		cp restart.test2d00.out restartfile.dat
					
		#save time-evolution energy file
		cp totenergy.test2d00.out $dir/data/energy_time_evolution_files/energy_time_evolution_k_${k_over_j}J_d_${d_over_j}J_structure_${structure}.dat
		
		printf "Time: " #print time
		date
		printf "\n\n"
		
		#run python script
		cd $dir/python_scripts
		python input_parameters_swiper.py $d_over_j $k_over_j
		
	done
done

#print time
printf "Ending time:\n"
date
