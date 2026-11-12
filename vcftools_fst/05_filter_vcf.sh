#!/bin/bash

#===================================
# filter vcfs
# based on Evelien's code
# refined with Claude 
# requires that input vcf be entered as command line argument
#===================================

#SBATCH --job-name=quality_filter
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=12:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err

vcf_file="$1"
if [ -z "$vcf_file" ]; then echo "Usage: sbatch $0 input.vcf.gz"; exit 1; fi

# tools
BCFTOOLS=/insomnia001/depts/delmore_lab/projects/tools/bcftools/bcftools
VCFTOOLS=/insomnia001/depts/delmore_lab/projects/tools/vcftools_0.1.17/bin/vcftools

# directory
cd /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/pilot/
set -eo pipefail					# stop if fails
export LC_ALL=C

# QUAL and mapping quality filtering already done before receiving vcfs, so skipped

# filter out indels
$VCFTOOLS --gzvcf "$vcf_file" --remove-indels --recode --recode-INFO-all --out "${vcf_file%.vcf.gz}.noindels"

# filter out minimum allele frequency (maf) < 5%
$VCFTOOLS --vcf "${vcf_file%.vcf.gz}.noindels.recode.vcf" --maf 0.05 --recode --recode-INFO-all --out "${vcf_file%.vcf.gz}.noindels.maf"

# filter out missing genotypes (range 0=missing all, 1=no missing)
$VCFTOOLS --vcf "${vcf_file%.vcf.gz}.noindels.maf.recode.vcf" --max-missing 0.8 --recode --recode-INFO-all --out "${vcf_file%.vcf.gz}.noindels.maf.0.8miss"

# filter out loci that don't match HWE
$VCFTOOLS --vcf "${vcf_file%.vcf.gz}.noindels.maf.0.8miss.recode.vcf" --hardy --out "${vcf_file%.vcf.gz}.hardy"
hwe_file="${vcf_file%.vcf.gz}.hardy.hwe"
het_list="${vcf_file%.vcf.gz}.het_exclude.txt"
/insomnia001/home/arn2160/.conda/envs/geoloc_env/bin/Rscript --vanilla filter.hets.R "$hwe_file" "$het_list"
$VCFTOOLS --vcf "${vcf_file%.vcf.gz}.noindels.maf.0.8miss.recode.vcf" --exclude-positions "$het_list" --recode --recode-INFO-all --out "${vcf_file%.vcf.gz}.noindels.maf.0.8miss.het0.6"

# filter out triallelic things (changed this from evelien's code to use bcftools instead
$BCFTOOLS view -M2 "${vcf_file%.vcf.gz}.noindels.maf.0.8miss.het0.6.recode.vcf" \
  -Oz -o "${vcf_file%.vcf.gz}.qualityfiltered.vcf.gz"
$BCFTOOLS index -c "${vcf_file%.vcf.gz}.qualityfiltered.vcf.gz"




