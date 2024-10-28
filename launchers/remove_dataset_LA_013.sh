#!/bin/bash

# Config Segmenting LA project
source config.sh

# Declare enviroment variables (bash function inputs)
DATASET_ID=13
DATASET_NAME="LA"


# Remove Dataset
remove_dataset_fun $DATASET_ID $DATASET_NAME
