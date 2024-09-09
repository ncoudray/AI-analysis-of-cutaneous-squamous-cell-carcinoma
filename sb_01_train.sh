#!/bin/bash
#SBATCH --partition=gpu8_long,gpu4_long
#SBATCH --job-name=Adal_cSCC102_A_train_NYUCSFBWH
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --output=rq_cSCC102_A_train_NYUCSFBWH_%A_%a.out
#SBATCH  --error=rq_cSCC102_A_train_NYUCSFBWH_%A_%a.err
#SBATCH --mem=50G
#SBATCH --gres=gpu:2


module load pathganplus/3.6


python3 run_representationspathology.py --img_size 224 --batch_size 64 --epochs 60 --z_dim 128 --model BarlowTwins_3 --dataset cSCC102_NYUCSFBWH_448px_0um252 --check_every 10 --report


 



