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
    # Set VIBRANT database path to your local database
    export VIBRANT_DATA_PATH=/homes/tylerdoe/databases/VIBRANT

    # Create output directory
    mkdir -p ${sample_id}_vibrant

    # Run VIBRANT using the full path to your installation
    python /homes/tylerdoe/databases/VIBRANT/VIBRANT_run.py -i ${assembly} -t ${task.cpus} -folder ${sample_id}_vibrant -d \$VIBRANT_DATA_PATH

    # Create versions file
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vibrant: \$(python /homes/tylerdoe/databases/VIBRANT/VIBRANT_run.py --version 2>&1 | head -1 | sed 's/.*v//' || echo "unknown")
    END_VERSIONS
    """

    stub:
    """
    mkdir -p ${sample_id}_vibrant/VIBRANT_${sample_id}/VIBRANT_phages_${sample_id}
    touch ${sample_id}_vibrant/VIBRANT_${sample_id}/VIBRANT_phages_${sample_id}/${sample_id}.phages_combined.fna
    touch versions.yml
    """
}
