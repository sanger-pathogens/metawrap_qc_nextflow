# metawrap_qc_nextflow

This pipeline performs adapter trimming using trim-galore and human read removal using bmtagger and is based off the metaWRAP software (https://github.com/bxlab/metaWRAP)
This pipeline supports illumina paired end sequencing data only.

## Usage

```
Usage:
nextflow run main.nf

Options:
  --manifest                   Manifest containing paths to fastq files (mandatory)
  --results_dir                Name of results folder. [default: nextflow_results] (optional)
  --bmtagger_db                Path to bmtagger database. [default: /data/pam/software/BMTAGGER_INDEX] (optional)
  --bmtagger_host              Name of bmtagger host. [default: T2T-CHM13v2.0] (optional)
  --skip_fastqc                Skip FASTQC. [default: false] (optional)
  --publish_host_reads         Publish host reads to results folder. [default: false] (optional)
  --help                       Print this help message. (optional)
```

An example manifest is stored in this repo ([example_manifest.csv](./example_manifest.csv)).

## Dependencies

This pipeline relies on the following modules:

```
nextflow
ISG/singularity
```

## Example commands

Running the pipeline with the default configuration:

```
module load nextflow ISG/singularity bsub.py
bsub.py 5 -q oversubscribed metawrap_job nextflow run main.nf --manifest <your_manifest.csv> --results_dir example_results
```

Running the pipeline without FASTQC:

```
module load nextflow ISG/singularity bsub.py
bsub.py 5 -q oversubscribed metawrap_job nextflow run main.nf --manifest manifest.csv --skip_fastqc
```

Running the pipeline with publishing host reads to results folder:

```
module load nextflow ISG/singularity bsub.py
bsub.py 5 -q oversubscribed metawrap_job nextflow run main.nf --manifest manifest.csv --publish_host_reads
```
