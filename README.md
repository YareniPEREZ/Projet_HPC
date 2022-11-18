README.md

Yareni PEREZ 

Project_HPC 

objective :  
Identify the genomic regions accessible by the DNA during the transcription. In order to do this, we re-analyzed the ATAC-seq results from 
a publication of 2019 ("STATegra, a comprehensive multi-omics dataset of B-cell differentiation in mouse" David Gomez-Cabrero et al. 2019 https://doi.org/10.1038/s41597-019-0202-7).
The analyse was performed on a B3 murine cellular line from the mouse model the pre-B1 stage. After the nuclear translocation of the transcription factor Ikaros, those cells grow to the pre-BII stage. During this stage, the B cells progenitor are subject to a growth arrest and a differentiation. This B3 cell line was transduced by a retroviral pathway with a vector coding for a fusion protein, Ikaros-REt2, which can control nuclear levels of Ikaros after exposition to the Tamoxifen drug. After this treatment, the cultures were collected at t=0h and t=24h.


Recuperation des données 
A set of scripts are copied from /home/users/teacher/atacseq/scripts/*.slurm  into home/users/studentXX/atacseq/scripts.These scripts will be modified later in order to be adapted to our dataset.


Subset of 4000 lines equivalent to 1000 sequences created from the original subset in order to be pushed into the git repository using this command line :
parallel 'zcat {} | head -n 4000 | gzip >
/home/users/student08/atacseq/data/test.{/.}.gz' :::
/home/users/shared/data/atacseq/data/subset/ss_50k*

Experimental design
About 50 000 cells were collected for each sample. There are 3 biological replicates by sample : R1, R2 and R3 Each of the biological replicates was performed for the two cellular stages : 0h and 24h In total, 
6 samples were studied (3 replicates for t=0h and 3 replicates for t=24h)
Each of these samples were sequenced by an Illumina sequencing with Nextera-based sequencing primers. Considering that the sequencing was performed in paired-end, each of the 6 samples has a forward result file and a reverse result file. So, in total, 12 samples were collected for the analysis

Raw dataset :

SRR4785152    50k_0h_R1_1     0.6G    50k_0h_R1_2     0.6G
SRR4785153    50k_0h_R2_1     0.5G    50k_0h_R2_2     0.6G
SRR4785154    50k_0h_R3_1     0.6G    50k_0h_R3_2     0.6G

SRR4785341    50k_24h_R1_1    0.5G    50k_24h_R1_2    0.5G
SRR4785342    50k_24h_R2_1    0.5G    50k_24h_R2_2    0.5G
SRR4785343    50k_24h_R3_1    0.5G    50k_24h_R3_2    0.5G

WORKFLOW 
1. Pré-processing des données  Contrôle Qualité des données et nettoyage des Reads :
- contrôle qualité : atac_qc_init.slurm
- Trimming : nettoyage des données : atac_trim.slurm
- Contrôle qualité : atac_qc_post.slurm

Scripts : 
* atac_qc_init.slurm :
	But : faire un premier contrôle qualité sur les données brutes afin d'éliminer celles qui sont de moins bonne qualité. Ce contrôle qualité sera réalisé par la fonction fastqc
* atac_trim.slurm :
	But : faire un trimming des séquences à l’aide de la fonction
* atac_qc_post.slurm :
	But : faire un contrôle qualité sur les résultats issus du trimming et les comparer par rapport aux résultats de base

2. Mapping 
- alignement sur le génome de référence avec Bowtie : atac_bowtie2.slurm
- nettoyage des doublons : fonction Markduplicates de l’outil picard (module load picard)

Scripts
* atac_bowtie2.slurm :
        But : faire un alignement des séquences selon l’algorithme Bowtie2 sur le génome de référence Mus_musculus_GRCm39.

* atac_picards.slurm : 
        But : supprimer les doublons présents dans les séquences à l’aide de l’outil picard, MarkDuplicates.

3. Exploration des données de mapping 
- Génération de fichiers BAM et SAM → depp tools (python) → couverture, corrélation, graphes 

Scripts
* atac_deeptools.slurm :
	But : réaliser des analyses statistiques (coverage, read length correlation) entre les échantillons multiBamSummary
	But : compile les différents fichiers BAM (nécessaire pour plotCorrelation)

4. Identification des sites d’accessibilité de l’ADN 
- Fichiers SAM et BAM → outil MACS2 et la fonction callpeaks (pics → commenter) 
- Utilisez MACS pour - Déterminer les sites d'accessibilité de l'ADN - I	inspecter les pics (cf visualisation) et commentez

Scripts 
* atac_macs2.slurm :
	But : determiner les sites d’accessibilités de l’ADN

5.Identification des sites d'accessibilité uniques et communs entre les stades cellulaires.
-Bam et SAM à 0h et 24h →outil BedTools (module load BedTools) et la fonction intersect (communs)

Scripts
* atac_bedtools.slurm :
	But : determiner les sites d’accessibilités communs et uniques de l’ADN


6. Visualisation. 
- Visualisation avec l’outil IGV 	 	 	 	
- Lancer l'application avec la commande igv.sh Sélectionner le génome de la souris GRC39 Importer vos données (File > Load from file) Le format bed, bigwig, etc .. est accepté

7. Construction du workflow
- Commandes SLURM pour connaître 
	- temps d'exécution
	- nb de CPUs
	- nb de RAMs


