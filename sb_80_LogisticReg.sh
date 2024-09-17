#!/bin/bash
#SBATCH --partition=gpu4_medium,gpu8_medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G


#SBATCH  --job-name=cSCC102_80a_cluster
#SBATCH --output=rq_cSCC102_80a_cluster_%A_%a.out
#SBATCH  --error=rq_cSCC102_80a_cluster_%A_%a.err


unset PYTHONPATH

module load condaenvs/gpu/pathgan_SSL37
python3 ./report_representationsleiden_tight_SAL.py \
--meta_folder cSCC102_v02a_tight_GP \
--matching_field patients \
--meta_field outcome_binary \
--min_tiles 100 \
--folds_pickle utilities/fold_creation/cSCC101_A_v01_ToFilter_class_folds_NYUCSFBWH.pkl \
--h5_complete_path results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight_NYUCSF_GP.h5  \
--h5_additional_path results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_Mayo_448px_40x_he_combined_NYUCSF_RFS_filtered_GP.h5 \
--min_range_auc 0.0 \






