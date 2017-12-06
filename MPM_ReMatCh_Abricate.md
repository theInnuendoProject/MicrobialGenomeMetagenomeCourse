# _In silico_ typing using ReMatCh and Abricate

---

* [_From microbial genomics to metagenomics_](./README.md)
  * [_Bacterial Genomics_](./Genomics.md)
    * [_Prepare the Virtual Machine_](./MPM_starting_VM.md)
    * [_From reads to assembly: working with INNUca pipeline_](./MPM_workingwithINNUCA.md)
    * In silico _typing using ReMatCh and Abricate_
      1. [_Get DB of antimicrobial resistance genes_](./MPM_ReMatCh_Abricate.md# Get DB of antimicrobial resistance genes)

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
cat ~/DBs/resfinder_db/*.fsa > ~/DBs/resfinder_db/resfinder_db.fasta
```
* For more information about reading entire different files: `cat --help` or `man cat`, and [here](https://www.computerhope.com/unix/ucat.htm "Google search: linux cat")
