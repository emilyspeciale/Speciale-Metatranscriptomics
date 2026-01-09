#!/bin/bash
#SBATCH -p general
#SBATCH --nodes=1
#SBATCH --time=02-0:00:00
#SBATCH --mem=60G
#SBATCH --ntasks=42
#SBATCH -J fastqc
#SBATCH -o fastqc.%A.out
#SBATCH -e fastqc.%A.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu

module load fastqc
# Set directories for your raw reads and trimmed reads
raw_reads=/path/to/raw_reads
trim_reads=/path/to/trimmed_reads
# Set an output directory
outdir=/path/to/fastqc
# Create output directory if it does not already exist
mkdir -p "${outdir}"
# Run fastqc on raw reads and trimmed reads
fastqc -t 42 $raw_reads/* -o ${outdir}
fastqc -t 42 $trim_reads/*.gz -o ${outdir}
# Run multiqc to get overall report of quality control results
cd ${outdir}
module load multiqc
multiqc .
