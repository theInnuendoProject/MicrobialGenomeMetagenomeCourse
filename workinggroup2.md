# Working group bacterial genomics, part 2

1) create a whole genome schema based on the full set of genomes using *chewBBACA CreateSchema* and call the alleles for each sample using *chewBBACA AlleleCall* 
2) test the quality of the genomes in term of allele calling using *chewBBACA TestGenomeQuality* 
3) extract the core genome MLST allele profiles from the dataset using *chewBBACA ExtractCgMLST* 
> will you include all the genomes? would you exclude certain loci (eg. reapted loci)? at which level you will perform your cgMLST analysis (100%, 99%, 95%, etc.)?
4) make sure that the *cgMLST.tsv* file contains the samples name in the first column as written in the TSV above produced with Abrigate. If not, adapt either the *cgMLST.tsv* or the TSV file.
