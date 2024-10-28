#!/bin/bash

# arguments:
#  1: CASE_NM_LIST
#     List of folder(s) with cases ID(s) where segmentations files are stored
#     Segmentations files MUST be named following convention used in
#     create_dataset.py
#  2: DATASET_ID
#  3: DATASET_NAME
#  4: IFOLD
#  5: TR_CONFIG_LIST (2d, 3d_lowres, 3d_fullres)
#  6: INPUT_FOLDER
#     Directory where cases ID(s) folder(s) are stored
#  7: OUTPUT_FOLDER 
#     Directory where predicted segmentations files are written
#  8: SAVE_PROB (true, false [default])
#     Flag to include save probabilities (it requires more storage)
#     

function predict_fun {
        CASE_NM_LIST=$1
        DATASET_ID=$2
        DATASET_NAME=$3
        IFOLD=$4
        TR_CONFIG_LIST=$5
        INPUT_FOLDER=$6
        OUTPUT_FOLDER=$7
        SAVE_PROB=$8

        # Define dataset full name [str]
        dataset_full_nm="Dataset$(printf %03d $DATASET_ID)_${DATASET_NAME}"

        # Predict segmentations using fine-tuned nnUNet with user-specified
        # dataset
        #
        # Loop through nnUNet training architectures
        for TR_CONFIG in "${TR_CONFIG_LIST[@]}"; do
            # TODO: Add Sanity check to verify nnUNet was trained with
            #       $TR_CONFIG architecture for dataset defined by user.
            #       Skip $TR_CONFIG if not.
            for CASE_NM in "${CASE_NM_LIST[@]}"; do
                # Define input and output directories
                INPUT_DIR=$INPUT_FOLDER/$CASE_NM
                OUTPUT_DIR=$OUTPUT_FOLDER/$TR_CONFIG/fold_$IFOLD/$CASE_NM

                # TODO: Add Sanity check to skip $INPUT_DIR if it does not
                #       exist.

                # Create output directory (if it does not exist)
                mkdir -p $OUTPUT_DIR

                # Call nnUNet predictor
                #
                if [ "$SAVE_PROB" = true ]; then
                   nnUNetv2_predict -i $INPUT_DIR -o $OUTPUT_DIR \
                                    -d ${dataset_full_nm} -c $TR_CONFIG \
                                    -f $IFOLD --save_probabilities
                else
                   nnUNetv2_predict -i $INPUT_DIR -o $OUTPUT_DIR \
                                    -d ${dataset_full_nm} -c $TR_CONFIG \
                                    -f $IFOLD 
                fi
            done
        done
}
