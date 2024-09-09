#!/bin/bash
#SBATCH --partition=gpu4_medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G

#SBATCH  --job-name=cSCC102_E_v01b_label_NYUCSFBWH_RFS
#SBATCH --output=rq_cSCC102_E_v01b_label_NYUCSFBWH_RFS_%A_%a.out
#SBATCH  --error=rq_cSCC102_E_v01b_label_NYUCSFBWH_RFS_%A_%a.err


module load pathganplus/3.6



python3 ./utilities/h5_handling/create_metadata_h5.py \
  --meta_file labels_SSL_NYUCSFBWH_20220524.csv \
  --matching_field patients \
  --list_meta_field  outcome_type outcome_binary \
  --h5_file  results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight.h5 \
  --meta_name NYUCSF_GP

python3 ./utilities/h5_handling/nc_create_metadata_h5.py \
  --meta_file labels_SSL_NYUCSF_RFS_v20221028.csv \
  --matching_field slides \
  --list_meta_field  samples os_event_data os_event_ind \
  --h5_file  results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight.h5 \
  --meta_name NYUCSF_RFS









