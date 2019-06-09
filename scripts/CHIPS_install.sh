#!/bin/bash

# Written by Rick Medemblik

echo "
This script installs the tools needed to run CHIPS a combination of tools to find Copy Number Variation.

Installs:
 - Miniconda version 4.6.3*
 - Perl version 5.26.2.1*
 - CNVnator version 0.3.3
 - Root version 6.14/06
 - Breakdancer version 1.4.5
 - Manta version 1.5.0
 - Delly version 0.7.9
 - Sambamba version 0.6.8
 - Survivor version 1.0.5
 - Bcftools version 1.9
 - Samtools version 1.9

* Version at the time of writing this script."
echo

echo -n "Do you want to continue (Y/N) "
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
    #Installation direcotory name
    folder_name=CHIPS

    #System packages
    apt-get update && apt-get install -y curl wget

    #Make install location
    echo "Make installation folder."
    mkdir -p $folder_name
    mkdir -p $folder_name/resources

    #Make temporary folder
    echo "Make temporary folder."
    mkdir -p $folder_name/tmp

    #Install miniconda
    echo "Install miniconda3."
    cd $folder_name/tmp
    curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -p $OLDPWD/$folder_name/resources/miniconda3 -b
    cd ..
    export PATH=$(pwd)/resources/miniconda3/bin:${PATH}

    #Install the necessary packages
    echo "Install the necassary packages with apt-get."
    apt-get install -y git dpkg-dev cmake g++ gcc binutils libx11-dev libxpm-dev libxft-dev libxext-dev libncurses5-dev libncursesw5-dev bzip2 make zlib1g-dev 

    #Install root
    echo "Install the root package from CERN."
    cd tmp
    wget https://root.cern.ch/download/root_v6.15.02.source.tar.gz
    tar -zxf root_v6.15.02.source.tar.gz -C $OLDPWD/resources/
    cd ..
    mkdir resources/builddir
    cd resources/builddir
    cd ..
    tmp_path=$(pwd)
    cd builddir
    cmake $tmp_path/root-6.15.02
    make -j8

    #Install CNVnator
    echo "Install CNVnator."
    ROOTSYS=$(pwd)
    export ROOTSYS

    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${ROOTSYS}/lib
    export LD_LIBRARY_PATH

    cd ../..
    cd tmp
    wget https://github.com/abyzovlab/CNVnator/releases/download/v0.3.3/CNVnator_v0.3.3.zip
    cd ..
    unzip -o $OLDPWD/CNVnator_v0.3.3.zip -d $(pwd)/resources
    cd resources/CNVnator_v0.3.3/src/samtools
    make
    cd ..
    make

    #Install Manta
    echo "Install Manta."
    cd ../../..
    cd tmp
    wget https://github.com/Illumina/manta/releases/download/v1.5.0/manta-1.5.0.centos6_x86_64.tar.bz2
    tar -xjf manta-1.5.0.centos6_x86_64.tar.bz2
    mv $(pwd)/manta-1.5.0.centos6_x86_64 $OLDPWD/resources/manta-1.5.0

    #Install programs with conda
    echo "Install Breakdancer, Delly, Survivor, Bcftools and Sambamba with conda."
    conda config --add channels conda-forge
    conda config --add channels bioconda
    conda config --add channels defaults
    conda install -c bioconda breakdancer=1.4.5 -y
    conda install -c bioconda delly=0.8.1 -y
    conda install -c bioconda survivor=1.0.5 -y
    conda install -c bioconda bcftools=1.9 -y
    conda install -c bioconda sambamba=0.6.8 -y
    conda install -c bioconda samtools=1.9 -y
    conda install -c conda-forge perl -y

    #Install Descriptive.pm
    #cpan install Statistics::Descriptive.pm
    apt-get install libstatistics-descriptive-perl

    #Install python packages
    pip install tablib
    pip install pandas

    cd ..

    echo "Make the configuration file."
    echo "#Automatically generated configuration script.
    #Author: Rick Medemblik

    ####CHANGE THE TWO PATHS UNDER THIS LINE BEFORE RUNNING THE SCRIPT!!!####

    #Location to store the result files
    output_dir=/location/to/store/the/output

    #Location of the reference genome.
    reference=/locaton/of/the/reference/potato_dm_v404_all_pm_un.fasta

    ####DO NOT CHANGE ANYTHING BELOW THIS LINE!!!####

    #Location of python 2
    python2=$(which python2)

    #Location of python 3
    python3=$(which python3)

    #Location of the configManta.py script
    configManta=$(pwd)/resources/manta-1.5.0/bin/configManta.py

    #Location of Delly
    delly=$(pwd)/resources/miniconda3/bin/delly

    #Location of sambamba
    sambamba=$(pwd)/resources/miniconda3/bin/sambamba

    #Location of bcftools
    bcftools=$(pwd)/resources/miniconda3/bin/bcftools

    #Rootsys path for cnvnator
    rootsys=$(pwd)/resources/builddir

    #Binsize for cnvnator
    binsize=250

    #Location of cnvnator script
    cnvnator=$(pwd)/resources/CNVnator_v0.3.3/src/cnvnator

    #Location of the cnvnator2VCF.pl script
    cnvnator2VCF=$(pwd)/resources/CNVnator_v0.3.3/cnvnator2VCF.pl

    #Location of the bam2cfg.pl script
    bam2cfg=$(pwd)/resources/miniconda3/bin/bam2cfg.pl

    #Location of the breakdancer-max script
    breakdancer_max=$(pwd)/resources/miniconda3/bin/breakdancer-max

    #Location of the Breakdancer2VCF.py script
    breakdancer2VCF=$(pwd)/resources/Breakdancer2VCF.py

    #Location of the survivor script
    survivor=$(pwd)/resources/miniconda3/bin/SURVIVOR" > config.conf
    sed -i -e 's/[ \t]*//' config.conf

    wget https://www.dropbox.com/s/tm1uz4s8yz2v9xi/CHIPS.sh?dl=0 -O CHIPS.sh
    wget https://www.dropbox.com/s/i1x0zbmdnjqj3m8/CHIPS.py?dl=0 -O CHIPS.py
    wget https://www.dropbox.com/s/g2lzquozjevqaaz/Breakdancer2VCF.py?dl=0 -O $(pwd)/resources/Breakdancer2VCF.py

    echo "Removing the temporary folder"
    rm -rf $(pwd)/$folder_name/tmp

    #Make the current user the owner of the installation directory
    cd ..
    chown -R $USER $folder_name

    echo
    echo "######\nInstallation is finished.\n\nBefore using the runner script change the output_dir and reference path in the config.conf file.\nTo use the runner script run python3 CHIPS.py -list 'path/to/csv/list/file'######"
else
    exit
fi
