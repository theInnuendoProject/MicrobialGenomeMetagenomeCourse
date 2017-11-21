*Antti Karkman*
**_UNDER CONSTRUCTION FROM HERE ON_**
# Taxonomic annotation with Metaxa2
The first annotation step is to run Metaxa2 on the same samples. We will make a array job that will run each sample as a separate job.  


```
nice -5 parallel -j 6 -a sample_names.txt scripts/metaxa2.sh
nice -5 parallel -j 6 -a sample_names.txt scripts/metaxa2_ttt.sh
metaxa2_dc -o birds_metaxa6.txt *level_6.txt
metaxa2_dc -o birds_metaxa7.txt *level_7.txt

#Tax table from the OTU table
awk '{print $1}' birds_metaxa6.txt > taxa_names.txt
sed 's/;/ /g' taxa_names.txt > temp
awk '{print "OTU"(++i)"\t"$0}' temp > taxa_names.txt
rm temp
#And add taxonomic levels by hand to the resulting file
##OTUs to metaxa file too.##
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


Search againts MegaRes (MIGHT BE AN OPTION TO CARD, better DB and VSEARCH can make a count table as output. Much slower though)
```
#!/bin/bash -l
#SBATCH -J vsearch
#SBATCH -o vsearch_out_%j.txt
#SBATCH -e vsearch_err_%j.txt
#SBATCH -t 10:00:00
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH -p serial
#SBATCH --mem=10000
#

module load biokit
cd $WRKDIR/BioInfo_course/trimmed_data
vsearch --usearch_global birds_R1.fasta -db $USERAPPL/database//megares_v1.01/megares_database_v1.01.fasta --id 0.9 --maxaccepts 8 --maxhits 1 --otutabout birds_MegaRes.txt --strand both --threads $SLURM_CPUS_PER_TASK --mincols 30
```
Submit the job to queue.  
`sbatch scripts/vsearch_batch`


Metaphlan 2 ??
