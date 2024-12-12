#!/bin/bash

# arguments:
#  1: TXT_FILE_PATH (absolute path of inference_instructions.txt file)

function find_predict_best_flags_fun {
        TXT_FILE_PATH=$1

        # Print message before extracting flags info
        printf "\n Getting flags to perform best masks inferenced from:\n $TXT_FILE_PATH\n"

        # Obtain flags to perform best masks inferenced from TXT_FILE_PATH
        #
        # Extract the line starting with nnUNetv2_predict
        predict_line=$(grep '^nnUNetv2_predict' $TXT_FILE_PATH)
        # Extract KFOLDS
        KFOLDS=$(echo "${predict_line}" | awk -F '-f ' '{split($2, arr, " -"); print arr[1]}')
	# Extract recommended nnUNet trainer (TRAINER)
        TRAINER=$(echo "${predict_line}" | awk -F '-tr ' '{split($2, arr, " "); print arr[1]}')
        # Extract recommended training config (TR_CONFIG)
        TR_CONFIG=$(echo "${predict_line}" | awk -F '-c ' '{split($2, arr, " "); print arr[1]}')
        # Export environment variables
        export KFOLDS
        export TRAINER
        export TR_CONFIG
}

# arguments:
#  1: TXT_FILE_PATH (absolute path of inference_instructions.txt file)

function find_postpro_flags_fun {
        TXT_FILE_PATH=$1

        # Print message before extracting flags info
        printf "\n Getting recommended flags for masks post-processing from:\n $TXT_FILE_PATH\n"

        # Obtain recommended flags for masks post-processing from TXT_FILE_PATH
        #
        # Extract the line starting with nnUNetv2_apply_postprocessing
        postpro_line=$(grep '^nnUNetv2_apply_postprocessing' $TXT_FILE_PATH)
	# Extract absolute path of post-processing Pickle file (PP_PKL_FILE)
        PP_PKL_FILE=$(echo "${postpro_line}" | awk -F '-pp_pkl_file ' '{split($2, arr, " -"); print arr[1]}')
	# Extract absolute path of json file with post-processing plans (PLANS_JSON)
        PLANS_JSON=$(echo "${postpro_line}" | awk -F '-plans_json ' '{split($2, arr, " "); print arr[1]}')
        # Export environment variables (to used them outside of this script)
        export PP_PKL_FILE
        export PLANS_JSON
}
