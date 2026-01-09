#!/bin/bash
#SBATCH -p general
#SBATCH -N 1
#SBATCH -t 3-00:00:00
#SBATCH -J cdhit
#SBATCH -o cdhit.out
#SBATCH -e cdhit.%j.err
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=email@unc.edu
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1

# First, remame and put all of the individual fasta files produced by rnaSPAdes into one directory

# Navigate to  spades directory
cd /path/to/spades

# Rename each transcripts.fasta file to something unique, such as the subdirectory name
for dir in */; do
    # Check if the file transcripts.fasta exists in the subdirectory
    if [ -f "${dir}transcripts.fasta" ]; then
        # Extract the subdirectory name (remove trailing slash)
        subdir_name=$(basename "$dir")
        # Rename the file
        cp "${dir}transcripts.fasta" "${dir}${subdir_name}_transcripts.fasta"
    fi
done

# Create a directory for transcripts directory if it doesn't exist, this will hold all the rnaSPAdes transcripts files
mkdir -p transcripts

# Copy each rnaSPAdes transcript file into the transcripts directory
for dir in */; do
    # Check if the file with the new name exists in the subdirectory
    if [ -f "${dir}${dir%/}_transcripts.fasta" ]; then
        # Copy the file to the transcripts directory
        cp "${dir}${dir%/}_transcripts.fasta" "transcripts/"
    fi
done

# Now run CD-HIT-EST
indir=/path/to/spades/transcripts
outdir=/path/to/cdhit

# Creat output directory of it doesn't exist
mkdir -p "${outdir}"

# ifn is the combined (concatenated) assemblies
# ofn is the clustered assembly for reducing redundacy
input=`ls ${indir}/*.fasta`
ifn="${outdir}/mega_assembly.fasta"
ofn="${outdir}/clustered_assembly.fasta"

# load default cdit module
module load cdhit

echo "${ifn}"
echo "${ofn}"

cd-hit-est \
 -i "${ifn}" \
 -o "${ofn}" \
 -c .98 -n 10 -d 100 \
 -T ${SLURM_CPUS_PER_TASK} \
 -M 40000 \

# --------------------- 
# sacct -j $SLURM_JOB_ID --format='JobID,user,elapsed, cputime, totalCPU,MaxRSS,MaxVMSize,ncpus,NTasks,ExitCode'

scontrol show job $SLURM_JOB_ID
