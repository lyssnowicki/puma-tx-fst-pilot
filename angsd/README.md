## scripts
* 01_meancoverage.sh -> get mean coverage of all bams from rwh and edg and compile summary to determine downsampling target. (Note, this script gets coverage for ALL edg and rwh bams; afterwards, I extracted coverages for only tx bams to get target downsampling coverage)
* 02_downsample_tx.sh -> downsample high-coverage rwh samples (tx only) to edg (tx only) mean coverage (1.74x) and save downsampled bams
* 03a_angsd_edg_tx.sh -> run angsd for 16 tx edg birds
* 03b_angsd_rwh_fullcov_tx.sh -> run angsd for 10 high-coverage tx rwh birds
* 03c_angsd_rwh_ds_tx.sh -> run angsd for 10 tx rwh birds downsampled to 1.74x (same as edg tx mean coverage) 
