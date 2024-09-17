#!/bin/bash
#SBATCH --partition=gpu4_dev
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=8G
#SBATCH --gres=gpu:1

#SBATCH  --job-name=cSCC102_71_project_May
#SBATCH --output=rq_cSCC102_71_project_May_%A_%a.out
#SBATCH  --error=rq_cSCC102_71_project_May_%A_%a.err



module load pathganplus/3.6


python3 ./run_representationspathology_projection.py \
 --checkpoint data_model_output/BarlowTwins_3/cSCC101_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/checkpoints/BarlowTwins_3.ckt \
 --real_hdf5  /gpfs/data/coudraylab/NN/Head_Neck/carucci/SSL_images/images/Mayo_0um252_448px/hdf5_Mayo_448px_40x_he_combined.h5 \
 --dataset  cSCC102_NYUCSFBWH_448px_0um252 \
 --model BarlowTwins_3





