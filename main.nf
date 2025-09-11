#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { PHAGE_ANALYSIS } from './workflows/phage_analysis'

workflow {
    PHAGE_ANALYSIS()
}