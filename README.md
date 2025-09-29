# Phage Analysis Pipeline

Nextflow pipeline for identifying and analyzing phage sequences in bacterial genome assemblies.

## Overview

This pipeline uses multiple bioinformatics tools to identify prophages and phage sequences within bacterial genomes, compare them to known prophage databases, assess quality, and predict genes.

## Pipeline Components

- **VIBRANT** - Identifies viral sequences and prophages in assemblies
- **DIAMOND** - Compares identified phages against prophage protein database using BLASTX
- **CheckV** - Assesses completeness and contamination of viral genomes
- **PHANOTATE** - Predicts genes in phage genomes

## Requirements

- Nextflow 24.04.2 or later
- Apptainer/Singularity for containers
- SLURM job scheduler (for HPC environments)

## Installation

```bash
git clone https://github.com/tdoerks/phage_analysis_pipeline.git
cd phage_analysis_pipeline
```

## Database Setup

### Prophage Protein Database

```bash
# Place your prophage protein FASTA file in databases directory
cd /path/to/databases
gunzip -c prophage_proteins.faa.gz > prophage_proteins.faa

# Create DIAMOND database
apptainer exec docker://staphb/diamond diamond makedb \
    --in prophage_proteins.faa \
    --db prophage_db
```

### CheckV Database

```bash
# Download CheckV database
wget https://portal.nersc.gov/CheckV/checkv-db-v1.5.tar.gz
tar -xzf checkv-db-v1.5.tar.gz
```

Update `modules/checkv.nf` with your database path:
```groovy
checkv end_to_end ${phage_sequences} ${sample_id}_checkv -t ${task.cpus} -d /path/to/checkv-db-v1.5
```

## Configuration

Edit `nextflow.config` to set your parameters:

```groovy
params {
    assemblies = "/path/to/assemblies/*.fasta"
    outdir = "results"
}
```

Key configuration for HPC:
- Uses `local` executor to run processes within single SLURM job
- Apptainer enabled for container execution
- Process-specific resource allocations defined

## Running the Pipeline

### On HPC with SLURM

```bash
sbatch run_phage_salmonella.sh
```

### Interactive Run

```bash
nextflow run main.nf \
  --assemblies '/path/to/assemblies/*.fasta' \
  --outdir results \
  -resume
```

### Monitoring

```bash
# Check job status
squeue -u $USER

# Monitor progress
tail -f phage_salmonella_*.log
```

## Container Images Used

- `docker://staphb/diamond` - DIAMOND sequence aligner
- `docker://staphb/vibrant` - VIBRANT phage identification
- `docker://quay.io/biocontainers/checkv:1.0.2--pyhdfd78af_0` - CheckV quality assessment
- `docker://quay.io/biocontainers/phanotate:1.6.7--py311he264feb_0` - PHANOTATE gene prediction

## Output Structure

```
results/
├── vibrant/              # Phage identification results
├── diamond_prophage/     # Prophage database comparison
├── checkv/              # Quality assessment metrics
├── phanotate/           # Gene predictions
└── databases/           # Cached databases
```

## Key Implementation Details

### Beocat HPC Specific Configurations

1. **Container System**: Uses `apptainer` (Singularity replacement)
2. **DIAMOND**: Uses `blastx` for DNA-to-protein comparison (not `blastp`)
3. **PHANOTATE**: Command is `phanotate.py` (not `phanotate`)
4. **Local Databases**: Configured to use pre-downloaded databases to avoid network issues

### Resume Functionality

Use `-resume` to restart from failed processes without repeating completed work:
```bash
nextflow run main.nf -resume
```

## Troubleshooting

**Container Pull Failures**
- Containers are cached in `~/.apptainer/cache/`
- If pulls fail, check network connectivity
- Consider pre-pulling containers manually

**Database Errors**
- Verify database paths in module files
- Ensure databases are properly extracted
- Check file permissions

**SLURM Issues**
- Adjust resource allocations in `nextflow.config`
- Check partition availability
- Monitor job queue with `squeue`

## Citation

If you use this pipeline, please cite the tools it uses:
- VIBRANT: Kieft et al. (2020) Microbiome
- DIAMOND: Buchfink et al. (2021) Nature Methods
- CheckV: Nayfach et al. (2021) Nature Biotechnology
- PHANOTATE: McNair et al. (2019) Bioinformatics

## License

See LICENSE file for details.
