*Antti Karkman and Jenni Hultman*

# Metagenome analysis of bird feces dataset
Log into Taito, either with ssh (Mac/Linux) or PuTTy (Windows)  
# Data download
First set up the course directory, make some folders and then download the data.  
Move to work directory at CSC and make a course directory there. Or a subfolder under a previous course folder.  
```
cd $WRKDIR
mkdir BioInfo_course
cd BioInfo_course
mkdir raw_data
mkdir scripts
```

Download the metagenomic data (takes few minutes)  
```
cd raw_data
wget https://filesender.funet.fi/download.php?vid=3f2d0511-8f32-2aa8-fbb2-00007ddc3254 -O course_metagenomes.tar.gz
tar -xzvf course_metagenomes.tar.gz
```

And make a file containing the sample names to be used later in bash scripts.  
 `ls *.fastq.gz |awk -F "-" '{print $2}'|uniq > ../sample_names.txt`  

# QC and trimming
QC for the raw data (takes few min, depending on the allocation).  
Go to the folder that contains the raw data, load the biokit module and make a folder called e.g. `FASTQC` for the QC reports.  
Then run the QC for the raw data and combine the results to one report using `multiqc`.  
```
# allocation of computing resources. Can be done also with sinteractive (use only 4 threads)
salloc -n 6 -t00:10:00 --ntasks-per-node=6 --mem=100 -p parallel
fastqc ./*.fastq -o FASTQC/ -t 6
exit # free the resources after the job is done
multiqc ./ --interactive
```

Copy the resulting HTML file to your local machine with `scp` from the command line (Mac/Linux) or *WinSCP* on Windows.  
Have a look at the QC report with your favorite browser.  

After inspecting the output, it should be clear that we need to do some trimming.  
(cutadapt with reverse complements of tagmentation adapter. Transposon End Sequence reverse complemented: _CTGTCTCTTATACACATCT_)

Make a folder for the trimmed data.  
Then we'll make a bash script that runs cutadapt for each file using the `sample_names.txt` file.    
Go to your scripts folder and make a bash script for cutadapt with any text editor. Make sure that the paths are correct.   
```
#!/bin/bash

while read i
do
        cutadapt  -a CTGTCTCTTATACACATCT -A CTGTCTCTTATACACATCT -q 28 -O 10 -o ../trimmed_data/$i"_R1_trimmed.fastq" -p ../trimmed_data/$i"_R2_trimmed.fastq" *$i*_R1*.fastq.gz *$i*_R2*.fastq.gz > ../trimmed_data/$i"_trim.log"
done < $1
```
Then we need a batch job file to submit the job to the SLURM system. More about CSC batch jobs here: https://research.csc.fi/taito-batch-jobs  
Make another file with text editor.
```
#!/bin/bash -l
#SBATCH -J cutadapt
#SBATCH -o cutadapt_out_%j.txt
#SBATCH -e cutadapt_err_%j.txt
#SBATCH -t 01:00:00
#SBATCH -n 1
#SBATCH -p serial
#SBATCH --mem=50
#

module load biokit
cd $WRKDIR/BioInfo_course/raw_data
bash ../scripts/cutadapt.sh ../sample_names.txt
```
After it is done, we can submit it to the SLURM system. Do it form the main folder, so go one step back in your folders.  
`sbatch scripts/cut_batch.sh`  

You can check the status of your job with:  
 `squeue -l -u $USER`  

After the job has finished, you can see how much resources it actually used and how many billing units were consumed. `JOBID` is the number after the batch job error and output files.  
`seff JOBID`  

Then let's check the results from the trimming. Go to the folder containing the trimmed reads and make a new folder for the QC files.  
Allocate some resources and then run FASTQC and MultiQC again.  
```
salloc -n 6 -t00:10:00 --ntasks-per-node=6 --mem=100 -p parallel
fastqc ./*.fastq -o FASTQC/ -t 6
exit
multiqc ./ --interactive
```

Copy it to your local machine as earlier and look how well the trimming went.  

# Assembly
Let's assemble first one seagull sample and one goose sample an then all six samples together (co-assembly). We will use tool Megahit for the assembly https://github.com/voutcn/megahit. It is installed to CSC and be loaded with following commands:

```
module purge
module load intel/16.0.0
module load megahit
```
module purge is needed to remove wrong Pyhton versions you might have loaded in earlier today.

Assembly requires lot of memory and we need to do a batch job. As we want to do both individual and co-assemblies the R1 and R2 reads need to be merged into twol files with cat

```
cat *R1_trimmed.fastq > all_R1_trimmed.fastq
cat *R2_trimmed.fastq > all_R2_trimmed.fastq
```
Make a script called co_assembly.sh in a text editor
```
#!/bin/bash
#SBATCH -J megahit
#SBATCH -o megahit_out_%j.txt
#SBATCH -e megahit_err_%j.txt
#SBATCH -t 12:00:00
#SBATCH -n 1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64000
#

module load intel/16.0.0
module load megahit

megahit -1 all_R1_trim.fastq -2 all_R2_trim.fastq -o all_assembly_def_1000 -t 16 --min-contig-len 1000
```

# Mapping reads to contigs




