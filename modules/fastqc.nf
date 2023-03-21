process FASTQC {
    tag "$sample_id"
    container '/software/pathogen/images/fastqc-0.11.9--hdfd78af_1.simg'

    input:
    tuple val(sample_id), path(first_read), path(second_read)

    output:
    path("*_fastqc.*"), emit: fastqc_ch

    script:
    """
    fastqc -q -o . -f fastq $first_read $second_read
    """
}