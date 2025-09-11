process DOWNLOAD_PROPHAGE_DB {
    tag "prophage_db"
    publishDir "${params.outdir}/databases", mode: 'copy'
    
    output:
    path "prophage_db.dmnd", emit: db
    path "versions.yml", emit: versions
    
    script:
    """
    # Download the protein FASTA file
    wget -O prophage_proteins.fasta.gz https://datadryad.org/downloads/file_stream/3332772
    
    # Decompress the file
    gunzip prophage_proteins.fasta.gz
    
    # Create DIAMOND database from the protein FASTA
    diamond makedb --in prophage_proteins.fasta --db prophage_db
    
    # Create versions file
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        diamond: \$(diamond version 2>&1 | grep -oP 'diamond version \\K[0-9.]+')
        wget: \$(wget --version 2>&1 | head -n1 | grep -oP 'Wget \\K[0-9.]+')
    END_VERSIONS
    """
    
    stub:
    """
    touch prophage_db.dmnd
    touch versions.yml
    """
}
