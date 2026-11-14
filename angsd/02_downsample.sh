#!/bin/bash

#===================================
# Downsample rwh bams to edg mean coverage (1.7x)
# Written w help of Claude Opus 5.5
#===================================

#SBATCH --job-name=downsample
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=12:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=arn2160@columbia.edu

# activate conda environment
source /insomnia001/depts/delmore_lab/projects/tools/miniconda3/etc/profile.d/conda.sh
conda activate /insomnia001/home/arn2160/.conda/envs/angsd-env

# change directory 
cd /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/angsd
mkdir -p downsampled_rwh_bams mosdepth_rwh_ds

TARGET=1.7 # this is the mean depth of the edg bams
SEED=17 # for reproducibility

> bams_rwh_ds.txt   # start a fresh list of downsampled BAMs

for b in $(cat bams_rwh.txt); do
  s=$(basename ${b%.bam})
  out=downsampled_rwh_bams/$s.ds.bam

  # original coverage from mosdepth, and fraction of reads to keep
  cov=$(awk '$1=="total"{print $4}' mosdepth/$s.mosdepth.summary.txt)
  frac=$(awk -v t=$TARGET -v c=$cov 'BEGIN{printf "%.4f", t/c}')

  if [ -e $out.bai ]; then
    echo "Skipping $s (already done)"
  else
    echo "Downsampling $s: coverage $cov, keeping fraction $frac"
    samtools view -@ 4 -b -s $(awk -v s=$SEED -v f=$frac 'BEGIN{printf "%.4f", s+f}') -o $out $b
    samtools index $out
  fi

# check new coverage
  if [ ! -e mosdepth_rwh_ds/$s.ds.mosdepth.summary.txt ]; then
    mosdepth -t 4 -n -x mosdepth_rwh_ds/$s.ds $out
  fi
  newcov=$(awk '$1=="total"{print $4}' mosdepth_rwh_ds/$s.ds.mosdepth.summary.txt)
  echo "  $s: $cov -> $newcov"

# add full path of new BAM to list
  echo "$(pwd)/$out" >> bams_rwh_ds.txt
done

echo "downsampling done"






