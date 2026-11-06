#!/bin/bash

#===================================
# filter Evelien's imputed vcf file and zip
#===================================

#SBATCH --job-name=edg_vcf_filter
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=12:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err


# bcftools path
BCFTOOLS=/insomnia001/depts/delmore_lab/projects/tools/bcftools/bcftools

# directory
cd /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/pilot

# filter to biallelic sites, SNPs only, and zip (add header for file recognition)
cat header_prefix.txt Imputed_all.vcf | \
  $BCFTOOLS view --threads 4 -m2 -M2 -v snps \
  -Oz -o Imputed_snps.biallelic.vcf.gz

# index 
$BCFTOOLS index -c Imputed_snps.biallelic.vcf.gz 

#checks
$BCFTOOLS index -s Imputed_snps.biallelic.vcf.gz | head
$BCFTOOLS view -H Imputed_snps.biallelic.vcf.gz | wc -l



