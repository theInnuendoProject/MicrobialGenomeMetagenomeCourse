# Create wgMLST scheme

---

**Note 1:** replace whatever is between `<>` with the proper value. For example, in _"Get HTS (High-throughput sequencing) data"_ `<IDs_separated_by_space>`, write the IDs you will select (something like `SRR494564 SRR497008 SRR628716`).  
**Note 2:** if the VM has 16 CPUs, use `16` in CPUs/threads instead of `8`.  
**Note 3:** do the steps bellow for the bacteria species of your choise. _Streptococcus agalactiae_ is used as example.

---

## Get genomic data

### Organize data for scheme creation

<span style="color:grey">_In the VM_</span>

Create a folder where the data for scheme creation will be stored.

```
mkdir ~/scheme_creation_data
mkdir ~/scheme_creation_data/complete_genomes
mkdir ~/scheme_creation_data/hts
```

### Get complete genomes

<span style="color:grey">_In your computer_</span>

In NCBI [website](https://www.ncbi.nlm.nih.gov/):
  1. Select _"Genome"_ in dropdown menu and search _"Streptococcus agalactiae"_
  2. On the top box, bellow _"All XX genomes for species"_ section, click on _"Browse the list"_
  3. On _"Levels"_ options, only select _"Complete"_
  4. Take note of the average genome size using _"Size (Mb)"_ column. For _Streptococcus agalactiae_, **2.1 Mb** will be used.
  5. Choose between 4-6 complete genomes to download:
    * For the selected genome, click on the green diamond under _"FTP"_ column
    * Copy Link Location of the link ending with *"_genomic.fna.gz"* (ignore the one ending with *"_rna_from_genomic.fna.gz"*)
    * <span style="color:grey">_In the VM_</span>:

```
# Change to directory where the data will be stored
# Only required to do once

cd ~/scheme_creation_data/complete_genomes

wget <the.copied.link>

# wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/007/265/GCF_000007265.1_ASM726v1/GCF_000007265.1_ASM726v1_genomic.fna.gz
# wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/012/705/GCF_000012705.1_ASM1270v1/GCF_000012705.1_ASM1270v1_genomic.fna.gz
# wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/196/055/GCF_000196055.1_ASM19605v1/GCF_000196055.1_ASM19605v1_genomic.fna.gz
# wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/427/035/GCF_000427035.1_09mas018883/GCF_000427035.1_09mas018883_genomic.fna.gz
# wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/026/925/GCF_001026925.1_ASM102692v1/GCF_001026925.1_ASM102692v1_genomic.fna.gz
# wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/689/235/GCF_000689235.1_GBCO_p1/GCF_000689235.1_GBCO_p1_genomic.fna.gz
```
<span style="color:grey">_In the VM_</span>  

Uncompressed the downloaded complete genomes:
```
cd ~/scheme_creation_data/complete_genomes
gunzip *
```

### Get HTS (High-throughput sequencing) data

<span style="color:grey">_In your computer_</span>  

In ENA (European Nucleotide Archive) [website](https://www.ebi.ac.uk/ena):
  1. Search _"Streptococcus agalactiae"_
  2. On the left list, bellow _"Read"_ section, click on _"Run"_
  3. Choose between 4-6 run accession IDs
    * Select only _Illumina paired end_ data, but produced with different sequencers modules (try _HiSeq, MiSeq, NextSeq, Genome Analyzer II_)
    * Try IDs from different pages
    * Select _"WGS"_ (under _"Library Strategy"_ information) and _"GENOMIC"_ (under _"Library Source"_ information) produced sequencing data
    * Select samples with a maximum estimated depth of coverage of 200x
      * Divide the number of sequenced nucleotides (under _"Base Count"_ information) by the previously determined genome size in bp (for _Streptococcus agalactiae_, 2.1 Mb * 1000000)

<span style="color:grey">_In the VM_</span>  

Get the data
```
# Create a file with the list of IDs to download
rm ~/scheme_creation_data/hts/ids.txt

for id in <IDs_separated_by_space>; do
  echo $id >> ~/scheme_creation_data/hts/ids.txt
done

# for id in SRR494564 SRR497008 SRR628716 SRR755352 SRR3320580 SRR4414149; do echo $id >> ~/scheme_creation_data/hts/ids.txt; done


# Download data using getSeqENA
getSeqENA.py --listENAids ~/scheme_creation_data/hts/ids.txt \
             --outdir ~/scheme_creation_data/hts/ \
             --asperaKey  ~/NGStools/aspera/connect/etc/asperaweb_id_dsa.openssh \
             --downloadLibrariesType PAIRED \
             --downloadInstrumentPlatform ILLUMINA \
             --threads 8 \
             --SRAopt
```

---

## Assembly HTS data

Assembly HTS data using INNUca

<span style="color:grey">_In the VM_</span>  

  *  Change the following options accordingly with the species chosen:
    * `--speciesExpected` "Streptococcus agalactiae"
    * `--genomeSizeExpectedMb` 2.1  

```
# Run inside a screen
screen -S create_scheme

# INNUca
docker run --rm -u $(id -u):$(id -g) -it -v ~/scheme_creation_data:/data/ ummidock/innuca:3.1 \
       INNUca.py --inputDirectory /data/hts/ \
                 --speciesExpected "Streptococcus agalactiae" \
                 --genomeSizeExpectedMb 2.1 \
                 --outdir /data/innuca/ \
                 --threads 8 \
                 --fastQCproceed

# Detatch the screen
# Press Ctrl + A (release) and then D

# With 8 CPUs and Streptococcus example
# Runtime :0.0h:34.0m:45.3s
```
