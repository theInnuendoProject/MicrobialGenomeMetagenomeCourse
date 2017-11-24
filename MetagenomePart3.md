# Prepping files for Anvio
* Tom Delmont, Antti Karkman, Jenni Hultman*

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
#
