
# From assemblies to cgMLST profiles: working with chewBBACA

### Task 1 -  Organizing and fetching the data

```
# Get chewBBACA
docker pull mickaelsilva/chewbbaca
 
# Create a working folder and enter it
mkdir test_chewBBACA
cd test_chewBBACA 
 
# Create folders to store the genomes

mkdir complete_genomes
mkdir other_assemblies
 
# create a list of complete genomes to download
# we will be using nano for text editing
touch 2down_cg.txt
nano 2down_cg.txt
 
# copy and paste this list of links into the file (to exit nano press "q" and save the changes with "y")
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/007/265/GCF_000007265.1_ASM726v1/GCF_000007265.1_ASM726v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/012/705/GCF_000012705.1_ASM1270v1/GCF_000012705.1_ASM1270v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/055/GCF_000196055.1_ASM19605v1/GCF_000196055.1_ASM19605v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/427/035/GCF_000427035.1_09mas018883/GCF_000427035.1_09mas018883_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/026/925/GCF_001026925.1_ASM102692v1/GCF_001026925.1_ASM102692v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/689/235/GCF_000689235.1_GBCO_p1/GCF_000689235.1_GBCO_p1_genomic.fna.gz
 
# create a list of assembled genomes to download
touch 2down_other.txt
nano 2down_other.txt
 
# copy and paste this list of links into the file
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/167/715/GCF_000167715.1_ASM16771v1/GCF_000167715.1_ASM16771v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/694/615/GCF_001694615.1_ASM169461v1/GCF_001694615.1_ASM169461v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/694/415/GCF_001694415.1_ASM169441v1/GCF_001694415.1_ASM169441v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/002/246/945/GCF_002246945.1_ASM224694v1/GCF_002246945.1_ASM224694v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/736/485/GCF_000736485.1_ASM73648v1/GCF_000736485.1_ASM73648v1_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/221/325/GCF_000221325.1_ASM22132v2/GCF_000221325.1_ASM22132v2_genomic.fna.gz
ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/287/955/GCF_000287955.1_ASM28795v1/GCF_000287955.1_ASM28795v1_genomic.fna.gz

# download and decompress the complete genomes files
cd complete_genomes
wget -i ../2down_cg.txt
gunzip ./*.gz
cd ..
 
# download and decompress other assemblies
cd other_assemblies
wget -i ../2down_other.txt
gunzip ./*.gz
cd ..

```

### Task 2 - Create a schema based on the downloaded complete genomes

```
# start a container with chewBBACA
docker run -it -v ~/:/data/ mickaelsilva/chewbbaca /bin/bash
 
# go to our working folder
cd /data/test_chewie
 
# run chewBBACA to create the schema using the complete genomes
chewBBACA.py CreateSchema -i complete_genomes/ -o schema_seed --cpu 8 -t "Streptococcus agalactiae"


```
### Task 3 - Run an allele call using the created schema and the genomes available

```

# create a file with full paths of the genomes we want to call alleles
 
find /data/test_chewie/complete_genomes/* >listgenomes.txt
find /data/test_chewie/other_assemblies/* >>listgenomes.txt
find /path/to/innuca/assemblies/*.fasta >>listgenomes.txt
 
# open listgenomes.txt and check if there are 20 lines with full paths for each assembly. Press "q" to exit less after the check
less listgenomes.txt
 
# use the created list of genomes to call the alleles 
chewBBACA.py AlleleCall -i listgenomes.txt -g schema_seed/ -o results --cpu 8 -t "Streptococcus agalactiae"
```

### Task 4 - schema eval
```
chewBBACA.py SchemaEvaluator -o rms/Myschema.html --cpu 8

zip -r myschemaEval.zip testcq

#download the myschemaEval.zip to your computer, unzip it and open the Myschema.html with firefox

```

### Task 5 - test genome allele call quality
```

# at the end of the command the program will try to open the html. Press "q" and "y" to exit that action when prompted
chewBBACA.py TestGenomeQuality -i results/<results_20171207T150515>/results_alleles.tsv -o testcq -n 12 -s 5 -t 300

# download testcq/GenomeQualityPlot.html to your local computer and open with your favorite browser

```
### Task 6- Extract the profile for phyloviz
```
# Extract a profile suitable to be used by phyloviz

chewBBACA.py ExtractCgMLST -i results/<results_20171207T150515>/results_alleles.tsv -o cgMLST_all -r results/results_20171207T150515/RepeatedLoci.txt -p 0.95

# download cgMLST_all/cgMLST.tsv to your computer and use it later for phyloviz

```

