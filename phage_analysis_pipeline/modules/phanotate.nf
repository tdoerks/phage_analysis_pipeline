process PHANOTATE {
    tag "$sample_id"
    publishDir "${params.outdir}/phanotate", mode: 'copy'
    
    input:
    tuple val(sample_id), path(phages)
    
    output:
    tuple val(sample_id), path("${sample_id}_phanotate.gff"), emit: gff
    tuple val(sample_id), path("${sample_id}_phanotate.faa"), emit: proteins
    path "versions.yml", emit: versions
    
    when:
    phages.size() > 0
    
    script:
    """
    # Run PHANOTATE for gene prediction
    phanotate.py ${phages} -o ${sample_id}_phanotate.gff -f gff
    
    # Extract protein sequences
    phanotate.py ${phages} -o ${sample_id}_phanotate.faa -f fasta
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        phanotate: \$(phanotate.py --version 2>&1 | grep -oP 'PHANOTATE \\K[0-9.]+')
    END_VERSIONS
    """
    
    stub:
    """
    touch ${sample_id}_phanotate.gff
    touch ${sample_id}_phanotate.faa
    touch versions.yml
    """
}