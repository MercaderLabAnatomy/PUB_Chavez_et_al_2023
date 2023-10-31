#!/bin/bash
#SBATCH --job-name=cellranger_index
#SBATCH --mem-per-cpu=8G  
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=02:00:00
#SBATCH --output=logs/02_mkref/mkref_%A_%a.out

module load UHTS/SingleCell/cellranger/6.0.1;


cellranger mkgtf \
  Danio_rerio.GRCz11.109_GFP.gtf \
  Danio_rerio.GRCz11.109_GFP.filtered.gtf \
  --attribute=gene_biotype:protein_coding
  cellranger mkref \
  --genome=v109_fp_10X \
  --fasta=/data/users/parora/reference/Ensmbl/Danio_rerio/GRCz11/Danio_rerio.GRCz11.dna_sm.primary_assembly_fp.fa \
  --genes=Danio_rerio.GRCz11.109_GFP.filtered.gtf