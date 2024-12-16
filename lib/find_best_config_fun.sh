#!/bin/bash

# arguments:
#  1: DATASET_ID
#  2: DATASET_NAME
#  3: N_PROC (Number of processers used for ensembling, postprocessing etc
#  4: TR_CONFIG_LIST
#     List with strings with all configurations to be used to find best
#     ensembling
#     ACHTUNG!!! Configurations MUST be trained before calling this function
#     (2d, 3d_lowres, 3d_fullres)
#  5: PLAN_TYPE
#     Options:
#      + Not defined:
#        Old nnUNet standard planner
#         - No longer recommended according to nnUNet webpage
#      + nnUNetResEncUNetMPlans:
#        New nnUNet planner preset (nnU-Net ResEnc M)
#         - Similar GPU budget than standard nnUNet standard planner
#         - Best suited for GPUs with 9-11GB VRAM
#         - Training time of ~12h on A100  
#      + nnUNetResEncUNetLPlans:
#        New nnUNet planner preset (nnU-Net ResEnc L)
#         - Recommended planner according to nnUNet webpage
#         - Requires GPU with at least 24GB VRAM
#         - Training time of ~35h on A100
#      + nnUNetResEncUNetXLPlans:
#        New nnUNet planner preset (nnU-Net ResEnc XL)
#         - Most accurate planner according to nnUNet webpage
#         - Requires GPU with at least 40GB VRAM
#         - Training time of ~66h on A100

function find_best_config_fun {
        DATASET_ID=$1
        DATASET_NAME=$2
	N_PROC=$3
        TR_CONFIG_LIST=$4
        PLAN_TYPE=$5

        # Define dataset full name [str]
        dataset_full_nm="Dataset$(printf %03d $DATASET_ID)_${DATASET_NAME}"

        # Find best configuration
	# (after training more than one fold [and more than one configuration])
        #
        # Get Old nnUNet standard planner name to find output folder of training fold
        if [ -z "${PLAN_TYPE}" ]; then
           PLAN_TYPE="nnUNetPlans"
        fi
        #
        if [[ ! -f "$nnUNet_results/${dataset_full_nm}/inference_instructions.txt" ]]; then
           # Find best configuration
           printf "\n Find best configuration for inferring segmentations\n"
	   nnUNetv2_find_best_configuration $DATASET_ID -c $TR_CONFIG_LIST \
	   	                         -p ${PLAN_TYPE} -np ${N_PROC}
        else
           printf "\n Best configuration for inferring segmentations previously found!\n"
        fi
}
