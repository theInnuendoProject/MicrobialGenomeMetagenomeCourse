# Working group bacterial genomics, part 1

1) transfer the **_fastq_** files of the bacteria you choice to work with to your **VM** in a dedicated directory
2) make sure that the directoy contains only the **_fastq_**
3) open a *[screen](* session by doing (substitute <screen_name> with your name of choice)

```
screen -S <screen_name>
```

4) then run the follow command (change where needed)

```
# INNUca basic command

# You should specify where the output goes whenever there is an option to do that
# Whenever possible use the option to specify the number of CPUs/threads to be used

docker run --rm -u $(id -u):$(id -g) -it -v /path/to/data:/data/ ummidock/innuca:3.1 \
       INNUca.py --inputDirectory /data/reads/<your_species_name>/ \
                 --speciesExpected "<your species name with space>" \
                 --genomeSizeExpectedMb <your_species_genome size> \
                 --outdir /data/genomes/<your_species_name>/innuca/ \
                 --threads 8
```

5) detach the screen by pressing  “Ctrl-A” and “d“. You will not see anything when you press those buttons. The output will be like this:

```
[detached from 5561.pts-0.193.166.24.142]
cloud-user@193.166.24.142 ~ $
```

6) re-attach the screen

```
screen -r <screen_name>
```

if you are not sure if you are already in a screen or you do not remember the screen name do as below

```
screen -ls
```
