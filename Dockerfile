FROM nvidia/cuda:12.1.0-devel-ubuntu20.04
ENV TZ=US/America/New_York
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update --fix-missing && \
    apt-get install -y libgtk2.0-dev && \
    apt-get install -y wget bzip2 ca-certificates curl git vim tmux g++ gcc build-essential cmake checkinstall gfortran libjpeg8-dev libtiff5-dev pkg-config yasm libavcodec-dev libavformat-dev libswscale-dev libdc1394-22-dev libxine2-dev libv4l-dev qt5-default libgtk2.0-dev libtbb-dev libatlas-base-dev libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libxvidcore-dev libopencore-amrnb-dev libopencore-amrwb-dev x264 v4l-utils libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libhdf5-dev doxygen libflann-dev libboost-all-dev proj-data libproj-dev libyaml-cpp-dev cmake-curses-gui libzmq3-dev freeglut3-dev


RUN apt install -y python3 \
    python3-setuptools \
    python3-pip \
	python3-dev \
    python-tk

ENV NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV CUDA_HOME="/usr/local/cuda"
ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX 8.9"
ENV FORCE_CUDA="1"

SHELL ["/bin/bash", "--login", "-c"]

RUN cd / && wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda.sh && \
    /bin/bash /miniconda.sh -b -p /opt/conda &&\
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh &&\
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc &&\
    /bin/bash -c "source ~/.bashrc" && \
    /opt/conda/bin/conda update -n base -c defaults conda -y &&\
    /opt/conda/bin/conda create -n Any6D python=3.9

ENV PATH=$PATH:/opt/conda/envs/Any6D/bin

RUN conda init bash &&\
    echo "conda activate Any6D" >> ~/.bashrc &&\
    conda activate Any6D &&\
    pip install torchvision==0.19.1+cu121 torchaudio==2.4.1 torch==2.4.1+cu121 --index-url https://download.pytorch.org/whl/cu121
   
# Install Eigen3 3.4.0 under conda environment
RUN conda activate Any6D && conda install conda-forge::eigen=3.4.0
ENV CMAKE_PREFIX_PATH="$CMAKE_PREFIX_PATH:/opt/conda/envs/Any6D/share/eigen3/cmake"

# clone Any6D repository and set working director
RUN git clone https://github.com/bblumberg/Any6D.git /opt/Any6D && \
    cd /opt/Any6D && \
    git submodule update --init --recursive
WORKDIR /opt/Any6D


RUN conda activate Any6D && python -m pip install -r requirements.txt
