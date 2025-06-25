#!/bin/bash

#SBATCH --job-name=99_lunch_python_msa
##SBATCH --time=24:00
#SBATCH --ntasks=1
#SBATCH -p smp
##SBATCH --nodelist=gdecnode02
#SBATCH --mem=250G
##SBATCH -c 32
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/99_lunch_python_msa.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/99_lunch_python_msa.out"

# Charger les modules nécessaires
module purge
module load python
#module load biopython/1.78      

# Exécuter le script
python /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/99_msa_get_pos_all.py
