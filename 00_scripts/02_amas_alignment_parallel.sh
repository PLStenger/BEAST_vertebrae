#!/bin/bash

#SBATCH --job-name=beast_alignment
#SBATCH --time=96:00:00       
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8     
#SBATCH -p smp
#SBATCH --mem=1000G            
#SBATCH --mail-user=pierrelouis.stenger@gmail.com
#SBATCH --mail-type=ALL 
#SBATCH --error="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/02_amas_alignment_parallel.err"
#SBATCH --output="/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/00_scripts/02_amas_alignment_parallel.out"

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
mkdir -p batches
ls *.fa | split -l 500 - batches/

# Traitement par lot avec partitions uniques
for batch in batches/*; do
    python3 -m amas.AMAS concat -i $(cat $batch) -f fasta -d aa -u fasta \
             -t "${batch}.fa" \
             -p "${batch}_partitions.txt" \
             -c 8
done

# Fusion finale sans charge mémoire
cat batches/*.fa > concatenated_alignment.fa
cat batches/*_partitions.txt > partitions.txt
# Diagnostic mémoire/temps
#/usr/bin/time -v python3 -m amas.AMAS concat \
#    -i *.fa \
#    -f fasta \
#    -d aa \
#    -u fasta \
#    -t concatenated_alignment_parallel.fa \
#    -c 8

#INPUT=/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/01_3350_OG

#WORKDIR=/storage/scratch/login/XXYYZZ
#mkdir -p $WORKDIR
#mkdir -p $WORKDIR/input
#mkdir -p $WORKDIR/output
#mkdir -p $WORKDIR/tmp

#module load rclone/1.55.1
# Les données sont copiées dans le `scratch`
#rclone copy s3-myproject:monBucket$INPUT $WORKDIR/input/
#cd $WORKDIR

# Exécution du job. Les données créées sont également copiées dans le `scratch`
# Publication: https://peerj.com/articles/1660/
#python3 -m amas.AMAS concat -i $WORKDIR/input/*.fa -f fasta -d aa -u fasta -t $WORKDIR/output/concatenated_alignment_parallel.fa -c 32  --temporary-directory=$WORKDIR/tmp

# Transfert des données produites dans l'espace de stockage S3
#rclone copy $WORKDIR/output s3-myproject:monBucket$INPUT

# Nettoyage du `scratch` pour une remise à disposition de l'espace aux autres utilisateurs
#cd /tmp
#rm -rf $WORKDIR

#Points importants
#Vérifie que les noms des séquences sont cohérents entre fichiers (même nom pour la même espèce partout).
#Si certaines espèces ne sont pas présentes dans tous les OG, AMAS et FASconCAT-G ajouteront automatiquement des gaps.
#Le fichier obtenu sera prêt pour BEAST (ou toute autre analyse phylogénétique).
