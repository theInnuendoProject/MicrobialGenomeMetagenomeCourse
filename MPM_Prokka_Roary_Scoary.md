# Annotation (_PROKKA_), pangenome anaylysis (_ROARY_) and GWAS (_SCOARY_)

---

* [_From microbial genomics to metagenomics_](./README.md)
  * [_Bacterial Genomics_](./Genomics.md)
    * [_Prepare the Virtual Machine_](./MPM_starting_VM.md)
    * [_From reads to assembly: working with INNUca pipeline_](./MPM_workingwithINNUCA.md)
    * In silico _typing using ReMatCh and Abricate_
    * [_Annotation (_PROKKA_), pangenome anaylysis (_ROARY_) and GWAS (_SCOARY_)_](./MPM_Prokka_Roary_Scoary.md)
      1. [_Get DB of antimicrobial resistance genes_](./MPM_ReMatCh_Abricate.md#get-db-of-antimicrobial-resistance-genes)
      2. [_Typing samples_](./MPM_ReMatCh_Abricate.md#typing-samples)

---

**Note 1:** replace whatever is between `<>` with the proper value. For example, in _"Organize the data"_ `<your_species_name>`, write the species name you selected (something like `campylobacter_jejuni`).  
**Note 2:** if the VM has 16 CPUs, use `16` in CPUs/threads instead of `8`.  
**Note 3:** do the steps bellow for the bacteria species of your choise. _Streptococcus agalactiae_ is used as example.

---

```bash
# Add Streptococcus agalactiae Prokka DB
mkdir ~/DBs/prokka

mkdir ~/DBs/prokka/<your_species_name>

# Create a folder for Streptococcus agalactiae example
mkdir ~/DBs/prokka/streptococcus_agalactiae_example

# Get list of GBS complete genomes from NCBI
wget -O ~/DBs/prokka/streptococcus_agalactiae_example/MPM_completeGenomes_GBS.20171210.txt https://raw.githubusercontent.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/master/MPM_completeGenomes_GBS.20171210.txt

# Download complete genomes
sed $'s/\r$//' ~/DBs/prokka/streptococcus_agalactiae_example/MPM_completeGenomes_GBS.20171210.txt | \
      sed 1d | \
      cut -f 20 | \
      parallel --jobs 8 'wget -O ~/DBs/prokka/streptococcus_agalactiae_example/{/}_genomic.gbff.gz {}/{/}_genomic.gbff.gz'
# Uncompressed downloaed genomes
ls ~/DBs/prokka/streptococcus_agalactiae_example/*.gbff.gz | \
      parallel --jobs 8 'gunzip {}'

# Prepare DB
## Create a shell script file containing the command to be run inside the container
echo 'prokka-genbank_to_fasta_db /data/*.gbff > /data/Streptococcus.faa' > ~/DBs/prokka/streptococcus_agalactiae_example/prokka-genbank_to_fasta_db_commands.sh
## Run the command to produce an aminoacid acid fasta from a genbank file
docker run --rm -u $(id -u):$(id -g) -it -v ~/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      sh /data/prokka-genbank_to_fasta_db_commands.sh
## Remove redundant sequences
docker run --rm -u $(id -u):$(id -g) -it -v ~/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      cd-hit -i /data/Streptococcus.faa -o /data/Streptococcus -T 0 -M 0 -g 1 -s 0.8 -c 0.9
## Remove intermediate and unnecessary files
rm -fv ~/DBs/prokka/streptococcus_agalactiae_example/*.gbff ~/DBs/prokka/streptococcus_agalactiae_example/prokka-genbank_to_fasta_db_commands.sh ~/DBs/prokka/streptococcus_agalactiae_example/Streptococcus.faa ~/DBs/prokka/streptococcus_agalactiae_example/Streptococcus.clstr
## Create blast DB
docker run --rm -u $(id -u):$(id -g) -it -v ~/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      makeblastdb -dbtype prot -in /data/Streptococcus
## Get default DB
docker run --rm -u $(id -u):$(id -g) -it -v ~/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      cp -r /NGStools/prokka/db/genus/ /data/
mv ~/DBs/prokka/streptococcus_agalactiae_example/genus/* ~/DBs/prokka/streptococcus_agalactiae_example/
rm -r ~/DBs/prokka/streptococcus_agalactiae_example/genus/

# Annotate the genomes
## Create a folder to store the annotations
mkdir ~/annotation
## Prepare folder to run Prokka
mkdir ~/annotation/<your_species_name>
mkdir ~/annotation/<your_species_name>/prokka

# Create a folder for Streptococcus agalactiae example
mkdir ~/annotation/streptococcus_agalactiae_example
mkdir ~/annotation/streptococcus_agalactiae_example/prokka

# Run Prokka
ls ~/genomes/streptococcus_agalactiae_example/all_assemblies/* | \
      parallel --jobs 8 'docker run --rm -u $(id -u):$(id -g) -v ~/:/data/ -v ~/DBs/prokka/streptococcus_agalactiae_example/:/NGStools/prokka/db/genus/ ummidock/prokka:1.12 prokka --outdir /data/annotation/streptococcus_agalactiae_example/prokka/$(echo {/} | cut -d "." -f 1) --force --centre MGMC --genus Streptococcus --species agalactiae --strain $(echo {/} | cut -d "." -f 1) --cpus 1 --prefix $(echo {/} | cut -d "." -f 1) --locustag $(echo {/} | cut -d "." -f 1)p --addgenes --usegenus --rfam --increment 10 --mincontiglen 1 --gcode 1 --kingdom Bacteria /data/genomes/streptococcus_agalactiae_example/all_assemblies/{/}'
```
