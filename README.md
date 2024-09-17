# AI analysis of cutaneous squamous cell carcinoma


This repository has the description of the code used in the following manuscript:
[Self-supervised artificial intelligence predicts recurrence, metastasis and disease specific death from primary cutaneous squamous cell carcinoma at diagnosis](https://www.researchsquare.com/article/rs-3607399/v1).


## Usage
To run the code you need to install [DeepPATH](https://github.com/ncoudray/DeepPATH) and [HPL](https://github.com/AdalbertoCq/Histomorphological-Phenotype-Learning). Both pages include detailed description on the libraries to install as well as the meaning of the options used here.


The code here was developed using the slurm executor on NYU's [UltraViolet HPC cluster](https://med.nyu.edu/research/scientific-cores-shared-resources/high-performance-computing-core). The python script is therefore here given with slurm headers appropriate for this cluster as example so they could easily be adapted.  

## Self-supervised analysis of cSCC
### Pre-processing

Images first need to be tiled and converted to H5. For all datasets, the following commands from DeepPATH wee used:
* Tiling:
```shell
python DeepPATH_code/00_preprocessing/0b_tileLoop_deepzoom6.py  -s 448 -e 0  -j 20 -B 75 -M -1  -P 0.252  -p -1    -o "448px_Cohort_B75_0um252px" -N '57,22,-8,20,10,5' /path_to_slides/*svs
```

* Combine all tiles 
```shell
python DeepPATH_code/00_preprocessing/0d_SortTiles.py --SourceFolder='448px_Cohort_B75_0um252px' --Magnification=0.252  --MagDiffAllowed=0 --SortingOption=19 --PatientID=4 --nSplit 0 --Balance=2  --PercentValid=30 --PercentTest=30
```

For the external test cohort, the same command with `--PercentValid=0 --PercentTest=100` was used instead.

* Convert to h5 files:
```shell
mpirun -n 40 python DeepPATH_code/00_preprocessing/0e_jpgtoHDF.py  --input_path path_to_output_of_previous_step  --output hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_train.h5   --chunks 40 --sub_chunks 20 --wSize 224 --mode 2 --subset='train'

mpirun -n 40 python DeepPATH_code/00_preprocessing/0e_jpgtoHDF.py  --input_path path_to_output_of_previous_step  --output hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_test.h5   --chunks 40 --sub_chunks 20 --wSize 224 --mode 2 --subset='test'

mpirun -n 40 python DeepPATH_code/00_preprocessing/0e_jpgtoHDF.py  --input_path path_to_output_of_previous_step --output hdf5_cSCC102_NYUCSFBWH_448px_0um252_he_validation.h5 --chunks 40 --sub_chunks 20 --wSize 224 --mode 2 --subset='valid'

```
For the external cohort, only the corrsponding 'test' h5 file script was run.


### Training and analysis on the development cohort
* Training:
```shell
sbatch sb_01_train.sh
```

* Projection of the whole development cohort into the trained network
```shell
sbatch sb_02_project.sh
```

* Combine the h5 files from the development cohort into 1 h5 file for future processing
```shell
sb_03_combine.sh
``` 

* Clustering number 1 to remove artifacts:
```shell
sbatch sb_05_Cluster_1.sh
```

The entry `cSCC101_A_v01_ToFilter_class_folds_NYUCSFBWH.pkl` was obtained using the [HPL fold creation script](https://github.com/AdalbertoCq/Histomorphological-Phenotype-Learning/tree/master/utilities/fold_creation). 

* Generate 100 random tiles from each cluster:
```shell
sbatch sb_06a_RepTiles_1.sh
``` 

Then, the clusters need to be visually assessed to identify the artifacts ones. 

* Create pickle file with the IDs of the cluster to remove.
This can be done using the [HPL cleaning script](https://github.com/AdalbertoCq/Histomorphological-Phenotype-Learning/tree/master/utilities/tile_cleaning).

* Remove the corresponding tiles from the h5 file:
```shell
sbatch sb_06b_RemoveTiles_1.sh
```

* Run Leiden clustering at different resolution using the cleaned h5 file:
```shell
for resolution in 0.05 0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 5.0 7.0 9.0
do 
sbatch --job-name=cSCC102t_E_v02a_cluster_HN_r${resolution}_200k --output=rq_cSCC102t_E_v02a_cluster_r${resolution}_%A_%a_200k.out  --error=rq_cSCC102t_E_v02a_cluster_r${resolution}_%A_%a_200k.err sb_05_Cluster.sh $resolution 
done
```

* Identify optimal Leiden resolution to use:
```shell
sbatch
sb_05b_assess_clusters.sh
```


* Add clinical data into the h5 file:
```shell
sbatch sb_04_AddField.sh
```

Note: the  `labels_SSL_NYUCSF_RFS_v20221028.csv` files contains the clinical data with the following columns:
  * `slides`: slides basename  - Must match the one in the h5 file (same field name)
  * `samples`: patient ID (in our case, the first 4 or 5 characters of the file names)
  * `os_event_data`: survival (in months)
  * `os_event_ind`: event (1: event; 0: no event)

the `labels_SSL_NYUCSFBWH_20220524.csv` file contains the clinical data with the following columns:
  * `patients`: same as samples in this case (patient ID) - Must match the one in the h5 file (same field name)
  * `outcome_type`: can be invasive SCC, or SCCIS, or NED for example
  * `outcome_binary`: either poor or good outcome class


 
* Assign clusters to the h5 files containing the annotations information
```shell
for resolution in 0.05 0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75  2.0 2.5 3.0 3.5 4.0 4.5 5.0
do 
sbatch --job-name=cSCC102t_F_v02a_r${resolution}_300k --output=rq_cSCC102t_F_v02a_r${resolution}_%A_%a_300k.out  --error=rq_cSCC102t_F_v02a_r${resolution}_%A_%a_300k.err sb_05c_AssignCluster.sh $resolution
done
```
 
* Generate 100 random tiles from each cluster for visual assessment by pathologists:
```shell
sb_06a_RepTiles_2.sh
```

* Run Logistic regression on all folds of Leiden classification  to assess binary prediction of good vs poor outcome for different Leiden clustering:
```shell
sbatch sb_07a_LogisticReg.sh
```

* Run Logistic regression on a frozen Leiden fold:
```shell
sbatch sb_07b_LogisticReg.sh
```

* Run Cox regression on all Leiden folds:
```shell
sbatch sb_08_CoxReg.sh
```

* Run Cox regression on a given Leiden fold:
```shell
sbatch sb_09_CoxReg_Indiv.sh
```

### Inferance on an external test cohort
* slides should be pre-processed and converted to h5 files using the same scriptis above used for the development set.

* Projection on the self-supervised model latent space:
```shell
sbatch sb_71_project_Mayo.sh
```

* Add clinical data (RFS) into the h5 file:
```shell
sbatch sb_72_AddField_Mayo.sh
```

Note: the  `labels_SSL_Mayo_RFS.csv` file should contain the following columns:
  * `slides`: slides basename - Must match the one in the h5 file (same field name)
  * `samples`: patient ID (in our case, the first 4 or 5 characters of the file names)
  * `os_event_data`: survival (in months)
  * `os_event_ind`: event (1: event; 0: no event)

* Assign to this cohort the Leiden clusters computed on the development cohort to filter the artifacts:

```shell
resolution=7.0
sbatch --job-name=cSCC102_73_v01_r${resolution}_300k --output=rq_cSCC102_73_v01_r${resolution}_%A_%a_300k.out  --error=rq_cSCC102_73_v01_r${resolution}_%A_%a_300k.err sb_73_AssignCluster_Mayo_v1.sh  $resolution
```

* Create pickle file with the IDs of the cluster to remove. The same IDs as those used previously on the development cluster must be used. 
This can be done using the [HPL cleaning script](https://github.com/AdalbertoCq/Histomorphological-Phenotype-Learning/tree/master/utilities/tile_cleaning).

* Remove the corresponding tiles from the h5 file
```shell
sbatch sb_74_RemoveTiles_Mayo.sh
```

* Assign to this now filtered cohort the Leiden clusters computed on the development cohort to conduct the study:
```shell
resolution=0.75
sbatch --job-name=cSCC102_75_v01_r${resolution}_300k --output=rq_cSCC102_75_v01_r${resolution}_%A_%a_300k.out  --error=rq_cSCC102_75_v01_r${resolution}_%A_%a_300k.err sb_75_AssignCluster_Mayo_v2.sh   $resolution
```

* Prepare `adatas` folder to use the new cohort as an external cohort. 
Since we used the `additional_as_fold` command during the development cohort process, in the `adatas` folder within the folder which is used in the `meta_folder` of the two following steps, the csv files of the development cohorts first need to be merged. For example, as a backup, first rename the original `cSCC102_v02a_tight_GP` to `cSCC102_v02a_tight_GP_dev_cohort`, then, using these commands within a new `cSCC102_v02a_tight_GP/adatas` folder in the same `results` folder path:
```shell
for kk in `ls cSCC102_v02a_tight_GP_dev_cohort/adatas/cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight_NYUCSF_GP*`; do kk2=`basename $kk`; kk3="${kk2%.*}" ; echo $kk3; more $kk | head -n 1 > ${kk3}.csv; more $kk | grep train >> ${kk3}.csv ; done

for kk in `ls cSCC102_v02a_tight_GP_dev_cohortadatas/cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight_NYUCSF_GP*`; do kk2=`basename $kk`; kk3="${kk2%.*}" ; echo $kk3; more $kk | head -n 1 > ${kk3}_test.csv; more $kk | grep test >> ${kk3}_test.csv ; done

for kk in `ls ../../cSCC102_v02a_tight_GP_dev_cohort/adatasadatas/cSCC102_NYUCSFBWH_448px_0um252_he_complete_filtered_tight_NYUCSF_GP*`; do kk2=`basename $kk`; kk3="${kk2%.*}" ; echo $kk3; more $kk | head -n 1 > ${kk3}_valid.csv; more $kk | grep valid  >> ${kk3}_valid.csv ; done
```

* Apply Cox Regression performed on the development cohort to this cohort
```shell
sbatch sb_76_CoxReg.sh
```

* Apply Cox Regression performed on the development cohort to this cohort (Individual resolution and penalty)
```shell
sb_77_CoxReg_Indiv.sh
```

* Perform the same for the log regression on the good/poor outcome binary classification. First, add information to the header of the h5 file:
```shell
sbatch sb_78_AddField_Mayo_bin.sh
```

the `labels_SSL_Mayo_RFS_GP.csv` file contains the clinical data with the following columns:
  * `slides`: slides basename - Must match the one in the h5 file (same field name)
  * `outcome_binary`: either poor or good outcome class

* Second, assign Leiden clusters:
```shell
resolution=0.75
sbatch --job-name=cSCC102_79_r${resolution}_300k --output=rq_cSCC102_79_r${resolution}_%A_%a_300k.out  --error=rq_cSCC102_79_r${resolution}_%A_%a_300k.err sb_79_AssignCluster_Mayo_GP.sh  $resolution
```

* Third, infer the classes from the Logistic regression done on the development cohort:
```shell
sb_80_LogisticReg.sh
```




