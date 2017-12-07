# Prepping files for Anvio
* Tom Delmont, Antti Karkman, Jenni Hultman*

Anvi’o is an analysis and visualization platform for ‘omics data. You can read more from Anvio's webpage at http://merenlab.org/software/anvio/.

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
## Rename the scaffolds and select those >2,500nt
```
anvi-script-reformat-fasta ../final.contigs.fa -l 2500 --simplify-names --prefix MEGAHIT_co_assembly -r REPORT -o MEGAHIT_co-assembly_2500nt.fa
```

## Generate CONTIGS.db
```
anvi-gen-contigs-database -f MEGAHIT_co-assembly_2500nt.fa -o MEGAHIT_co-assembly_2500nt_CONTIGS.db -n MEGAHIT_co-assembly
```
## Run HMMs to identify single copy core genes for Bacteria and Archaea, plus rRNAs
```
anvi-run-hmms -c MEGAHIT_co-assembly_2500nt_CONTIGS.db -T 10
```
## Run COGs
```
anvi-run-ncbi-cogs -c MEGAHIT_co-assembly_2500nt_CONTIGS.db -T 10
```
## Export GENES
```
anvi-get-dna-sequences-for-gene-calls -o gene-calls.fa -c MEGAHIT_co-assembly_2500nt_CONTIGS.db
```

## Run centrifuge

```
centrifuge -f -x /wrk/hultman/DONOTREMOVE/SCRIPTS/centrifuge_db/p+h+v/p+h+v gene-calls.fa -S centrifuge_hits.tsv
```

