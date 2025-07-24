#!/bin/bash
#SBATCH --job-name=03_beast
#SBATCH --ntasks=1
#SBATCH -p smp
#SBATCH --mem=1000G
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/03_beast.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/03_beast.out"

KR_DIR="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/03_beast"

cd $KR_DIR

#module load java/oracle-1.8.0_45
#module load BEAST/2.5.2

module load conda/4.12.0
source ~/.bashrc
conda activate beast

beast test2.xml
