#!/bin/bash
#SBATCH -J predict_with_best_LA_013
#SBATCH -A mambrino
#SBATCH -p gpu-a40
#SBATCH -t 24:00:00
#SBATCH --mem=119G
#SBATCH --gpus=1
#SBATCH --cpus-per-task=7
#SBATCH -o predict_with_best_LA_013.o
#SBATCH -e predict_with_best_LA_013.e


# Config Segmenting LA project
source config.sh

# Declare inputs in enviroment variables
#
# Select Dataset ID
DATASET_ID=13
# Select Dataset name
DATASET_NAME=LA
# Select training plane used to train selected Dataset (one at a time)
PLAN_TYPE=nnUNetResEncUNetLPlans
# Specify the absolute path to the folder containing cases directories with
# Nifti images for which masks need to be predicted
INPUT_FOLDER=${Segmenting_LA_data_path}/CT_scans_data/imgs_to_predict
# Select list of cases for mask prediction
# e.g., CASE_NM_LIST=(27468 28024 30016 30701 30919 31174)
#CASE_NM_LIST=(30016 30701 30919 31174)
#CASE_NM_LIST=(31174)
CASE_NM_LIST=(30016 30701 30919)
# Select list of training configurations (full training MUST be completed)
# e.g., TR_CONFIG_LIST=3d_fullres, 3d_lowres, 2d
TR_CONFIG_LIST=3d_fullres
# Specify the absolute path to the folder where predicted masks will be save
#  - After best inference --> $OUTPUT_FOLDER/best
#  - After postprocessing --> $OUTPUT_FOLDER/postpro
OUTPUT_FOLDER=${Segmenting_LA_data_path}/CT_scans_data/segs_nnUNet/Dataset013_LA
# Select number of processes used to determine best predictive configuration
# and to perform postprocessing
# (same number of processes will be used for both tasks)
N_PROC=6


# Call function find_best_config_fun.sh
find_best_config_fun $DATASET_ID $N_PROC "$TR_CONFIG_LIST" $PLAN_TYPE

# Obtain flags to perform best masks inferenced from inference_intruction.txt
#
# Get absolute path of inference_instructions.txt file
TXT_FILE_PATH=${nnUNet_results}/Dataset$(printf %03d $DATASET_ID)_$DATASET_NAME/\
inference_instructions.txt
# Extract recommended flags
find_predict_best_flags_fun $TXT_FILE_PATH

# Call function training_best_fun.sh to get best inference
predict_best_fun $CASE_NM_LIST $DATASET_ID $DATASET_NAME "$KFOLDS" $TRAINER \
	         $PLAN_TYPE $TR_CONFIG $INPUT_FOLDER $OUTPUT_FOLDER

# Extract recommended flags for masks post-processing from inference_intruction.txt
find_postpro_flags_fun $TXT_FILE_PATH
#
# Call function training_best_fun.sh to get best inference
postpro_fun $CASE_NM_LIST $OUTPUT_FOLDER $PP_PKL_FILE $PLANS_JSON $N_PROC

