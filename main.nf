#!/usr/bin/env nextflow

include { FASTQC as PRE_FILTERING_FASTQC } from './modules/fastqc.nf'
include { FASTQC as POST_FILTERING_FASTQC } from './modules/fastqc.nf'
include { MULTIQC as PRE_FILTERING_MULTIQC } from './modules/multiqc.nf'
include { MULTIQC as POST_FILTERING_MULTIQC } from './modules/multiqc.nf'
include { TRIMGALORE } from './modules/trimgalore.nf'
include { BMTAGGER } from './modules/bmtagger.nf'
include { FILTER_HOST_READS; GET_HOST_READS } from './modules/filter_reads.nf'
include { GENERATE_STATS } from './modules/generate_stats.nf'
include { COLLATE_STATS } from './modules/collate_stats.nf'
include { VALIDATE_PARAMETERS } from './modules/validate_parameters.nf'

// helper functions
def PRINT_HELP() {
    log.info """
    Usage:
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
    """.stripIndent()
}

workflow {
    if (params.help) {
        PRINT_HELP()
        exit 0
    }

    VALIDATE_PARAMETERS()

    manifest_ch = Channel.fromPath(params.manifest)

    fastq_path_ch = manifest_ch.splitCsv(header: true, sep: ',')
            .map{ row -> tuple(row.sample_id, file(row.first_read), file(row.second_read)) }

    if (!params.skip_fastqc) {
        PRE_FILTERING_FASTQC(fastq_path_ch)
        def post_qc_report = false
        PRE_FILTERING_MULTIQC(PRE_FILTERING_FASTQC.out.fastqc_ch.collect(), post_qc_report)
    }

    TRIMGALORE(fastq_path_ch)

    BMTAGGER(TRIMGALORE.out.trimmed_fastqs)

    FILTER_HOST_READS(BMTAGGER.out.data_ch, BMTAGGER.out.bmtagger_list_ch)

    GET_HOST_READS(BMTAGGER.out.data_ch, BMTAGGER.out.bmtagger_list_ch)

    all_reads_ch = FILTER_HOST_READS.out.data_ch
                    .join(FILTER_HOST_READS.out.cleaned_ch)
                    .join(GET_HOST_READS.out.host_ch)
                    .join(fastq_path_ch)

    GENERATE_STATS(all_reads_ch)

    COLLATE_STATS(GENERATE_STATS.out.stats_ch.collect())

    if (!params.skip_fastqc) {
        POST_FILTERING_FASTQC(FILTER_HOST_READS.out.cleaned_ch)
        def post_qc_report = true
        POST_FILTERING_MULTIQC(POST_FILTERING_FASTQC.out.fastqc_ch.collect(), post_qc_report)
    }
}
