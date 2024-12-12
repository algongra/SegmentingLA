#!/bin/bash

# arguments:
#  1: CASE_NM_LIST
#     List of folder(s) with cases ID(s) where segmentations files are stored
#     Segmentations files MUST be named following convention used in
#     create_dataset.py
#  2: OUTPUT_FOLDER 
#     Directory where predicted segmentations files are written
#  3: PP_PKL_FILE
#     Absolute path of post-processing Pickle file
#  4: PLANS_JSON
#     Absolute path of json file with post-processing plans
#  5: N_PROC
#     Number of processes used to apply prost-processing
#     

function postpro_fun {
        CASE_NM_LIST=$1
        OUTPUT_FOLDER=$2
        PP_PKL_FILE=$3
	PLANS_JSON=$4
	N_PROC=$5

        # Post-process masks from best inference
        #
        # Loop through nnUNet training architectures
        for CASE_NM in "${CASE_NM_LIST[@]}"; do
            # Define input and output directories
            OUTPUT_DIR=$OUTPUT_FOLDER/best/$CASE_NM
            OUTPUT_PP_DIR=$OUTPUT_FOLDER/best/postpro/$CASE_NM

            # Print message before starting post-processing
            printf "\n Applying post-processing to masks in:\n $OUTPUT_DIR\n"

            # Create output directory for post-processing (if it does not exist)
            mkdir -p $OUTPUT_PP_DIR

            # Call nnUNet function to apply post-processing
            #
            nnUNetv2_apply_postprocessing -i $OUTPUT_DIR -o $OUTPUT_PP_DIR \
                                          -pp_pkl_file "$PP_PKL_FILE" \
                                          -plans_json "$PLANS_JSON" -np $N_PROC

            # Print message after post-processing to indicate where
            # post-processed masks have been stored
            printf " Post-processed masks saved in:\n $OUTPUT_PP_DIR\n"
        done
}
