#!/bin/bash

#===================================
# Get mean coverages for edg and rwh samples
# Written w Claude 
#===================================

#SBATCH --job-name=coverage
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=24:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err

# activate conda environment
source /insomnia001/depts/delmore_lab/projects/tools/miniconda3/etc/profile.d/conda.sh
conda activate /insomnia001/home/arn2160/.conda/envs/angsd-env

# change directory 
cd /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/angsd
mkdir -p mosdepth

###################################################
# first, get mean coverage for all birds 

# run for both rwh and edg bams 
for b in $(cat bams_*.txt); do
  echo "Running $b"
  mosdepth -t 4 -n -x mosdepth/$(basename ${b%.bam}) $b
done

echo "mosdepth done"

###################################################
# next, build a table of mean coverages 

echo -e "sample_ID\tgroup\tmean_coverage" > coverage_summary.tsv
for list in bams_*.txt; do
  group=${list#bams_}; group=${group%.txt}
  for b in $(cat $list); do
    s=$(basename ${b%.bam})
    cov=$(awk '$1=="total"{print $4}' mosdepth/$s.mosdepth.summary.txt)
    echo -e "$s\t$group\t$cov"
  done
done >> coverage_summary.tsv

column -t coverage_summary.tsv

# summarize by group
awk -F'\t' 'NR>1{
  n[$2]++; sum[$2]+=$3
  if(!($2 in min) || $3<min[$2]) min[$2]=$3
  if($3>max[$2]) max[$2]=$3
} END{
  printf "group\tn\tmean\tmin\tmax\n"
  for(g in n) printf "%s\t%d\t%.2f\t%.2f\t%.2f\n", g, n[g], sum[g]/n[g], min[g], max[g]
}' coverage_summary.tsv > coverage_by_group.tsv
column -t coverage_by_group.tsv

echo "summary done"

