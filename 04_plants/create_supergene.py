#!/usr/bin/env python3

"""
Script optimisé pour créer un super-gène à partir de multiples alignements OG
Usage: python create_supergene.py <liste_OG.txt> <dossier_alignements> <fichier_sortie>
"""

import sys
import os
import time
from collections import defaultdict, OrderedDict
from pathlib import Path
import argparse

def parse_fasta_fast(filepath):
    """Parse un fichier FASTA rapidement et retourne un dictionnaire {espece: sequence}"""
    sequences = {}
    current_species = None
    current_seq = []
    
    try:
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                if line.startswith('>'):
                    if current_species is not None:
                        sequences[current_species] = ''.join(current_seq)
                    current_species = line[1:]  # Enlever le '>'
                    current_seq = []
                elif line:
                    current_seq.append(line)
            
            # Dernière séquence
            if current_species is not None:
                sequences[current_species] = ''.join(current_seq)
                
    except FileNotFoundError:
        print(f"Attention: Fichier {filepath} non trouvé")
        return {}
    
    return sequences

def get_alignment_length(sequences_dict):
    """Retourne la longueur de l'alignement (toutes les séquences ont la même longueur)"""
    if not sequences_dict:
        return 0
    return len(next(iter(sequences_dict.values())))

def write_fasta_line(f, sequence, line_width=80):
    """Écrit une séquence FASTA avec retours à la ligne"""
    for i in range(0, len(sequence), line_width):
        f.write(sequence[i:i+line_width] + '\n')

def main():
    parser = argparse.ArgumentParser(description='Créer un super-gène à partir de multiples alignements OG')
    parser.add_argument('liste_og', help='Fichier contenant la liste des OG')
    parser.add_argument('dossier_alignements', help='Dossier contenant les alignements')
    parser.add_argument('fichier_sortie', help='Fichier FASTA de sortie')
    parser.add_argument('--chunk-size', type=int, default=100, 
                       help='Nombre d\'OG à traiter simultanément (défaut: 100)')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.liste_og):
        print(f"Erreur: Le fichier {args.liste_og} n'existe pas")
        sys.exit(1)
    
    if not os.path.exists(args.dossier_alignements):
        print(f"Erreur: Le dossier {args.dossier_alignements} n'existe pas")
        sys.exit(1)
    
    print("=== Création du super-gène BEAST (version optimisée) ===")
    print(f"Liste OG: {args.liste_og}")
    print(f"Dossier alignements: {args.dossier_alignements}")
    print(f"Fichier de sortie: {args.fichier_sortie}")
    
    start_time = time.time()
    
    # Lire la liste des OG
    with open(args.liste_og, 'r') as f:
        og_list = [line.strip() for line in f if line.strip()]
    
    print(f"Nombre d'OG à traiter: {len(og_list)}")
    
    # Étape 1: Collecter toutes les espèces et longueurs d'OG en une seule passe
    print("Étape 1: Analyse des alignements...")
    all_species = set()
    og_lengths = {}
    og_data = {}  # Stockage temporaire des données
    
    for i, og in enumerate(og_list):
        if (i + 1) % 100 == 0:
            print(f"  Analysé {i + 1}/{len(og_list)} OG...")
        
        filepath = os.path.join(args.dossier_alignements, f"{og}.fa")
        sequences = parse_fasta_fast(filepath)
        
        if sequences:
            og_data[og] = sequences
            og_lengths[og] = get_alignment_length(sequences)
            all_species.update(sequences.keys())
    
    print(f"Nombre total d'espèces trouvées: {len(all_species)}")
    print(f"Longueur totale du super-gène: {sum(og_lengths.values())} bp")
    
    # Conversion en liste triée pour un ordre consistant
    all_species = sorted(all_species)
    
    # Étape 2: Construction du super-gène par chunks d'espèces
    print("Étape 2: Construction du super-gène...")
    
    # Calculer la taille optimale des chunks d'espèces
    species_chunk_size = max(100, min(1000, len(all_species) // 10))
    print(f"Taille des chunks d'espèces: {species_chunk_size}")
    
    with open(args.fichier_sortie, 'w') as output_file:
        for chunk_start in range(0, len(all_species), species_chunk_size):
            chunk_end = min(chunk_start + species_chunk_size, len(all_species))
            species_chunk = all_species[chunk_start:chunk_end]
            
            print(f"  Traitement des espèces {chunk_start + 1}-{chunk_end}/{len(all_species)}...")
            
            # Construire les séquences pour ce chunk d'espèces
            species_sequences = {species: [] for species in species_chunk}
            
            for og in og_list:
                if og in og_data:
                    og_seqs = og_data[og]
                    gap_sequence = '-' * og_lengths[og]
                    
                    for species in species_chunk:
                        if species in og_seqs:
                            species_sequences[species].append(og_seqs[species])
                        else:
                            species_sequences[species].append(gap_sequence)
                else:
                    # OG non trouvé, ajouter des gaps pour toutes les espèces
                    gap_sequence = '-' * og_lengths.get(og, 0)
                    for species in species_chunk:
                        species_sequences[species].append(gap_sequence)
            
            # Écrire les séquences de ce chunk
            for species in species_chunk:
                output_file.write(f">{species}\n")
                full_sequence = ''.join(species_sequences[species])
                write_fasta_line(output_file, full_sequence)
    
    # Libérer la mémoire
    del og_data
    
    # Statistiques finales
    end_time = time.time()
    total_time = end_time - start_time
    
    print("=== Statistiques finales ===")
    print(f"Nombre d'OG traités: {len(og_list)}")
    print(f"Nombre d'espèces: {len(all_species)}")
    print(f"Longueur totale: {sum(og_lengths.values())} bp")
    print(f"Temps d'exécution: {total_time:.2f} secondes")
    print(f"Fichier de sortie: {args.fichier_sortie}")
    
    # Estimation de la taille du fichier
    estimated_size_mb = (len(all_species) * sum(og_lengths.values())) / (1024 * 1024)
    print(f"Taille estimée du fichier: {estimated_size_mb:.1f} MB")
    
    print("=== Terminé avec succès! ===")

if __name__ == "__main__":
    main()
