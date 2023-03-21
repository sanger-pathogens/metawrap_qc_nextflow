process MULTIQC {
    publishDir "${params.results_dir}/multiqc", mode: 'copy', overwrite: true, pattern: "*.html"
    container '/software/pathogen/images/multiqc-1.14--pyhdfd78af_0.simg'

    input:
    path(fastqc_reports)
    val(post_qc_report)

    output:
    path("*.html"), emit: multiqc_report_ch

    script:
    """
    multiqc .
    if ${post_qc_report}
    then
      mv multiqc_report.html post_qc_multiqc_report.html
    else
      mv multiqc_report.html pre_qc_multiqc_report.html
    fi
    """
}