#!/bin/bash
#SBATCH -J predict_with_LA_011
#SBATCH -A mambrino
#SBATCH -p gpu-a40
#SBATCH -t 24:00:00
#SBATCH --mem=119G
#SBATCH --gpus=1
#SBATCH --cpus-per-task=7
#SBATCH -o predict_with_LA_011.o
#SBATCH -e predict_with_LA_011.e


# Config Segmenting LA project
source config.sh

# Declare enviroment variables
CASE_NM_LIST=(27468 28024 30016 30701 30919 31174)
DATASET_ID=11
DATASET_NAME=LA
TR_CONFIG_LIST=(3d_fullres 3d_lowres 2d)
KFOLD=5
INPUT_FOLDER=${Segmeting_LA_lib}/CT_scans_data/imgs_to_predict
OUTPUT_FOLDER=${Segmeting_LA_lib}/CT_scans_data/segs_nnUNet


# Call function training_fun.sh for each fold
for IFOLD in $( seq 0 $(($KFOLD-1)) )
 do
    predict_fun $CASE_NM_LIST $DATASET_ID $DATASET_NAME $IFOLD $TR_CONFIG_LIST \
                $INPUT_FOLDER $OUTPUT_FOLDER
 done
