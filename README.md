READme.md

Yareni DURANTHON (née PEREZ)<br>
# Project_HPC 

## Introduction
 
#### What is ATAC-seq ?<br>
ATAC-seq  (Assay for Transposase-Accessible Chromatin using sequencing).<br>
It is an integrative epigenetic analysis method that provides genome-wide information on open chromatin regions at the nucleotide level.

#### What kind of information can we get ?<br>
The position of the nucleosome and the level of chromatin compaction.

#### Why use the ATAC-seq method ?<br>
* The test preparation time is very fast, there is less experimental calibration to do.<br>
* The protocol requires a small information (500 to 50,000 cells).<br>
* It allows us to quantify differences in cellular response to disease treatment.<br>

## Objective
  
Identify the genomic regions accessible by the DNA during the transcription. In order to do this, we re-analyzed the ATAC-seq results from  a publication of 2019 ("STATegra, a comprehensive multi-omics dataset of B-cell differentiation in mouse" David Gomez-Cabrero et al. 2019 https://doi.org/10.1038/s41597-019-0202-7).<br>

The analyse was performed on a B3 murine cellular line from the mouse model the pre-B1 stage.<br>
After the nuclear translocation of the transcription factor Ikaros, those cells grow to the pre-BII stage. During this stage, the B cells progenitor are subject to a growth arrest and a differentiation. This B3 cell line was transduced by a retroviral pathway with a vector coding for a fusion protein, Ikaros-REt2, which can control nuclear levels of Ikaros after exposition to the Tamoxifen drug. After this treatment, the cultures were collected at t=0h and t=24h. 



## Materials and methods 
 
### Data recovery 
A set of scripts are copied from /home/users/teacher/atacseq/scripts/*.slurm  into home/users/studentXX/atacseq/scripts. <br>
These scripts will be modified later in order to be adapted to our dataset with the original data.<br>

Subset of 4000 lines equivalent to 1000 sequences created from the original subset in order to be pushed into the git repository using this command line :<br>
parallel 'zcat {} | head -n 4000 | gzip > /home/users/student08/atacseq/data/test.{/.}.gz' ::: /home/users/shared/data/atacseq/data/subset/ss_50k*

### Experimental design
* About 50 000 cells were collected for each sample. There are 3 biological replicates by sample : R1, R2 and R3 Each of the biological replicates was performed for the two cellular stages : 0h and 24h In total.<br>
* 6 samples were studied (3 replicates for t=0h and 3 replicates for t=24h).<br>
* Each of these samples were sequenced by an Illumina sequencing with Nextera-based sequencing primers. Considering that the sequencing was performed in paired-end, each of the 6 samples has a forward result file and a reverse result file. So, in total, 12 samples were collected for the analysis.

#### Raw dataset :

SRR4785152&nbsp;&nbsp;&nbsp;&nbsp;50k_0h_R1_1&nbsp;&nbsp;&nbsp;&nbsp;0.6G&nbsp;&nbsp;&nbsp;&nbsp;50k_0h_R1_2&nbsp;&nbsp;&nbsp;&nbsp;0.6G<br>
SRR4785153&nbsp;&nbsp;&nbsp;&nbsp;50k_0h_R2_1&nbsp;&nbsp;&nbsp;&nbsp;0.5G&nbsp;&nbsp;&nbsp;&nbsp;50k_0h_R2_2&nbsp;&nbsp;&nbsp;&nbsp;0.6G<br>
SRR4785154&nbsp;&nbsp;&nbsp;&nbsp;50k_0h_R3_1&nbsp;&nbsp;&nbsp;&nbsp;0.6G&nbsp;&nbsp;&nbsp;&nbsp;50k_0h_R3_2&nbsp;&nbsp;&nbsp;&nbsp;0.6G<br>

SRR4785341&nbsp;&nbsp;&nbsp;&nbsp;50k_24h_R1_1&nbsp;&nbsp;&nbsp;&nbsp;0.5G&nbsp;&nbsp;&nbsp;&nbsp;50k_24h_R1_2&nbsp;&nbsp;&nbsp;&nbsp;0.5G<br>
SRR4785342&nbsp;&nbsp;&nbsp;&nbsp;50k_24h_R2_1&nbsp;&nbsp;&nbsp;&nbsp;0.5G&nbsp;&nbsp;&nbsp;&nbsp;50k_24h_R2_2&nbsp;&nbsp;&nbsp;&nbsp;0.5G<br>
SRR4785343&nbsp;&nbsp;&nbsp;&nbsp;50k_24h_R3_1&nbsp;&nbsp;&nbsp;&nbsp;0.5G&nbsp;&nbsp;&nbsp;&nbsp;50k_24h_R3_2&nbsp;&nbsp;&nbsp;&nbsp;0.5G<br>


### WORKFLOW and tools 

#### 1. Quality control before trimming
Quality control on the raw data in order to see the general quality.<br>
Script : 
* atac_qc_init.slurm : tool Fastqc.



#### 2. Trimming
To clean the data we will proceed to a trimming of the adapters with the trimmomatic function.<br>
All this by using a file that contains the sequences of the adapters and imposing a minimum size of reads equal to 33 nucleotides.<br>
Script : 
* atac_trim.slurm : tool Trimmomatic.



#### 3. Quality control after trimming
Second quality control to identify if the overall quality of the samples has been improved or not.<br> 
Script :
* atac_qc_post.slurm : tool Fastqc.



#### 4. Mapping
The cleaned reads will be mapped to the mouse reference genome (GRCm39 assembly).<br>
Script :
* atac_bowtie2.slurm : tool Bowtie2.



#### 5. Removal of duplicates
Elimination of duplicates in order to remove biases related to PCR amplification.<br>
This with the help of the MarkDuplicates function of the picard module.<br>
Script : 
* atac_picards.slurm : this with the help of the MarkDuplicates function of the picard module.



#### 6. Data mining 
Utilisation of deepTools for the exploration of the results obtained after removal duplicated and perform statistical analyzes (coverage, read length correlation) between the samples.<br>
script : <br>
* atac_deeptools.slurm : deepTools <br>
 We will use differents fonctions from the deepTools module to explore the resultsand applied statistical analysis.<br> 
	- multiBamSummary : compiles the different BAM files (required for plotCorrelation).<br>
	- plotCorrelation :  identifie les corrélations entre échantillons.<br>
	- bamCoverage : analyzes the coverage on the genome of the samples.<br>
	- bamPEFragmentSize : Comparison of read sizes across samples.<br>



#### 7. Identification of chromatin access sites
In order to define unique and common DNA accessibility sites between cell stages, we used two different tools, MACS2 and Bedtools.<br>
Scripts :
* atac_macs2.slurm : determine DNA accessibility sites. 
* atac_bedtools.slurm : determine common and unique DNA accessibility sites. 

