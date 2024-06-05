FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# update the package list
RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y git curl wget unzip build-essential 
# Requirement	Version	Required Commands *
# bcftools	1.9-220-gc65ba41	bcftools
# plink2	2.0	plink2
# TreeMix	1.13	treemix
# Python	Python 2.7.16 (at least)	-
# Nextflow	19.04.1.5072	nextflow
# Plan9 port	Latest (as of 10/01/2019 )	mk **
# R	3.4.4	Rscript
# Run install script in the repo https://github.com/9fans/plan9port.git

# Install bcftools and htslib
RUN git clone --recurse-submodules https://github.com/samtools/htslib.git
RUN git clone https://github.com/samtools/bcftools.git
RUN apt-get install -y libgsl-dev \
    libperl-dev \
    liblzma-dev \
    libz-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libssl-dev
WORKDIR /bcftools
RUN make
RUN make install
WORKDIR /

WORKDIR /htslib
RUN make
RUN make install
WORKDIR /

# Install plink and plink2
RUN wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20231211.zip
RUN unzip plink_linux_x86_64_20231211.zip
RUN wget https://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_20240318.zip
RUN unzip plink2_linux_x86_64_20240318.zip
ENV PATH=$PATH:/

# Install treemix
RUN git clone https://bitbucket.org/nygcresearch/treemix.git
RUN apt install -y libboost-all-dev
WORKDIR /treemix
RUN ./configure
RUN make
RUN make install
WORKDIR /

# install the required packages
RUN apt-get install -y python2.7

# Install plan9port
RUN git clone https://github.com/9fans/plan9port.git
RUN apt-get install -y libx11-dev \
    libxt-dev \
    libfontconfig1-dev\
    libxext-dev
WORKDIR /plan9port
RUN ./INSTALL
ENV PLAN9 /plan9port
ENV PATH $PATH:$PLAN9/bin
WORKDIR /

# Install R
RUN apt install -y --no-install-recommends software-properties-common dirmngr
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
RUN add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
RUN apt install -y --no-install-recommends r-base

# Set env variables
ENV BCFTOOLS_PLUGINS=/bcftools/plugins

RUN Rscript -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
