#!/bin/bash

#===================================
# rename EDG's scaffolds according to GenBank names (used by RWH)
#===================================

#SBATCH --job-name=rename_edg
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=4:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err


# bcftools path
BCFTOOLS=/insomnia001/depts/delmore_lab/projects/tools/bcftools/bcftools

# directory
cd /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/pilot/
set -e						# stop if fails
export LC_ALL=C

# files
A=Imputed_snps.biallelic.vcf.gz          # EDG, scaffoldN names
KEY=puma_scaffold_key.clean.txt

# 1. rename EDG scaffolds to GenBank accessions
$BCFTOOLS annotate --rename-chrs $KEY --threads 4 $A -Oz -o Imputed_snps.biallelic.renamed.vcf.gz
$BCFTOOLS index -c Imputed_snps.biallelic.renamed.vcf.gz
