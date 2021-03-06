# shortcut
Small one-step or two-step scripts for automating simple repetitive tasks

## Descriptions

### Individual scripts
* firstofeach: gives list of rows for each first occurrence of value in chosen column
* listofusableloci: removes loci where not every entry is an integer
* NEXcolour: switches the colour of point labels in a NEX file as per conversion list
* NEXswap: switches labels in NEXUS format matrix files 
* splitXMFA: splits a XMFA file produced by BIGSDB GC alignment into one file per locus
* subtractlist: removes items present in a second list from a first list

### Grouped scripts

#### For reference genome annotations CDS extractions
* annotation-cutdown: keeps only relevant lines (for CDS extraction) from genome annotation
* FASTAextract: splits concatenated FASTA into ID tab CDS 

#### Label assignment
* assign-labels-s1: opens isolate-locus tabel, creates matrix and writes matrix pairs
* assign-labels-s2: assigns labels based on pairwise distances, cutoff and known labels 
