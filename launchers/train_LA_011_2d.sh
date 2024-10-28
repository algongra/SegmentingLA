#!/bin/bash
#SBATCH -J train_LA_011_2d
#SBATCH -A mambrino
#SBATCH -p gpu-a40
#SBATCH -t 72:00:00
#SBATCH --mem=119G
#SBATCH --gpus=1
#SBATCH --cpus-per-task=7
#SBATCH -o train_LA_011_2d.o
#SBATCH -e train_LA_011_2d.e


# Config Segmenting LA project
source config.sh

# Declare enviroment variables
DATASET_ID=11
DATASET_NAME=LA
KFOLD=5
TR_CONFIG=2d


# Call function train_fun.sh for each fold
for IFOLD in $( seq 0 $(($KFOLD-1)) )
 do
    train_fun $nnUNet_results $DATASET_ID $DATASET_NAME $IFOLD $TR_CONFIG
 done
