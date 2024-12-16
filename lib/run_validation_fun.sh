#!/bin/bash

# arguments:
#  1: DATASET_ID
#  2: DATASET_NAME
#  4: TR_CONFIG (2d, 3d_lowres, 3d_fullres)
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
#
# Notes:
#  - Assumes a maximum of five folds. Validation will only be run for folds 0-4
#    (if they exist).
#  - Assumes all training configurations used the same plan type.

function run_validation_fun {
        DATASET_ID=$1
        DATASET_NAME=$2
        TR_CONFIG_LIST=$3
        PLAN_TYPE=$4

	# ACHTUNG!!! hard-coded value might not be the best of the ideas
	# Define maximum number of folds
	KFOLD=5

	# Perform validation for folds 0, 1, 2, 3, and 4 (if they exist)
        #
        # Get Old nnUNet standard planner name to find output folder of training fold
        if [ -z "${PLAN_TYPE}" ]; then
           PLAN_TYPE="nnUNetPlans"
        fi
        for TR_CONFIG in "${TR_CONFIG_LIST[@]}"; do
           for IFOLD in $( seq 0 $(($KFOLD-1)) )
	    do
               # Get absolute path of training fold directory
               FOLDDIR=$nnUNet_results/Dataset$(printf %03d $DATASET_ID)_$DATASET_NAME/nnUNetTrainer__${PLAN_TYPE}__$TR_CONFIG/fold_$IFOLD
	       if [[ -d "$FOLDDIR" ]]; then
                  # Get absolute path of validation directory inside of training fold directory
                  VALDIR=$FOLDDIR/validation
                  # Check if there are .npz files saved in VALDIR
	          if [[ -n $(find "$VALDIR" -maxdepth 1 -type f -name "*.npz" 2>/dev/null) ]]; then
                     printf "Validation of fold $IFOLD already completed using --npz flag\n"
                  else
	             printf "\nStarting validation of fold $IFOLD of configuration $TR_CONFIG from scratch (including --npz flag)\n"
                     nnUNetv2_train -p ${PLAN_TYPE} $DATASET_ID $TR_CONFIG $IFOLD --val --npz
                  fi
               else
                  printf "Skipping validation of fold $IFOLD of configuration $TR_CONFIG. Training fold $IFOLD not available\n"
               fi
            done
         done
}
