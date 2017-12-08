*Jenni Hultman and Antti Karkman*

# Metagenome part 2

## Mapping the reads back to the assembly
The assembly should be finished and we hopefully have also some contigs. Next thing to do is mapping all the reads back to the contigs. We do it sample-wise, so each sample is mapped separately using the trimmed R1 & R2 reads.  
We will need to two scripts for that, one for the actual mapping and another to run it as an array job. Save both scripts to your `scripts` folder. 

But before doing that we have make a bowtie2 index from the contig file. Move to the assembly folder where you have a file called `final.contigs.fa` and load the biokit. Then run the following command:  

`bowtie2-build final.contigs.fa co-assembly`  

`co-assembly` is the base name for the resulting index files.  


The mapping script from Tom, modified to be used in Taito:
```
#!/bin/bash
# example run: ./bowtie2-map-batch.sh SAMPLE1_R1.fastq SAMPLE1_R2.fastq SAMPLE1 bt2_index

# $1: Forward reads
# $2: Reverse reads
# $3: Sample name
# $4: Bowtie2 index

set -e

bowtie2 --threads $SLURM_CPUS_PER_TASK -x $4 -1 $1 -2 $2 -S $3.sam --no-unal
samtools view -F 4 -bS $3.sam > $3-RAW.bam
samtools sort $3-RAW.bam -o $3.bam
samtools index $3.bam
rm $3.sam $3-RAW.bam
```
The array job script:
```
#!/bin/bash -l
#SBATCH -J array_map
#SBATCH -o array_map_out_%A_%a.txt
#SBATCH -e array_map_err_%A_%a.txt
#SBATCH -t 00:30:00
#SBATCH --mem-per-cpu=1000
#SBATCH --array=1-6
#SBATCH -n 1
#SBATCH --cpus-per-task=6
#SBATCH -p serial

cd $WRKDIR/BioInfo_course/all_assembly_def_1000
# we need Bowtie2 from the biokit
module load biokit
# each job will get one sample from the sample names file
name=$(sed -n "$SLURM_ARRAY_TASK_ID"p ../sample_names.txt)
bash ../scripts/bowtie2-map-batch.sh ../trimmed_data/$name"_R1_trimmed.fastq" \
     ../trimmed_data/$name"_R2_trimmed.fastq" \
     $name ../co-assembly
```
Then again submit the array job with `sbatch`.  

During luch break check what the different steps in mapping mean.
bowtie2 
samtools view 
samtools sort 
samtools index 


## Assembly quality assesment
Let's take a look at the assembly file from yesterday. From the log file at $WRKDIR/BioInfo_course/trimmed_data/all_assembly_def_1000 you can check how the assembly run and at the last rows how is the output. However, for more detailed analysis we run MetaQUAST (http://bioinf.spbau.ru/metaquast) together with the assembly. Copy folder called "assembly_QC" to your computer. We will view the results in your favorite browser. 

## Taxonomic profiling with Metaxa2 continued...
When all Metaxa2 array jobs are done, we can combine the results to an OTU table. Different levels correspond to different taxonomic levels.  
When using any 16S rRNA based software, be cautious with species (and beyond) level classifications. Especially when using short reads.  
We will look at genus level classification.
```
# Genus level taxonomy
metaxa2_dc -o birds_metaxa6.txt *level_6.txt
```

## Antibiotic resistance gene annotation - reads
Next step is the antibiotic resistance gene annotation.  

First convert all R1 files from fastq to fasta. You can use `fastq_to_fasta_fast` program that is included in the biokit.  
`fastq_to_fasta_fast TRIMMED.fastq > TRIMMED.fasta`  

Then add the sample name to each sequence header after the `>` sign. Keep the original fasta header and separate it with `-`. You can do this either separately for each file or write a batch script to go through all files .You can use the `sample_names.txt` as a input to your bash script.  
```
# Example header
>L3-M01457:76:000000000-BDYH7:1:1101:17200:1346
```

When all R1 files have been converted to fasta and renamed, combine them to one file. It will be the input file for antibiotic resistance gene annotation. The sample name in each fasta header will make it possible to count the gene abundances for each sample afterwards using the script you downloaded earlier.  

We will annotate the resistance genes using The Comprehensive Antibiotic Resistance Database, [CARD.](https://card.mcmaster.ca)  
Go to the CARD website and download the latest CARD release to folder called CARD under your user applications (`$USERAPPL`) folder and unpack the file.  

`bunzip2 broadstreet-v1.2.1.tar.bz2 && tar -xvf broadstreet-v1.2.1.tar `  

Then make a DIAMOND database file form the protein homolog model. It is a fasta file with amino acid sequences.  

`diamond makedb --in protein_fasta_protein_homolog_model.fasta -d CARD`

The annotation of resistance genes will be done as a batch job using DIAMOND against CARD. Make the batch script and submit it as previously. (This takes less than an hour + possible time in the queue).  
```
#!/bin/bash -l
#SBATCH -J diamond
#SBATCH -o diamond_out_%j.txt
#SBATCH -e diamond_err_%j.txt
#SBATCH -t 05:00:00
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH -p serial
#SBATCH --mem-per-cpu=2000
#

module load biokit
cd $WRKDIR/BioInfo_course
diamond blastx -d ~/appl_taito/CARD/CARD -q trimmed_data/birds_R1.fasta \
            --max-target-seqs 1 -o birds_R1_CARD.txt -f 6 --id 90 --min-orf 20 \
            -p $SLURM_CPUS_PER_TASK --masking 0
```

When the job is finished, inspect the results.  
They are in one file with each hit on one line and we would like to have a count table where we have different ARGs as rows and our samples as columns.  
This is a stupid script, but does the job.  

`python scripts/parse_diamond/parse_diamond.py -i birds_R1_CARD.txt -o birds_CARD.csv`

## Antibiotic resistance gene annotation - contigs
```
# allocate resources
salloc -n 1 --cpus-per-task=6 --mem=100 --nodes=1 -t 00:10:00 -p serial
srun --pty $SHELL
# run DIAMOND
diamond blastx -d ~/appl_taito/CARD/CARD -q gene-calls.fa \
            --max-target-seqs 1 -o CARD.out -f 6 --id 90 --min-orf 20 -p 6 --masking 0
# parse the output for Anvi'o  
printf "gene_callers_id\tsource\taccession\tfunction\te_value\n" > CARD_functions.txt
awk '{print $1"\tCARD\t\t"$2"\t"$11}' CARD.out >> CARD_functions.txt
# and finally import the functions to anvio contigs DB  
anvi-import-functions -c contigs.db -i CARD_functions.txt
