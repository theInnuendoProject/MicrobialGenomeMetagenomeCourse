# Working group bacterial genomics, part 2

Today the group work is divided in two sessions: 1) evaluation of the assemblies and in silico prediction of the antibiotic resistance genes; 2) schema creation and allele-calling. The first session will be during lunch time and the second from 16:00 to 17:00 after the **chewBBACA** session.

## Session (1)

1) evaluate the quality of the assemblies inspecting *combine_samples_reports* and *samples_report* outfile of **INNUca**
> did all the samples pass the QA/QC? If not, what are the reasons for *FAIL* or *WARNING*?
2) make a new directory and transfer in it all the genomes passing the QA/QC
3) in the same directory upload the *full* and/or *draft* genome sequencing of the species of your choice (previously downloaded from NCBI/EMBL-EBI)
4) use *abrigate* and *ResFinder* database for detecting antibiotic resistance genes
5) starting from *abrigate* report, decide cut-off for presence/absence make a single file containing two columns, following the example below:

```
FILE  ResistanceGenes
Samplename_1  GeneName-GeneName-...-GeneName
Samplename_2  GeneName-GeneName-...-GeneName
```
