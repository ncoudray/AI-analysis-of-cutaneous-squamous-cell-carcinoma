#!/bin/bash
#SBATCH --partition=gpu4_dev
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G



#SBATCH  --job-name=cSCC102p_RFS_I_CoxRes_OS_FF1
#SBATCH --output=rq_cSCC102p_RFS_I_CoxRes_OS_FF1_%A_%a.out
#SBATCH  --error=rq_cSCC102p_RFS_I_CoxRes_OS_FF1_%A_%a.err


unset PYTHONPATH
module load condaenvs/gpu/pathgan_SSL37







python3 ./report_representationsleiden_cox_individual.py \
--meta_folder cSCC102_v02a_tight_RFS \
--matching_field patients \
--event_ind_field os_event_ind \
--event_data_field os_event_data \
--folds_pickle utilities/fold_creation/032_NYUCSF_train_896px_Intg_v01_3f_bis.pkl  \
--h5_complete_path results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight.h5 \
--h5_additional_path results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight_NYUCSF_RFS.h5 \
--resolution 0.75 \
--force_fold 1 \
--l1_ratio 0.01 \
--alpha 3.5 \
--min_tiles 10 \
--additional_as_fold




