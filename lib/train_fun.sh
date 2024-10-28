#!/bin/bash

# arguments:
#  1: RESULTS_DIR
#  2: DATASET_ID
#  3: DATASET_NAME
#  4: IFOLD
#  5: TR_CONFIG (2d, 3d_lowres, 3d_fullres)
#  6: PLAN_TYPE
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

function train_fun {
        RESULTS_DIR=$1
        DATASET_ID=$2
        DATASET_NAME=$3
        IFOLD=$4
        TR_CONFIG=$5
        PLAN_TYPE=$6


        # Train model
        #
        # Get Old nnUNet standard planner name to find output folder of training fold
        if [ -z "${PLAN_TYPE}" ]; then
           PLAN_TYPE="nnUNetPlans"
        fi
        # Get output folder of training fold
        OUTDIR=$RESULTS_DIR/Dataset$(printf %03d $DATASET_ID)_$DATASET_NAME/nnUNetTrainer__${PLAN_TYPE}__$TR_CONFIG/fold_$IFOLD
        # Get absolute path of checkpoint_final.pth file (only available when training of
        # fold has finished)
        CHKPNT_FINAL=$OUTDIR/checkpoint_final.pth
        if [ ! -f $CHKPNT_FINAL ]; then
           if [ ! -d $OUTDIR ]; then
              echo Starting training of fold $IFOLD from scratch
              if [ -z "${PLAN_TYPE}" ]; then
                 nnUNetv2_train $DATASET_ID $TR_CONFIG $IFOLD --npz
              else
                 nnUNetv2_train -p ${PLAN_TYPE} $DATASET_ID $TR_CONFIG $IFOLD --npz
              fi
           else
              echo Continue training of fold $IFOLD
              if [ -z "${PLAN_TYPE}" ]; then
                 nnUNetv2_train $DATASET_ID $TR_CONFIG $IFOLD --c --npz
              else
                 nnUNetv2_train -p ${PLAN_TYPE} $DATASET_ID $TR_CONFIG $IFOLD --c --npz
              fi
           fi
        else
           echo Training of fold $IFOLD is already completed
        fi
}
