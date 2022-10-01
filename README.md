# Fully-Automated-FHIaims-Stepping
Instructions for Running Pulling Out/Pushing In Junctions with FHI-aims Bash Script

FILES NEEDED:
- run.sh
- control.in
- geometry.in
- runT.sh
- batch_script.py
- aimsconverter.py
- runTconverter.py
- EandT.py

NECESSARY CHANGES IN EACH FILE:
1. run.sh
    line 9: path to the working directory   (ACTIVE=...)
    line 24: change the number of steps you want to take    (n<=10)
    line 66: change the atom numbers in the generate tcontrol command to atom numbers that are in the pack planes of the electrodes     (/projectnb/kamenet/Programs/FHIaims/Previous_Attempts/fhi-aims.171221/bin/tcontrol.aims.x -lsurc 11 -lsurx 15 -lsury 16 -rsurc 30 -rsurx 31 -rsury 35 -nlayers 2 -ener -0.4 -estep 0.001 -eend 0.1)

2. control.in
    make sure that lines 12 and 33 are commented out and line 28 is uncommented

3. geometry.in
    follow instructions for generating the geometry.in file

4. runT.sh
    line 9: change path to working directory (ACTIVE=...)
    
5. batch_script.py
    line 8: "nmolecule" is the number of atoms in your molecule
	line 9: "nelectrodeL" is the number of atoms in your first electrode
	line 10: "nLrelax" is the number of atoms in the first electrode that are not frozen during the calculation
	line 11: "nelectrodeR" is the number of atoms in your second electrode 
	line 12: "nRrelax" is the number of atoms in the second electrode that are not frozen during the calculation
	line 13: "InorOut" can either be "In" or "Out". If you are pulling the junction out then its "Out" and pushing in its "In". It will exit the calculation if you put in any other words
    make sure that the elements you use in the calculation are listed after line 183. if not add in an additional element variable and elif loop with the corresponding atomic number

6. aimsconverter.py
    change lines 8-13 to be the same as in batch_script.py
    
7. runTconverter.py
    line 27: change substra variable to the current working directory  ("ACTIVE=...")
    line 39: only change the part of the path that is the same as the working directory. Make sure you have after the working directory 'step%s" % stepnum)'. 
    
8. EandT.py
    line 36: change the variable pathb in the same way as line 39 in runTconverter.py by only changing the working directory and leaving the step%s ...
    

GENERATING GEOMETRY.IN:  
1. Generate an initial electrode-molecule-electrode structure and relax it in FHI-aims normally. 
2. After it is fully relaxed, convert the atom coordinates to and XYZ file as normally done and open it up in Chemcraft
3. Select one of the central Au atoms towards the rear of each electrode (one of the Au atoms that are frozen and not allowed to move during the relaxation step)
4. With only those two Au atoms selected, go to the dropdown Edit menu and under the "Translate Atomic Coordinates", click on "Align two selected atoms along the Z axis".
5. Now save the structure as XYZ file named geometry.xyz
6. Next open geometry.xyz and make sure the atoms belonging to the molecule are first, the atoms belonging to the electrode with the Au atom that is at the origin (0.0,0.0,0.0) are next and then last is the other electrode.
7. Also make sure the Au atoms that are allowed to move during the relaxation calculation are the first atoms corresponding to each electrode (for example if the molecule has 6 atoms and its bound to two 18 Au electrodes, the molecule atoms will be lines 1-6, the Au electrode that has one atom at the origin will be lines 7-24 with the four apex atoms in lines 7,8,9,10 and the final electrode will be lines 25-42 with the four apex atoms in lines 25,26,27,28)
8. Save the geometry.xyz file and then run the xyz2aims.py script on your local computer to generate the geometry.in file
9. Manually add in the lines of "  constrain_relaxation .true." below the Au atoms that are frozen during the relaxation calculation and save the file. 


RUNNING THE PROCEDURE

Once all that is set, type in to the command line
- qsub run.sh

Once all of the steps have completed type into the command line
- module load python3/3.7.7
- python EandT.py n             *n is the number of steps + 1. So if you did 10 steps, the command would be "python EandT.py 11"
