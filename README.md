# Wellcome to SegmentingLA

A library for pre-processing Nifti files from our database to obtain automatic segmentations using nnUNet

## Installing SegmentingLA

**1. Access** the **install directory inside SegmentingLA directory** (this last one is the absolute path where you cloned this repository :p)

   ```
   cd ./install
   ```

**2. Copy configure_template.sh** file **to configure.sh**

   ```
   cp configure_template.sh configure.sh
   ```

**3. Modify configure.sh** file with your system information and preferences using your favorite editor

   ```
   vim configure.sh
   ```

**4. Run build.sh** file

   ```
   nohup ./build.sh > build.log 2> build.err &
   ```

## Using SemgentingLA

**1. Access** the **launchers directory inside SegmentingLA directory**

   ```
   cd ./launchers
   ```

**2. Copy settings_template.sh** file **to settings.sh**

   ```
   cp settings_template.sh settings.sh
   ```

**3. The FIRST TIME** (and the FIRST TIME ONLY), **modify settings.sh** file with your system information and preferences using your favorite editor

   ```
   vim settings.sh
   ```

### Steps to train nnUNet

From launchers directory:

**1. Create nnUNet valid dataset's raw data** using images and sementations files (in Nifti format) from our database

   * **Copy** one of the **existent create_dataset_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh** files **to create_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

     ```
     cp create_dataset_LA_012.sh create_dataset_LAA_100.sh
     ```

   * **Modify inputs editing create_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** using your favourite editor, **e.g.:**

     ```
     vim create_dataset_LAA_100.sh
     ```

     Example of modified inputs:

     ```
     # Declare enviroment variables (parse_args inputs)
     INPUT_FOLDER="/gscratch/mambrino/algongra/data/Segmenting_LA/CT_scans_data"
     TRAINING_PERCENTAGE=80.0 # I HAVE MODIFIED THIS INPUT! IT WAS 70.0 IN create_dataset_LA_012.sh
     DATASET_ID=100           # I HAVE MODIFIED THIS INPUT! IT WAS 12 IN create_dataset_LA_012.sh
     DATASET_NAME="LAA"       # I HAVE MODIFIED THIS INPUT! IT WAS LA IN create_dataset_LA_012.sh
     EXT="nii.gz"
     KFOLD=5
     CHANNELS="cineCT"        # I HAVE MODIFIED THIS INPUT! IT WAS "cineCT PerfusionCT" IN create_dataset_LA_012.sh
     ```

   * **Run create_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**
 
     ```
     nohup ./create_dataset_LAA_100.sh > create_dataset_LAA_100.log 2> create_dataset_LAA_100.err &
     ```

     If your server/workstation has SLURM installed, modify the header of create_dataset_LAA_100.sh appropiately and use

     ```
     sbatch create_dataset_LAA_100.sh
     ```
     
     If you are wondering what an SLURM header is, don't use this second option

**2.** Once nnUNet valid dataset is created, **preprocess dataset with nnUNet and plan nnUNet training**

   * **Copy** one of the **existent plan_and_preprocess_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh** files **to ./launchers/plan_and_preprocess_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

     ```
     cp plan_and_preprocess_LA_012.sh plan_and_preprocess_LAA_100.sh
     ```

   * **Modify inputs editing plan_and_preprocess_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** using your favourite editor, **e.g.:**

     ```
     vim plan_and_preprocess_LAA_100.sh
     ```

     Example of modified inputs:

     ```
     # Declare enviroment variables
     DATASET_ID=100                   # I HAVE MODIFIED THIS INPUT! IT WAS 12 IN plan_and_preprocess_LA_012.sh
     DATASET_NAME="LAA"               # I HAVE MODIFIED THIS INPUT! IT WAS LA IN plan_and_preprocess_LA_012.sh
     PLAN_TYPE=nnUNetResEncUNetLPlans # I HAVE MODIFIED THIS INPUT! IT WAS nnUNetResEncUNetXLPlans IN plan_and_preprocess_LA_012.sh
     ```
     
     Note that **DATASET_ID**, and **DATASET_NAME must coincide in create_dataset*.sh and plan_and_preprocess_*.sh**

   * **Run plan_and_preprocess_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

     ```
     nohup ./plan_and_preprocess_LAA_100.sh > plan_and_preprocess_LAA_100.out 2> plan_and_preprocess_LAA_100.err &
     ```

     If your server/workstation has SLURM installed, modify the header of plan_and_preprocess_LAA_100.sh appropiately and use

     ```
     sbatch plan_and_preprocess_LAA_100.sh
     ```

     If you are wondering what an SLURM header is, don't use this second option
 
 
**3.** Once dataset is preprocess and nnUNet plaining train is created, **start training** (fine-tuning) **nnUNet with the new dataset created**

   * **Copy** one of the **existent train_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}_{TR_CONFIG_TEMPLATE}.sh** files **to ./launchers/train_{DATASET_ID_NEW}_{DATASET_NAME_NEW}_{TR_CONFIG_NEW}.sh** file, **e.g.:**

     ```
     cp train_LA_012_3d_fullres.sh train_LAA_100_3d_fullres.sh
     ```

   * **Modify inputs editing train_{DATASET_ID_NEW}_{DATASET_NAME_NEW}_{TR_CONFIG_NEW}.sh** using your favourite editor, **e.g.:**

     Example of modified inputs:

     ```
     # Declare enviroment variables
     DATASET_ID=100                   # I HAVE MODIFIED THIS INPUT! IT WAS 12 IN train_LA_012_3d_fullres.sh
     DATASET_NAME=LAA                 # I HAVE MODIFIED THIS INPUT! IT WAS LA IN train_LA_012_3d_fullres.sh
     KFOLD=5
     TR_CONFIG=3d_lowres              # I HAVE MODIFIED THIS INPUT! IT WAS 3d_fullres IN train_LA_012_3d_fullres.sh
     PLAN_TYPE=nnUNetResEncUNetLPlans # I HAVE MODIFIED THIS INPUT! IT WAS nnUNetResEncUNetXLPlans IN train_LA_012_3d_fullres.sh
     ```

     Note that **DATASET_ID**, **DATASET_NAME**, and **PLAN_TYPE must coincide in plan_and_preprocess*.sh and train_*.sh**

   * **Run train_{DATASET_ID_NEW}_{DATASET_NAME_NEW}_{TR_CONFIG_NEW}.sh** file, **e.g.:**

     ```
     nohup ./train_LAA_100_3d_fullres.sh > train_LAA_100_3d_fullres.out 2> train_LAA_100_3d_fullres.err &
     ```

     If your server/workstation has SLURM installed, modify the header of train_LAA_100_3d_fullres.sh appropiately and use
     **(RECOMMENDED OPTION since training runs for days!!!)**

     ```
     sbatch train_LAA_100_3d_fullres.sh
     ```

     If you are wondering what an SLURM header is, don't use this second option
 
### Remove datasets

**Datasets can be remove to liberate storage space** once they are no longer useful **(raw data, plans, and trained model will be deleted)**. **To remove** an **existing dataset**

* **Copy** one of the **existent remove_dataset_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh** files **to remove_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

  ```
  cp remove_dataset_LA_013.sh remove_dataset_LAA_100.sh
  ```

* **Modify inputs editing remove_dataset__{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** using your favourite editor, **e.g.:**

  ```
  vim remove_dataset_LAA_100.sh
  ```

  Example of modified inputs:

  ```
  # Declare enviroment variables (bash function inputs)
  DATASET_ID=100     # I HAVE MODIFIED THIS INPUT! IT WAS 12 IN remove_dataset_LA_013.sh
  DATASET_NAME="LAA" # I HAVE MODIFIED THIS INPUT! IT WAS LA IN remove_dataset_LA_013.sh

  ```

* **Run remove_dataset_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

  ```
  nohup ./remove_dataset_LAA_100.sh > remove_dataset_LAA_100.out 2> remove_dataset_LAA_100.err &
  ```
  
### Predicting segmentations

**To predict segmentation(s)** from image(s) **using** a **trained** (fine-tuned) **nnUNet** with any of the dataset available

* **Copy** one of the **existent predict_with_{DATASET_ID_TEMPLATE}_{DATASET_NAME_TEMPLATE}.sh** files **to predict_with_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

  ```
  cp predict_with_LA_011.sh predict_with_LA_011_new_cases.sh
  ```

* **Modify inputs editing predict_with_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** using your favourite editor, **e.g.:**

  ```
  vim predict_with_LA_011_new_cases.sh
  ```

  Example of modified inputs:

  ```
  # Declare enviroment variables
  CASE_NM_LIST=(31174 44243_1) # I HAVE MODIFIED THIS INPUT! IT WAS (27468 28024 30016 30701 30919 31174) IN predict_with_LA_011.sh  
  DATASET_ID=11
  DATASET_NAME=LA
  TR_CONFIG_LIST=(3d_fullres)  # I HAVE MODIFIED THIS INPUT! IT WAS (3d_fullres 3d_lowres 2d) IN predict_with_LA_011.sh
  KFOLD=5
  INPUT_FOLDER=${Segmenting_LA_data_path}/CT_scans_data/imgs_to_predict
  OUTPUT_FOLDER=${Segmenting_LA_data_path}/CT_scans_data/segs_nnUNet
  ```

* **Run predict_with_{DATASET_ID_NEW}_{DATASET_NAME_NEW}.sh** file, **e.g.:**

  ```
  nohup ./predict_with_LA_011_new_cases.sh > predict_with_LA_011_new_cases.out 2> predict_with_LA_011_new_cases.err &
  ```

  If your server/workstation has SLURM installed, modify the header of predict_with_LA_011_new_cases.sh appropiately and use

  ```
  sbatch predict_with_LA_011_new_cases.sh
  ```
     
  If you are wondering what an SLURM header is, don't use this second option
