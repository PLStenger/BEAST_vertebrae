#!/bin/bash

#SBATCH --job-name=beast_alignment
##SBATCH --time=24:00
##SBATCH --ntasks=1
##SBATCH -c 1
#SBATCH --mem-per-cpu=32
#SBATCH -p smp
#SBATCH --mem=400G
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

# Publication: https://peerj.com/articles/1660/
python3 -m amas.AMAS concat -i *.fa -f fasta -d aa -u fasta -t concatenated_alignment_parallel.fa -c 32



#Points importants
#Vérifie que les noms des séquences sont cohérents entre fichiers (même nom pour la même espèce partout).
#Si certaines espèces ne sont pas présentes dans tous les OG, AMAS et FASconCAT-G ajouteront automatiquement des gaps.
#Le fichier obtenu sera prêt pour BEAST (ou toute autre analyse phylogénétique).
