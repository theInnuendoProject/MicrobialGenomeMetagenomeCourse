# Prepping files for Anvio
* Tom Delmont, Antti Karkman, Jenni Hultman*

Anvio is an analysis and visualization platform for omics data. You can read more from Anvio's webpage at http://merenlab.org/software/anvio/.

![alt text](https://github.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/raw/master/Screen%20Shot%202017-12-07%20at%2013.50.20.png "Tom's fault")

Go to your co-assembly folder and make a new folder called ANVIO

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
```
anvi-get-dna-sequences-for-gene-calls -o gene-calls.fa -c MEGAHIT_co-assembly_2500nt_CONTIGS.db
```

## Run centrifuge
Remember to set the environmental variable pointing to the centrifuge folder as shown in [MetagenomeInstallations](https://github.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/blob/master/MetagenomeInstallations.md). 

```
centrifuge -f -x $CENTRIFUGE_BASE/p+h+v/p+h+v gene-calls.fa -S centrifuge_hits.tsv
```
## IMPORT CENTRIFUGE RESULTS
```
anvi-import-taxonomy -i centrifuge_report.tsv centrifuge_hits.tsv -p centrifuge -c MEGAHIT_co-assembly_2500nt_CONTIGS.db 
```
## Create the BOWTIE2 index
```
bowtie2-build MEGAHIT_co-assembly_2500nt.fa MEGAHIT_co-assembly_2500nt
```
## MAPPING 


## Visualization in the interface

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



