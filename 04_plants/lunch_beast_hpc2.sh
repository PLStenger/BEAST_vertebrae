#!/bin/bash
#SBATCH --job-name=lunch_beast_hpc2
#SBATCH --ntasks=1
#SBATCH -p gdec
#SBATCH --time=10-00:00:00
#SBATCH --mem=500G
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/lunch_beast_hpc2.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/lunch_beast_hpc2.out"

# Pour télécharger la bonne version de Beast (2.7.8) (il est important de ne pas prendre une autre version pour éviter les conflits):
# https://www.beast2.org

# Si linux:
# wget https://www.beast2.org/download-linux-x86/
# tar fxz BEAST.v2.7.7.Linux.x86.tgz
# cd beast/bin
# Puis pour lancer beast: ./beast/bin/beast

module load conda/4.12.0
source ~/.bashrc
#source activate beast
module load java/oracle-1.8.0_45
#module load BEAST/2.5.2
module load gcc/8.1.0
module load beagle/3.1.2

WORKING_DIRECTORY=/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/beast/bin

# S'il y a des conflits avec d'autres version Beagle:
# Masquer les anciennes libs conda BEAGLE
#for f in libhmsbeagle.so libhmsbeagle.so.1 libhmsbeagle-jni.so libhmsbeagle-cpu-sse.so libhmsbeagle-cpu.so libhmsbeagle-cpu-sse.so.31.0.0 libhmsbeagle-cpu.so.31.0.0 libhmsbeagle.so.1.3.2; do
#  if [ -f "$CONDA_PREFIX/lib/$f" ]; then
#    mv "$CONDA_PREFIX/lib/$f" "$CONDA_PREFIX/lib/$f.bak"
#  fi
#done

#export JAVA_TOOL_OPTIONS="-Djava.library.path=$CONDA_PREFIX/lib"
#export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

cd $WORKING_DIRECTORY

./beast /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/Murat_parameters_cleaned_calibrated.xml
#beast /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/Murat_parameters_cleaned_calibrated.xml
