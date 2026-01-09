#!/bin/bash

indir=/path/to/trimmed_reads
outdir=/path/to/salmon_quant

mkdir -p "${outdir}"

# Example sample names, list all of them with spaces in between
samples='1-1A 1-1B 2-1A 2-1B 2-1C 3-1A 3-1B 3-1C'

for s in $samples; do
    echo ${s}
    R1=`ls -l $indir | grep -o ${s}_R1_001_val_1.fq.gz`
    R2=`ls -l $indir | grep -o ${s}_R2_001_val_2.fq.gz`
    echo ${R1}
    echo ${R2}
    jobfile="salmonquant${s}.sh"
    echo $jobfile
    cat <<EOF > $jobfile
#!/bin/bash
#SBATCH -N 1
#SBATCH -t 05-00:00:00
#SBATCH --mem=250g
#SBATCH -n 16
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH -J salmon_align
#SBATCH -o salmon_align.%A.out
#SBATCH -e salmon_align.%A.err


module add salmon
echo 'BEGIN'
date
hostname
salmon quant -l A -i  /path/to/AssemblyIndex \
        -1 $indir/${R1} \\
        -2 $indir/${R2} \\
        -p 5 --validateMappings \\
        -o /path/to/salmon_quant/${s}_quant

echo 'END'

date

EOF

    sbatch $jobfile

done