#!/bin/bash
#SBATCH --partition=gpu4_dev,gpu8_short
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=120G

#SBATCH  --job-name=cSCC102t_RFS_J_plot_cluster_NYUCSFBWH_23f
#SBATCH --output=rq_cSCC102t_RFS_J_plot_cluster_NYUCSFBWH_23f_%A_%a.out
#SBATCH  --error=rq_cSCC102t_RFS_J_plot_cluster_NYUCSFBWH_23f_%A_%a.err




unset PYTHONPATH
module load condaenvs/gpu/pathgan_SSL37





python3 ./report_representationsleiden_samples.py \
 --meta_folder cSCC102_v01 \
 --meta_field labels \
 --matching_field slides \
 --h5_complete_path  results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered.h5 \
 --fold 1 \
 --resolution 7.0 \
 --dpi 14 \
 --min_tiles 10 \
 --extensive \
 --dataset cSCC102_NYUCSFBWH_448px_0um252





