#SBATCH --job-name=create_supergene
#SBATCH --ntasks=1
#SBATCH -p smp
#SBATCH --mem=1000G
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/create_supergene.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/create_supergene.out"

# Charger les modules nécessaires
module purge
module load gcc/8.1.0
module load python
#module load biopython/1.78      

# Exécuter le script
# python create_supergene.py <liste_OG.txt> <dossier_alignements> <fichier_sortie>
python /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/create_supergene.py /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/singlecopy_OG_50plus.txt /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/MultipleSequenceAlignments /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/04_plants/supergene.txt
