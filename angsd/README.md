## scripts
* 01_meancoverage.sh -> get mean coverage of all bams from rwh and edg and compile summary to determine downsampling target. (Note, this script gets coverage for ALL edg and rwh bams; afterwards, I extracted coverages for only tx bams to get target downsampling coverage)
* 02_downsample_tx.sh -> downsample high-coverage rwh samples (tx only) to edg (tx only) mean coverage (1.74x) and save downsampled bams
