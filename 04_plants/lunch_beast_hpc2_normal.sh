#!/bin/bash
#SBATCH --job-name=lunch_beast_hpc2_normal
#SBATCH --ntasks=1
#SBATCH -p long
#SBATCH --time=12-00:00:00
#SBATCH --mem=92G
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/lunch_beast_hpc2_normal.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/lunch_beast_hpc2_normal.out"

# Pour télécharger la bonne version de Beast (2.7.8) (il est important de ne pas prendre une autre version pour éviter les conflits):
# https://www.beast2.org

# Si linux:
# wget https://www.beast2.org/download-linux-x86/
# tar fxz BEAST.v2.7.7.Linux.x86.tgz
# cd beast/bin
# Puis pour lancer beast: ./beast/bin/beast

module load conda/4.12.0
source ~/.bashrc
module load java/oracle-1.8.0_45
module load gcc/8.1.0
module load beagle/3.1.2

WORKING_DIRECTORY=/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/beast/bin

cd $WORKING_DIRECTORY

./beast /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/Murat_parameters_cleaned_calibrated_all_prior_all_normal.xml
