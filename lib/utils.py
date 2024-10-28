import os
import shutil
import sys
from pathlib import Path
import re
import pickle
import warnings

from nnunetv2.paths import nnUNet_raw


def check_dataset_id_existence(dataset_id: int):
   datasets_ids_flnm = os.path.join(Path(nnUNet_raw.replace('"', "")),\
                                    "datasets_ids.pkl")

   try:
       with open(datasets_ids_flnm, 'rb') as f:
           datasets_ids = pickle.load(f)
       if dataset_id in datasets_ids:
         print(f"Dataset(s) used: {datasets_ids}")
         raise ValueError(f"Dataset {dataset_id} has already been used")
   except FileNotFoundError:
       datasets_ids = []
       with open(datasets_ids_flnm, 'wb') as f:
           pickle.dump(datasets_ids, f, protocol=pickle.HIGHEST_PROTOCOL)
       warnings.warn(f"\nWarning: {datasets_ids_flnm} did not exist.\n" \
                      "Empty list created and saved in pickle file")

   return


def delete_dataset_id_from_datasets_ids(dataset_id: int):
   datasets_ids_flnm = os.path.join(Path(nnUNet_raw.replace('"', "")),\
                                    "datasets_ids.pkl")

   try:
       with open(datasets_ids_flnm, 'rb') as f:
           datasets_ids = pickle.load(f)
       if dataset_id in datasets_ids:
         datasets_ids.remove(dataset_id)
         with open(datasets_ids_flnm, 'wb') as f:
             pickle.dump(datasets_ids, f, protocol=pickle.HIGHEST_PROTOCOL)
         print(f" Dataset {dataset_id} removed from:\n {datasets_ids_flnm}")
       else:
         raise ValueError(f"Dataset {dataset_id} does not exist in:\n"
                          f"{datasets_ids_flnm}")
   except FileNotFoundError:
       datasets_ids = []
       with open(datasets_ids_flnm, 'wb') as f:
           pickle.dump(datasets_ids, f, protocol=pickle.HIGHEST_PROTOCOL)
       warnings.warn(f"\nWarning: {datasets_ids_flnm} did not exist.\n" \
                      "Empty list created and saved in pickle file")

   return


def add_dataset_id_to_file(dataset_id: int):
   #datasets_ids_flnm = os.path.join(Path(nnUNet_raw.replace('"', "")),\
   #                                 "datasets_ids.pkl")
   datasets_ids_flnm = os.path.join(Path(nnUNet_raw),"datasets_ids.pkl")

   try:
       with open(datasets_ids_flnm, 'rb') as f:
           datasets_ids = pickle.load(f)
       datasets_ids.append(dataset_id)
       datasets_ids.sort()
       with open(datasets_ids_flnm, 'wb') as f:
           pickle.dump(datasets_ids, f, protocol=pickle.HIGHEST_PROTOCOL)
   except FileNotFoundError:
       print(f"Error: {datasets_ids_flnm} file does not exist")

   return


def get_cases_dict(input_folder: str) -> dict:
   cases_dict_pkl_flnm = os.path.join(input_folder,"cases_dict.pkl")
   cases_dict_py_flnm = os.path.join(input_folder,"cases_dict.py")

   try:
       with open(cases_dict_pkl_flnm, 'rb') as f:
           cases_dict = pickle.load(f)
   except FileNotFoundError:
       try:
          # Add the directory containing cases_dict.py file to system path
          sys.path.append(os.path.abspath(input_folder))
          # Import cases_dict dictionary from the cases_dict_py_flnm file
          from cases_dict import cases_dict
          with open(cases_dict_pkl_flnm, 'wb') as f:
              pickle.dump(cases_dict, f, protocol=pickle.HIGHEST_PROTOCOL)
          warnings.warn(f"\nWarning: {cases_dict_pkl_flnm} did not exist.\n" \
                        f"cases_dict dictionary has been copied from file:\n" \
                        f"{cases_dict_py_flnm}")
       except FileNotFoundError:   
          print(f"Error: Files do not exist:\n{cases_dict_pkl_flnm}\n" \
                f"{cases_dict_py_flnm}")
          sys.exit()

   return cases_dict


def create_dataset_cases_dict(input_folder: str, dataset_id: int, dataset_name: str):
   # Check cases_dict.pkl file exist
   cases_dict_pkl_flnm = os.path.join(input_folder, f"cases_dict.pkl")
   assert os.path.exists(cases_dict_pkl_flnm), \
          f"Error: {cases_dict_pkl_flnm} does not exist"
   #
   # Check cases_dict.py file exist
   cases_dict_py_flnm = os.path.join(input_folder, f"cases_dict.py")
   assert os.path.exists(cases_dict_py_flnm), \
          f"Error: {cases_dict_py_flnm} does not exist"

   # Define file name to save cases_dict used in dataset in .pkl and .py files
   #
   # Get Dataset directory inside of nnUNet_raw folder (dataset_dir)
   dataset_nm = f"Dataset{dataset_id:03}_{dataset_name}"
   dataset_dir = os.path.join(Path(nnUNet_raw), dataset_nm)
   # Define absolute path to save cases_dict.[pkl|py] files in dataset folder
   dataset_cases_dict_pkl_flnm = cases_dict_pkl_flnm.replace(input_folder, \
                                                             dataset_dir)
   dataset_cases_dict_py_flnm = cases_dict_py_flnm.replace(input_folder, \
                                                           dataset_dir)

   # Copy cases_dict_pkl_flnm (cases_dict.pkl) in dataset_cases_dict_pkl_flnm
   shutil.copy(cases_dict_pkl_flnm, dataset_cases_dict_pkl_flnm)
   #
   # Copy cases_dict_py_flnm (cases_dict.py) in dataset_cases_dict_py_flnm
   shutil.copy(cases_dict_py_flnm, dataset_cases_dict_py_flnm)

   return


def extract_caseid_from_path(pth: str, pttrn: str) -> str:
   # Find pttrn (default: 5 consecutive numbers) in string pth
   tmp = re.findall(pttrn, pth)

   # If pttrn has been found more than once in pth string
   if len(tmp) > 1:
       raise ValueError(f"More than one possible caseid matches found in:\n{pth}\nmatches: {tmp}")
   # If only one pttrn is found in pth string
   elif len(tmp) == 1:
       return tmp[0]
   # If pttrn is not found in pth string
   else:
       raise ValueError(f"No matches for the defined caseid pattern found in:\n{pth}")

   return



