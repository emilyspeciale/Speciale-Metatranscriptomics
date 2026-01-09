#!/bin/bash

# Set in directory to where raw reads are
indir=/path/to/raw_reads
outdir=/path/to/trimmed_reads
# Create the out directory if it does not already exist
mkdir -p "${outdir}"
# Cut path file at R1 for input list
input=`ls ${indir}/*R1*`
# Run trimgalore.sh for each sample, it will create a job for each one
for file in $input
do
	sbatch trimgalore.sh $file ${file::-14}2_001.fastq.gz ${outdir}
done
