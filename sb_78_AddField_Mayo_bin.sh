#!/bin/bash
#SBATCH --partition=gpu4_medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G

#SBATCH  --job-name=cSCC102_78_label_Mayo_RFS
#SBATCH --output=rq_cSCC102_78_label_Mayo_RFS_%A_%a.out
#SBATCH  --error=rq_cSCC102_78_label_Mayo_RFS_%A_%a.err

module load pathganplus/3.6


python3 ./utilities/h5_handling/nc_create_metadata_h5.py \
  --meta_file labels_SSL_Mayo_RFS_GP.csv \
  --matching_field slides \
  --list_meta_field  outcome_binary \
  --h5_file  results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_Mayo_448px_40x_he_combined_NYUCSF_RFS_filtered.h5 \
  --meta_name GP









