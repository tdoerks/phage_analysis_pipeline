include { VIBRANT } from '../modules/vibrant'
include { DOWNLOAD_PROPHAGE_DB; DIAMOND_PROPHAGE } from '../modules/diamond_prophage'
include { CHECKV } from '../modules/checkv'
include { PHANOTATE } from '../modules/phanotate'
include { COMBINE_RESULTS } from '../modules/combine_results'

workflow PHAGE_ANALYSIS {
    
    // Create input channel from assemblies
    assemblies_ch = Channel
        .fromPath(params.assemblies, checkIfExists: true)
        .map { file -> 
            def sample_id = file.baseName.replaceAll(/\.(fasta|fa|fna)$/, '')
            [sample_id, file]
        }
    
    // Download Prophage-DB database
    DOWNLOAD_PROPHAGE_DB()
    
    // Run VIBRANT on all assemblies
    VIBRANT(assemblies_ch)
    
    // Run DIAMOND BLAST against Prophage-DB on identified phages
    DIAMOND_PROPHAGE(
        VIBRANT.out.phages,
        DOWNLOAD_PROPHAGE_DB.out.db
    )
    
    // Run CheckV quality assessment on identified phages
    CHECKV(VIBRANT.out.phages)
    
    // Run PHANOTATE gene prediction on identified phages
    PHANOTATE(VIBRANT.out.phages)
    
    // Combine all results into summary
    COMBINE_RESULTS(
        VIBRANT.out.results.collect(),
        DIAMOND_PROPHAGE.out.results.collect(),
        CHECKV.out.results.collect()
    )
    
    // Collect all versions
    ch_versions = Channel.empty()
    ch_versions = ch_versions.mix(VIBRANT.out.versions.first())
    ch_versions = ch_versions.mix(DOWNLOAD_PROPHAGE_DB.out.versions)
    ch_versions = ch_versions.mix(DIAMOND_PROPHAGE.out.versions.first())
    ch_versions = ch_versions.mix(CHECKV.out.versions.first())
    ch_versions = ch_versions.mix(PHANOTATE.out.versions.first())
    ch_versions = ch_versions.mix(COMBINE_RESULTS.out.versions)
    
    emit:
    summary = COMBINE_RESULTS.out.summary
    report = COMBINE_RESULTS.out.report
    versions = ch_versions
}