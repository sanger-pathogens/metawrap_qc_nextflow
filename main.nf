#!/usr/bin/env nextflow

/*
========================================================================================
    HELP
========================================================================================
*/

def printHelp() {
    log.info """
    Usage:
    nextflow run main.nf

    Options:
      --manifest                   Manifest containing paths to fastq files (mandatory)
      --results_dir                Name of results folder. [default: nextflow_results] (optional)
      --bmtagger_db                Path to bmtagger database. [default: /data/pam/software/bmtagger] (optional)
      --bmtagger_host              Name of bmtagger host. [default: T2T-CHM13v2.0] (optional)
      --skip_fastqc                Skip FASTQC. [default: false] (optional)
      --publish_host_reads         Publish host reads to results folder. [default: false] (optional)
      --help                       Print this help message. (optional)
    """.stripIndent()
}

if (params.help) {
    printHelp()
    exit 0
}

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULES
//
include { validate_parameters } from './modules/helper_functions.nf'
include { FASTQC as PRE_FILTERING_FASTQC } from './assorted-sub-workflows/qc/modules/fastqc.nf'
include { FASTQC as POST_FILTERING_FASTQC } from './assorted-sub-workflows/qc/modules/fastqc.nf'
include { MULTIQC as PRE_FILTERING_MULTIQC } from './assorted-sub-workflows/reporting/modules/multiqc.nf'
include { MULTIQC as POST_FILTERING_MULTIQC } from './assorted-sub-workflows/reporting/modules/multiqc.nf'
include { METAWRAP_QC } from './assorted-sub-workflows/mags_maker/metawrap_qc/modules/metawrap_qc.nf'

/*
========================================================================================
    VALIDATE INPUTS
========================================================================================
*/

validate_parameters()

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    manifest_ch = Channel.fromPath(params.manifest)

    fastq_path_ch = manifest_ch.splitCsv(header: true, sep: ',')
        .map{ row -> tuple(row.ID, file(row.R1), file(row.R2)) }

    if (!params.skip_fastqc) {
        PRE_FILTERING_FASTQC(fastq_path_ch)
        def post_qc_report = false
        PRE_FILTERING_MULTIQC(PRE_FILTERING_FASTQC.out.fastqc_ch.collect(), post_qc_report)
    }

    METAWRAP_QC(fastq_path_ch)

    if (!params.skip_fastqc) {
        POST_FILTERING_FASTQC(FILTER_HOST_READS.out.cleaned_ch)
        def post_qc_report = true
        POST_FILTERING_MULTIQC(POST_FILTERING_FASTQC.out.fastqc_ch.collect(), post_qc_report)
    }
}
