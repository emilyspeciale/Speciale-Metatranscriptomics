#!/bin/bash

#SBATCH -p general
#SBATCH --nodes=1
#SBATCH --time=0-48:00:00
#SBATCH --mem=400G
#SBATCH --ntasks=12
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J transdecoder_predict
#SBATCH -o transdecoder_predict.%j.out
#SBATCH -e transdecoder_predict.%j.err


/path/to/TransDecoder-TransDecoder-v5.7.1/TransDecoder.Predict -t clustered_assembly.fasta