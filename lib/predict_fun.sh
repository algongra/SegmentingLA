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

                # Print message before starting masks inference
                printf "\n Inferring masks of images in:\n $INPUT_DIR\n"

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

                # Print message after inference to indicate where inferred masks
                # have been stored
                printf " Inferred masks saved in:\n $OUTPUT_DIR\n"

            done
        done
}


# arguments:
#  1:  CASE_NM_LIST
#      List of folder(s) with cases ID(s) where segmentations files are stored
#      Segmentations files MUST be named following convention used in
#      create_dataset.py
#  2:  DATASET_ID
#  3:  DATASET_NAME
#  4:  KFOLDS
#      string with all kfolds to be used
#  5:  TRAINER
#      Trainer to be used
#  6:  PLAN_TYPE
#      Plan type to be used
#  7:  TR_CONFIG
#      Training configuration to be used
#  8:  INPUT_FOLDER
#      Directory where cases ID(s) folder(s) are stored
#  9:  OUTPUT_FOLDER 
#      Directory where predicted segmentations files are written
#  10: SAVE_PROB (true, false [default])
#      Flag to include save probabilities (it requires more storage)
#     

function predict_best_fun {
        CASE_NM_LIST=$1
        DATASET_ID=$2
        DATASET_NAME=$3
        KFOLDS=$4
        TRAINER=$5
	PLAN_TYPE=$6
        TR_CONFIG=$7
        INPUT_FOLDER=$8
        OUTPUT_FOLDER=$9
        SAVE_PROB=${10}

        # Define dataset full name [str]
        dataset_full_nm="Dataset$(printf %03d $DATASET_ID)_${DATASET_NAME}"

        # Predict segmentations using fine-tuned nnUNet with user-specified
        # dataset
        #
        # Loop through nnUNet training architectures
        for CASE_NM in "${CASE_NM_LIST[@]}"; do
            # Define input and output directories
            INPUT_DIR=$INPUT_FOLDER/$CASE_NM
            OUTPUT_DIR=$OUTPUT_FOLDER/best/$CASE_NM

            # TODO: Add Sanity check to skip $INPUT_DIR if it does not
            #       exist.
            # Create output directory (if it does not exist)
            mkdir -p $OUTPUT_DIR

            # Print message before starting masks inference
            printf "\n Inferring masks of images in:\n $INPUT_DIR\n"

            # Call nnUNet predictor
            #
            if [ "$SAVE_PROB" = true ]; then
               nnUNetv2_predict -i $INPUT_DIR -o $OUTPUT_DIR 
                                -d ${dataset_full_nm} -c $TR_CONFIG \
                                -f $KFOLDS --save_probabilities \
                                -tr $TRAINER -p $PLAN_TYPE
            else
               nnUNetv2_predict -i $INPUT_DIR -o $OUTPUT_DIR \
                                -d ${dataset_full_nm} -c $TR_CONFIG \
                                -f $KFOLDS -tr $TRAINER -p $PLAN_TYPE
            fi

            # Print message after inference to indicate where inferred masks
            # have been stored
            printf " Inferred masks saved in:\n $OUTPUT_DIR\n"
        done
}
