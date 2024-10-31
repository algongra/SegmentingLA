#!/bin/bash
#SBATCH -J create_dataset_LA_013
#SBATCH -A mambrino
#SBATCH -p compute
#SBATCH -t 01:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=20
#SBATCH --mem=20G
#SBATCH -o create_dataset_LA_013.o
#SBATCH -e create_dataset_LA_013.e


# Config Segmenting LA project
source config.sh

# Declare enviroment variables (parse_args inputs)
INPUT_FOLDER="/gscratch/mambrino/algongra/data/Segmenting_LA/CT_scans_data"
TRAINING_PERCENTAGE=70.0
DATASET_ID=13
DATASET_NAME="LA"
EXT="nii.gz"
KFOLD=5


# Create Dataset
#
python3 ${Segmenting_LA_lib_path}/create_dataset.py \
        --input_folder $INPUT_FOLDER \
        --training_percentage $TRAINING_PERCENTAGE \
        --dataset_id $DATASET_ID \
        --dataset_name $DATASET_NAME \
        --ext $EXT \
        --kfold $KFOLD
