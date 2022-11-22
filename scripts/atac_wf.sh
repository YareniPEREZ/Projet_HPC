#! /bin/bash
#cd "$(dirname "$0")"

echo 'CHAMARET Quentin (Universite Clermont Auvergne)'
echo 'Date: Fall Master course 2021 '
echo 'Object: Sample case of ATACseq workflow showing job execution and dependency handling.'
echo 'Inputs: paths to scripts qc, trim, bowtie2, picard, MACS2'
echo 'Outputs: trimmed fastq files, QC HTML files and BAM files'

# Handling errors
#set -x # debug mode on
set -o errexit # ensure script will stop in case of ignored error
set -o nounset # force variable initialisation
#set -o verbose

IFS=$'\n\t'

# first job - no dependencies
# Quality control of the raw data
jid1=$(sbatch --parsable /home/users/student08/Projet_HPC/scripts/atac_qc_init.slurm)

echo "$jid1 : Initial Quality Control"

# Elimination of the adaptaters
jid2=$(sbatch --parsable --dependency=afterok:$jid1 /home/users/student08/Projet_HPC/scripts/atac_trim.slurm)

echo "$jid2 : Trimming with Trimmomatic tool"

# Quality control following the trimming
jid3=$(sbatch --parsable --dependency=afterok:$jid2 /home/users/student08/Projet_HPC/scripts/atac_qc_post.slurm)

echo "$jid3 : Quality control after the trimming"

# Mapping
jid4=$(sbatch --parsable --dependency=afterok:$jid3 /home/users/student08/Projet_HPC/scripts/atac_bowtie2.slurm)

echo "$jid4 : Mapping with Bowtie2 tool"

# Elimination of the duplicates
jid5=$(sbatch --parsable --dependency=afterok:$jid4 /home/users/student08/Projet_HPC/scripts/atac_picards.slurm)

echo "$jid5 : Elimination of the duplicates with picard tools"

# Data exploration (correlation)
jid6=$(sbatch --parsable --dependency=afterok:$jid5 /home/users/student08/Projet_HPC/scripts/atac_array.npz.slurm)

echo "$jid6 : Correlation analysis with Deeptools"

# Data exploration (read length and coverage)
jid7=$(sbatch --parsable --dependency=afterok:$jid6 /home/users/student08/Projet_HPC/scripts/atac_deeptools.slurm)

echo "$jid7 : Read length and coverage analysis with Deeptools"

# Identification of DNA access sites
jid8=$(sbatch --parsable --dependency=afterok:$jid7 /home/users/student08/Projet_HPC/scripts/atac_macs2.slurm)

echo "$jid8 : Identification of DNA access sites with MACS2 tool"

# Identification of common and unique DNA access sites
jid9=$(sbatch --parsable --dependency=afterok:$jid8 /home/users/student08/Projet_HPC/scripts/atac_bedtools.slurm)

echo "$jid9 : Identification of DNA common and unique access sites with bedtools"

# show dependencies in squeue output:
squeue -u $USER -o "%.8A %.4C %.10m %.20E"
