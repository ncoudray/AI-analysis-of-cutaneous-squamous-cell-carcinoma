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


### Training and amalysis on the development cohort
* Training:
```shell
sbatch sb_01_train.py
```

* Projection of the whole development cohort into the trained network
```shell
sbatch sb_02_project.py
```

* Combine the h5 files from the development cohort into 1 h5 file for future processing
```shell
sb_03_combine.py
``` 


* Clustering number 1 to remove artifacts:
```shell
sbatch sb_05_Cluster_1.py
```

The entry `cSCC101_A_v01_ToFilter_class_folds_NYUCSFBWH.pkl` was obtained using the [HPL fold creation script](https://github.com/AdalbertoCq/Histomorphological-Phenotype-Learning/tree/master/utilities/fold_creation). 

* Generate 100 random tiles from each cluster:
```shell
sbatch sb_06a_RepTiles_1.py
``` 

Then, the clusters need to be visually assessed to identify the artifacts ones. 

* Create pickle file with the IDs of the cluster to remove.
This can be done using the [HPL cleaning script](https://github.com/AdalbertoCq/Histomorphological-Phenotype-Learning/tree/master/utilities/tile_cleaning).

* Remove the corresponding tiles from the h5 file:
```shell
sbatch sb_06b_RemoveTiles_1.py
```

* Run Leiden clustering at different resolution using the cleaned h5 file:
```shell
for resolution in 0.05 0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75 2.0 2.5 3.0 5.0 7.0 9.0
do 
sbatch --job-name=cSCC102t_E_v02a_cluster_HN_r${resolution}_200k --output=rq_cSCC102t_E_v02a_cluster_r${resolution}_%A_%a_200k.out  --error=rq_cSCC102t_E_v02a_cluster_r${resolution}_%A_%a_200k.err sb_05_Cluster.py $resolution 
done
```

* Identify optimal Leiden resolution to use:
```shell
sbatch
sb_05b_assess_clusters.py
```


* Add clinical data into the h5 file:
```shell
sbatch sb_04_AddField.sh
```

Note: the  `labels_SSL_NYUCSF_RFS_v20221028.csv` files contains the clinical data with the following columns:
** `slides`: slides basename
** `samples`: patient ID (in our case, the first 4 or 5 characters of the file names)
** `os_event_data`: survival (in months)
** `os_event_ind`: event (1: event; 0: no event)
the `labels_SSL_NYUCSFBWH_20220524.csv` file contains the clinical data with the following columns:
** `patients`: same as samples in this case (patient ID)
** `outcome_type`: can be invasive SCC, or SCCIS, or NED for example
** `outcome_binary`: either poor or good outcome class


 
* Assign clusters to the h5 files containing the annotations information
```shell
for resolution in 0.05 0.1 0.25 0.5 0.75 1.0 1.25 1.5 1.75  2.0 2.5 3.0 3.5 4.0 4.5 5.0
do 
sbatch --job-name=cSCC102t_F_v02a_r${resolution}_300k --output=rq_cSCC102t_F_v02a_r${resolution}_%A_%a_300k.out  --error=rq_cSCC102t_F_v02a_r${resolution}_%A_%a_300k.err sb_05c_AssignCluster.py $resolution
done
```
 
* Generate 100 random tiles from each cluster for visual assessment by pathologists:
```shell
sb_06a_RepTiles_2.py
```

* Run Logistic regression on all folds of Leiden classification  to assess binary prediction of good vs poor outcome for different Leiden clustering:
```shell
sbatch sb_07a_LogisticReg.py
```

* Run Logistic regression on a frozen Leiden fold:
```shell
sbatch sb_07b_LogisticReg.py
```

* Run Cox regression on all Leiden folds:
```shell
sbatch sb_08_CoxReg.py
```

* Run Cox regression on a given Leiden fold:
```shell
sbatch sb_09_CoxReg_Indiv.py
```




