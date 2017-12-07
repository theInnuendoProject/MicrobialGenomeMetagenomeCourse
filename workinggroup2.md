# Working group bacterial genomics, part 2

Today the group work is divided in two sessions: 1) evaluation of the assemblies and *in silico* prediction of the antibiotic resistance genes; 2) schema creation and allele-calling. The first session will be performed during lunch time and the second from 16:00 to 17:00 after the **chewBBACA** session.

## Session (1)

1) evaluate the quality of the assemblies inspecting *combine_samples_reports* and *samples_report* outfile of **INNUca**
> did all the samples pass the QA/QC? If not, what are the reasons for *FAIL* or *WARNING*?
2) make a new directory and transfer in it all the genomes passing the QA/QC
3) in the same directory upload the *full* and/or *draft* genome sequencing of the species of your choice (previously downloaded from NCBI/EMBL-EBI)
4) use *abrigate* and *ResFinder* database for detecting antibiotic resistance genes
5) starting from *abrigate* report, decide the cut-off for presence/absence of genes, and make a single *tab-separated values (TSV)* file containing two columns, following the example below:

```
FILE  ResistanceGenes
Samplename_1  GeneName-GeneName-...-GeneName
Samplename_2  ND
```

**Note**: use the same nomenclature for same antibiotic resistance profile (e.g. two samples with the same list of genes should have the same value under *ResistanceGenes*)

## Session (2)

1) create a whole genome schema based on the full set of genomes using *chewBBACA CreateSchema* and call the alleles for each sample using *chewBBACA AlleleCall* 
2) test the quality of the genomes in term of allele calling using *chewBBACA TestGenomeQuality* 
3) extract the core genome MLST allele profiles from the dataset using *chewBBACA ExtractCgMLST* 
> will you include all the genomes? would you exclude certain loci (eg. reapted loci)? at which level you will perform your cgMLST analysis (100%, 99%, 95%, etc.)?
4) make sure that the *cgMLST.tsv* file contains the samples name in the first column as written in the TSV above. If not, adapt either the *cgMLST.tsv* or the TSV file.
