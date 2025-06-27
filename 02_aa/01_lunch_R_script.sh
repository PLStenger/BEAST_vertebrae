#!/bin/bash

#SBATCH --job-name=02_run_R_script
##SBATCH --time=24:00
#SBATCH --ntasks=1
#SBATCH -p smp
##SBATCH --nodelist=gdecnode02
#SBATCH --mem=250G
##SBATCH -c 32
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/02_aa/02_run_R_script.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/02_aa/02_run_R_script.out"

module load gcc/8.1.0
module load R/3.5.1
module load Rextra/0.1

# Lancer le script R
Rscript /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/02_aa/01_fixation_aa.R
