# metawrap_qc_nextflow
This pipeline performs adapter trimming using trim-galore and human read removal using bmtagger and is based off the metaWRAP software (https://github.com/bxlab/metaWRAP)
This pipeline supports illumina paired end sequencing data only.


## Usage
```
    nextflow run .
    
    Options:
      --manifest                   Manifest containing paths to fastq files (mandatory)
      -profile                     always use sanger_lsf when running on the farm (mandatory)
      --results_dir                Name of results folder, default: nextflow_results (optional)
      --bmtagger_db                Path to bmtagger database, default: /data/pam/software/BMTAGGER_INDEX (optional)
      --bmtagger_host              Name of bmtagger host, default: hg38 (optional)
      --skip_fastqc                Skip FASTQC, default: false (optional)
      --publish_host_reads         Publish host reads to results folder, default: false (optional)
      --help                       print this help message (optional)
```

An example manifest is stored in this repo ([example_manifest.csv](./example_manifest.csv)).


## Generating manifests
### If your data is stored in the PaM informatics pipeline system, you can use the following method:
`./generate_manifest_from_lanes.sh -l <lanes_file>`

For more information, run:
`./generate_manifest_from_lanes.sh -h`

### If your data is not stored in the PaM informatics pipeline system, you can use the following method:
#### Step 1:
Obtain fastq paths:
`ls -d -1 <path>/*.fastq.gz > fastq_paths.txt`
#### Step 2:
Generate manifest:
`./generate_manifest.sh fastq_paths.txt`

This will output the manifest to `manifest.csv` which can be fed into the nextflow pipeline


## Dependencies
This pipeline relies on the following modules:
```
nextflow/22.10
ISG/singularity/3.6.4
```

## Example commands

Running the pipeline with the default configuration:
```
module load nextflow ISG/singularity bsub.py
bsub.py 5 -q oversubscribed metawrap_job nextflow run . --manifest <your_manifest.csv> -profile sanger_lsf --results_dir example_results
```

Running the pipeline without FASTQC:
```
module load nextflow ISG/singularity bsub.py
bsub.py 5 -q oversubscribed metawrap_job nextflow run . --manifest manifest.csv -profile sanger_lsf --skip_fastqc
```

Running the pipeline with publishing host reads to results folder:
```
module load nextflow ISG/singularity bsub.py
bsub.py 5 -q oversubscribed metawrap_job nextflow run . --manifest manifest.csv -profile sanger_lsf --publish_host_reads
```
