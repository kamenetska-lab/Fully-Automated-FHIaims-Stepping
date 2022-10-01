#!/bin/bash -l

#$ -P kamenet

#$ -pe omp 16

#$ -l h_rt=12:00:00

ACTIVE=/projectnb/kamenet/Brent/FHIaims/au18_c4da_au18/

export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export MKL_DYNAMIC=FALSE

ulimit -s unlimited

module load gcc/5.5.0
module load intel/2019.5
module load openmpi/3.1.4_intel-2019
module load cuda/9.2
module load python3/3.7.7

n=1
for ((n=1; n<=10; n++))
do
nohup mpirun -np 16 /projectnb/kamenet/Programs/FHIaims/fhi-aims.171221/bin/aims.171221_1.scalapack.mpi.x < /dev/null | tee aims.dft.out

mkdir step$n

cp aims.dft.out aimstemp.dft.out
cp aims.dft.out "aims$n.dft.out"
cp aims.dft.out step$n

cp geometry.in geometrytemp.in
cp geometry.in geometryinitial$n.in
cp geometryinitial$n.in step$n

rm geometry.in

cp geometry.in.next_step geometry.in
cp geometry.in step$n
rm geometry.in

cp control.in controltemp.in
rm control.in

python aimsconverter.py

nohup mpirun -np 16 /projectnb/kamenet/Programs/FHIaims/fhi-aims.171221/bin/aims.171221_1.scalapack.mpi.x < /dev/null | tee aims.dft.out

cp mos.aims step$n
cp omat.aims step$n
cp basis-indices.out step$n

rm aims.dft.out
cp aimstemp.dft.out aims.dft.out
rm geometry.in

python batch_script.py

cp geometry.xyz geometryrelaxed$n.xyz
cp geometryrelaxed$n.xyz step$n

cd step$n

/projectnb/kamenet/Programs/FHIaims/Previous_Attempts/fhi-aims.171221/bin/tcontrol.aims.x -lsurc 29 -lsurx 33 -lsury 34 -rsurc 48 -rsurx 49 -rsury 53 -nlayers 2 -ener -0.4 -estep 0.001 -eend 0.1

cd ..

cp runT.sh runTcp.sh

python runTconverter.py $n

cp runTtemp.sh runT.sh

cp runT.sh step$n

cd step$n

qsub runT.sh

cd ..


#rm runTtemp.sh
#rm runT.sh
#cp runTcp.sh runT.sh
 


rm geometry.xyz
rm mos.aims
rm aims.dft.out
rm geometrytemp.in
rm aimstemp.dft.out
rm omat.aims
rm aims$n.dft.out
rm control.in
cp controltemp.in control.in
rm controltemp.in
rm basis-indices.out
rm geometry.in.next_step

done
