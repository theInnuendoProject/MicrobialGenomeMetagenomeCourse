# Working group bacterial genomics, part 1

1) transfer the **_fastq_** files of the bacteria you choice to work with to your **VM** in a dedicated directory
2) make sure that the directoy contains only the **_fastq_**
3) open a *[screen](* session by doing (substitute <screen_name> with your name of choice)
```
screen -S <screen_name>
```
4) 

then run the follow command
```
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
