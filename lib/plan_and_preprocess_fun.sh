#!/bin/bash

# This function preprocess user-inputted dataset and plan nnUNet training:
#  - nnUNet verifies dataset (previously created in nnUNet_raw) integrity
#  - nnUNet generates dataset_fingertip.json and nnUNet*Plans.json files in
#    nnUNet_preprocessed directory
#  - nnUNet prepares 2d(, 3d_lowres,) and 3d_fullres nnUNetPlans* folders for
#    training and stored them in nnUNet_preprocessed directory
#  - nnUNet creates (ground truth) gt_segmentations foler in nnUNet_preprocessed
#    directory
#
# arguments:
#  1: DATASET_ID
#  2: DATASET_NAME
#  3: PLAN_TYPE
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
#         - Rrecommended planner according to nnUNet webpage
#         - Requires GPU with at least 24GB VRAM
#         - Training time of ~35h on A100
#      + nnUNetResEncUNetXLPlans:
#        New nnUNet planner preset (nnU-Net ResEnc XL)
#         - Most accurate planner according to nnUNet webpage
#         - Requires GPU with at least 40GB VRAM
#         - Training time of ~66h on A100
#
#      nnUNet planners documentation:
#      https://github.com/MIC-DKFZ/nnUNet/blob/master/documentation/resenc_presets.md

function plan_and_preprocess_fun {
        DATASET_ID=$1
        DATASET_NAME=$2
        PLAN_TYPE=$3

# Define log file name
dataset_nm_id="${DATASET_NAME}_$(printf %03d $DATASET_ID)"
LOGFILE=nnUNetv2_plan_and_preprocess_${dataset_nm_id}.log

# Plan and preprocess Dataset:
#  - nnUNet verifies Dataset (previously created in nnUNet_raw) integrity
#  - nnUNet generates fingertip and in nnUNet_preprocessed
#
if [ -z "${PLAN_TYPE}" ]; then
   # Old nnUNet standard planner
   printf "Planning and preprocessing ${dataset_nm_id} using old nnUNet standard planner"
   nnUNetv2_plan_and_preprocess -d $DATASET_ID \
	                        --verify_dataset_integrity > $LOGFILE
elif [ "${PLAN_TYPE}" == "nnUNetResEncUNetMPlans" ]; then
   # New nnUNet planner preset (nnU-Net ResEnc M)
   printf "Planning and preprocessing ${dataset_nm_id} using ${PLAN_TYPE}"
   nnUNetv2_plan_and_preprocess -d $DATASET_ID -pl nnUNetPlannerResEncM \
                                --verify_dataset_integrity > $LOGFILE
elif [ "${PLAN_TYPE}" == "nnUNetResEncUNetLPlans" ]; then
   # New nnUNet planner preset (nnU-Net ResEnc L)
   printf "Planning and preprocessing ${dataset_nm_id} using ${PLAN_TYPE}"
   nnUNetv2_plan_and_preprocess -d $DATASET_ID -pl nnUNetPlannerResEncL \
                                --verify_dataset_integrity > $LOGFILE
elif [ "${PLAN_TYPE}" == "nnUNetResEncUNetXLPlans" ]; then
   # New nnUNet planner preset (nnU-Net ResEnc XL)
   nnUNetv2_plan_and_preprocess -d $DATASET_ID -pl nnUNetPlannerResEncXL \
                             --verify_dataset_integrity > $LOGFILE
#
else
   # New personalized nnUNet planner (changing presets)
   printf "Personalized ResEncUNet planning changing presets is not available yet"
   printf "Plan type selected not available:\n${PLAN_TYPE}"
   printf "Read PLAN_TYPE options in plan_and_preprocess_fun.sh header"
   # e.g.,
   # New preset using nnUNetPlannerResEncM planner as baseline
   #  - Ppdating memory to 80GB VRAM
   #  - Saving plan with a new name (nnUNetResEncMUNetPlans_80G)
   #nnUNetv2_plan_experiment -d $DATASET_ID -pl nnUNetPlannerResEncM \
   #                         -gpu_memory_target 80 \
   #                         -overwrite_plans_name nnUNetResEncMUNetPlans_80G \
   #                         --verify_dataset_integrity > $LOGFILE
fi
}
