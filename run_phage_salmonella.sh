#!/bin/bash
#SBATCH --job-name=phage-salmonella
#SBATCH --partition=killable.q
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --output=phage_salmonella_%j.log
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=tdoerks@vet.k-state.edu

# cd /homes/tylerdoe/pipelines/phage_analysis_pipeline

# Load Nextflow
module load Nextflow

# Create results directory
#mkdir -p /homes/tylerdoe/salmonella_phage_results

# Run the pipeline
nextflow run main.nf \
  --assemblies '/fastscratch/tylerdoe/sra_downloads/salmonella_assemblies_fasta/*.fasta' \
  --outdir /homes/tylerdoe/salmonella_phage_results \
  -resume
