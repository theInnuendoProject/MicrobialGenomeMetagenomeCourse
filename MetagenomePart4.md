---
title: "A tutorial on genome-resolved metagenomics"
excerpt: "Extracting population genomes from millions of short metagenomic reads"
tags: [anvi'o, binning, it always snows in Helsinki, snow is nice through]
---

# Genome-resolved metagenomics

* Tom Delmont, Antti Karkman, Jenni Hultman*

This tutorial describes a way to extract and curate population genomes from millions of short metagenomic reads using a methodology called "genome-resolved metagenomics", or simply "binning".

This approach has led to major discoveries in the fields of evolutionary biology and microbial ecology. Here are two examples of what can be learned from the newly discovered genomes (phylogeny on the left, functioning on the right):

![alt text](Figure/FIGURE_GENOME_RESOLVED_METAG.png "Genome-resolved metagenomics")

Here are a few definitions we came up with, so we can try to speak the same language today:

-**A microbial species**: Is this a real thing?

-**A microbial population**: pool of microbial cells sharing most of their genomic content due to a very close evolutionary history (close ancestor in the tree of life). 

-**A metagenome**: sequencing data corresponding to more than one genome. 

-**A metagenomic assembly**: set of DNA sequences called contigs that were reconstructed from metagenomic short reads.

-**A population genome**: consensus genomic content of a microbial population acquired using a metagenomic assembly.

-**Metagenomic binning**: the act of clustering contigs from a metagenomic assembly into "bins". Note that not all bins represent population genomes (e.g., phages, plasmids, and all the things we have very little clue about).

-**The platform anvi'o**: this place where microbiologists can finally feel they are bioinformatics superheros!

-**A split**: a section of a contig defined by length (for improved binning experience, we display multiple splits for very long contigs in the anvi'o interface).

So, we hope you are in a good mood to discover and characterize new genomes!

Today, we are going to use these prorgams within the platform anvi'o:

`anvi-interactive`
`anvi-import-collection`
`anvi-refine`
`anvi-summarize`
`anvi-rename-bins`

You can learn details for each anvi'o program using the `-h` flag. For example: `anvi-interactive -h`

Ok.

## 01- A reminder of what has been done until now

As you may remember, we have already done all of this:

-Assembling six metagenomes corresponding to the gut of two species

-Creating a CONTIGS database to make sense of the assembly output (find genes, get GC-content and tetra-nucleotide frequency of contigs)

-Searching for single copy-core genes, and running COGs for functions

-Exporting genes stored in the CONTIGS database, determining their taxonomy and importing the results into the CONTIGS database

-Recruiting short reads from each metagenome using the assembly output

-Creating PROFILE databases from the recruited reads, and merging them into a single PROFILE database

Well, I think that's it, right? **Now it is time for the fun part of visualizing and manipulating raw genome-resolved metagenomic results using the anvi'o interactive interface**.

## 02- Describing the interface

There are currently two programs to invoke the interactive interface. We will first use the most common one: `anvi-interactive`

Open a new ssh window. In mac:

```
ssh -L 8080:localhost:8080 hultman@taito.csc.fi
```

in Windows with Putty:
In SSH category [+] select "tunnels". Add

Source port: 8080 
Destination: localhost:8080

Click add and log in to Taito as usual.

Activate anvio

```
anvi-interactive -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db --server-only -P 8080
```

Then open google chrome and go to address 

http://localhost:8080

So far, so good?

## 03- Describing the interface

Basically, **the interface allows you to manipulate various parameters**, zoom in and out in the display and learn names/values using the mouse, save/load your work, and summarize your binning results.

Overwhelmed by the interface? Here is a brief explanation to help digest this new environment:

![alt text](Figure/Interface-explanations.png "Interface-explanations.png")

We hope that by the end of the day all of you will be familiar with the interface.

## 04- A first look at the display

**Clicking on the "Draw" button will show the raw display**. The display describes 13,010 contigs organized into 13,266 splits of 40 kbp or less, along with their mean coverage values across the six metagenomes and other relevant metadata (GC-content and taxonomy of splits especially).

Here is what you should see:

![alt text](Figure/Interface-RAW.png "Interface-RAW.png")

Here is the key part to remember: **the six grey layers correspond to the mean coverage values in the six metagenomes**. For each split, a black color means their is environmental signal. No black color means the split did not recruit any reads.

To do:

Inspection

## 05- Manipulating the inner tree

Let's play with the different contig clustering options:

![alt text](Figure/Interface-Clustering-splits.png "Interface-Clustering-splits.png")

It is important to understand what they are based on. This knowledge will be key for the manual binning, and curation of population genomes in downstream analyses.

-**Differential coverage**: clustering solely based on the differential coverage of contigs across the samples. This metric is often stable across a genome, and will be different between genomes that do not have the same distribution patterns in the dataset.

-**Sequence composition**: clustering solely based on sequence composition (the tetra-nucleotide frequency) of contigs. This metric is often stable across a genome, and different between genomes from different lineages.

-**Differential coverage and sequence composition**: clustering using the two metrics for optimal binning resolution

Note: as a strategy, the anvi'o developers decided to trust the assembly, so splits from the same contig will remain together.

## 06- Binning the co-asssembly output (from individual contigs to bins) 

We are going to zoom in and out, and use the mouse to make selection of clusters of splits, using the clustering based on `differential coverage` and `sequence composition`.

The game is to find as many bins with high completion value, and low redundancy value. 

To save some time, we will focus on a subset of the data (Tom has done the entire binning and found out that other parts did not allow the recovery of population genomes. That being said, anyone is welcome to perform the entire binning another day!).

Please close the windows of the interface, and kill the job in the terminal using `control + c`. Then, you are going to (1) download the collection called `collection-TOM_5_BINS.txt` from the Github and upload it in your working directory (reminder: this is the path where you have the CONTIGS.db), (2) import it into the PROFILE.db (program is called `anvi-import-collection`), and visualize it in the interface.

Feel free to take a look at the `collection-TOM_5_BINS.txt` file to understand what it is (e.g., using `head collection-TOM_5_BINS.txt -n 10`). It simply links splits to Bins. Easy.

Here is the command line for importing the collection:

```
anvi-import-collection -c MEGAHIT_2500nt_CONTIGS.db  -p SAMPLES-MERGED/PROFILE.db -C TOM_5_BINS collection-TOM_5_BINS.txt```
```

Then please invoke the interface once again:

```
anvi-interactive -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db --server-only -P 8080
```

And go to the "Bins" section of the interface to load the bin collection called `TOM_5_BINS`. You should then see this after drawing the figure:

![alt text](Figure/Interface-first-binning-step.png "Interface-first-binning-step.png")

Ok.

These five bins exhibit different sizes and completion/redundancy values. For instance, the `Bin_01` has a length of 8.69 Mpb with a completion of 100% and a redundancy of 171.9%. This bin is mostly detected in the sample `L4`, and slightly detected in the sample `L3`.

Wait, how do we assess the completion and redundancy values again?
Good question folks.

This is thanks to the program called `anvi-run-hmms`, which searched for single copy core genes that should occur once in each microbial genome. Let's say there are 100 of these genes. If all of them are detected once in the selected cluster (i.e., the bin), then the completion is 100% and the redundancy is 0%. If a few genes are detected multiple times, the redundancy value will increase. If a few genes are missing, then it is the completion value that will drop.

Ok.

Now, let's refine each one of them using the program `anvi-refine` (this is the second way to invoke the interface; it is mostly used to work on a single bin within a collection).

We shall start with the `Bin_01`:

```
anvi-refine -c MEGAHIT_2500nt_CONTIGS.db  -p SAMPLES-MERGED/PROFILE.db -C TOM_5_BINS -b Bin_01 --server-only -P 8080
```

Which should load this figure:


[alt text](Figure/Interface-refining-Bin_01.png "Interface-refining-Bin_01.png")

It is actually a good example. Let's refine it together.

When done, we will do the same for the bins 02, 03, 04 and 05, and finally summarize our results:

```
anvi-summarize -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db -C TOM_5_BINS -o SUMMARY_BINNING
```

This step create a folder called `SUMMARY_BINNING`. Please download this folder into your laptop using `scp`, open it to and double click on the file called `index.html`. This should open a windows in your browser.

Ok.

If some of the bins remain with redundancy value >10%, please refine them again, and summarize once again (SUMMARY_BINNING-2 as anvi'o does not want to overwrite the folder SUMMARY_BINNING). The game is to have all bins with redundancy <10%.

OK! Now we have bins with low redundancy values, and some of them look like they represent population genomes!

Cool. 

## 07- Rename the collection of bins and identify population genomes

Create a new collection where bins are nicely renamed, and MAGs identified (MAG = metagenome-assembled genome = population genome)

```
anvi-rename-bins -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db --collection-to-read TOM_5_BINS --collection-to-write MAGs --call-MAGs --prefix MEGAHIT --use-highest-completion-score --report-file REPORT
```

Bins >2 Mbp and those with a completion >70% will be renamed as MAGs (i.e., as population genomes).

And summarize the collection:

```
anvi-summarize -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db -C MAGs -o SUMMARY_MAGs
```

So, how many MAGs did you get???

## 08- Don't forget to curate each population genome!


Now is the time for some genomic curation. This step is boring, but critical: we need to manually curate each one of the MAGs using the `anvi-refine` command line:
 
```
anvi-refine -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db -C MAGs -b MEGAHIT_MAG_000001  --server-only -P 8080
```

and so one for all MAGs. After that, we will create a final collection called `MAGs_FINAL`:

```
anvi-rename-bins -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db --collection-to-read MAGs --collection-to-write MAGs_FINAL --call-MAGs --prefix MEGAHIT --use-highest-completion-score --report-file REPORT
```

and summarize the final, curated collection:

```
anvi-summarize -c MEGAHIT_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db -C MAGs_FINAL -o SUMMARY_MAGs_FINAL
```

We are done with the binning and the curation of this metagenomic co-assembly output!

Tom got seven bacterial population genomes. What did you get?

Here is the end product for Tom:

![alt text](Figure/Summary_only_MAGs_FINAL.png "Summary_only_MAGs_FINAL.png")

And this is the perspective of these MAGs in the interface:

![alt text](Figure/Interface-Final-MAGs-tod.png "Interface-Final-MAGs-tod.png")

We should discuss why contigs from each MAG are not next to each other. This is a key advantage of the manual binning, and explains well why automatic binning as it is developpeed today is noy working well (Tom's opinion, at least).

PS: if you want, you can download the collection called `collection-TOM_only_MAGs_FINAL.txt` on the Github, import it into the PROFILE.db (program is called `anvi-import-collection`), and visualize it in the interface.

## 10- Exploring the summary output

Anvi'o produced a fast file for each MAG, along with various parameters regarding notably their environmental detection:

Here are values for each MAG that I find particularly useful:

-Mean coverage across metagenomes
-Detection across genomes (percentage of the nucleotides covered by the recruited reads)
-Table of genes and identified functions (very useful when you have metatranscriptomes!)
-All identified rRNAs (do we have a 16S rRNA gene?)

## 11- What do we do with these genomes? The case of E. coli using tools introduced in the first days of the workshop

To do.
