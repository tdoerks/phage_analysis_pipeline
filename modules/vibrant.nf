process VIBRANT {
    tag "$sample_id"
    publishDir "${params.outdir}/vibrant", mode: 'copy'
    
    input:
    tuple val(sample_id), path(assembly)
    
    output:
    tuple val(sample_id), path("${sample_id}_vibrant"), emit: results
    tuple val(sample_id), path("${sample_id}_vibrant/VIBRANT_${sample_id}/VIBRANT_phages_${sample_id}/${sample_id}.phages_combined.fna"), emit: phages, optional: true
    path "versions.yml", emit: versions
    
    script:
    """
    # Create output directory
    mkdir -p ${sample_id}_vibrant
    
    # Run VIBRANT
    VIBRANT_run.py -i ${assembly} -t ${task.cpus} -folder ${sample_id}_vibrant
    
    # Create versions file
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vibrant: \$(VIBRANT_run.py --version 2>&1 | grep -oP 'VIBRANT v\\K[0-9.]+')
    END_VERSIONS
    """
    
    stub:
    """
    mkdir -p ${sample_id}_vibrant/VIBRANT_${sample_id}/VIBRANT_phages_${sample_id}
    touch ${sample_id}_vibrant/VIBRANT_${sample_id}/VIBRANT_phages_${sample_id}/${sample_id}.phages_combined.fna
    touch versions.yml
    """
}