#!/bin/bash

#===================================
# merge edg vcf with rwh; includes only sites found in BOTH vcfs
# written w help of Cluade
#===================================

#SBATCH --job-name=merge_intersect
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

A=Imputed_snps.biallelic.renamed.vcf.gz     # EDG
B=rwh_at_edg_sites.vcf.gz                   # RWH (subset to EDG positions)

# 1. keep only positions present in both files
mkdir -p isec_out
$BCFTOOLS isec -n=2 -c all -p isec_out -Oz $A $B
$BCFTOOLS index -c isec_out/0000.vcf.gz     # EDG shared sites
$BCFTOOLS index -c isec_out/0001.vcf.gz     # RWH shared sites

# 2. merge the two shared-site files
$BCFTOOLS merge -m all --threads 4 isec_out/0000.vcf.gz isec_out/0001.vcf.gz -Ou \
  | $BCFTOOLS view -Oz -o merged_edg_rwh_intersect.vcf.gz
$BCFTOOLS index -c merged_edg_rwh_intersect.vcf.gz

# 3. sanity checks (counts from the index are instant)
echo "Samples in EDG, RWH, merged:"
$BCFTOOLS query -l $A | wc -l
$BCFTOOLS query -l $B | wc -l
$BCFTOOLS query -l merged_edg_rwh_intersect.vcf.gz | wc -l

echo "Sites in EDG, RWH, shared-EDG, shared-RWH, merged:"
for f in $A $B isec_out/0000.vcf.gz isec_out/0001.vcf.gz merged_edg_rwh_intersect.vcf.gz; do
  $BCFTOOLS index -s $f | awk '{s+=$3} END {print s}'
done

echo "Sample name duplicates (should be empty):"
$BCFTOOLS query -l merged_edg_rwh_intersect.vcf.gz | sort | uniq -d

