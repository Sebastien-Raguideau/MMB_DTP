#!/bin/bash

echo "install repos/tools needed for workshop"

###### seb ll -h need accomodation ######
sed -i 's/ls -alF/ls -lhaF/g' .bashrc 

export REPOS=$HOME"/repos"
mkdir -p $REPOS
cd $REPOS


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
export PATH=/var/lib/miniconda3/condabin:$PATH
./install_STRONG.sh

# Bandage install
cd $HOME/repos/
wget https://github.com/rrwick/Bandage/releases/download/v0.8.1/Bandage_Ubuntu_dynamic_v0_8_1.zip
mkdir Bandage && unzip Bandage_Ubuntu_dynamic_v0_8_1.zip -d Bandage && mv Bandage_Ubuntu_dynamic_v0_8_1.zip Bandage

# trait inference
mamba env create -f $APP_DIR/conda_env_Trait_inference.yaml

# Plasmidnet
mamba create --name plasmidnet python=3.8 -y
source /var/lib/miniconda3/bin/activate plasmidnet
pip install -r $HOME/repos/PlasmidNet/requirements.txt

# -------------------------------------
# -----------Rob Tuto --------------
# -------------------------------------
# --- guppy ---
cd $HOME/repos
wget https://europe.oxfordnanoportal.com/software/analysis/ont-guppy-cpu_5.0.16_linux64.tar.gz
tar -xvzf ont-guppy-cpu_5.0.16_linux64.tar.gz && mv ont-guppy-cpu_5.0.16_linux64.tar.gz ont-guppy-cpu/

# --- everything else ---
mamba env create -f $APP_DIR/conda_env_LongReads.yaml


# --- Pavian ---
#source /var/lib/miniconda3/bin/activate LongReads
#R -e 'if (!require(remotes)) { install.packages("remotes",repos="https://cran.irsn.fr") }
#remotes::install_github("fbreitwieser/pavian")'

# -------------------------------------
# -----------Seb Tuto --------------
# -------------------------------------

source /var/lib/miniconda3/bin/deactivate
source /var/lib/miniconda3/bin/activate STRONG
mamba install -c bioconda checkm-genome megahit bwa

# # add checkm database
# mkdir -p /mnt/mydatalocal/checkm
# cd /mnt/mydatalocal/checkm
# wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz && tar -xvzf checkm_data_2015_01_16.tar.gz
# checkm data setRoot /mnt/mydatalocal/checkm

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
echo -e "\n\n #------ Ebame -------">>$HOME/.bashrc
echo -e 'export PATH=~/repos/Ebame/scripts:$PATH'>>$HOME/.bashrc

# add strainberry
echo -e "\n\n #------ strainberry -------">>$HOME/.bashrc 
echo -e 'export PATH=/home/ubuntu/repos/strainberry:$PATH'>>$HOME/.bashrc

# add strainberry
echo -e "\n\n #------ plasmidnet -------">>$HOME/.bashrc 
echo -e 'export PATH=/home/ubuntu/repos/PlasmidNet/bin:$PATH'>>$HOME/.bashrc

# --------------------------------------------
# ------------ fix rigths --------------------
# --------------------------------------------

# mamba crash as a user and this fix it
chown -R 1000:1000 /var/lib/miniconda3

# fix HOME ownership, so that user can create stuffs
chown -R 1000:1000 $HOME/*
# }&>"$APP_DIR/vm_install.log"

