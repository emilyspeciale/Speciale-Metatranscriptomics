#!/bin/bash

#SBATCH -p general
#SBATCH --nodes=1
#SBATCH --time=0-48:00:00
#SBATCH --mem=400G
#SBATCH --ntasks=12
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J transdecoder_longorfs
#SBATCH -o transdecoder_longorfs.%j.out
#SBATCH -e transdecoder_longorfs.%j.err


/path/to/TransDecoder-TransDecoder-v5.7.1/TransDecoder.LongOrfs -t clustered_assembly.fasta