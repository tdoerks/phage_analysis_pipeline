process CHECKV {
    tag "$sample_id"
    publishDir "${params.outdir}/checkv", mode: 'copy'
    container = 'docker://quay.io/biocontainers/checkv:1.0.2--pyhdfd78af_0'

    input:
    tuple val(sample_id), path(phage_sequences)

    output:
    tuple val(sample_id), path("${sample_id}_checkv"), emit: results
    path "versions.yml", emit: versions

    script:
    """
    checkv end_to_end ${phage_sequences} ${sample_id}_checkv -t ${task.cpus}
    
    echo '"CHECKV": {"version": "1.0.2"}' > versions.yml
    """
}
