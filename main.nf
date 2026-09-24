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
include { FASTQC_MULTIQC as PRE_FILTERING_FASTQC_MULTIQC } from './assorted-sub-workflows/qc/subworkflows/fastqc_reporting.nf'
include { FASTQC_MULTIQC as POST_FILTERING_FASTQC_MULTIQC } from './assorted-sub-workflows/qc/subworkflows/fastqc_reporting.nf'
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

    PRE_FILTERING_FASTQC_MULTIQC(fastq_path_ch)

    METAWRAP_QC(fastq_path_ch)

    POST_FILTERING_FASTQC_MULTIQC(METAWRAP_QC.out.filtered_reads)
}

workflow.onComplete {
    NextflowTool.summary(workflow, params, log)
}
