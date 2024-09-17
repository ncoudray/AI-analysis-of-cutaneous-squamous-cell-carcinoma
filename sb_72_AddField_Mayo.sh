#!/bin/bash
#SBATCH --partition=gpu4_medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
# #SBATCH --gres=gpu:1

#SBATCH  --job-name=cSCC102_72_label_May_RFS
#SBATCH --output=rq_cSCC102_72_label_May_RFS_%A_%a.out
#SBATCH  --error=rq_cSCC102_72_label_May_RFS_%A_%a.err


module load pathganplus/3.6

python3 ./utilities/h5_handling/nc_create_metadata_h5.py \
  --meta_file labels_SSL_Mayo_RFS.csv \
  --matching_field slides \
  --list_meta_field  samples os_event_data os_event_ind \
  --h5_file  results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_Mayo_448px_40x_he_combined.h5 \
  --meta_name NYUCSF_RFS









