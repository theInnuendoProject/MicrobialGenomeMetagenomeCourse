*Antti Karkman*


# Taxonomic profiling with Metaxa2
The microbial community profiling for the samples will be done using a 16S/18S rRNA gene based classification software [Metaxa2](http://microbiology.se/software/metaxa2/).  
It identifies the 16S/18S rRNA genes from the short reads using HMM models and then annotates them using BLAST and a reference database.
We will run Metaxa2 as an array job in Taito. More about array jobs at CSC [here](https://research.csc.fi/taito-array-jobs).  

Make a folder for Metaxa2 results and direct the results to that folder in your array job script. (Takes ~6 h for the largest files)
```
#!/bin/bash -l
#SBATCH -J metaxa
#SBATCH -o metaxa_out_%A_%a.txt
#SBATCH -e metaxa_err_%A_%a.txt
#SBATCH -t 10:00:00
#SBATCH --mem=500
#SBATCH --array=1-6
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=6
#SBATCH -p serial

cd $WRKDIR/BioInfo_course/Metaxa2
# Metaxa uses HMMER3 and BLAST, so load the biokit first
module load biokit
# each job will get one sample from the sample names file stored to a variable $name
name=$(sed -n "$SLURM_ARRAY_TASK_ID"p ../sample_names.txt)
# then the variable is used in running metaxa2
metaxa2 -1 ../trimmed_data/$name"_R1_trimmed.fastq" -2 ../trimmed_data/$name"_R2_trimmed.fastq" \
            -o $name --align none --graphical F --cpu $SLURM_CPUS_PER_TASK --plus
metaxa2_ttt -i $name".taxonomy.txt" -o $name
```

When all Metaxa2 array jobs are done, we can combine the results to an OTU table. Different levels correspond to different taxonomic levels.  
When using any 16S rRNA based software, be cautious with species (and beyond) level classifications. Especially when using short reads.  
We have longer reads than metagenomic studies in general and Metaxa2 should be conservative in its classification, so we could have a look at the species level classification as well.  
```
# Genus level taxonomy
metaxa2_dc -o birds_metaxa6.txt *level_6.txt
# Species level taxonomy
metaxa2_dc -o birds_metaxa7.txt *level_7.txt
```

# Assembly quality assesment
Let's take a look at the assembly file from yesterday. From the log file at $WRKDIR/BioInfo_course/trimmed_data/all_assembly_def_1000 you can check how the assembly run and at the last rows how is the output. However, for more detailed analysis we will run MetaQUAST (http://bioinf.spbau.ru/metaquast)
```
#load biokit
module load biokit
#go to $WRKDIR/BioInfo_course/trimmed_data/all_assembly_def_1000
metaquast.py final.contigs.fa
```


# Antibiotic resistance gene annotation - reads
Next step is the antibiotic resistance gene annotation.  

First convert all R1 files from fastq to fasta. You can use `fastq_to_fasta_fast` program that is included in the biokit.  
`fastq_to_fasta_fast TRIMMED.fastq > TRIMMED.fasta`  

Then add the sample name to each sequence header after the `>` sign. Keep the original fasta header and separate it with `-`. You can do this either separately for each file or write a batch script to go through all files .You can use the `sample_names.txt` as a input to your bash script.  
```
# Example header
>L3-1-M01457:76:000000000-BDYH7:1:1101:17200:1346
```

When all R1 files have been transformed to fasta and reamed, combine them to one file. It will be the input file for antibiotic resistance gene annotation. The sample name in each fasta header will make it possible to count the gene abundances for each sample afterwards.  

We will annotate the resistance genes using The Comprehensive Antibiotic Resistance Database, [CARD](https://card.mcmaster.ca)  
Go to the CARD website and download the latest CARD release to folder called CARD under your user applications (`$USERAPPL`) folder and unpack the file.  
`bunzip2 broadstreet-v1.2.1.tar.bz2 && tar -xvf broadstreet-v1.2.1.tar `
Then make a DIAMOND database file form the protein homolog model amino acid fasta file.  
`diamond makedb --in protein_fasta_protein_homolog_model.fasta -d CARD`

The annotation of resistance genes could be done as a batch job using DIAMOND against CARD. (This took ~1h 30min + the time in the queue).
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

# Antibiotic resistance gene annotation - contigs
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
