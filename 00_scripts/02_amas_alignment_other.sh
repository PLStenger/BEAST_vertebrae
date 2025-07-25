#!/bin/bash

#SBATCH --job-name=02_amas_alignment_other
#SBATCH --time=10-00:00:00      
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8     
#SBATCH -p gdec
#SBATCH --mem=500G            
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/02_amas_alignment_other.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/02_amas_alignment_other.out"

# long -> 92Go seulement
# SMP avec 750 Go plus de probleme de memoire, mais de temps -> out of time au bout de 3 jours

# BEAST attend un seul alignement, c’est-à-dire que toutes les séquences doivent être alignées les unes par rapport aux autres (mêmes espèces, mêmes positions).
# Concaténer les alignements revient à créer une supermatrice : pour chaque espèce, tu concatènes ses séquences alignées pour chaque OG, en respectant l’ordre des OG.
# Il existe des outils spécialisés pour faire cela, car il faut gérer les absences de séquences (mettre des gaps là où il manque des séquences pour certaines espèces).

# Le meilleur outil pour concaténer des alignements multiples en une supermatrice est AMAS (https://github.com/marekborowiec/AMAS) ou FASconCAT-G (https://github.com/PatrickKueck/FASconCAT-G).

#python3 -m pip install --user git+https://github.com/marekborowiec/AMAS.git

cd /home/plstenge/BEAST_vertebrae/BEAST_vertebrae/01_3350_OG

#python3 -m amas.AMAS concat -i *.fa -f fasta -d aa -u fasta -t concatenated_alignment_parallel.fa -c 32
#python3 -m amas.AMAS concat -i *.fa -f fasta -d aa -u fasta -t concatenated_alignment_parallel.fa -c 16

# Méthode par lots car out of memory sinon
# Création des lots
mkdir -p batches_other
ls *.fa | split -l 500 - batches_other/

# Traitement par lot avec partitions uniques
#for batch_other in batches_other/*; do
#    python3 -m amas.AMAS concat -i $(cat $batch_other) -f fasta -d aa -u fasta \
#             -t "${batch_other}.fa" \
#             -p "${batch_other}_partitions_other.txt" \
#             -c 8
#done

for batch_other in batches_other/*; do
    python3 -m amas.AMAS concat -i $(cat $batch_other) -f fasta -d aa -u fasta \
             -t "${batch_other}.fa" \
             -p "${batch_other}_partitions_other.txt" \
             -c 8 &
    # Limite à N taches en parallèle (optionnel avec Parallel)
    [[ $(jobs -r -p | wc -l) -ge 8 ]] && wait -n
done
wait

# Fusion finale sans charge mémoire
cat batches_other/*.fa > concatenated_alignment.fa
cat batches_other/*_partitions_other.txt > partitions_other.txt


# Diagnostic mémoire/temps
#/usr/bin/time -v python3 -m amas.AMAS concat \
#    -i *.fa \
#    -f fasta \
#    -d aa \
#    -u fasta \
#    -t concatenated_alignment_parallel.fa \
#    -c 8
