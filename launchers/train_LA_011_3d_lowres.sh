#!/bin/bash
#SBATCH -J train_LA_011_3d_lowres
#SBATCH -A mambrino
#SBATCH -p gpu-a40
#SBATCH -t 72:00:00
#SBATCH --mem=119G
#SBATCH --gpus=1
#SBATCH --cpus-per-task=6
#SBATCH -o train_LA_011_3d_lowres.o
#SBATCH -e train_LA_011_3d_lowres.e


# Config Segmenting LA project
source config.sh

# Declare enviroment variables
DATASET_ID=11
DATASET_NAME=LA
KFOLD=5
TR_CONFIG=3d_lowres


# Call function train_fun.sh for each fold
for IFOLD in $( seq 0 $(($KFOLD-1)) )
 do
    train_fun $nnUNet_results $DATASET_ID $DATASET_NAME $IFOLD $TR_CONFIG
 done
