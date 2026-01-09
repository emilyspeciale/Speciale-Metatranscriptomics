#!/bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 02-00:00:00
#SBATCH --mem=250g
#SBATCH --ntasks=16
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J rna_spades
#SBATCH -o rna_spades.%A.out
#SBATCH -e rna_spades.%A.err

module load spades
# Set output directory, make a different out directory for each sample
outdir=/path/to/spades/sample1
# Create output directory if it does not already exist
mkdir -p "${outdir}"
# Run spades for each sample, you want to use the trimmed reads now. Input with your own sample name.
rnaspades.py \
 --pe1-1 /path/to/trimmed_reads/sample1_R1_001_val_1.fq.gz \
 --pe1-2 /path/to/trimmed_reads/sample1_R2_001_val_2.fq.gz \
 -o $outdir
