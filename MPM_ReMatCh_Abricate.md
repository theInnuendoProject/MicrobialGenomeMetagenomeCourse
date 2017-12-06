# _In silico_ typing using ReMatCh and Abricate

---

* [_From microbial genomics to metagenomics_](./README.md)
  * [_Bacterial Genomics_](./Genomics.md)
    * [_Prepare the Virtual Machine_](./MPM_starting_VM.md)
    * [_From reads to assembly: working with INNUca pipeline_](./MPM_workingwithINNUCA.md)
    * In silico _typing using ReMatCh and Abricate_
      1. [_Get DB of antimicrobial resistance genes_](./MPM_ReMatCh_Abricate.md#get-db-of-antimicrobial-resistance-genes)

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

```bash
git clone https://bitbucket.org/genomicepidemiology/resfinder_db.git
mv resfinder_db/ ~/DBs/

# Create a single file containing the sequences of genes confering resistance to all antibiotic classes together
mkdir temp_concat_resfinder
ls ~/DBs/resfinder_db/*.fsa | parallel --jobs 8 'cp {} temp_concat_resfinder/; echo "" >> temp_concat_resfinder/{/}'
mkdir temp_concat_resfinder/seq_file
cat temp_concat_resfinder/*.fsa | sed $'s/\r$//' | grep --invert-match "^$" | parallel --jobs 8 --pipe -N 1 --recstart '>' 'cat | { seq=$(cat); header=$(echo "$seq" | grep ">" | sed -e "s/[[:space:]]*$//"); echo "$seq" > temp_concat_resfinder/seq_file/${header:1}.fasta; }'
cat temp_concat_resfinder/seq_file/*.fasta > ~/DBs/resfinder_db/resfinder_db.fasta
rm -r temp_concat_resfinder/
```
* More information about adding newlines at the end of files [here](https://stackoverflow.com/questions/23055831/add-new-line-character-at-the-end-of-file-in-bash "Google search: add newline at end of file")
* For more information about reading different files together: `cat --help` or `man cat`, and [here](https://www.computerhope.com/unix/ucat.htm "Google search: linux cat")
* More information about using skipping blank lines [here](https://stackoverflow.com/questions/22080937/bash-skip-blank-lines-when-iterating-through-file-line-by-line "Google search: bash skip blank lines")

remove space end string linux
https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable

sed dos to unix
https://stackoverflow.com/questions/2613800/how-to-convert-dos-windows-newline-crlf-to-unix-newline-n-in-a-bash-script

add newline at end of file
https://stackoverflow.com/questions/23055831/add-new-line-character-at-the-end-of-file-in-bash

remove first character from string shell
https://stackoverflow.com/questions/11469989/how-can-i-strip-first-x-characters-from-string-using-sed

bash skip blank lines
https://stackoverflow.com/questions/22080937/bash-skip-blank-lines-when-iterating-through-file-line-by-line
```bash
mkdir ~/typing
mkdir ~/typing/rematch
# /home/cloud-user/reads/streptococcus_agalactiae_example/ERR048560/ERR048560_1.fq.gz
ls ~/reads/streptococcus_agalactiae_example/*/* | parallel --jobs 1 'mkdir ~/typing/rematch/$(basename {//}); ln -s {} ~/typing/rematch/$(basename {//})/{/}'
rematch.py -w ~/typing/rematch/ -r ~/DBs/resfinder_db/resfinder_db.fasta -j 8 --reportSequenceCoverage --notWriteConsensus
```

```bash
cat ~/DBs/resfinder_db/*.fsa | grep --invert-match "^$" | parallel --jobs 1 -N 1 --recstart '>' --pipe 'cat | { seq=$(cat); header=$(echo "$seq" | grep ">"); echo "$seq" > ~/test/${header:1}.fasta; }'
cat ~/test/*.fasta > ~/DBs/resfinder_db/resfinder_db.fasta.tmp2
```
