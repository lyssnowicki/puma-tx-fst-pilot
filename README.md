# puma-tx-fst-pilot
Pilot analysis to look for differences in allele frequencies between 2013 and 2024 TX Purple Martin populations

## files
* BARS_PUMA_alignment.csv -> _details order of PUMA scaffolds according to Barn Swallow genome_ <br>
* sequence_report.tsv -> _key to rename EDG-style scaffolds ("scaffold*") to RWH-style ("JAK*"); includes scaffold lengths_ <br>

## data
* Imputed_all.vcf -> _EDG's imputed VCF of low-coverage PUMAs (unfiltered, unzipped, no header); file path: /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/pilot/Imputed_all.vcf_ <br>
* puma_allsites.eastern_only.vcf.gz -> _RWH's vcf of 2024 high-coverage PUMAs; file path: /insomnia001/depts/delmore_lab/users/rwh2140/puma_wgs/WGS_pipeline_output/final_var_call/genotyped_chunks_allsites/
puma_allsites.eastern_only.vcf.gz_

## scripts
* 01_edg_zip_filter.sh -> filter EDG's vcf to bialleleic snps and zip
