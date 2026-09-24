#!/usr/bin/env nextflow

/*
========================================================================================
    HELP
========================================================================================
*/

def logo = NextflowTool.logo(workflow, params.monochrome_logs)

log.info logo

def printHelp() {
    NextflowTool.help_message("${workflow.ProjectDir}/schema.json", 
                               ["${workflow.ProjectDir}/assorted-sub-workflows/irods_extractor/schema.json",
                                "${workflow.ProjectDir}/assorted-sub-workflows/mixed_input/schema.json",
                                "${workflow.ProjectDir}/assorted-sub-workflows/qc/schema.json",
                                "${workflow.ProjectDir}/assorted-sub-workflows/mags_maker/metawrap_qc/schema.json"],
    params.monochrome_logs, log)
}

/*
========================================================================================
    IMPORT MODULES/SUBWORKFLOWS
========================================================================================
*/

//
// MODULES
//
include { validate_parameters } from './assorted-sub-workflows/mixed_input/modules/validate_parameters.nf'
include { MIXED_INPUT } from './assorted-sub-workflows/mixed_input/mixed_input.nf'
include { FASTQC as PRE_FILTERING_FASTQC } from './assorted-sub-workflows/qc/modules/fastqc.nf'
include { FASTQC as POST_FILTERING_FASTQC } from './assorted-sub-workflows/qc/modules/fastqc.nf'
include { MULTIQC as PRE_FILTERING_MULTIQC } from './assorted-sub-workflows/reporting/modules/multiqc.nf'
include { MULTIQC as POST_FILTERING_MULTIQC } from './assorted-sub-workflows/reporting/modules/multiqc.nf'
include { METAWRAP_QC } from './assorted-sub-workflows/mags_maker/metawrap_qc/metawrap_qc.nf'

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
    if (params.help) {
        printHelp()
        exit 0
    }

    fastq_path_ch = MIXED_INPUT()

    if (!params.skip_fastqc) {
        PRE_FILTERING_FASTQC(fastq_path_ch)
        def post_qc_report = false
        PRE_FILTERING_MULTIQC(PRE_FILTERING_FASTQC.out.zip.collect(), post_qc_report)
    }

    METAWRAP_QC(fastq_path_ch)

    if (!params.skip_fastqc) {
        POST_FILTERING_FASTQC(METAWRAP_QC.out.filtered_reads)
        def post_qc_report = true
        POST_FILTERING_MULTIQC(POST_FILTERING_FASTQC.out.zip.collect(), post_qc_report)
    }
}

workflow.onComplete {
    NextflowTool.summary(workflow, params, log)
}
