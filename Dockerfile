FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

# Install base utilities
RUN apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git curl wget unzip build-essential 

# Install planport9
WORKDIR /
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

# Install miniconda
ENV CONDA_DIR /opt/conda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
RUN /bin/bash ~/miniconda.sh -b -f -p /opt/conda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH

# Initialize Conda and activate environment
RUN echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate vcf2treemix" >> ~/.bashrc

WORKDIR /app
COPY environment.yml ./environment.yml
RUN conda env create --file environment.yml

ENTRYPOINT ["bash", "-l"]