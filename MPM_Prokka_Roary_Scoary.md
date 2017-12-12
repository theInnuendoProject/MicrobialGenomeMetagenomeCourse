#  Annotation with Prokka and intro of Roary

---

* [_From microbial genomics to metagenomics_](./README.md)
  * [_Bacterial Genomics_](./Genomics.md)
    * [_Prepare the Virtual Machine_](./MPM_starting_VM.md)
    * [_From reads to assembly: working with INNUca pipeline_](./MPM_workingwithINNUCA.md)
    * [In silico _typing using ReMatCh and Abricate_](./MPM_ReMatCh_Abricate.md)
    * _ Annotation with Prokka and intro of Roary_

---

**Note 1:** replace whatever is between `<>` with the proper value. For example, in _"Organize the data"_ `<your_species_name>`, write the species name you selected (something like `campylobacter_jejuni`).  
**Note 2:** if the VM has 16 CPUs, use `16` in CPUs/threads instead of `8`.  
**Note 3:** do the steps bellow for the bacteria species of your choise. _Streptococcus agalactiae_ is used as example.

---

```bash
# Before start, make sure Prokka image is already in the VM
sudo service docker restart
docker pull ummidock/prokka:1.12
```

<!---
```bash
# Add Streptococcus agalactiae Prokka DB
mkdir /media/volume/DBs/prokka

mkdir /media/volume/DBs/prokka/<your_species_name>

# Create a folder for Streptococcus agalactiae example
mkdir /media/volume/DBs/prokka/streptococcus_agalactiae_example

# Get list of GBS complete genomes from NCBI
wget -O /media/volume/DBs/prokka/streptococcus_agalactiae_example/MPM_completeGenomes_GBS.20171210.txt https://raw.githubusercontent.com/INNUENDOCON/MicrobialGenomeMetagenomeCourse/master/MPM_completeGenomes_GBS.20171210.txt

# Download complete genomes
sed $'s/\r$//' /media/volume/DBs/prokka/streptococcus_agalactiae_example/MPM_completeGenomes_GBS.20171210.txt | \
      sed 1d | \
      cut -f 20 | \
      parallel --jobs 8 'wget -O /media/volume/DBs/prokka/streptococcus_agalactiae_example/{/}_genomic.gbff.gz {}/{/}_genomic.gbff.gz'
# Uncompressed downloaed genomes
ls /media/volume/DBs/prokka/streptococcus_agalactiae_example/*.gbff.gz | \
      parallel --jobs 8 'gunzip {}'

# Prepare DB
## Create a shell script file containing the command to be run inside the container
echo 'prokka-genbank_to_fasta_db /data/*.gbff > /data/Streptococcus.faa' > /media/volume/DBs/prokka/streptococcus_agalactiae_example/prokka-genbank_to_fasta_db_commands.sh
## Run the command to produce an aminoacid acid fasta from a genbank file
docker run --rm -u $(id -u):$(id -g) -it -v /media/volume/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      sh /data/prokka-genbank_to_fasta_db_commands.sh
## Remove redundant sequences
docker run --rm -u $(id -u):$(id -g) -it -v /media/volume/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      cd-hit -i /data/Streptococcus.faa -o /data/Streptococcus -T 0 -M 0 -g 1 -s 0.8 -c 0.9
## Remove intermediate and unnecessary files
rm -fv /media/volume/DBs/prokka/streptococcus_agalactiae_example/*.gbff /media/volume/DBs/prokka/streptococcus_agalactiae_example/prokka-genbank_to_fasta_db_commands.sh /media/volume/DBs/prokka/streptococcus_agalactiae_example/Streptococcus.faa /media/volume/DBs/prokka/streptococcus_agalactiae_example/Streptococcus.clstr
## Create blast DB
docker run --rm -u $(id -u):$(id -g) -it -v /media/volume/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      makeblastdb -dbtype prot -in /data/Streptococcus
## Get default DB
docker run --rm -u $(id -u):$(id -g) -it -v /media/volume/DBs/prokka/streptococcus_agalactiae_example/:/data/ ummidock/prokka:1.12 \
      cp -r /NGStools/prokka/db/genus/ /data/
mv /media/volume/DBs/prokka/streptococcus_agalactiae_example/genus/* /media/volume/DBs/prokka/streptococcus_agalactiae_example/
rm -r /media/volume/DBs/prokka/streptococcus_agalactiae_example/genus/
```
-->

```bash
# Annotate the genomes
## Create a folder to store the annotations
mkdir /media/volume/annotation
## Prepare folder to run Prokka
mkdir /media/volume/annotation/<your_species_name>
mkdir /media/volume/annotation/<your_species_name>/prokka

# Create a folder for Streptococcus agalactiae example
mkdir /media/volume/annotation/streptococcus_agalactiae_example
mkdir /media/volume/annotation/streptococcus_agalactiae_example/prokka
```

<!---
```bash
# Run Prokka
## Copy genomes folders to extra volume to Prokka folder to map into Docker container
cp -r ~/genomes/streptococcus_agalactiae_example/all_assemblies/ /media/volume/annotation/streptococcus_agalactiae_example/prokka/
## Run Prokka
ls /media/volume/annotation/streptococcus_agalactiae_example/prokka/all_assemblies/* | \
      parallel --jobs 8 'docker run --rm -u $(id -u):$(id -g) -v /media/volume/annotation/streptococcus_agalactiae_example/prokka/:/data/ -v /media/volume/DBs/prokka/streptococcus_agalactiae_example/:/NGStools/prokka/db/genus/ ummidock/prokka:1.12 prokka --outdir /data/$(echo {/} | cut -d "." -f 1) --force --centre MGMC --genus Streptococcus --species agalactiae --strain $(echo {/} | cut -d "." -f 1) --cpus 1 --prefix $(echo {/} | cut -d "." -f 1) --locustag $(echo {/} | cut -d "." -f 1)p --addgenes --usegenus --rfam --increment 10 --mincontiglen 1 --gcode 1 --kingdom Bacteria /data/all_assemblies/{/}'
```
-->

```bash
# Run Prokka
## Copy genomes folders to extra volume to Prokka folder to map into Docker container
cp -r ~/genomes/streptococcus_agalactiae_example/all_assemblies/ /media/volume/annotation/streptococcus_agalactiae_example/prokka/
## Run Prokka
ls /media/volume/annotation/streptococcus_agalactiae_example/prokka/all_assemblies/* | \
      parallel --jobs 8 'docker run --rm -u $(id -u):$(id -g) -v /media/volume/annotation/streptococcus_agalactiae_example/prokka/:/data/ ummidock/prokka:1.12 prokka --outdir /data/$(echo {/} | cut -d "." -f 1) --force --centre MGMC --genus Streptococcus --species agalactiae --strain $(echo {/} | cut -d "." -f 1) --cpus 1 --prefix $(echo {/} | cut -d "." -f 1) --locustag $(echo {/} | cut -d "." -f 1)p --addgenes --usegenus --rfam --increment 10 --mincontiglen 1 --gcode 1 --kingdom Bacteria /data/all_assemblies/{/}'
```
