#!/bin/bash

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

/bin/bash Miniconda3-py38_4.12.0-Linux-x86_64.sh -b -p $REPOS/miniconda3 && rm Miniconda3-py38_4.12.0-Linux-x86_64.sh

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
export CONDA=$(dirname $(dirname $(which conda)))
source $CONDA/bin/activate plasmidnet
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

source $CONDA/bin/deactivate
source $CONDA/bin/activate STRONG
mamba install -Y -c bioconda checkm-genome megahit bwa kraken2 krona

# update db for krona
cd $CONDA/envs/STRONG/opt/krona && ./updateTaxonomy.sh 

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


# install gtdbbtk database
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/auxillary_files/gtdbtk_v2_data.tar.gz
mkdir gtdb && tar -xzvf gtdbtk_v2_data.tar.gz --strip 1 -C gtdb && rm gtdbtk_v2_data.tar.gz

# install checkm/gtdb database
source $CONDA/bin/activate STRONG
checkm data setRoot $HOME/Databases/checkm
conda env config vars set GTDBTK_DATA_PATH="$HOME/Databases/gtdb";
source $CONDA/bin/deactivate

# -------------------------------------
# ---------- access to hmem03   -------
# -------------------------------------

echo "-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----" > /home/ubuntu/.ssh/id_rsa

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDVBIPv4/upccSRjnlahpwkFIvB8NAyL/Sb8/Ph8HLIIs+Dcp1/okregYVVfiSVkif+1Xsp5/xGVsCv3IYRwL8mlr3C0OwhM7rqlQKxojUDMfCblF/eK6Xpi0npgRhV2EWitgnwWuuNTF3Ig7HsHFo+haW5rsmnptaRRAZM0JHTnMbDfriZXloC+W1uemyl7823Q9IZGIa7toWAUBH+LjADkuNAMqQkJYXWwDoexvTZiMMo25yIPFAZEJowJOhDA3jUoX2bTByxV9fuhUvnIS1Wvgdrdf0RuYiuWGBVPgwnXx6C2bFGmAcalnW17ezN8lfmY1vdFoGfFegHBSxwZI7l+8lXVYLtGeo8hF92D7xY2G1wY0b+jxTVrYhDqxQ5PuYHtNq6KXj2QzwdZym2lj+6sW3BMYbnY06hJPnZgGRCU/OvKv5GkNJ6u1a27VnXoVLIS71EJVj2WIrgZqyDgaShsv3mECplG4h3EDaa4naS0fziwZ983/NPn2gtLO1D920= ubuntu@mmb-dtp"> /home/ubuntu/.ssh/id_rsa



# -------------------------------------
# ---------- add key   ----------------
# -------------------------------------

# Rob
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOmbDQthXhZ78qqiY85QLzCEl44sZhb6jnatlzoKu+CR0M7VZumWP1LNaI62VaPAuvzSACgwE/9IfSD9YbwVkBPVobYSXyeGb3/JuGiZiErF7bkK4JOpu0K19JogXQCn8CKkFvBwqe4ufaDRch3HGX8MylYwSQViceTPJsGVlCIb5X22+JOFB8uO8Ho1QmTnrRiX1Zw1r/Zw/xT5B+pruMHxE2qGbuKSvZ3okpXwQlyDHw/002GruhQRBb7sMNuRt7fKgZf6/jIH7rbFWlJHtCayDBLK2Y891Ae7ANNfXR8AFPLgLQKsswHOG3/VX4aX6btyKNu2SPXwFDnGFDw63h u1673564@MAC20210
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDeEetuKkj9mJ6aK0wRgbPxUWZEVtXiQK856hAVY3fYlK45X6i5wEYT+6/ymIcJ3yDo1Vii3fvYlh46FfNak53Gp8/YOvC/3HQGUR01PfIW1sAdFN6q6EpZ070zkRgp/9E+evTAJkqQ09zueH+Y2o713s4PQMWOnZeDCO5Sksu+5yY5y4Io4hZHPGQYl/M0aG20j44nlWTL1LI1TG4MLMThG2VlZZ8qRnIpvzavLjIXqxgpoYQYEHc9h+KC/ycX5ijahedO/LD2chmk3WoBh8W1SNS4t5dCuT2T9kO0J26uKaWjipm+zoCnO+XJ0AiJGO0TnVh4Z5WMzNbX7D+caQA3b7cG2KwFi8RHk3DxtMaIKhGULEjro0GfoHwbWNdKEyPlpTMlx2NJfUjiJHtWSimHyTHhk7Qg/s7428G+pEYITMFli2jnmRcl7phX9w/gFZHQmEwfkgH065w2p4J65ztDA1rJirNMGO5SZkErJaTQPa1DvudfjglzXhv3HBafcB8= rjames@N120057
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOmbDQthXhZ78qqiY85QLzCEl44sZhb6jnatlzoKu+CR0M7VZumWP1LNaI62VaPAuvzSACgwE/9IfSD9YbwVkBPVobYSXyeGb3/JuGiZiErF7bkK4JOpu0K19JogXQCn8CKkFvBwqe4ufaDRch3HGX8MylYwSQViceTPJsGVlCIb5X22+JOFB8uO8Ho1QmTnrRiX1Zw1r/Zw/xT5B+pruMHxE2qGbuKSvZ3okpXwQlyDHw/002GruhQRBb7sMNuRt7fKgZf6/jIH7rbFWlJHtCayDBLK2Y891Ae7ANNfXR8AFPLgLQKsswHOG3/VX4aX6btyKNu2SPXwFDnGFDw63h u1673564@MAC20210" >> /home/ubuntu/.ssh/authorized_keys

# Chris
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCw7y/8QoRVBZZQYxBl/DYPuKoTnJm0HJeI25HfqmtsELApX+FOtq6n3xFcfpRCu2cbN9SBZkU+FTLiCZ0g6GyfIeTHgQYYKCcB7VdxQT/KjY1Pn6tz0wKOpF1MQpnV5AwvGFe8hHwK4P+uCAOslGfMfbAAcnHVN4h6c6Ta6wS6hdo3BORg816pU8IVxsBAcpxt636YR7KbRLi8xE+hyxcuteCOlbrYhQoNB7yW/f1v2Xo6ucl3mU+6hmo3gQKnT5Cslw1KpP1cOckjgSCUvv0Ab3qEVi1JSNZSU0mAW0Vo9rST1fO9CltuD4cumpJq++3WGHPg5qRw693+xQLUg2ydW+hCBG03zUAkM8S5jxT3p/z1bClaAfrlk/6SMdz0wNUYr7he53Z6Twnu+ZvCT/lFPKZeLG23bC2bxrW3u0VI+IbbX98V+vYkG3tbAfFaLOtu4BimQDBuHGc/l7hZ0OseT/lOJI70JOGc25wSOk0v1z4M7jfF50n6HaczieocsxSdC5lj0MJYdpwK8m6o4PzCMrlXf12UXRhLMeaQbf5P46KP5nZ7qWmZAIEWXPomcQjjwiaODj1QbpDhbmBXdsNiRAMe1wDhysXCMZseofUFICJmxdnQ60LfEWDDFI1tyeGrxs4ZVBPEH8/VEPtCjPXorrYJTTEA6kbtmQzG9KfmWw== u1375038@006575.home" >> /home/ubuntu/.ssh/authorized_keys

