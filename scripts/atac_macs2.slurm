#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=6   # Nb of threads we want to run on
#SBATCH -o Projet_HPC/log/slurmjob-%A-%a
#SBATCH --job-name=macs2_atac
#SBATCH --partition=short
#SBATCH --array=0-5

# Program configuration
__author__='Nadia Goué'
__email__='nadia.goue@uca.fr'
__credits__=["Nadia Goué"]
__license__='GPL3'
__maintainer__='Nadia Goué'
__status__='Development'
__version__='0.0.1'
__developer__='Yareni PEREZ'
__email__='yareni.duranthon@etu.uca.fr'

echo 'Identification of DNA access sites with MACS2'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 cython/0.25.2 MACS2/2.1.2

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/Projet_HPC/results/macs2
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

echo "Set up an array with all BAM alignment files" >&2

tab=($(find "$HOME"/Projet_HPC/results/picards -type f -name "*_trim_mapped_sorted_q2_nodup.bam" -printf "%f %p \n" | sort -k1 | cut -d " " -f 2))
echo "tab = " >&2
printf '%s\n' "${tab[@]}" >&2

# Current filename
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam )
echo "shortname = $SHORTNAME" >&2

# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Identification of DNA access sites with MACS2" >&2
# Args -t <file> : Path to the input BAM files to analyze
# Args --outdir <file> : Path to where the output files should be writen
# Args -f <character> : Format of the input files
# Args -n <character> : Name of the output files

macs2 callpeak -t "${tab[SLURM_ARRAY_TASK_ID]}" -f BAM  -n "$SHORTNAME" --outdir "$SCRATCHDIR"

#Move results from scratch to user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2
