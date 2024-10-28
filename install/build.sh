#!/bin/bash


# 1 Export environment variables from configure.sh
echo "-------------------------------------------------------------------------"
echo ""
echo "Export environment variables from edited configure.sh"
echo ""
echo "-------------------------------------------------------------------------"
. ./configure.sh


# 2. Export and create additional environment variables
echo "-------------------------------------------------------------------------"
echo ""
echo "Export and create additional environment variables"
echo ""
echo "-------------------------------------------------------------------------"
# Miniconda binary files path
export CONDA_BIN=${MINICONDA_PREFIX}/bin
# Miniconda virtual enviroments path
export CONDA_ENVS=${MINICONDA_PREFIX}/envs
# Path where Miniconda installer will be downloaded
export SOFTWARE_PATH=`echo ${MINICONDA_PREFIX} | sed 's![^/]*$!!'`
# Name of Miniconda installer executable file
export CONDA_EXEC=`echo ${MINICONDA_DOWNLOAD} | sed 's|.*/||'`


# 3. Install Miniconda and initialize it
echo "-------------------------------------------------------------------------"
echo ""
echo "Install Miniconda in ${MINICONDA_PREFIX} and"
echo "initialize it"
echo ""
echo "-------------------------------------------------------------------------"
# If Miniconda is installed, there is not need to install it again
if conda --version > /dev/null 2>&1; then
   echo ""
   echo "miniconda3 is already installed in this system"
   echo ""
else
   # Install Miniconda
   mkdir -p ${SOFTWARE_PATH}
   wget -P ${SOFTWARE_PATH} ${MINICONDA_DOWNLOAD}
   bash ${SOFTWARE_PATH}/${CONDA_EXEC} -b -y -p ${MINICONDA_PREFIX}
fi
# Initialize Miniconda
export PATH=${CONDA_BIN}:${PATH}
conda init
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('${CONDA_BIN}/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${MINICONDA_PREFIX}/etc/profile.d/conda.sh" ]; then
        . "${MINICONDA_PREFIX}/etc/profile.d/conda.sh"
    else
        export PATH=${CONDA_BIN}:${PATH}
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# 4. Create virtual environment (with conda) to install all required packages
echo "-------------------------------------------------------------------------"
echo ""
echo "Create virtual environment ${ENV_NAME} with python version ${PYTHON_V}"
echo ""
echo "-------------------------------------------------------------------------"
. ./configure.sh
conda create -y -p ${CONDA_ENVS}/${ENV_NAME} python=${PYTHON_V}


# 5. Activate virtual environment
echo "-------------------------------------------------------------------------"
echo ""
echo "Activate virtual environment ${ENV_NAME}"
echo ""
echo "-------------------------------------------------------------------------"
export PATH=${CONDA_BIN}:${PATH}
conda activate ${ENV_NAME} 


# 6. Confirm both pip and python commands point to virtual environment
#
#    If they don't, install version of pip within virtual environment using
echo "-------------------------------------------------------------------------"
echo ""
echo "Confirm pip, pip3, and python comands point to enviroment ${ENV_NAME}"
echo ""
echo "-------------------------------------------------------------------------"
pip_which=`which -a pip`
pip3_which=`which -a pip3`
python_which=`which -a python`
#
if [[ ${pip_which} == *${ENV_NAME}* ]]; then
  echo "Already using pip from environment"
else
  echo "Installing pip in environment ${ENV_NAME}"
  conda install -y pip
fi
#
if [[ ${pip3_which} == *${ENV_NAME}* ]]; then
  echo "Already using pip3 from environment"
else
  echo "Installing pip3 in environment ${ENV_NAME}"
  conda install -y pip3
fi
#
if [[ ${python_which} == *${ENV_NAME}* ]]; then
  echo "Already using python from environment"
else
  echo "Installing version ${PYTHON_V} of python in environment ${ENV_NAME}"
  conda install -y python=${PYTHON_V}
fi


# 7. If pip, pip3, and python commands still don't point to the version within
# environment, in the next steps use the full path to the virtual environment
# versions
#  - Example of pip and python commands full paths in Klone:
#     ${CONDA_ENVS}/${ENV_NAME}/bin/pip
#     ${CONDA_ENVS}/${ENV_NAME}/bin/pip3
#     ${CONDA_ENVS}/${ENV_NAME}/bin/python


# 8. Install required packages
echo "-------------------------------------------------------------------------"
echo ""
echo "Install requirements (additional libraries with their dependencies)"
echo ""
echo "-------------------------------------------------------------------------"
# Pytorch (version defined by user with environment variable
#          PYTORCH_PIP_INSTALL_CMD)
eval $PYTORCH_PIP_INSTALL_CMD
# nnUNet (install most dependencies)
if [ ! -d ${NNUNET_PREFIX} ]; then
   mkdir -p ${NNUNET_PREFIX}
   cd ${NNUNET_PREFIX}
   git clone https://github.com/MIC-DKFZ/nnUNet.git
   cd nnUNet
   pip install -e .
fi
## OR (if source code is not going to be modified)
#pip install nnunetv2
## Install batchgeneratorv2 (if it does not get installed with nnUNet)
#pip install batchgeneratorv2==0.1.1
# hiddenlayer (to plot network topologies) [OPTIONAL]
pip install --upgrade git+https://github.com/FabianIsensee/hiddenlayer.git
