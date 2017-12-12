# _In silico_ typing using ReMatCh and Abricate

---

* [_From microbial genomics to metagenomics_](./README.md)
  * [_Bacterial Genomics_](./Genomics.md)
    * [_Prepare the Virtual Machine_](./MPM_starting_VM.md)
    * [_From reads to assembly: working with INNUca pipeline_](./MPM_workingwithINNUCA.md)
    * In silico _typing using ReMatCh and Abricate_
      1. [_Get DB of antimicrobial resistance genes_](./MPM_ReMatCh_Abricate.md#get-db-of-antimicrobial-resistance-genes)
      2. [_Typing samples_](./MPM_ReMatCh_Abricate.md#typing-samples)

---

**Note 1:** replace whatever is between `<>` with the proper value. For example, in _"Organize the data"_ `<your_species_name>`, write the species name you selected (something like `campylobacter_jejuni`).  
**Note 2:** if the VM has 16 CPUs, use `16` in CPUs/threads instead of `8`.  
**Note 3:** do the steps bellow for the bacteria species of your choise. _Streptococcus agalactiae_ is used as example.

---

## Get DB of antimicrobial resistance genes

Download a database containing antimicrobial resistance genes

### Resfinder

**_What is [Resfinder](https://cge.cbs.dtu.dk/services/ResFinder/)?_**  

> ResFinder identifies acquired antimicrobial resistance genes and/or find chromosomal mutations in total or partial sequenced isolates of bacteria

But it also provides a curated database for antimicrobial resistance genes.

**_Get ResFinder DB_**  
_In your computer_  

In Genomic Epidemiology databases Bitbucket [webpage](https://hub.docker.com/u/sangerpathogens/):
  * resfinder_db
  * Copy the _HTTPS_ link

_In the VM_  

Althoug ResFinder is a curated database, small details impair a simple concatenation for downstream use. Therefore several steps are required to properlly prepare the DB.

```bash
# Get ResFinder DB
git clone https://bitbucket.org/genomicepidemiology/resfinder_db.git
mv resfinder_db/ ~/DBs/

# Create a single file containing the sequences of genes confering resistance to all antibiotic classes together
## Make sure all files end with a newline to avoid concatening two sequences together
mkdir temp_concat_resfinder
ls ~/DBs/resfinder_db/*.fsa | parallel --jobs 8 'cp {} temp_concat_resfinder/; echo "" >> temp_concat_resfinder/{/}'
## Correct several details
### Concatenate all files
### Convert DOS to UNIX newlines special chracters
### Ignore blank lines
### Pass everytnhing to parallel
#### Split everything that enters parallel by sequence (--recstart '>')
#### cat receives each sequence
#### Each sequence is saved in seq variable
#### The header line is saved by grepping the line with ">" while removing trailing spaces with sed
#### The sequnce is saved in a file named as the sequence header without the '>' character, therefore removing duplicated sequences (at least on headers level)
mkdir temp_concat_resfinder/seq_file
cat temp_concat_resfinder/*.fsa | \
       sed $'s/\r$//' | \
       grep --invert-match "^$" | \
       parallel --jobs 1 --pipe -N 1 --recstart '>' 'cat | { seq=$(cat); header=$(echo "$seq" | grep ">" | sed -e "s/[[:space:]]*$//"); echo "$seq" > temp_concat_resfinder/seq_file/${header:1}.fasta; }'

# Concatenate the cleaned sequences
cat temp_concat_resfinder/seq_file/*.fasta > ~/DBs/resfinder_db/resfinder_db.fasta
rm -r temp_concat_resfinder/
```
More informations:
* [Adding newlines at the end of files](https://stackoverflow.com/questions/23055831/add-new-line-character-at-the-end-of-file-in-bash "Google search: add newline at end of file")
* Reading different files together: `cat --help` or `man cat`, and [here](https://www.computerhope.com/unix/ucat.htm "Google search: linux cat")
* [Converting newline characters from DOS to UNIX](https://stackoverflow.com/questions/2613800/how-to-convert-dos-windows-newline-crlf-to-unix-newline-n-in-a-bash-script "Google search: sed dos to unix")
* [Skipping blank lines](https://stackoverflow.com/questions/22080937/bash-skip-blank-lines-when-iterating-through-file-line-by-line "Google search: bash skip blank lines")
* [Removing trailing spaces](https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable "Google search: remove space end string linux")
* [Removing characters from the beggining of a string](https://stackoverflow.com/questions/11469989/how-can-i-strip-first-x-characters-from-string-using-sed "Google search: remove first character from string shell")

### Update Abricate DB

After a Docker image is built, its content is static, which mean it might carry outdated databases. However, some small steps can overwrite the provided DBs with updated ones.

_In the VM_  

```bash
# Create folder to store Abricate DBs
mkdir ~/DBs/abricate

# Copy DB folder to outside image
## External folder will overwrite image inside folder when mapped
docker run --rm -u $(id -u):$(id -g) -it -v ~/DBs/abricate/:/data/ ummidock/abricate:latest \
       cp -r /NGStools/miniconda/db/ /data/
mv ~/DBs/abricate/db/* ~/DBs/abricate/
rm -r ~/DBs/abricate/db/

# Update DB in a folder that will persist after container stops
docker run --rm -u $(id -u):$(id -g) -it -v ~/DBs/abricate/:/NGStools/miniconda/db/ ummidock/abricate:latest \
      abricate-get_db --db resfinder --force
```

## Typing samples

Two different approaches can be used to type HTS data: directly from reads using a reference mapping approach, or throught similarity sequence search using an already produced genome assembly.
* Since the similarity sequence search approach uses a reduced representation of original HTS reads dataset, it's a very fast method
* Therefore, we will leave the first read command running and move to _de novo_ assembly approach

_In the VM_  

```bash
# Create folder to store typing results
mkdir ~/typing
mkdir ~/typing/<your_species_name>

# Create a folder for Streptococcus agalactiae example
mkdir ~/typing/streptococcus_agalactiae_example
```

### Using reads

**MLST for a given taxon**

Let's start with Multi-Locus Sequence Typing (MLST), and type all HTS reads available for a given taxon using ReMatCh.
* For example purposes, we will use _Bartonella bacilliformis_ because only around 30 reads datasets are available
* Only Illumina reads will be used

_In the VM_  

```bash
# Run inside a screen
screen -S rematch_mlst_Bb

rematch.py \
    --workdir ~/typing/rematch_mlst_Bb_example/ \
    --mlst "Bartonella bacilliformis" \
    --mlstReference \
    --doubleRun \
    --threads 8 \
    --taxon "Bartonella bacilliformis" \
    --asperaKey ~/NGStools/aspera/connect/etc/asperaweb_id_dsa.openssh \
    --SRAopt

# Detatch the screen
# Press Ctrl + A (release) and then D

# 29 samples out of 30 run successfully
# Runtime :0.0h:55.0m:6.53s
```

**Antibiotic resistance genes**

To screen antibiotic resistance genes we will use the Resfinder DB obtained before. For that, we will:
* Move back to _Streptococcus agalactiae_ example
* Re-download example's samples while running, or using already downloaded reads data

_In the VM_  

 Re-download example's samples while running

```bash
# Run inside a screen
screen -S rematch_ARgenes_download

rematch.py \
    --workdir ~/typing/streptococcus_agalactiae_example/rematch_ARgenes_download/ \
    --reference ~/DBs/resfinder_db/resfinder_db.fasta \
    --reportSequenceCoverage \
    --notWriteConsensus \
    --summary \
    --threads 8 \
    --listIDs ~/reads/streptococcus_agalactiae_example/ids.txt \
    --asperaKey  ~/NGStools/aspera/connect/etc/asperaweb_id_dsa.openssh \
    --SRAopt

# Detatch the screen
# Press Ctrl + A (release) and then D

# 10 samples out of 10 run successfully
# Runtime :0.0h:59.0m:54.58s
```

_In the VM_  

Using already downloaded reads data

```bash
# Create a ReMatCh working directory
mkdir ~/typing/streptococcus_agalactiae_example/rematch_ARgenes_localSamples

# Set ReMatCh working directory
## Using a bash for-loop for that
## Create symlinks instead of duplicate data
### Iterate over samples directories from reads folders
#### Create sample directory by obtaining only last directory name instead of directory path using basename
#### Create symbolic links to sample's reads inside newly created sample's directory
for sample_dir in $(ls -d ~/reads/streptococcus_agalactiae_example/*/); do
  mkdir ~/typing/streptococcus_agalactiae_example/rematch_ARgenes_localSamples/$(basename $sample_dir)
  ln -s $(ls ${sample_dir}*_1.fq.gz) ~/
  typing/streptococcus_agalactiae_example/rematch_ARgenes_localSamples/$(basename $sample_dir)/$(basename $(ls ${sample_dir}*_1.fq.gz))
  ln -s $(ls ${sample_dir}*_2.fq.gz) ~/typing/streptococcus_agalactiae_example/rematch_ARgenes_localSamples/$(basename $sample_dir)/$(basename $(ls ${sample_dir}*_2.fq.gz))
done

# ReMatCh command example
# Not necessary to run
# Added fake option to avoid ReMatCh to run
# Don't forget use screen
rematch.py \
    --workdir ~/typing/streptococcus_agalactiae_example/rematch_ARgenes_localSamples/ \
    --reference ~/DBs/resfinder_db/resfinder_db.fasta \
    --reportSequenceCoverage \
    --notWriteConsensus \
    --summary \
    --threads 8 \
    --avoidRunningReMatCh

# 10 samples out of 10 run successfully
# Runtime :0.0h:56.0m:30.66s
```
More informations:
* [Using bash for-loop](https://www.cyberciti.biz/faq/bash-for-loop/ "Google search: bash for loop")
* Listing only folders: `ls --help` or `man ls` and [here](https://stackoverflow.com/questions/14352290/listing-only-directories-using-ls-in-bash-an-examination "Google search: linux list only directories")
* [Using subcommands and other things](http://www.compciv.org/topics/bash/variables-and-substitution/ "Google search: bash subcommand example")
* Create symbolic links: `ln --help` or `man ln` and [here](https://www.cyberciti.biz/faq/unix-creating-symbolic-link-ln-command/ "Google search: linux symbolic link")

### Using _de novo_ assembly

Typing with Abricate using Resfinder DB (the one previously updated)

**Antibiotic resistance genes**

_In the VM_  

```bash
# Create folder to store Abricate outputs
mkdir ~/typing/streptococcus_agalactiae_example/abricate

# Run Abricate for each sample
## List all produced assemblies and pass to parallel
### Run Docker without TTY (-t option)
### Map the assemblies folder in /data/ folder and the updated Abricate DB in Docker Abricate DB folder
### Redirect the Abricate output to a file named as the assembly but without the extension (using {/.})
### Note that the redirection should be done using filesystem paths outside the container
ls ~/genomes/streptococcus_agalactiae_example/all_assemblies/* | \
      parallel --jobs 8 'docker run --rm -u $(id -u):$(id -g) -v ~/genomes/streptococcus_agalactiae_example/all_assemblies/:/data/ -v ~/DBs/abricate/:/NGStools/miniconda/db/ ummidock/abricate:latest abricate --db resfinder /data/{/} > ~/typing/streptococcus_agalactiae_example/abricate/{/.}.abricate_out.tab'

# Summarize all Abricate results into a single file
## With Docker, when using * to refer multiple files, the paths obtained refer to the filesystem outside the container
## Therefore, a shell script file is created containing the command to be run inside the container
## Note that the command inside the shell script only contains paths refering to mapped folder /data/
echo 'abricate --summary /data/*.abricate_out.tab > /data/abricate_summary.resfinder.tab' > ~/typing/streptococcus_agalactiae_example/abricate/abricate_commands.sh
## Run the summary Abricate command
docker run --rm -u $(id -u):$(id -g) -it -v ~/typing/streptococcus_agalactiae_example/abricate/:/data/ -v ~/DBs/abricate/:/NGStools/miniconda/db/ ummidock/abricate:latest \
      sh /data/abricate_commands.sh
```
More informations on what TTY is [here](https://askubuntu.com/questions/481906/what-does-tty-stand-for "Google search: tty device")
