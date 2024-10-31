#!/bin/bash

# arguments:
#  2: DATASET_ID
#  3: DATASET_NAME

function remove_dataset_fun {
        DATASET_ID=$1
        DATASET_NAME=$2

        # Sanity check (Does Segmenting LA data path exist?)
        if [ ! -d "${Segmenting_LA_data_path}" ]; then
           printf " Directory does not exist:\n ${Segmenting_LA_data_path}\n"
           exit 1
        fi

        # Define dataset full name [str]
        dataset_full_nm="Dataset$(printf %03d $DATASET_ID)_${DATASET_NAME}"

        # Sanity check (Does Dataset inputted by user exist?)
        if [ ! -d "${nnUNet_raw}/${dataset_full_nm}" ] && \
           [ ! -d "${nnUNet_preprocessed}/${dataset_full_nm}" ] && \
           [ ! -d "${nnUNet_result}/${dataset_full_nm}" ];  then
           printf " ${dataset_full_nm} does not exist\n"
           exit 1
        fi

        # Delete Dataset from all nnUNet directories in Segmenting LA data path
        #
        # nnUNet_raw
        if [ -d "${nnUNet_raw}/${dataset_full_nm}" ]; then
           printf " Deleting directory:\n ${nnUNet_raw}/${dataset_full_nm}\n"
           rm -r ${nnUNet_raw}/${dataset_full_nm}
        else
           printf " ${nnUNet_raw}/${dataset_full_nm} does not exist\n"
        fi
        # nnUNet_preprocessed
        if [ -d "${nnUNet_preprocessed}/${dataset_full_nm}" ]; then
           printf " Deleting directory:\n ${nnUNet_preprocessed}/${dataset_full_nm}\n"
           rm -r ${nnUNet_preprocessed}/${dataset_full_nm}
        else
           printf " ${nnUNet_preprocessed}/${dataset_full_nm} does not exist\n"
        fi
        # nnUNet_results
        if [ -d "${nnUNet_results}/${dataset_full_nm}" ]; then
           printf " Deleting directory:\n ${nnUNet_results}/${dataset_full_nm}\n"
           rm -r ${nnUNet_results}/${dataset_full_nm}
        else
           printf " ${nnUNet_results}/${dataset_full_nm} does not exist\n"
        fi

        # Delete Dataset from datasets_ids.pkl
        if [ -f "${nnUNet_raw}/datasets_ids.pkl" ]; then
           python -c "import sys; sys.path.insert(0,\"${Segmenting_LA_lib_path}\"); import utils as utls; utls.delete_dataset_id_from_datasets_ids(${DATASET_ID})"
        else
           printf "${nnUNet_raw}/datasets_ids.pkl not found"
        fi
}
