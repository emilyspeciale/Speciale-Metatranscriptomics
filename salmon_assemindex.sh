#!/bin/bash
#SBATCH -p general
#SBATCH --nodes=1
#SBATCH --time=5-00:00:00
#SBATCH --mem=400G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J salmon_assemindex
#SBATCH -o salmon_assemindex.%A.out
#SBATCH -e salmon_assemindex.%A.err

module load salmon

salmon index -i /path/to/AssemblyIndex \
--transcripts /path/to/cdhit/clustered_assembly.fasta -k 31
