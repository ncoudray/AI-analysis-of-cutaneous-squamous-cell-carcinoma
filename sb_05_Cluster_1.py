#!/bin/bash
#SBATCH --partition=cpu_medium,cpu_long
#SBATCH --time=4-20:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
#SBATCH --job-name=cSCC102_D_v01_cluster_HN_r7_200k 
#SBATCH --output=rq_cSCC102_D_v01_cluster_r7_%A_%a_200k.out
#SBATCH  --error=rq_cSCC102_D_v01_cluster_r7_%A_%a_200k.err

unset PYTHONPATH

x=$(printf %.2f $1)
echo $x

module load singularity/3.9.8
singularity shell  --bind /gpfs/data/coudraylab/NN/Head_Neck/carucci/Histomorphological-Phenotype-Learning:/mnt docker://gcfntnu/scanpy:1.7.0 << eof
cd /mnt/



python3 ./run_representationsleiden.py \
 --meta_field cSCC102_v01 \
 --matching_field patients \
 --folds_pickle  utilities/fold_creation/cSCC101_A_v01_ToFilter_class_folds_NYUCSFBWH.pkl \
 --h5_complete_path  results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete.h5 \
 --resolution 7.0 \
 --subsample 200000












eof
