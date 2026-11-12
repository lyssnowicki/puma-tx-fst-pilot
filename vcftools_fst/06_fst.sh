#!/bin/bash

#===================================
# Calculate genome wide Fst for 2013 vs 2024 TX samples (Z and W are left IN)
# Refined with Claude 
#===================================

#SBATCH --job-name=tx_fst
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=4:00:00
#SBATCH --mem=8G
#SBATCH --cpus-per-task=1
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err

vcf_file="$1"
if [ -z "$vcf_file" ]; then echo "Usage: sbatch $0 input.vcf.gz"; exit 1; fi

VCFTOOLS=/insomnia001/depts/delmore_lab/projects/tools/vcftools_0.1.17/bin/vcftools

pilot=/insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/pilot
outdir=/insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/fst_out
mkdir -p "$outdir"

cd "$pilot"
set -eo pipefail
export LC_ALL=C

input_vcf="$pilot/$vcf_file"
pop1="$pilot/edg_tx2013.txt"
pop2="$pilot/rwh_tx2024.txt"
type=ZWin

# fail early if an input is missing
for f in "$input_vcf" "$pop1" "$pop2"; do
  [ -f "$f" ] || { echo "Missing file: $f"; exit 1; }
done

# output name
base=$(basename "$vcf_file" .vcf.gz)

$VCFTOOLS --gzvcf "$input_vcf" \
  --weir-fst-pop "$pop1" \
  --weir-fst-pop "$pop2" \
  --fst-window-size 5000 --fst-window-step 5000 \
  --out "$outdir/${base}_edg_tx2013_vs_rwh_tx2024_${type}"