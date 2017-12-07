Metagenome part 4

## Visualization in the interface

Open a new ssh window. In mac:
```
ssh -L 8080:localhost:8080 hultman@taito.csc.fi
```

in Windows with Putty:
In SSH tab select "tunnels". Add

Source port: 8080 
Destination: localhost:8080

Click add and log in to Taito.

Activate anvio

```
anvi-interactive -c METASPADES_co-assembly_2500nt_CONTIGS.db -p SAMPLES-MERGED/PROFILE.db --server-only -P 8080
```

Then open google chrome and go to address 

http://localhost:8080
