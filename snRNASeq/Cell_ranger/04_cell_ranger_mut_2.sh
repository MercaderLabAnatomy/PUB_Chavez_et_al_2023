#!/usr/bin/env bash  

#SBATCH --partition=pall
#SBATCH --mem-per-cpu=8G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --output=logs/04_mut_2/cellranger_outfile_generated_%j.txt
#SBATCH --error=logs/04_mut_2/cellranger_errfile_generated_%j.txt
#SBATCH --time=24:00:00  
#SBATCH --job-name=cellranger_Myra_mut_2
#SBATCH --mail-user=prateek.arora@unibe.ch  
#SBATCH --mail-type=begin,end  


module add UHTS/SingleCell/cellranger/6.0.1;

cellranger count --id=mut_2_cellranger \
--fastqs='Myra_spns_snRNASeq_23/mut_2' \
--sample=mtant_2 \
--transcriptome='reference/Ensmbl/Danio_rerio/v109/v109_fp_10X' \
--include-introns=true \
--localcores=24 \
--chemistry=ARC-v1 \
--lanes=1,2