#!/bin/bash

#===================================
# merge edg vcf with rwh vcf subsetted to only sites in edg
#===================================

#SBATCH --job-name=merge_keepall
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
set -eo pipefail					# stop if fails
export LC_ALL=C

# merge the vcfs 
$BCFTOOLS merge -m all --threads 4 Imputed_snps.biallelic.renamed.vcf.gz rwh_at_edg_sites.vcf.gz -Ou \
  | $BCFTOOLS view -Oz -o merged_edg_rwh_keepall.vcf.gz
$BCFTOOLS index -c merged_edg_rwh_keepall.vcf.gz #index it

# sanity checks
echo "Samples in EDG file:"
$BCFTOOLS query -l Imputed_snps.biallelic.renamed.vcf.gz | wc -l
echo "Samples in RWH file:"
$BCFTOOLS query -l rwh_at_edg_sites.vcf.gz  | wc -l
echo "Samples in merged file:"
$BCFTOOLS query -l merged_edg_rwh_keepall.vcf.gz | wc -l

echo "Sites in EDG file:"
$BCFTOOLS view -H Imputed_snps.biallelic.renamed.vcf.gz | wc -l
echo "Sites in RWH file:"
$BCFTOOLS view -H rwh_at_edg_sites.vcf.gz | wc -l
echo "Sites in merged file:"
$BCFTOOLS view -H merged_edg_rwh_keepall.vcf.gz | wc -l

echo "Sample name duplicates (should be empty):"
$BCFTOOLS query -l merged_edg_rwh_keepall.vcf.gz | sort | uniq -d


