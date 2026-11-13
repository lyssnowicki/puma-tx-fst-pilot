## scripts
* 01_edg_zip_filter.sh -> filter EDG's vcf to bialleleic snps and zip
* 02_rename_edg_scaffolds.sh -> rename EDG scaffolds according to NCBI key
* 03_check_site_agreement.sh -> check for sites in EDG that are not in RWH and create a subsetted vcf from RWH all sites that only includes sites in EDG
* 04a_merge_keepall.sh -> merge rwh and edg vcfs (keeps all edg sites and only rwh sites that appear in edg)
* 04b_merge_intersect.sh -> merge rwh and edg vcfs (keeps only sites found in BOTH edg and rwh)
* 05_filter_vcf.sh -> filter vcf files (requires name of zipped vcf as command line argument)
* 06_fst.sh -> calculates fst (requires name of zipped quality filtered vcf as command line argument)

* filter.hets.R -> filters by heterozygosity; required for script 05_filter_vcf.sh

