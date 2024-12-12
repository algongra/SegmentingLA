#!/bin/bash

################################################################################
################################# USER DEFINED #################################
################################################################################
# Miniconda installer
#  - Search installer compatible with your platform at:
#    https://docs.anaconda.com/free/miniconda/
export MINICONDA_DOWNLOAD="https://repo.anaconda.com/miniconda/\
Miniconda3-latest-Linux-x86_64.sh"
# Miniconda installation path
export MINICONDA_PREFIX="/gscratch/mambrino/algongra/Software/miniconda3"
# nnUNet installation path
# (nnUNet will be installed in a directory named nnUNet inside the defined path)
export NNUNET_PREFIX="/gscratch/mambrino/algongra/Software"
# Pytorch GPU compatible with OS and system resources
export PYTORCH_PIP_INSTALL_CMD="pip3 install torch torchvision torchaudio \
--index-url https://download.pytorch.org/whl/cu124"
# Virtual environment name (created automatically with conda)
export ENV_NAME="nnUNetGPU"
# Python version used in virtual environment
export PYTHON_V="3.11.4"
################################################################################
