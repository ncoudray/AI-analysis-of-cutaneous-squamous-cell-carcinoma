#!/bin/bash
# #SBATCH --partition=gpu4_medium,gpu8_medium,gpu8_long,gpu4_long
#SBATCH --partition=gpu4_dev
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --gres=gpu:1

#SBATCH  --job-name=cSCC102_B_project_nyucsfbwh
#SBATCH --output=rq_cSCC102_B_project_nyucsfbwh_%A_%a.out
#SBATCH  --error=rq_cSCC102_B_project_nyucsfbwh_%A_%a.err



module load pathganplus/3.6


python3 ./run_representationspathology_projection.py \
 --checkpoint data_model_output/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/checkpoints/BarlowTwins_3.ckt \
 --real_hdf5  dataset/cSCC102_NYUCSFBWH_448px_0um252/he/patches_h224_w224/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_validation.h5 \
 --dataset  cSCC102_NYUCSFBWH_448px_0um252 \
 --model BarlowTwins_3

python3 ./run_representationspathology_projection.py \
 --checkpoint data_model_output/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/checkpoints/BarlowTwins_3.ckt \
 --real_hdf5  dataset/cSCC102_NYUCSFBWH_448px_0um252/he/patches_h224_w224/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_test.h5 \
 --dataset  cSCC102_NYUCSFBWH_448px_0um252 \
 --model BarlowTwins_3

python3 ./run_representationspathology_projection.py \
 --checkpoint data_model_output/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/checkpoints/BarlowTwins_3.ckt \
 --real_hdf5  dataset/cSCC102_NYUCSFBWH_448px_0um252/he/patches_h224_w224/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_train.h5 \
 --dataset  cSCC102_NYUCSFBWH_448px_0um252 \
 --model BarlowTwins_3





