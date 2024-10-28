#!/bin/bash
#SBATCH -J plan_and_preprocess_LA_011
#SBATCH -A mambrino
#SBATCH -p ckpt
#SBATCH -t 1:00:00
#SBATCH --mem=80G
#SBATCH --gres=gpu:a100:1
#SBATCH --cpus-per-task=7
#SBATCH -o plan_and_preprocess_LA_011.o
#SBATCH -e plan_and_preprocess_LA_011.e


# Config Segmenting LA project
source config.sh

# Declare enviroment variables
DATASET_ID=11
DATASET_NAME="LA"


# Call function plan_and_preprocess_fun.sh
# Plan training and preprocess dataset (verifying its integrity)
plan_and_preprocess_fun $DATASET_ID $DATASET_NAME
