#!/bin/bash

#===================================
# Run angsd on tx rwh bams (NOT DOWNSAMPLED)
# From Tori Wiley's code, refined for my data with Claude Opus 5.5

# Requires reads per individual (either 2 or 3) as command line argument
#===================================

#SBATCH --job-name=angsd_rwh_fullcov_tx
#SBATCH --account=delmore_lab                 
#SBATCH --partition=delmore_lab1   
#SBATCH --time=24:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=4
#SBATCH --output=slurm_logs/%x_%j.out 
#SBATCH --error=slurm_logs/%x_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=arn2160@columbia.edu

# activate conda environment
source /insomnia001/depts/delmore_lab/projects/tools/miniconda3/etc/profile.d/conda.sh
conda activate /insomnia001/home/arn2160/.conda/envs/angsd-env

# stop at the first error, so later steps never run on broken files
set -eo pipefail

# change directory 
cd /insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/angsd

REF=puma_ref.fa
OUT=/insomnia001/depts/delmore_lab/users/arn2160/tx_fst_pilot/angsd/angsd_out
mkdir -p $OUT

# Set reads per individual as argument (so I can tweak later)
RPI=$1
if [ -z "$RPI" ]; then
  echo "Error: no reads-per-individual given. Usage: sbatch 03b_angsd_rwh_fullcov_tx.sh <RPI>"
  exit 1
fi
echo "RPI set to $RPI"

# run for tx rwh birds (high coverage, NOT downsampled)

# set parameters
# minInd=5 (half of 10 tx rwh samples)
rwh_minind=5

# setMinDepth=10 (minInd*2) (trying this for now per Tori's advice, but may up to x3)
rwh_mindepth=$((rwh_minind*RPI))

# setMaxDepth=224 (mean depth(11.16)*n(10))*2
rwh_maxdepth=224


echo "minInd $rwh_minind | setMinDepth $rwh_mindepth | setMaxDepth $rwh_maxdepth"

angsd -bam bams_tx_rwh.txt -ref $REF -anc $REF -out ${OUT}/rwh_fullcov_tx_mindepth${RPI}_fstsaf \
	-gl 1 -doCounts 1 -dosaf 1 \
	-minMapQ 20 -minQ 20 -uniqueOnly 1 -remove_bads 1 \
	-only_proper_pairs 1 -baq 1 -minInd $rwh_minind -setMinDepth $rwh_mindepth \
	-setMaxDepth $rwh_maxdepth \
	-nThreads 4

echo "angsd run complete"

