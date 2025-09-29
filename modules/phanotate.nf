process PHANOTATE {
    tag "$sample_id"
    publishDir "${params.outdir}/phanotate", mode: 'copy'
    container = 'docker://quay.io/biocontainers/phanotate:1.6.7--py311he264feb_0'

    input:
    tuple val(sample_id), path(phage_sequences)

    output:
    tuple val(sample_id), path("${sample_id}_phanotate.gff"), emit: results
    path "versions.yml", emit: versions

    script:
    """
    phanotate.py ${phage_sequences} -o ${sample_id}_phanotate.gff -f gff3
    
    echo '"PHANOTATE": {"version": "1.6.7"}' > versions.yml
    """
}
