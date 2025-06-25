import csv
import os
from Bio import AlignIO

# Define the paths

# MultipleSequenceAlignments:
alignment_file_path = "/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/99_raw_data"
# 
file_list_path = "/home/plstenge/BEAST_vertebrae/BEAST_vertebrae/99_raw_data/Orthogroup_3349.csv"  

# List to keep track of processed files
successful_files = []
failed_files = []

# Function to process a single alignment file
def process_alignment_file(filename):
    try:
        # Load the alignment file
        alignment = AlignIO.read(os.path.join(alignment_file_path, filename), "fasta")  # Change format if necessary

        # Create a unique output filename
        output_filename = f"{os.path.splitext(filename)[0]}_amino_acid_positions.csv"  # Use os.path.splitext to get the name without extension
        output_path = os.path.join(alignment_file_path, output_filename)  # Full path for output

        # Check if output file already exists and modify the name if necessary
        counter = 1
        while os.path.exists(output_path):
            output_filename = f"{os.path.splitext(filename)[0]}_amino_acid_positions_{counter}.csv"
            output_path = os.path.join(alignment_file_path, output_filename)
            counter += 1

        with open(output_path, "w", newline='') as output_file:
            writer = csv.writer(output_file)
            
            # Write header
            header = ["Position"] + [record.id for record in alignment]
            writer.writerow(header)
            
            # Iterate through each position in the alignment
            for position in range(alignment.get_alignment_length()):
                row = [position + 1]  # +1 for human-readable position
                for record in alignment:
                    amino_acid = record.seq[position]  # Get the amino acid
                    row.append(amino_acid)
                writer.writerow(row)

        print(f"Output saved to {output_path}")
        successful_files.append(filename)  # Add to successful list

    except Exception as e:
        print(f"Error processing {filename}: {e}")
        failed_files.append(filename)  # Add to failed list

# Read the list of alignment files from the specified text file
with open(file_list_path, "r") as file_list:
    all_files = [line.strip() for line in file_list]  # Store all filenames

# Process all files initially
for filename in all_files:
    process_alignment_file(filename)

# Rerun for only failed files
if failed_files:
    print("\nRetrying failed files...")
    for filename in failed_files:
        process_alignment_file(filename)

# Summary of processing
print("\nProcessing Summary:")
print(f"Successfully processed files: {successful_files}")
print(f"Failed files: {failed_files}")
