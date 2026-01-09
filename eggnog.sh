#!/bin/bash

#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 5-00:00:00
#SBATCH --mem=500g
#SBATCH --ntasks-per-node=24
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J eggnog
#SBATCH -o eggnog.%A.out
#SBATCH -e eggnog.%A.err

cd /path/to/eggnog/eggnog-mapper

module load python/3.7.9

python -m pip install biopython==1.76
python -m pip install psutil==5.7.0
python -m pip install xlsxwriter==1.4.3

python emapper.py -i /path/to/TransDecoder-TransDecoder-v5.7.1/clustered_assembly.fasta.transdecoder.pep --output /path/to/eggnog/eggnog_annot -m diamond --evalue 1e-6 --cpu 24 --excel