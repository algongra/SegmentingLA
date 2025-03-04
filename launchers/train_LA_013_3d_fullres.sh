#!/bin/bash
#SBATCH -J train_LA_013_3d_fullres
#SBATCH -A mambrino
#SBATCH -p ckpt
#SBATCH -t 90:00:00
#SBATCH --mem=80G
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=7
#SBATCH -o train_LA_013_3d_fullres.o
#SBATCH -e train_LA_013_3d_fullres.e


# Config Segmenting LA project
source config.sh

# Declare enviroment variables
DATASET_ID=13
DATASET_NAME=LA
KFOLD=5
TR_CONFIG=3d_fullres
PLAN_TYPE=nnUNetResEncUNetLPlans

# optional: select the GPU to run on
#export CUDA_VISIBLE_DEVICES=6
# optional: declare which fold to run
#IFOLD=0

# if IFOLD is not defined, call function train_fun.sh for each fold
# otherwise, only train on this fold
if [[ -z "${IFOLD}" ]]; then
 for IFOLD in $( seq 0 $(($KFOLD-1)) )
  do
     train_fun $nnUNet_results $DATASET_ID $DATASET_NAME $IFOLD $TR_CONFIG \
               $PLAN_TYPE
  done
else
 train_fun $nnUNet_results $DATASET_ID $DATASET_NAME $IFOLD $TR_CONFIG \
           $PLAN_TYPE
fi
