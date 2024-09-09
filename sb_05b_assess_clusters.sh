#!/bin/bash
#SBATCH --partition=a100_short,a100_long,gpu8_long,gpu4_long
#SBATCH --job-name=Adal_cSCC102_D_clusterEval
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --output=rq_cSCC102_D_clusterEval_%A_%a.out
#SBATCH  --error=rq_cSCC102_D_clusterEval_%A_%a.err
#SBATCH --mem=50G
#SBATCH --gres=gpu:1



module load pathganplus/3.8.11

python3 run_representationsleiden_evalutation.py \
 --meta_folder cSCC102_v02a_tight \
 --folds_pickle  utilities/fold_creation/cSCC101_A_v01_ToFilter_class_folds_NYUCSFBWH.pkl \
 --h5_complete_path ./results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight.h5 


