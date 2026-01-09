#!/bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 04-00:00:00
#SBATCH --mem=300g
#SBATCH --ntasks-per-node=10
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J eukulele_phylodb
#SBATCH -o eukulele_phylodb.%A.out
#SBATCH -e eukulele_phylodb.%A.err

#conda init

#condsource ~/.bashrc

module purge
module load anaconda
conda activate /path/to/miniconda3/envs/EUKulele

EUKulele -m mets -s /path/to/TransDecoder-TransDecoder-v5.7.1 -o /path/to/EUKulele --database phylodb --p_ext .pep --alignment_choice diamond