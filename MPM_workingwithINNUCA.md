# From reads to assembly: working with INNUca pipeline

---

* [_From microbial genomics to metagenomics_](./README.md)
  * [_Bacterial Genomics_](./Genomics.md)
    * [_Prepare the Virtual Machine_](./MPM_starting_VM.md)
    * _From reads to assembly: working with INNUca pipeline_
      1. [_Get genomic data_](./MPM_workingwithINNUCA.md#get-genomic-data)
      2. [_Assembly HTS data_](./MPM_workingwithINNUCA.md#assembly-hts-data)
      3. [_Organize assemblies_](./MPM_workingwithINNUCA.md#organize-assemblies)
      4. [_Remove INNUca image_](./MPM_workingwithINNUCA.md#remove-innuca-image)
    * [In silico _typing using ReMatCh and Abricate_](./MPM_ReMatCh_Abricate.md)
    * [_ Annotation with Prokka and intro of Roary_](./MPM_Prokka_Roary_Scoary.md)

---

**Note 1:** replace whatever is between `<>` with the proper value. For example, in _"Organize the data"_ `<your_species_name>`, write the species name you selected (something like `campylobacter_jejuni`).  
**Note 2:** if the VM has 16 CPUs, use `16` in CPUs/threads instead of `8`.  
**Note 3:** do the steps bellow for the bacteria species of your choise. _Streptococcus agalactiae_ is used as example.

---

## Get genomic data

<!---
### Get complete genomes

_In your computer_

In NCBI [website](https://www.ncbi.nlm.nih.gov/):
  1. Select _"Genome"_ in dropdown menu and search _"Streptococcus agalactiae"_
  2. On the top box, bellow _"All XX genomes for species"_ section, click on _"Browse the list"_
  3. On _"Levels"_ options, only select _"Complete"_
  4. Take note of the average genome size using _"Size (Mb)"_ column. For _Streptococcus agalactiae_, **2.1 Mb** will be used.
  5. Choose between 4-6 complete genomes to download:
      * For the selected genome, click on the green diamond under _"FTP"_ column
      * Copy Link Location of the link ending with *"_genomic.fna.gz"* (ignore the one ending with *"_rna_from_genomic.fna.gz"*)
      * _In the VM_:

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
_In the VM_  

Uncompressed the downloaded complete genomes:
```
cd ~/scheme_creation_data/complete_genomes
gunzip *
```
-->

### Get genomic information

_In your computer_

In NCBI [website](https://www.ncbi.nlm.nih.gov/):
  1. Select _"Genome"_ in dropdown menu and search _"Streptococcus agalactiae"_
  2. On the top box, bellow _"All XX genomes for species"_ section, click on _"Browse the list"_
  3. On _"Levels"_ options, only select _"Complete"_
  4. Take note of the average genome size using _"Size (Mb)"_ column. For _Streptococcus agalactiae_, **2.1 Mb** will be used.

### Organize the data

_In the VM_

```bash
# Create a folder to store the HTS reads

mkdir ~/reads
mkdir ~/reads/<your_species_name>

# Create a folder for Streptococcus agalactiae example
mkdir ~/reads/streptococcus_agalactiae_example


# Create a folder to store the genomes

mkdir ~/genomes
mkdir ~/genomes/<your_species_name>

# Create a folder for Streptococcus agalactiae example
mkdir ~/genomes/streptococcus_agalactiae_example
```

### Get HTS (High-throughput sequencing) data

<!---
* **_Example: "What I did"_**

  _In your computer_

  In ENA (European Nucleotide Archive) [website](https://www.ebi.ac.uk/ena):
    1. Search _"Streptococcus agalactiae"_
    2. On the left list, bellow _"Read"_ section, click on _"Run"_
    3. Choose between 4-6 run accession IDs
        * Select only _Illumina paired end_ data, but produced with different sequencers modules (try _HiSeq, MiSeq, NextSeq, Genome Analyzer II_)
        * Try IDs from different pages
        * Select _"WGS"_ (under _"Library Strategy"_ information) and _"GENOMIC"_ (under _"Library Source"_ information) produced sequencing data
        * Select samples with a maximum estimated depth of coverage of 200x
          * Divide the number of sequenced nucleotides (under _"Base Count"_ information) by the previously determined genome size in bp (for _Streptococcus agalactiae_, 2.1 Mb * 1000000)
-->

**Upload a file with IDs to download**  

_In your computer_

_UNIX terminal_  

```bash
scp -i </path/to/provided/private/ssh/key/mgmc.key> </path/to/file/with/IDs.txt> cloud-user@<VM.IP>:~/reads/<your_species_name>
```

_FileZilla_  

* Get FileZilla [here](https://filezilla-project.org/)
* More information on using Filezilla with SSH key [here](https://www.digitalocean.com/community/tutorials/how-to-use-filezilla-to-transfer-and-manage-files-securely-on-your-vps#sftp-via-ssh2-key-based-authentication "Google search: filezilla ssh key")
* Upload the file to `/home/cloud-user/reads/<your_species_name>/`

**Get the data**

_In the VM_  

```bash
# Using the Streptococcus agalactiae example
# 10 samples

# Get the file with IDs
wget -O ~/reads/streptococcus_agalactiae_example/MPM_GBS_samples.tab https://raw.githubusercontent.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/master/MPM_GBS_samples.tab

# Produce a clean file by removing the header line (first line) and containing only the first column
# The next command pipes two different commands and redirects the output to a file
sed 1d ~/reads/streptococcus_agalactiae_example/MPM_GBS_samples.tab | cut -f 1 > ~/reads/streptococcus_agalactiae_example/ids.txt

# Download data using getSeqENA
getSeqENA.py --listENAids ~/reads/streptococcus_agalactiae_example/ids.txt \
             --outdir ~/reads/streptococcus_agalactiae_example/ \
             --asperaKey  ~/NGStools/aspera/connect/etc/asperaweb_id_dsa.openssh \
             --downloadLibrariesType PAIRED \
             --downloadInstrumentPlatform ILLUMINA \
             --threads 8 \
             --SRAopt

# Runtime :0.0h:2.0m:10.12s
```
* More information about piping and redirection [here](https://ryanstutorials.net/linuxtutorial/piping.php "Google search: linux pipe command")
* More information on skipping lines [here](https://stackoverflow.com/questions/604864/print-a-file-skipping-x-lines-in-bash "Google search: linux skip first line file")
* For more information about cutting text based on delimiters: `cut --help` or `man cut`, and [here](http://www.thegeekstuff.com/2013/06/cut-command-examples "Google search: linux cut")

---

## Assembly HTS data

Assembly HTS data using INNUca

_In the VM_  

```bash
# INNUca basic command

# You should specify where the output goes whenever there is an option to do that
# Whenever possible use the option to specify the number of CPUs/threads to be used

docker run --rm -u $(id -u):$(id -g) -it -v ~/:/data/ ummidock/innuca:3.1 \
       INNUca.py --inputDirectory /data/reads/<your_species_name>/ \
                 --speciesExpected "<your species name with space>" \
                 --genomeSizeExpectedMb <your_species_genome size> \
                 --outdir /data/genomes/<your_species_name>/innuca/ \
                 --threads 8
```

Using the Streptococcus agalactiae example:

```bash
# Run inside a screen
screen -S streptococcus_agalactiae_example

# INNUca
docker run --rm -u $(id -u):$(id -g) -it -v ~/:/data/ ummidock/innuca:3.1 \
       INNUca.py --inputDirectory /data/reads/streptococcus_agalactiae_example/ \
                 --speciesExpected "Streptococcus agalactiae" \
                 --genomeSizeExpectedMb 2.1 \
                 --outdir /data/genomes/streptococcus_agalactiae_example/innuca/ \
                 --threads 8 \
                 --fastQCproceed \
                 --fastQCkeepFiles \
                 --trimKeepFiles \
                 --saveExcludedContigs

# Detatch the screen
# Press Ctrl + A (release) and then D

# Runtime :1.0h:14.0m:33.47s
```
* More information about `screen` [here](https://www.rackaid.com/blog/linux-screen-tutorial-and-how-to/ "Google search: linux screen") and `man screen`

## Organize assemblies

Store all assembled genomes (good and bad assemblies) in a single folder to use with next tools.

_In the VM_  

```bash
# Create the folder where assemblies will be stored
mkdir ~/genomes/<your_species_name>/all_assemblies

# Using the Streptococcus agalactiae example

mkdir ~/genomes/streptococcus_agalactiae_example/all_assemblies

# Copy INNUca's final assemblies
# The next command pipes different commands:
## The first sed command read the INNUca combine_samples_reports.tab file and skip the header line
## cut command will get the final_assembly column
## grep will ignore those samples that did not produced a final assembly ("NA")
## Then, the resulting list feeds parallel command that will copy the file for each entry
### Inside parallel {} substitutes each line that gets inside parallel
### Because INNUca ran inside Docker, the assembly path is relative to /data/
### The second sed (inside parallel) replaces the /data/ with user HOME directory in each line that gets inside parallel

sed 1d ~/genomes/streptococcus_agalactiae_example/innuca/combine_samples_reports.*.tab | \
          cut -f 23 | \
          grep --invert-match "NA" | \
          parallel --jobs 8 'cp $(sed s#/data/#$HOME/#1 <(echo {})) $HOME/genomes/streptococcus_agalactiae_example/all_assemblies/'
```
* For more information about finding patterns: `grep --help` or `man grep`, and [here](https://www.cyberciti.biz/faq/howto-use-grep-command-in-linux-unix/ "Google search: linux grep")
* More information about using parallel: [introduction and bioinformatics examples](https://www.biostars.org/p/63816/); [manual](https://www.gnu.org/software/parallel/man.html); [tutorial](https://www.gnu.org/software/parallel/parallel_tutorial.html)

## Remove INNUca image

To avoid VM space problems during the course, unused Docker images will be removed

_In the VM_  

```bash
# List Docker images
docker images
# Remove INNuca image
# Find the INNUca image line starting with ummidock/innuca
# Get the Image ID, something like 1f467865b7f3
docker rmi <INNUca_Image_ID>
```
