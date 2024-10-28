# Wellcome to SegmentingLA

Library to pre-process our database of Nifti files to use nnUNet for automatic segmentation.

## Installing SegmentingLA

1. Access the install directory (cd ./install) from your SegmentingLA directory (i.e., absolute path where you cloned this repository)
2. Modify configure.sh file with your system information and preferences using your favorite editor (e.g., vim configure.sh or nano configure.sh)
3. Run build.sh file (bash build.sh or ./build.sh)

## Using SemgentingLA

1. Access the launchers directory (cd ./launchers) from your SegmentingLA directory 
2. The FIRST TIME, and the FIRST TIME ONLY you access to this directory, modify settings.sh file with your system information and preferences using your favorite editor
3. Create nnUNet valid dataset using images and sementations files in Nifti format from our database
  * Copy one of the existent create_dataset_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh files into create_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh file
  * Modify inputs editing create_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh using your favourite editor
  * Run create_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh file
4. Once nnUNet valid dataset is created, preprocess dataset with nnUNet and plan nnUNet training
  * Copy one of the existent plan_and_preprocess_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh files into ./launchers/plan_and_preprocess_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh file
  * Modify inputs editing plan_and_preprocess_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh using your favourite editor
  * Run plan_and_preprocess_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh file
5. Once dataset is preprocess and nnUNet plaining train is created, start training
  * Copy one of the existent train_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}_{TR_CONFIG_TEMPLATE}.sh into ./launchers/train_{DATASET_ID_NEW}_{DATASET_NAME_NEW}_{TR_CONFIG_NEW}.sh
  * Modify inputs editing train_{DATASET_ID_NEW}_{DATASET_NAME_NEW}_{TR_CONFIG_NEW}.sh using your favourite editor
  * Run train_{DATASET_ID_NEW}_{DATASET_NAME_NEW}_{TR_CONFIG_NEW}.sh file
6. To predict segmentations using a trained (fine-tuned) configuration of nnUNet
  * Copy one of the existent predict_with_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh in ./launcher into ./launchers/predict_with_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh
  * Modify inputs editing predict_with_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh file using your favourite editor
  * Run predict_with_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.s file
