import os
import shutil
import numpy as np
from pathlib import Path
from typing import List
import random
import datetime
import re
import warnings
import copy

from batchgenerators.utilities.file_and_folder_operations import nifti_files, save_json
import sys
sys.path.insert(0,os.environ['nnUNet_dir'])
from nnunetv2.dataset_conversion.generate_dataset_json import generate_dataset_json
from nnunetv2.paths import nnUNet_raw, nnUNet_preprocessed

import utils as utls



def parse_args():
    import argparse

    parser = argparse.ArgumentParser(description= \
                                     'Get arguments required to create dataset')
    parser.add_argument('--input_folder',
                        type=str, default='/gscratch/mambrino/algongra/data/Segmenting_LA/CT_scans_data',
                        help='Directory where CT raw images (imgs) and segmentations (segs) are stored')
    parser.add_argument('--training_percentage', type=float, default=60.0,
                        help='Percentage of images selected for training')
    parser.add_argument('--dataset_id', type=int,
                        help='Number of dataset to be created')
    parser.add_argument('--dataset_name', type=str, default='LA',
                        help='Name of dataset to be created')
    parser.add_argument('--ext', type=str, default='nii.gz',
                        help='File extension of raw images and segmentations')
    parser.add_argument('--kfold', type=int, default=5,
                        help='Number of k for k-fold Cross-Validation')
    parser.add_argument('--channels', nargs='+', default="CineCT",
                        help='Name of imaging channels')
    parser.add_argument('--caseid_pattern', type=str, default=r'\b(\d{5})\b',
                        help='Pattern to find caseIDs. Default: 5 consecutive numbers')

    args = parser.parse_args()

    return args


def make_out_dirs(dataset_id: int, task_name="LA"):
    dataset_name = f"Dataset{dataset_id:03d}_{task_name}"

    out_dir = os.path.join(Path(nnUNet_raw.replace('"', "")),dataset_name)
    out_train_images_dir = os.path.join(out_dir,"imagesTr")
    out_train_labels_dir = os.path.join(out_dir,"labelsTr")
    out_test_images_dir = os.path.join(out_dir,"imagesTs")
    out_test_labels_dir = os.path.join(out_dir,"labelsTs")

    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(out_train_images_dir, exist_ok=True)
    os.makedirs(out_train_labels_dir, exist_ok=True)
    os.makedirs(out_test_images_dir, exist_ok=True)
    os.makedirs(out_test_labels_dir, exist_ok=True)

    return dataset_name, out_dir, out_train_images_dir, out_train_labels_dir, \
           out_test_images_dir, out_test_labels_dir


def copy_database_files_to_nnUNet_raw(args, pth: str, files_list: List, cases_dict: dict[str]) -> List[int]:
    # Loop through all files (list) saved in database
    for ifl, flnm in enumerate(files_list):
        # Obtain case ID and frame
        caseid = utls.extract_caseid_from_path(flnm, args.caseid_pattern)
        case = int(cases_dict[caseid])
        ifr = int(os.path.basename(flnm).split(f".{args.ext}")[0])
        ichannel = 0
        if "Perfusion" in flnm:
           # AGG_NOT_USABLE_YET_BEG
           #ichannel = 1 # Cannot be used until we register and interpolate
                         # Perfusion imgs|segs data into Cine imgs|segs "mesh"
           # AGG_NOT_USABLE_YET_END
           ifr = 9999 # channel selected for Perfusion files is 9999
        #
        # Copy flnm in dataset directory folders with required nomenclature
        if "imgs" in flnm:
           new_flnm = os.path.join(pth, f"LA{case:03d}_{ifr:04d}_{ichannel:04d}.{args.ext}")
        elif "segs" in flnm:
           new_flnm = os.path.join(pth, f"LA{case:03d}_{ifr:04d}.{args.ext}")
        shutil.copy(flnm, new_flnm)

    return


def create_dataset_json(args, out_dir, n_tr_fls, labels_dict=None, \
                        file_ext=None, channels_dict=None):
    # Define default values
    #
    # channels dictionary
    # AGG_NOT_USABLE_YET_BEG
    #  Cannot be used until we register and interpolate erfusion imgs|segs data
    #  into Cine imgs|segs "mesh"
    #dflt_channels_dict = {i: channel for i, channel in enumerate(args.channels)}
    dflt_channels_dict = {0: "CT"}
    # AGG_NOT_USABLE_YET_END
    # labels dictionary
    dflt_labels_dict = {"background": 0, "LV": 1, "LA": 2, "LAA": 3, \
                        "LSPV": 4, "LIPV": 5, "RSPV": 6, "RIPV": 7, "Aorta": 8}
    # file extension (str)
    dflt_file_ext = f".{args.ext}"

    # Assign default values if user does not introduce inputs
    if channels_dict is None:
       channels_dict = dflt_channels_dict
    if labels_dict is None:
       labels_dict = dflt_labels_dict
    if file_ext is None:
       file_ext = dflt_file_ext

    # Create json file using generate_dataset_json from nnunetv2
    #
    generate_dataset_json(str(out_dir), channel_names=channels_dict, \
                          labels=labels_dict, file_ending=file_ext, \
                          num_training_cases=n_tr_fls)

    return


def create_kfold_split(args, labelsTr_folder: str, seed: int) -> List[dict[str, List]]:
    nii_files = nifti_files(labelsTr_folder, join=False)
    patients = np.unique([i[:len(f"{args.dataset_name}000")] for i in nii_files])
    random.seed(seed)
    random.shuffle(patients)
    splits = []
    for fold in range(args.kfold):
        val_patients = patients[fold::args.kfold]
        train_patients = [i for i in patients if i not in val_patients]
        val_cases = [i[:-7] for i in nii_files for j in val_patients if i.startswith(j)]
        train_cases = [i[:-7] for i in nii_files for j in train_patients if i.startswith(j)]
        splits.append({'train': train_cases, 'val': val_cases})

    return splits


def max_len_list(list):
    lens = [len(s) for s in list]

    return max(lens)


def write_seed_and_list(out_dir,segs_list,now,date_int):
    # Write segs_list and date_int in dataset_and_seed.py
    #
    # Get maximum string lenght in segs_list
    max_flnm_len = max_len_list(segs_list)
    #
    print("  Writing dataset_and_seed.py...")
    with open(os.path.join(out_dir,"dataset_and_seed.py"), "w") as ftxt:
         ftxt.write(f"# Module with list of segmentations available on {now} and seed used to shuffle\n\n")
         ftxt.write(f"date_int = {date_int}\n\n")
         #
         list_str_beg = "segs_list = ["
         max_str_len = len(list_str_beg) + max_flnm_len + 2
         #
         str_tmp = f"{list_str_beg}'{segs_list[0]}'"
         str_append = f"{str_tmp:<{max_str_len}},\n"
         ftxt.write(str_append)
         for flnm in segs_list[1:-1]:
             str_tmp = f"             '{flnm}'"
             str_append = f"{str_tmp:<{max_str_len}},\n"
             ftxt.write(str_append)
         str_tmp = f"             '{segs_list[-1]}'"
         str_append = f"{str_tmp:<{max_str_len}}]"
         ftxt.write(str_append)


def create_dataset(args):

    # Check Dataset ID has not been used yet
    #
    utls.check_dataset_id_existence(args.dataset_id)

    # Get dictionary linking original cases IDs and nnU-Net cases IDs
    #
    cases_dict = utls.get_cases_dict(args.input_folder)

    # Define path(s) containing segmentations files and check they exist
    #
    # Cine segmentations directory
    Cine_segs_path = os.path.join(args.input_folder, "segs", "Cine")
    if not os.path.exists(Cine_segs_path):
       raise FileNotFoundError(f"Directory not found:\n{Cine_segs_path}")
    #
    # Perfusion segmentations directory
    if "PerfusionCT" in args.channels:
       Perfusion_segs_path = os.path.join(args.input_folder, "segs", "Perfusion")
       if not os.path.exists(Perfusion_segs_path):
          raise FileNotFoundError(f"Directory not found:\n{Perfusion_segs_path}")

    # Add all Perfusion segmentations (one per case) to
    # Perfusion_segs_training_list
    #
    if "PerfusionCT" in args.channels:
       # Initialize empty training and test lists for Perfusion files (segs)
       Perfusion_segs_training_list = []
       Perfusion_segs_test_list = [] # This list may not remain empty in other
                                     # code versions
       # Initialiaze list to save cases available in Perfusion folder when this
       # Dataset ID was created
       Perfusion_caseid_list = []
       for root, _, files in os.walk(Perfusion_segs_path):
           for file in files:
               if file.endswith(args.ext):
                  # Add segmentation file to Perfusion segmentations training list
                  Perfusion_segs_training_list.append(os.path.join(root, file))
                  # Get caseID from path containing file (root)
                  caseid = os.path.basename(root)
                  # Save all caseIDs available when this Dataset ID was created
                  Perfusion_caseid_list.append(caseid)
       # Number of Cine segmentations available
       n_Perfusion_segs = len(Perfusion_segs_training_list)

       # Create training and test list for Perfusion files (imgs)
       #
       Perfusion_imgs_training_list  = [re.sub("segs", "imgs", f) \
                                        for f in Perfusion_segs_training_list]
       Perfusion_imgs_test_list = [] # This list may not remain empty in other
                                     # code versions

    # Save all segmentations available in Cine folder in Cine_segs_list
    #
    # Initialize empty list to save all files in Cine folder
    Cine_segs_list = []
    # Initialiaze list to save cases available in Cine folder when this Dataset
    # ID was created
    Cine_caseid_list = []
    for root, _, files in os.walk(os.path.join(args.input_folder, "segs", "Cine")):
        for file in files:
            if file.endswith(args.ext):
               # Add segmentation file to Cine segmentations list
               Cine_segs_list.append(os.path.join(root, file))
               # Get caseID from path containing file (root)
               caseid = os.path.basename(root)
               # Save all caseIDs available when this Dataset ID was created
               if caseid not in Cine_caseid_list:
                  Cine_caseid_list.append(caseid)
    # Number of Cine segmentations available
    n_Cine_segs = len(Cine_segs_list)

    # Create Dataset directory (including tree folder structure)
    #
    dataset_name, out_dir, imagesTr, labelsTr, imagesTs, labelsTs = \
            make_out_dirs(args.dataset_id, args.dataset_name)

    # Shuffle Cine_segs_list to randomize files in training and testing sets
    #
    # Get seeding from current date
    now = datetime.datetime.now()
    date_int = int(now.strftime("%Y%m%d%H%M%S"))
    random.seed(date_int)
    #
    # Write seed and list in python module
    write_seed_and_list(out_dir,Cine_segs_list,now,date_int)
    #
    # Shuffle list
    random.shuffle(Cine_segs_list)

    # Add one Cine segmentation per case to Cine_segs_training_list
    #
    # Initialize empty training list for Cine files (segs)
    Cine_segs_training_list = []
    # Initialiaze list to discard segmenations of cases wiht one segmentation
    # already included in Cine_segs_training_list
    caseid_list = []
    # Copy Cine_segs_list in temporal List to delete files added in
    # Cine_segs_training_list from Cine_segs_list without conflict
    tmp_segs_list = copy.copy(Cine_segs_list)
    for file in tmp_segs_list:
        # Get caseID from path
        caseid = utls.extract_caseid_from_path(file, args.caseid_pattern)
        if caseid not in caseid_list:
           # Add segmentation file to training list
           Cine_segs_training_list.append(file)
           # Add caseID to caseid_list
           caseid_list.append(caseid)
           # Remove file from Cine_segs_list
           Cine_segs_list.remove(file)
    # Delete temporal List
    del tmp_segs_list

    # Complete Cine_segs_training_list until the number of segmentations used
    # for training (including Perfusion and Cine) meets the training percentage
    # defined by the user
    # (i.e., first segmentations files remaining in Cine_segs_list will be used
    #  for training until args.training_percentage is reached)
    #
    # Calculate total number of segmentations files available (n_segs)
    # and current percentage of segmentation files used for training
    n_segs = n_Cine_segs
    current_percentage = 100*len(Cine_caseid_list)/n_segs
    if "PerfusionCT" in args.channels:
       n_segs = n_segs + n_Perfusion_segs
       current_percentage = 100*(n_Perfusion_segs + len(Cine_caseid_list))/n_segs
    # Calculate number of segmentations files used for training based on user
    # training_percentage
    n_segs_training = np.ceil(n_segs*args.training_percentage/100).astype(int)
    #
    # Check if n_segs_training is compatible with the criteria used to select
    # training set (all Perfusion segmentation + one Cine segmentation per case
    # + additional random Cine segmentations from the remaining if possible)
    # AND
    # Calculate index of last Cine_segs_list required to complete
    # Cine_segs_training_list
    iendTr = n_segs_training - len(Cine_caseid_list)
    if "PerfusionCT" in args.channels:
       iendTr = iendTr - n_Perfusion_segs
    if iendTr < len(Cine_segs_list):
       # Add random Cine segmentations files to Cine_segs_training_list to
       # complete the training percentage defined by the user
       Cine_segs_training_list.extend(Cine_segs_list[:iendTr])
       # Remove those segmentations from Cine_segs_list
       del Cine_segs_list[:iendTr]
    else:
       if "PerfusionCT" not in args.channels:
          warnings.warn(f"\nWarning: {args.training_percentage} is smaller " \
                        f"than {current_percentage: .1f}, the percentage " \
                        f"obtained from adding:\none Cine segmentation per "\
                        f"case ({len(Cine_caseid_list)}) and divide it" \
                        f"by the total number of segmentations available " \
                        f"({n_segs})")
       else:
          warnings.warn(f"\nWarning: {args.training_percentage} is smaller " \
                        f"than {current_percentage: .1f}, the percentage " \
                        f"obtained from adding:\none Cine segmentation per "\
                        f"case ({len(Cine_caseid_list)}) and all Perfusion" \
                        f"segmentations ({n_Perfusion_segs}) and divide it" \
                        f"by the total number of segmentations available " \
                        f"({n_segs})")

    # Copy rest of segmentations files in Cine_segs_list to Cine_segs_test_list
    #
    Cine_segs_test_list = copy.copy(Cine_segs_list)

    # Create training and test list for Cine files (imgs)
    #
    Cine_imgs_training_list  = [re.sub("segs", "imgs", f) \
                                for f in Cine_segs_training_list]
    Cine_imgs_test_list  = [re.sub("segs", "imgs", f) \
                            for f in Cine_segs_test_list]
    
    # Renaming and sort lists (housekeeping)
    #
    if "PerfusionCT" not in args.channels:
       # Rename Cine_[segs|imgs]_[training|test]_list as
       # [segs|imgs]_[training|test]_list
       segs_training_list = sorted(copy.copy(Cine_segs_training_list))
       imgs_training_list = sorted(copy.copy(Cine_imgs_training_list))
       segs_test_list     = sorted(copy.copy(Cine_segs_test_list))
       imgs_test_list     = sorted(copy.copy(Cine_imgs_test_list))
    else:
       # Join Cine_[segs|imgs]_[training|test]_list and
       # Perfusion_[segs|imgs]_[training|test]_list into
       # [segs|imgs]_[training|test]_list
       segs_training_list = sorted(Cine_segs_training_list + \
                                   Perfusion_segs_training_list)
       imgs_training_list = sorted(Cine_imgs_training_list + \
                                   Perfusion_imgs_training_list)

       segs_test_list     = sorted(Cine_segs_test_list + \
                                   Perfusion_segs_test_list)
       imgs_test_list     = sorted(Cine_imgs_test_list + \
                                   Perfusion_imgs_test_list)

    # Calculate total number of segmentations files used for training
    n_training_cases = len(segs_training_list)

    # Copy training and test datasets in dataset directory folders with defined
    # nomenclature
    #
    # Training:
    print(f"  Copying {len(imgs_training_list)} nii.gz images for training in" \
          f" imagesTr...")
    copy_database_files_to_nnUNet_raw(args, imagesTr, imgs_training_list, \
                                      cases_dict)
    print(f"  Copying {len(segs_training_list)} nii.gz segmentations for" \
          f" training in labelsTr...")
    copy_database_files_to_nnUNet_raw(args, labelsTr, \
                                      segs_training_list, cases_dict)
    print(f"  Copying {len(imgs_test_list)} nii.gz images for testing in" \
          f" imagesTs...")
    copy_database_files_to_nnUNet_raw(args, imagesTs, imgs_test_list, \
                                      cases_dict)
    print(f"  Copying {len(segs_test_list)} nii.gz segmentations for testing" \
          f" in labelsTs...")
    _ = copy_database_files_to_nnUNet_raw(args, labelsTs, segs_test_list, \
                                          cases_dict)

    # Get "channels" (including all the Cine frames and the Perfusion frame)


    # Create json file using generate_dataset_json from nnunetv2
    #
    print("  Creating nnUNet database json file...")
    create_dataset_json(args, out_dir, n_training_cases)

    # Create splits_final.json file with training/testing splitting
    #
    print("  Creating nnUNet kfold split json file...")
    preprocessed_folder = os.path.join(Path(nnUNet_preprocessed),dataset_name)
    os.makedirs(preprocessed_folder, exist_ok=True)
    split = create_kfold_split(args,labelsTr,date_int)
    save_json(split, os.path.join(preprocessed_folder, 'splits_final.json'), \
              sort_keys=False)

    # Add Dataset ID to pickle file with list of IDs already used
    utls.add_dataset_id_to_file(args.dataset_id)

    # Copy existing cases_dict.[py|pkl] to
    # cases_dict_Dataset{args.dataset_id}_{args.dataset_name}.[py|pkl]
    utls.create_dataset_cases_dict(args.input_folder, args.dataset_id, \
                                   args.dataset_name)


if __name__ == '__main__':
    print(" Getting arguments...")
    args = parse_args()
    print(" Creating Database following nnUNet instructions...")
    create_dataset(args)
    print(" Done!")
