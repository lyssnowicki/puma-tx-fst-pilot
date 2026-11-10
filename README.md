# puma-tx-fst-pilot
Pilot analysis to look for differences in allele frequencies between 2013 and 2024 TX Purple Martin populations

## files
* BARS_PUMA_alignment.csv -> details order of PUMA scaffolds according to Barn Swallow genome <br>
* sequence_report.tsv -> key to rename EDG-style scaffolds ("scaffold*") to RWH-style ("JAK*"); includes scaffold lengths <br>

## data
* Imputed_all.vcf -> EDG's imputed VCF of low-coverage PUMAs (unfiltered, unzipped, no header); file path: /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/pilot/Imputed_all.vcf <br>
* puma_allsites.eastern_only.vcf.gz -> RWH's vcf of 2024 high-coverage PUMAs; file path: /insomnia001/depts/delmore_lab/users/rwh2140/puma_wgs/WGS_pipeline_output/final_var_call/genotyped_chunks_allsites/
puma_allsites.eastern_only.vcf.gz

## scripts
* 01_edg_zip_filter.sh -> filter EDG's vcf to bialleleic snps and zip
* 02_rename_edg_scaffolds.sh -> rename EDG scaffolds according to NCBI key
* 03_check_site_agreement.sh -> check for sites in EDG that are not in RWH and create a subsetted vcf from RWH all sites that only includes sites in EDG
* 04a_merge_keepall.sh -> merge rwh and edg vcfs (keeps all edg sites and only rwh sites that appear in edg)
