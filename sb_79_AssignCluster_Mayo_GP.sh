#!/bin/bash
#SBATCH --partition=cpu_dev
#SBATCH --time=4:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30G


unset PYTHONPATH
x=$(printf %.2f $1)
echo $x

module load singularity/3.9.8
singularity shell  --bind /gpfs/data/coudraylab/NN/Head_Neck/carucci/Histomorphological-Phenotype-Learning:/mnt docker://gcfntnu/scanpy:1.7.0 << eof
cd /mnt/


python3 ./run_representationsleiden_assignment.py \
 --meta_field cSCC102_v02a_tight_GP \
 --folds_pickle  utilities/fold_creation/cSCC101_A_v01_ToFilter_class_folds_NYUCSFBWH.pkl \
 --h5_complete_path   results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight.h5 \
--h5_additional_path results/BarlowTwins_3/cSCC102_NYUCSFBWH_448px_0um252/h224_w224_n3_zdim128/hdf5_Mayo_448px_40x_he_combined_NYUCSF_RFS_filtered_GP.h5 \
--resolution $1 


# for resolution in 0.75; do sbatch --job-name=cSCC102_79_r${resolution}_300k --output=rq_cSCC102_79_r${resolution}_%A_%a_300k.out  --error=rq_cSCC102_79_r${resolution}_%A_%a_300k.err sb_79_AssignCluster_Mayo_GP.py  $resolution; done



eof


