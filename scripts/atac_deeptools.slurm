#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=30G
#SBATCH --cpus-per-task=6   # Nb of threads we want to run on
#SBATCH -o Projet_HPC/log/slurmjob-%A-%a
#SBATCH --job-name=deeptools_atac
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

echo 'Use of the deepTools to analyze data'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose
#set -euo pipefail

IFS=$'\n\t'

#Set up whatever package we need to run with
module purge
module load gcc/4.8.4 python/2.7.9 numpy/1.9.2 samtools/1.3 deepTools/3.1.2

echo "Set up directories ..." >&2
#Set up the temporary directory
SCRATCHDIR=/storage/scratch/"$USER"/"$SLURM_JOB_ID"

OUTPUT="$HOME"/Projet_HPC/results/deeptools
mkdir -p "$OUTPUT"
mkdir -p -m 700 "$SCRATCHDIR"
cd "$SCRATCHDIR"

echo "Set up an array with all BAM alignment files with no duplicates" >&2

tab=($(find "$HOME"/Projet_HPC/results/picards -type f -name "*_trim_mapped_sorted_q2_nodup.bam" -printf "%f %p \n" | sort -k1 | cut -d " " -f 2))
echo "tab = " >&2
printf '%s\n' "${tab[@]}" >&2

# Current filename
SHORTNAME=$(basename "${tab[$SLURM_ARRAY_TASK_ID]}" .bam )
echo "shortname = $SHORTNAME" >&2

# Run the program
echo "Start on $SLURMD_NODENAME: "`date` >&2

echo "multiBamSummary to combine the BAM files into one" >&2
# Args --bamfiles <file> : Path to the input BAM files to analyze
# Args -o <file> : Path to where the output files should be writen

multiBamSummary bins --bamfiles "${tab[@]}" -o "$OUTPUT"/array.npz

#Set up the path to the aggregate file
NPZ_FILE="$OUTPUT"/array.npz

echo "plotCorrelation in order to see the correlation between samples" >&2
# Args -in <file> : Path to the aggregated BAM file
# Args -o <file> : Path to where the output files should be writen
# Args -p <character> : Choose whether you want to plot a heatmap or a scatterplot
# Args -c <character> : Choose whether to use the pearson or the spearman coefficient
# Args --removeOutliers : Will remove outliers from the samples

plotCorrelation -in "$NPZ_FILE" -p heatmap -c pearson -o "$OUTPUT"/heatmap.png --removeOutliers

echo "bamCoverage in order to see the coverage on the genome from each sample"
# Args -b <file> : Path to the input BAM file
# Args -o <file> : Path to where the output files should be writen
# Args -of <character> : Choose whether the output will be in Bigwig or in bedgraph format

bamCoverage -b "${tab[$SLURM_ARRAY_TASK_ID]}" -o "$SHORTNAME".bedgraph -of bedgraph

echo "bamPEFragmentSize to compare the reads length according to the samples"
# Args -b <file> : Path to the input BAM files
# Args -o <file> : Path to where the output should be writen
# Args --samplesLabels <character> : Rename the samples by these labels

bamPEFragmentSize -b "${tab[@]}" --samplesLabel 0h_R1 0h_R2 0h_R3 24h_R1 24h_R2 24h_R3 --table "$OUTPUT"/table.tsv \
 -o "$OUTPUT"/hist.png

#Move results from scratch to user one's directory
mv  "$SCRATCHDIR" "$OUTPUT"

echo "Stop job : "`date` >&2
