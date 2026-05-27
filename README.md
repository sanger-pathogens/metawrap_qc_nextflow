# metawrap_qc_nextflow

[[_TOC_]]

## Pipeline overview

metawrap_qc_nextflow is a Nextflow DSL2 pipeline for preprocessing metagenomic short-read data, based on the [metaWRAP](https://github.com/bxlab/metaWRAP) QC module. It performs adapter trimming and human read decontamination on Illumina paired-end FASTQ data, producing clean reads suitable for downstream metagenomic assembly or analysis.

The pipeline performs the following steps:

1. **Pre-filtering QC** — FastQC reports are generated on the raw input reads.
2. **Adapter trimming** — TrimGalore removes adapter sequences and low-quality bases.
3. **Human read removal** — BMTagger screens trimmed reads against a human reference (T2T-CHM13v2.0 by default) and removes any matching reads.
4. **Post-filtering QC** — FastQC reports are generated on the cleaned reads.
5. **Reporting** — MultiQC aggregates QC metrics from both pre- and post-filtering steps. Read counts before and after each filtering step are collected and collated into a per-sample summary.

This pipeline supports Illumina paired-end sequencing data only.

## Usage

### Quickstart

#### From source code

1. Clone this repository:

   ```bash
   git clone --recurse-submodules https://gitlab.internal.sanger.ac.uk/sanger-pathogens/pipelines/metawrap_qc_nextflow.git
   cd metawrap_qc_nextflow
   ```

2. To run with `docker`, use the `-profile docker` option:

   ```bash
   nextflow run main.nf \
       -profile docker \
       --manifest manifest.csv \
       --results_dir my_output
   ```

   Other profiles are also supported (`singularity`).
   :warning: If no profile is specified the pipeline will run with the Sanger HPC-specific configuration.

3. Once the run has finished, clean up intermediate files:

   ```bash
   rm -rf work .nextflow*
   ```

#### Using on the Sanger farm

First load the latest pipeline module:

```bash
module load metawrap_qc_nextflow
```

Then run on the command line with `metawrap_qc_nextflow <options>`. For instance, to see a help message:

```bash
metawrap_qc_nextflow --help
```

Submit to LSF:

```bash
bsub -o output.o -e error.e -q oversubscribed -R "select[mem>4000] rusage[mem=4000]" -M4000 \
    metawrap_qc_nextflow \
        --manifest manifest.csv \
        --results_dir my_output
```

### Input

#### Manifest (`--manifest`)

A CSV file with the required header `ID,R1,R2`, containing per-sample paths to paired `.fastq.gz` files:

```
ID,R1,R2
sampleA,/path/to/sampleA_1.fastq.gz,/path/to/sampleA_2.fastq.gz
sampleB,/path/to/sampleB_1.fastq.gz,/path/to/sampleB_2.fastq.gz
```

An example manifest is provided in this repository: [example_manifest.csv](./example_manifest.csv).

#### Generating a manifest

**Sanger users:** the [manifest_generator](https://gitlab.internal.sanger.ac.uk/sanger-pathogens/pipelines/manifest_generator/) tool can generate a compatible `ID,R1,R2` manifest from a directory of FASTQ files or from iRODS.

### Output

Results are written to `--results_dir` (default: `./nextflow_results`):

```
nextflow_results/
  fastqc/
    pre_filtering/
      <sample_ID>_1_fastqc.html    # FastQC reports on raw reads
      <sample_ID>_2_fastqc.html
    post_filtering/
      <sample_ID>_1_fastqc.html    # FastQC reports on cleaned reads
      <sample_ID>_2_fastqc.html
  clean_reads/
    <sample_ID>_1.fastq.gz         # Adapter-trimmed, human-depleted reads
    <sample_ID>_2.fastq.gz
  host_reads/                      # Only when --publish_host_reads is set
    <sample_ID>_host_1.fastq.gz
    <sample_ID>_host_2.fastq.gz
  multiqc/
    pre_filtering_multiqc.html     # MultiQC reports
    post_filtering_multiqc.html
  stats/
    <sample_ID>_stats.csv          # Per-sample read count statistics
```

### Parameters

**Input options**

| Option       | Type   | Default | Description                                                     |
| ------------ | ------ | ------- | --------------------------------------------------------------- |
| `--manifest` | `path` | `""`    | Input manifest CSV with required header `ID,R1,R2` (mandatory). |

---

**Decontamination options**

| Option            | Type     | Default                       | Description                                                        |
| ----------------- | -------- | ----------------------------- | ------------------------------------------------------------------ |
| `--bmtagger_db`   | `path`   | `/data/pam/software/bmtagger` | Path to the BMTagger database directory.                           |
| `--bmtagger_host` | `string` | `T2T-CHM13v2.0`               | Name of the BMTagger host reference to use for human read removal. |

---

**Pipeline options**

| Option                 | Type      | Default | Description                                          |
| ---------------------- | --------- | ------- | ---------------------------------------------------- |
| `--skip_fastqc`        | `boolean` | `false` | Skip FastQC steps (both pre- and post-filtering).    |
| `--publish_host_reads` | `boolean` | `false` | Publish host (human) reads to the results directory. |

---

**Output options**

| Option          | Type   | Default              | Description                          |
| --------------- | ------ | -------------------- | ------------------------------------ |
| `--results_dir` | `path` | `./nextflow_results` | Directory where results are written. |

### Advanced usage

#### Running outside of Sanger

The BMTagger database defaults to a Sanger-internal path (`/data/pam/software/bmtagger`). When running outside of Sanger, provide the path to a locally installed BMTagger database via `--bmtagger_db`. The database must contain prebuilt BMTagger index files for the selected host reference.

#### Custom host reference

To decontaminate against a host other than human, provide a different BMTagger database prefix to `--bmtagger_db` and set `--bmtagger_host` to the corresponding reference name.

### Dependencies

All dependencies are containerised in publicly available Docker/Singularity images.

- BMTagger database (human T2T-CHM13v2.0): available at `/data/pam/software/bmtagger` on the Sanger HPC. For external users, download from [NCBI](https://www.ncbi.nlm.nih.gov/genome/51) and build the BMTagger index.

## Software versions

| Software       | Version | Image                                              |
| -------------- | ------- | -------------------------------------------------- |
| FastQC         | 0.11.9  | `quay.io/biocontainers/fastqc:0.11.9--hdfd78af_1`  |
| TrimGalore     | 0.4.4   | `quay.io/sangerpathogens/trimgalore:v0.4.4`        |
| BMTagger       | 3.101   | `quay.io/biocontainers/bmtagger:3.101--h470a237_4` |
| MultiQC        | 1.19    | `quay.io/biocontainers/multiqc:1.19--pyhdfd78af_0` |
| Python (stats) | 1.0     | `quay.io/sangerpathogens/metawrap_qc_python:1.0`   |

## Troubleshooting

- **BMTagger database not found**: ensure `--bmtagger_db` points to a directory containing a valid BMTagger index for the selected host reference. On the Sanger HPC the default path `/data/pam/software/bmtagger` should be available.
- **Out of memory for BMTagger**: BMTagger loads the full database into memory. The default resource allocation uses 16 GB RAM; request more via a custom config if needed.
- **Resuming a failed run**: add `-resume` to your command to restart from cached intermediate results.
- For further help, check `.nextflow.log` and the per-process logs in the `work/` directory.

## Issues and Contributions

If you find an issue with this pipeline, or would like to suggest an improvement, please log an issue or open a pull request on this repository.

If you are at Sanger and need internal support, you can raise an issue on the PAM Freshservice portal: https://sanger.freshservice.com/support/catalog/items/426
