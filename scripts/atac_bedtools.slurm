#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=1   # Nb of threads we want to run on
#SBATCH -o Projet_HPC/log/slurmjob-%A-%a
#SBATCH --job-name=bedtools_atac
#SBATCH --partition=short
#SBATCH --array=0-0

# Program configuration
__author__='Nadia Goué'
__email__='nadia.goue@uca.fr'
__credits__=["Nadia Goué"]
__license__='GPL3'
__maintainer__='Nadia Goué'
__status__='Development'
__version__='0.0.1'
__developer__='YareniPEREZ'
__email__='yareni.duranthon@etu.uca.fr'

echo 'Identification of unique and common DNA access sites with bedtools'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 bedtools/2.27.1

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/Projet_HPC/results/bedtools
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

echo "Set up two arrays with results of 0h for one and 24h for the other from MACS2" >&2

tab_0h=($(find "$HOME"/Projet_HPC/results/macs2 -type f -name "ss_50k_0h_*.narrowPeak" -printf "%f %p \n" | sort -k1 | cut -d " " -f 2))
echo "tab_0h = " >&2
printf '%s\n' "${tab_0h[@]}" >&2

tab_24h=($(find "$HOME"/Projet_HPC/results/macs2 -type f -name "ss_50k_24h_*.narrowPeak" -printf "%f %p \n" | sort -k1 | cut -d " " -f 2))
echo "tab_24h = " >&2
printf '%s\n' "${tab_24h[@]}" >&2

# Current filename
SHORTNAME=$(basename "${tab_0h[$SLURM_ARRAY_TASK_ID]}" .bed )
echo "shortname = $SHORTNAME" >&2

# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "Concatenate all files from each array" >&2
cat "${tab_0h[@]}" > "$OUTPUT"/ss_50k_0h_trim_mapped_sorted_q2_nodup_combined_peaks.narrowPeak
cat "${tab_24h[@]}" > "$OUTPUT"/ss_50k_24h_trim_mapped_sorted_q2_nodup_combined_peaks.narrowPeak

ZERO="$OUTPUT"/ss_50k_0h_trim_mapped_sorted_q2_nodup_combined_peaks.narrowPeak
TWENTY_FOUR="$OUTPUT"/ss_50k_24h_trim_mapped_sorted_q2_nodup_combined_peaks.narrowPeak

echo "Sorting and merging of each combined files"
# Args -i : Path to the input file to merge

sort -k1,1 -k2,2n "$ZERO" | bedtools merge -i - > "$OUTPUT"/ss_50k_0h_trim_mapped_sorted_q2_nodup_merged_peaks.bed 
sort -k1,1 -k2,2n "$TWENTY_FOUR" | bedtools merge -i - > "$OUTPUT"/ss_50k_24h_trim_mapped_sorted_q2_nodup_merged_peaks.bed

ZERO="$OUTPUT"/ss_50k_0h_trim_mapped_sorted_q2_nodup_merged_peaks.bed
TWENTY_FOUR="$OUTPUT"/ss_50k_24h_trim_mapped_sorted_q2_nodup_merged_peaks.bed

echo "Identification of common DNA access sites with intersect from bedtools" >&2
# Args -a and -b : Path to the input BAM files to analyze
# Args -wa : For each overlap, write the original entry of -a
# Args -v : Returns entries in -a that have no overlap in -b

bedtools intersect -wa -a "$ZERO" -b "$TWENTY_FOUR" > ss_50k_trim_mapped_sorted_q2_nodup_common.bed

echo "Identification of unique DNA access sites with intersect from bedtools" >&2

bedtools intersect -wa -v -a "$ZERO" -b "$TWENTY_FOUR" > ss_50k_trim_mapped_sorted_q2_nodup_Oh_unique.bed
bedtools intersect -wa -v -a "$TWENTY_FOUR" -b "$ZERO" > ss_50k_trim_mapped_sorted_q2_nodup_24h_unique.bed

#Move results from scratch to user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2
