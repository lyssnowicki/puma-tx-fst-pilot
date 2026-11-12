#!/bin/bash

#===================================
# check whether sites in EDG's vcf are missing from RWH allsites 
# this also creates a subsetted vcf from RWH's all sites that is only sites listed in EDG
# written w help of Claude
#===================================

#SBATCH --job-name=site_agreement
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=12:00:00
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

# RWH's vcf
rwh_vcf=/insomnia001/depts/delmore_lab/users/rwh2140/puma_wgs/WGS_pipeline_output/final_var_call/genotyped_chunks_allsites/puma_allsites.eastern_only.vcf.gz

# make list of edg sites (sorted CHROM:POS for comm, and CHROM<TAB>POS for -T)
$BCFTOOLS query -f '%CHROM:%POS\n' Imputed_snps.biallelic.renamed.vcf.gz | sort > edg_pos.txt
$BCFTOOLS query -f '%CHROM\t%POS\n' Imputed_snps.biallelic.renamed.vcf.gz > edg_sites.tsv

# one pass through RWH's all-sites file: keep only EDG's positions
$BCFTOOLS view -T edg_sites.tsv --threads 4 $rwh_vcf -Oz -o rwh_at_edg_sites.vcf.gz
$BCFTOOLS index -c rwh_at_edg_sites.vcf.gz #index it

# list the positions that came back
$BCFTOOLS query -f '%CHROM:%POS\n' rwh_at_edg_sites.vcf.gz | sort > rwh_pos.txt

# compare
echo "Line counts (EDG, RWH):"
wc -l edg_pos.txt rwh_pos.txt
echo "EDG sites missing from RWH:"
comm -23 edg_pos.txt rwh_pos.txt | wc -l
echo "Examples of missing sites:"
comm -23 edg_pos.txt rwh_pos.txt | head

# check for sites present in RWH but with no data (AN=0)
echo "EDG sites present in RWH but with no called genotypes:"
$BCFTOOLS query -f '%CHROM:%POS\t%AN\n' rwh_at_edg_sites.vcf.gz | awk '$2==0' | wc -l