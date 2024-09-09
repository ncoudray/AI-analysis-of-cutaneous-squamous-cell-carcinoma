#!/bin/bash
#SBATCH --partition=gpu4_dev,gpu8_short
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G


#SBATCH  --job-name=cSCC102_F_v01_filter_remove_NYUCSFBWH
#SBATCH --output=rq_cSCC102_F_v01_filter_remove_NYUCSFBWH_%A_%a.out
#SBATCH  --error=rq_cSCC102_F_v01_filter_remove_NYUCSFBWH_%A_%a.err




unset PYTHONPATH
module load condaenvs/gpu/pathgan_SSL37


python3 ./utilities/tile_cleaning/remove_indexes_h5.py \
--pickle_file utilities/files/indexes_to_remove/cSCC102_v01/complete_a_tight.pkl \
--h5_file results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete.h5








