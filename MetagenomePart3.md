# Prepping files for Anvio
* Tom Delmont, Antti Karkman, Jenni Hultman*

Anvio is an analysis and visualization platform for omics data. You can read more from Anvio's webpage at http://merenlab.org/software/anvio/.

![alt text](https://github.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/raw/master/Screen%20Shot%202017-12-07%20at%2013.50.20.png "Tom's fault")

Go to your co-assembly folder and make a new folder called ANVIO. All task on this section are to be done in this folder. 

```
mkdir ANVIO
cd ANVIO
```
We need to do some tricks for the contigs from assembly before we can use them on Friday. You'll need to upload biokit and activate Anvio

```
module load biokit
source activate anvio3
```
## Rename the scaffolds and select those >2,500nt.
Anvio wants sequence IDs in your FASTA file as simple as possible. Therefore we need to reformat the headerlines to remove spaces and non-numeric characters. Also contigs shorter than 2500 bp will be removed. 

```
anvi-script-reformat-fasta ../final.contigs.fa -l 2500 --simplify-names --prefix MEGAHIT_co_assembly -r REPORT -o MEGAHIT_co-assembly_2500nt.fa
```

## Generate CONTIGS.db

Contigs database (contigs.db) contains information on contig length, open reading frames (searched with Prodigal) and kmers. See http://merenlab.org/2016/06/22/anvio-tutorial-v2/#creating-an-anvio-contigs-database for more information.

```
anvi-gen-contigs-database -f MEGAHIT_co-assembly_2500nt.fa -o MEGAHIT_co-assembly_2500nt_CONTIGS.db -n MEGAHIT_co-assembly
```
## Run HMMs to identify single copy core genes for Bacteria and Archaea, plus rRNAs
```
anvi-run-hmms -c MEGAHIT_co-assembly_2500nt_CONTIGS.db -T 10
```
## Run COGs

Next we annotate genes in  contigs database with functions from the NCBI’s Clusters of Orthologus Groups (COGs). 

```
anvi-run-ncbi-cogs -c MEGAHIT_co-assembly_2500nt_CONTIGS.db -T 10
```
## Export GENES
With this command we export the genecalls from Prodigal to gene-calls.fa and do taxonomic annotation against centrifuge database you installed on Wednesday

```
anvi-get-dna-sequences-for-gene-calls -o gene-calls.fa -c MEGAHIT_co-assembly_2500nt_CONTIGS.db
```

## Run centrifuge
“classification engine that enables rapid, accurate and sensitive labeling of reads and quantification of species on desktop computers”. Read more from http://biorxiv.org/content/early/2016/05/25/054965. 

Remember to set the environmental variable pointing to the centrifuge folder as shown in [MetagenomeInstallations](https://github.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/blob/master/MetagenomeInstallations.md). 

```
centrifuge -f -x $CENTRIFUGE_BASE/p+h+v/p+h+v gene-calls.fa -S centrifuge_hits.tsv
```
## Import centrifuge results
```
anvi-import-taxonomy -i centrifuge_report.tsv centrifuge_hits.tsv -p centrifuge -c MEGAHIT_co-assembly_2500nt_CONTIGS.db 
```
## Create the BOWTIE2 index
We will use Bowtie2 to map the trimmed reads against assembled contigs.
```
module load biokit
bowtie2-build MEGAHIT_co-assembly_2500nt.fa MEGAHIT_co-assembly_2500nt
```
## Mapping with bowtie2
What does the following script do? KORJAA AJAT JA MUISTI
```
#!/bin/bash
#SBATCH -J bowtie_batch
#SBATCH -o bowtie_out_%j.txt
#SBATCH -e bowtie_err_%j.txt
#SBATCH -t 06:00:00
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=20000
#

#example run: ./bowtie2-map-batch.sh 13_Jan_CAT-QUALITY_PASSED_R1.fastq 13_Jan_CAT-QUALITY_PASSED_R2.fastq CAT0113 /Quaterly_megahit_12samples-assembly/Ella_quaterly_12samples_assembly_5kb

# $1: 13_Jan_CAT-QUALITY_PASSED_R1.fastq
# $2: 13_Jan_CAT-QUALITY_PASSED_R2.fastq
# $3: CAT0113
# $4: /Quaterly_megahit_12samples-assembly/Ella_quaterly_12samples_assembly_5kb

bowtie2 --threads 6 -x MEGAHIT_co-assembly_2500nt -1 ../trimmed_data/$name"_R1_trimmed.fastq" -2 ../trimmed_data/$name"_R2_trimmed.fastq -S $name.sam --no-unal
samtools view -F 4 -bS $name.sam > $name-RAW.bam
samtools sort $name-RAW.bam -o $name.bam
samtools index $name.bam
rm $name.sam $name-RAW.bam

```
run

sbatch ../../../scripts/bowtie2-map-batch.sh ../../../sample_names.txt

## Visualization in the interface (On Friday)

Open a new ssh window. In mac:
```
ssh -L 8080:localhost:8080 hultman@taito.csc.fi
```

in Windows with Putty:
In SSH tab select "tunnels". Add

Source port: 8080 
Destination: localhost:8080

Click add and log in to Taito.

Activate anvio

```
anvi-interactive -c METASPADES_co-assembly_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db --server-only -P 8080
```

Then open google chrome and go to address 

http://localhost:8080

# In case sinteractive gets stuck
```
salloc -n 1 --cpus-per-task=4 --mem=8000 --nodes=1 -t 08:00:00 -p serial
```



