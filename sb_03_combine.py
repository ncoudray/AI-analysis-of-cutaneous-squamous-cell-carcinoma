#!/bin/bash
#SBATCH --partition=gpu4_short,gpu8_short,gpu4_medium,gpu8_medium,gpu8_long,gpu4_long
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G
#SBATCH --gres=gpu:1

#SBATCH  --job-name=cSCC102_C_combine_HE_NYUCSFBWH
#SBATCH --output=rq_cSCC102_C_combine_HE_NYUCSFBWH_%A_%a.out
#SBATCH  --error=rq_cSCC102_C_combine_HE_NYUCSFBWH_%A_%a.err


module load pathganplus/3.6


## cSCC
python3 ./utilities/h5_handling/combine_complete_h5.py \
 --img_size 224 \
 --z_dim 128 \
 --dataset cSCC102_NYUCSFBWH_448px_0um252 \
 --model BarlowTwins_3






