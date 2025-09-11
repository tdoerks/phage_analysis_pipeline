process DOWNLOAD_PROPHAGE_DB {
    storeDir "${params.outdir}/databases"
    
    output:
    path "prophage_db.dmnd", emit: db
    path "versions.yml", emit: versions
    
    script:
    """
    # Download Prophage-DB diamond database
    wget -O prophage_db.dmnd ${params.prophage_db_url}
    
    # Verify download
    if [ ! -f prophage_db.dmnd ]; then
        echo "Failed to download Prophage-DB"
        exit 1
    fi
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -n1 | grep -oP 'Wget \\K[0-9.]+')
    END_VERSIONS
    """
    
    stub:
    """
    touch prophage_db.dmnd
    touch versions.yml
    """
}

process DIAMOND_PROPHAGE {
    tag "$sample_id"
    publishDir "${params.outdir}/diamond_prophage", mode: 'copy'
    
    input:
    tuple val(sample_id), path(phages)
    path prophage_db
    
    output:
    tuple val(sample_id), path("${sample_id}_prophage_hits.tsv"), emit: results
    path "versions.yml", emit: versions
    
    when:
    phages.size() > 0
    
    script:
    """
    # Run DIAMOND BLASTX against Prophage-DB
    diamond blastx \\
        --query ${phages} \\
        --db ${prophage_db} \\
        --out ${sample_id}_prophage_hits.tsv \\
        --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore stitle \\
        --threads ${task.cpus} \\
        --sensitive \\
        --max-target-seqs 10 \\
        --evalue 1e-5
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamond: \$(diamond version 2>&1 | grep -oP 'diamond version \\K[0-9.]+')
    END_VERSIONS
    """
    
    stub:
    """
    touch ${sample_id}_prophage_hits.tsv
    touch versions.yml
    """
}