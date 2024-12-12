#!/bin/bash

# Get user-defined settings
source settings.sh

# Add Minicona binary files path to PATH
export PATH=${Miniconda_bin_path}:${PATH}
# Load gpu enviroment (previously created with Miniconda)
source activate ${Miniconda_env_name}

# Export Segmenting LA library path
export Segmenting_LA_lib=${Segmenting_LA_lib_path}
# Source bash files and export functions from Segmenting LA library path
source $Segmenting_LA_lib/plan_and_preprocess_fun.sh
export -f plan_and_preprocess_fun
source $Segmenting_LA_lib/train_fun.sh
export -f train_fun
source $Segmenting_LA_lib/find_best_config_fun.sh
export -f find_best_config_fun
source $Segmenting_LA_lib/predict_fun.sh
export -f predict_fun
export -f predict_best_fun
source $Segmenting_LA_lib/remove_dataset_fun.sh
export -f remove_dataset_fun
source $Segmenting_LA_lib/extract_info_from_inference_instructions.sh
export -f find_predict_best_flags_fun
export -f find_postpro_flags_fun
source $Segmenting_LA_lib/postpro_fun.sh
export -f postpro_fun

# Export nnUNet paths
export nnUNet_dir=${nnUNet_dir}
export nnUNet_raw="${Segmenting_LA_data_path}/nnUNet_raw"
export nnUNet_preprocessed="${Segmenting_LA_data_path}/nnUNet_preprocessed"
export nnUNet_results="${Segmenting_LA_data_path}/nnUNet_results"

