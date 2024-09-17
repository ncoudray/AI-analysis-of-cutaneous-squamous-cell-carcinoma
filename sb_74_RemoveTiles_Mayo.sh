#!/bin/bash
#SBATCH --partition=fn_medium,fn_long
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G



#SBATCH  --job-name=cSCC102_74_v01_filter_remove_Mayo
#SBATCH --output=rq_cSCC102_74_v01_filter_remove_Mayo_%A_%a.out
#SBATCH  --error=rq_cSCC102_74_v01_filter_remove_Mayo_%A_%a.err




unset PYTHONPATH
module load condaenvs/gpu/pathgan_SSL37



python3 ./utilities/tile_cleaning/remove_indexes_h5.py \
--pickle_file utilities/files/indexes_to_remove/cSCC102_v01/Mayo_448px_40x_tight.pkl \
--h5_file results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_Mayo_448px_40x_he_combined_NYUCSF_RFS.h5 








