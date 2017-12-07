# Working group bacterial genomics, part 3

1) annotate all the assemblies with *prokka* and cluster the genes in groups of orthologs using *roary*
> with *-i* flag in *roary* you can decide the minimum percentage identity for blastp (default *95%*); do you think this value is appropriate for your dataset? 

**Note**: since your dateset is very small for performing GWAS, you will select a set of few accessory genes to be used in the final part of the course

2) from *gene_presence_absence.csv* produced by *roary* select three accessory genes, present in a significant number of samples (e.g. 1/3 of your dataset)
3) add to the *tab-separated values (TSV)* file produced during *working with your data part 2 session 2* three extra columns corresponding to the three selected genes, as follow:

```
FILE  ResistanceGenes Gene1 Gene2 Gene3
Samplename_1  GeneName-GeneName-...-GeneName  present absent  present
Samplename_2  ND  present absent  absent
```
