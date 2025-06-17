# Base image with selected CUDA version (with cuDNN, on Ubuntu 24.04)
ARG CUDA_IMAGE_VERSION=12.8.1-cudnn-devel-ubuntu24.04
FROM nvcr.io/nvidia/cuda:${CUDA_IMAGE_VERSION}

# Ensure all NVIDIA GPU devices and driver capabilities are accessible
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Define the version of TensorRT to install
ARG TENSORRT_VERSION=10.9.0.34-1+cuda12.8

# Set noninteractive mode for apt to avoid prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# Optional HTTPS if HTTPS fails. Proposed by kneave: https://github.com/PierreMarieCurie/ubuntu-cuda-tensorrt-opencv-docker/issues/1
ARG USE_HTTPS=false
RUN if [ "$USE_HTTPS" = "true" ]; then \
      echo "Switching APT sources to HTTPS"; \
      sed -i 's|http:|https:|' /etc/apt/sources.list && \
      sed -i 's|http:|https:|' /etc/apt/sources.list.d/*.list || true; \
    else \
      echo "Using default HTTP APT sources"; \
    fi

# Install build tools, development dependencies, and TensorRT packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        # Core build & system tools
        build-essential \
        autoconf \
        automake \
        libtool \
        pkg-config \
        cmake \
        ca-certificates \
        curl \
        wget \
        git \
        unzip \
        vim \
        gdb \
        valgrind \
        swig \
        yasm \
        # Python and package tools
        python3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        # Image & video processing libraries
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libtiff5-dev \
        libavformat-dev \
        libavcodec-dev \
        libavutil-dev \
        libpostproc-dev \
        libswscale-dev \
        libxine2-dev \
        zlib1g-dev \
        libv4l-dev \
        libxvidcore-dev \
        libx264-dev \
        # GUI and rendering support
        libgtk2.0-dev \
        libglew-dev \
        libsm6 \
        libxext6 \
        libxrender-dev \
        # Optimization libs
        libtbb-dev \
        libeigen3-dev \
        # Protobuf
        libprotobuf-dev \
        protobuf-compiler && \
    \
    # Install specific version of TensorRT and its components (if version is defined)
    #if [ -n "${TENSORRT_VERSION}" ]; then apt-get install -y --no-install-recommends \
    #    libnvinfer-bin=${TENSORRT_VERSION} \
    #    libnvinfer-dev=${TENSORRT_VERSION} \
    #    libnvinfer-dispatch-dev=${TENSORRT_VERSION} \
    #    libnvinfer-dispatch10=${TENSORRT_VERSION} \
    #    libnvinfer-headers-dev=${TENSORRT_VERSION} \
    #    libnvinfer-headers-plugin-dev=${TENSORRT_VERSION} \
    #    libnvinfer-lean-dev=${TENSORRT_VERSION} \
    #    libnvinfer-lean10=${TENSORRT_VERSION} \
    #    libnvinfer-plugin-dev=${TENSORRT_VERSION} \
    #    libnvinfer-plugin10=${TENSORRT_VERSION} \
    #    libnvinfer-samples=${TENSORRT_VERSION} \
    #    libnvinfer-vc-plugin-dev=${TENSORRT_VERSION} \
    #    libnvinfer-vc-plugin10=${TENSORRT_VERSION} \
    #    libnvinfer10=${TENSORRT_VERSION} \
    #    libnvonnxparsers-dev=${TENSORRT_VERSION} \
    #    libnvonnxparsers10=${TENSORRT_VERSION} \
    #    python3-libnvinfer-dev=${TENSORRT_VERSION} \
    #    python3-libnvinfer-dispatch=${TENSORRT_VERSION} \
    #    python3-libnvinfer-lean=${TENSORRT_VERSION} \
    #    python3-libnvinfer=${TENSORRT_VERSION} \
    #    tensorrt-dev=${TENSORRT_VERSION} \
    #    tensorrt-libs=${TENSORRT_VERSION} \
    #    tensorrt=${TENSORRT_VERSION}; \
    #fi && \
    \
    # Clean up to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# OpenCV version to build from source
ARG OPENCV_VERSION=4.11.0
WORKDIR /opt

# Download, build, and install OpenCV with CUDA support
RUN if [ -n "$OPENCV_VERSION" ]; then \
        git clone --branch ${OPENCV_VERSION} --depth 1 https://github.com/opencv/opencv.git && \
        git clone --branch ${OPENCV_VERSION} --depth 1 https://github.com/opencv/opencv_contrib.git && \
        mkdir -p /opt/opencv/build && \
        cd /opt/opencv/build && \
        cmake -D CMAKE_BUILD_TYPE=Release \
            -D CMAKE_INSTALL_PREFIX=/usr/local \
            -D WITH_CUDA=ON \
            -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules \
            -D CUDA_ARCH_BIN="7.0;7.5;8.0;8.6;8.9" \
            -D BUILD_opencv_python3=ON \
            .. && \
        make -j"$(nproc)"&& \
        make install && \
        ldconfig && \
        cd /opt && rm -rf /opt/opencv /opt/opencv_contrib; \
    else \
        echo "Skipping OpenCV build because OPENCV_VERSION is not set."; \
    fi
