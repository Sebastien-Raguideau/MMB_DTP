#!/bin/bash

###### seb ll -h need accomodation ######

export REPOS=$HOME"/repos"
mkdir -p $REPOS
cd $REPOS

MMB_DTP=$HOME/repos/MMB_DTP
# ------------------------------
# ----- get all repos ---------- 
# ------------------------------

mkdir -p $HOME/repos
cd $HOME/repos

git clone https://github.com/Sebastien-Raguideau/MMB_DTP.git
git clone --recurse-submodules https://github.com/chrisquince/STRONG.git
git clone https://github.com/chrisquince/genephene.git
git clone https://github.com/rvicedomini/strainberry.git
git clone https://github.com/kkpsiren/PlasmidNet.git


# ------------------------------
# ----- install conda ---------- 
# ------------------------------
cd $HOME/repos
wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.12.0-Linux-x86_64.sh

/bin/bash Miniconda3-py38_4.12.0-Linux-x86_64.sh -b -p $REPOS/miniconda3
/home/ubuntu/repos/miniconda3/condabin/conda init
/home/ubuntu/repos/miniconda3/condabin/conda config --set auto_activate_base false

__conda_setup="$('/home/ubuntu/repos/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/ubuntu/repos/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/ubuntu/repos/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/ubuntu/repos/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# ------------------------------
# ----- install mamba ---------- 
# ------------------------------


# ------------------------------
# ----- all sudo installs ------
# ------------------------------

sudo apt-get update
# STRONG compilation
sudo apt-get -y install libbz2-dev libreadline-dev cmake g++ zlib1g zlib1g-dev
# bandage and utils
sudo apt-get -y install qt5-default gzip unzip feh evince

# ------------------------------
# ----- Chris tuto -------------
# ------------------------------
cd $HOME/repos/STRONG

# conda/mamba is not in the path for root, so I need to add it
./install_STRONG.sh

# trait inference
mamba env create -f $MMB_DTP/conda_env_Trait_inference.yaml

# Plasmidnet
mamba create --name plasmidnet python=3.8 -y
export CONDA=$(dirname $(which conda))
source $CONDA/activate plasmidnet
pip install -r $HOME/repos/PlasmidNet/requirements.txt

# -------------------------------------
# -----------Rob Tuto --------------
# -------------------------------------
# --- guppy ---
cd $HOME/repos
wget https://europe.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_5.0.16_linux64.tar.gz
tar -xvzf ont-guppy-cpu_5.0.16_linux64.tar.gz && mv ont-guppy-cpu_5.0.16_linux64.tar.gz ont-guppy-cpu/

# --- everything else ---
mamba env create -f $MMB_DTP/conda_env_LongReads.yaml


# --- Pavian ---
#source /var/lib/miniconda3/bin/activate LongReads
#R -e 'if (!require(remotes)) { install.packages("remotes",repos="https://cran.irsn.fr") }
#remotes::install_github("fbreitwieser/pavian")'

# -------------------------------------
# -----------Seb Tuto --------------
# -------------------------------------

source $CONDA/deactivate
source $CONDA/activate STRONG
mamba install -c bioconda checkm-genome megahit bwa

# add R environement
mamba env create -f $MMB_DTP/R.yaml

# -------------------------------------
# ---------- modify .bashrc -----------
# -------------------------------------

# add -h to ll 
sed -i "s/alias ll='ls -alF'/alias ll='ls -alhF'/g" $HOME/.bashrc 

# add multitude of export to .bashrc
echo -e "\n\n#--------------------------------------\n#------ export path to repos/db -------\n#--------------------------------------">>$HOME/.bashrc

# ---------- add things in path --------------
# guppy install
echo -e "\n\n #------ guppy path -------">>$HOME/.bashrc 
echo -e 'export PATH=~/repos/ont-guppy-cpu/bin:$PATH'>>$HOME/.bashrc

# STRONG install
echo -e "\n\n #------ STRONG path -------">>$HOME/.bashrc 
echo -e 'export PATH=~/repos/STRONG/bin:$PATH '>>$HOME/.bashrc

# Bandage install
echo -e "\n\n #------ guppy path -------">>$HOME/.bashrc 
echo -e 'export PATH=~/repos/Bandage:$PATH'>>$HOME/.bashrc

#  add repos scripts 
echo -e "\n\n #------ MMB_DTP -------">>$HOME/.bashrc
echo -e 'export PATH=~/repos/MMB_DTP/scripts:$PATH'>>$HOME/.bashrc

# add strainberry
echo -e "\n\n #------ strainberry -------">>$HOME/.bashrc 
echo -e 'export PATH=/home/ubuntu/repos/strainberry:$PATH'>>$HOME/.bashrc

# add strainberry
echo -e "\n\n #------ plasmidnet -------">>$HOME/.bashrc 
echo -e 'export PATH=/home/ubuntu/repos/PlasmidNet/bin:$PATH'>>$HOME/.bashrc


# -------------------------------------
# ---------- add conda  ---------------
# -------------------------------------

$CONDA/../condabin/conda init
/home/ubuntu/repos/miniconda3/condabin/conda config --set auto_activate_base false


###### Install Bandage ######
cd $HOME/repos
wget https://github.com/rrwick/Bandage/releases/download/v0.9.0/Bandage_Ubuntu-x86-64_v0.9.0_AppImage.zip  -P Bandage && unzip Bandage/Bandage_Ubuntu-x86-64_v0.9.0_AppImage.zip -d Bandage && mv Bandage/Bandage_Ubuntu-x86-64_v0.9.0.AppImage Bandage/Bandage


###### add silly jpg ######
cd
wget https://raw.githubusercontent.com/Sebastien-Raguideau/strain_resolution_practical/main/Figures/image_you_want_to_copy.jpg
wget https://raw.githubusercontent.com/Sebastien-Raguideau/strain_resolution_practical/main/Figures/image_you_want_to_display.jpg


# -------------------------------------
# ---------- download datasets  -------
# -------------------------------------
mkdir $HOME/Data
ssh-keyscan 137.205.71.34 >> ~/.ssh/known_hosts # add to known host to suppress rsync question
rsync -a --progress -L "sebr@137.205.71.34:/home/sebr/seb/Project/Tuto/MMB_DTP/datasets/*" "$HOME/Data/"
cd $HOME/Data

tar xzvf AD16S.tar.gz && mv data AD_16S && rm AD16S.tar.gz && mv metadata.tsv AD_16S&
tar xzvf HIFI_data.tar.gz && rm HIFI_data.tar.gz &
tar xzvf Quince_datasets.tar.gz && mv Quince_datasets/* . && rm Quince_datasets.tar.gz && rm -r Quince_datasets&
tar xzvf STRONG_prerun.tar.gz && rm STRONG_prerun.tar.gz&


# -------------------------------------
# ---------- download databases -------
# -------------------------------------
mkdir -p $HOME/Databases
cd $HOME/Databases


wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08gb_20220926.tar.gz
wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz

# rsync databases
# dada2 
rsync -a --progress -L "sebr@137.205.71.34:/mnt/gpfs/seb/Database/silva/silva_dada2_138" "$HOME/Databases/"
# cogs
rsync -a --progress -L "sebr@137.205.71.34:/mnt/gpfs/seb/Database/rpsblast_cog_db/Cog_LE.tar.gz" "$HOME/Databases/"

# untar
mkdir Cog && tar xzvf Cog_LE.tar.gz -C Cog && rm Cog_LE.tar.gz
mkdir checkm && tar xzvf checkm_data_2015_01_16.tar.gz -C checkm && rm checkm_data_2015_01_16.tar.gz
mkdir kraken && tar xzvf k2_standard_08gb_20220926.tar.gz -C kraken && rm k2_standard_08gb_20220926.tar.gz
rm *.log


# install checkm database
source $CONDA/activate STRONG
checkm data setRoot $HOME/Databases/checkm
source $CONDA/deactivate

# install gtdbbtk database
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_v2_data.tar.gz
mkdir gtdb && tar gtdbtk_v2_data.tar.gz -C gtdb && rm gtdbtk_v2_data.tar.gz
