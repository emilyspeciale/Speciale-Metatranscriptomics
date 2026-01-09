#!/bin/bash

#SBATCH -p general
#SBATCH --nodes=1
#SBATCH --time=0-48:00:00
#SBATCH --mem=200G
#SBATCH --ntasks=12
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J marferret
#SBATCH -o marferret.%j.out
#SBATCH -e marferret.%j.err

module load diamond

indir=/path/to/TransDecoder-TransDecoder-v5.7.1

outdir=/path/to/Marferret

mkdir -p "${outdir}"

samples='clustered_assembly.fasta.transdecoder.pep'

for s in `echo $samples`; do

diamond blastp -d /path/to/MarFERReT_v1/MarFERReT.v1.1.1.dmnd \
        -q $indir/${s} \
        -o $outdir/${s}marferret.m8 \
        -p 12 -e 0.000001 -k 1

done