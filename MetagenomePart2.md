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


# Resistance gene annotation
Next step is the antibiotic resistance annotation. We will use only the R1 reads.  
Convert the fastq files to fasta and rename all sequences in the files with the sample name + running no.  
After that combine all the R1 fasta reads with sample name in the header to one file.  
```
nice -5 parallel -j 6 -a sample_names.txt scripts/fastq2fasta.py # this takes ~5 min
cat *R1_renamed.fasta > birds_R1.fasta
# to save space, you can remove the individual renamed files  
rm *_renamed.fasta
```

Download the latest CARD release to your applications folder under a folder called CARD and extract the file.  
`bunzip2 broadstreet-v1.2.1.tar.bz2 && tar -xvf broadstreet-v1.2.1.tar `
Then make a DIAMOND database file form the protein homolog model.  
`diamond makedb --in protein_fasta_protein_homolog_model.fasta -d CARD`

The annotation of resistance genes will be done as a batch job using DIAMOND (This might take slightly longer, depending on the queue).
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
#SBATCH --mem=5000
#

module load biokit
cd $WRKDIR/BioInfo_course/trimmed_data
diamond blastx -d ~/databases/CARD/CARD_prot -q birds_R1.fasta --max-target-seqs 1 -o birds_R1_CARD.txt -f 6 --id 90 --min-orf 20 -p 24 --seq no
```

When the job is finished, go tot the folder with trimmed data and inspect the results.  
They are in one file with each hit on one line and we would like to have a count table where we have ARGs on rows and samples as columns.  
This is a stupid script, but does the job.  
`python ../scripts/parse_diamond.py -i birds_R1_CARD.txt -o birds_CARD.csv`
