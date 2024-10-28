#!/bin/bash

# Get user-defined settings
source settings.sh

# Add Minicona binary files path to PATH
export PATH=${Miniconda_bin_path}:${PATH}
# Load gpu enviroment (previously created with Miniconda)
source activate ${Miniconda_env_name}

# Export Segmenting LA library path
export Segmeting_LA_lib=${Segmeting_LA_lib_path}
# Source bash files and export functions from Segmenting LA library path
source $Segmeting_LA_lib/plan_and_preprocess_fun.sh
export -f plan_and_preprocess_fun
source $Segmeting_LA_lib/train_fun.sh
export -f train_fun
source $Segmeting_LA_lib/predict_fun.sh
export -f predict_fun
source $Segmeting_LA_lib/remove_dataset_fun.sh
export -f remove_dataset_fun

# Export nnUNet paths
export nnUNet_dir=${nnUNet_dir}
export nnUNet_raw="${Segmeting_LA_data_path}/nnUNet_raw"
export nnUNet_preprocessed="${Segmeting_LA_data_path}/nnUNet_preprocessed"
export nnUNet_results="${Segmeting_LA_data_path}/nnUNet_results"

