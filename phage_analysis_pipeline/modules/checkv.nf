process CHECKV {
    tag "$sample_id"
    publishDir "${params.outdir}/checkv", mode: 'copy'
    
    input:
    tuple val(sample_id), path(phages)
    
    output:
    tuple val(sample_id), path("${sample_id}_checkv"), emit: results
    path "versions.yml", emit: versions
    
    when:
    phages.size() > 0
    
    script:
    """
    # Download CheckV database if not present
    if [ ! -d "\$CHECKV_DB" ]; then
        checkv download_database ./checkv_db
        export CHECKV_DB=./checkv_db
    fi
    
    # Run CheckV
    checkv end_to_end ${phages} ${sample_id}_checkv -t ${task.cpus}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        checkv: \$(checkv -h 2>&1 | grep -oP 'CheckV v\\K[0-9.]+')
    END_VERSIONS
    """
    
    stub:
    """
    mkdir -p ${sample_id}_checkv
    touch ${sample_id}_checkv/quality_summary.tsv
    touch versions.yml
    """
}