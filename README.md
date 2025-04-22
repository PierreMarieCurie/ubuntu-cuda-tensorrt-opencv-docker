# Dev Container for Machine Learning & Computer Vision

This repository provides a **ready-to-use Development Container** setup for **machine learning** and **computer vision** projects, powered by [Dev Containers]((https://github.com/devcontainers)).

It allows you to easily customize and select specific versions of:
- **Ubuntu**
- **CUDA**
- **OpenCV**
- **TensorRT**

Ideal for development, testing, and reproducible environments on **NVIDIA GPUs**.

This tutorial works on both **x86_64 (AMD/Intel)** and **ARM** architectures.

## Prerequisites

Make sure you have the following installed:
1. [Docker](https://docs.docker.com/desktop/)
2. [Visual Studio Code](https://code.visualstudio.com/)

If it’s not installed, you can install it using this [link](https://code.visualstudio.com/download), or via terminal:

``` bash
sudo apt update
sudo apt install code
```
3. **Dev Containers Extension** for VS Code

You can install it from the Extensions panel, or via terminal:
``` bash
code --install-extension ms-vscode-remote.remote-containers
```

## Installation
First, clone the repository
``` bash
git clone TO DO
```
Then, open the project in VS Code
``` bash
code devcontainer-cuda-tensorrt-opencv/
```

## Usage

### Selection of Ubuntu and CUDA versions 

1. Visit the official [NVIDIA GitLab](https://gitlab.com/nvidia/container-images/cuda/blob/master/doc/supported-tags.md) page to choose the appropriate CUDA image for your project.

2. Once you've selected the **Ubuntu** and **CUDA** versions, **ensure that the image includes the** ```cudnn-devel``` **version** for optimal deep learning performance. For instance : *12.8.1-cudnn-runtime-ubuntu24.04* or *12.6.3-cudnn-runtime-ubuntu20.04*.

3. Ensure your **NVIDIA driver** version is compatible with the selected **CUDA** version. Refer to the official [CUDA Compatibility Table](https://docs.nvidia.com/deploy/cuda-compatibility/index.html#binary-compatibility__table-toolkit-driver) to verify compatibility.
If your driver is outdated, you can [download and install the latest version here](https://www.nvidia.com/en-us/drivers/).

4. Set an environment variable with the CUDA image :
```bash
CUDA_IMAGE_VERSION=12.8.1-cudnn-runtime-ubuntu24.04
```

### Selection of TensorRT version

Navigating the NVIDIA documentation can be challenging, especially when you're looking to use a **specific version of TensorRT** rather than the latest one.

For detailed information about features, changes, and compatibility of each version, refer to the official [TensorRT release history](https://github.com/NVIDIA/TensorRT/releases) or for a given version :
- [Latest release 10.9](https://docs.nvidia.com/deeplearning/tensorrt/10.9.0/getting-started/release-notes.html)
- [10.8](https://docs.nvidia.com/deeplearning/tensorrt/10.8.0/getting-started/release-notes.html)
- [10.7 and earlier](https://docs.nvidia.com/deeplearning/tensorrt/archives/index.html)

Each TensorRT release includes a **Support Matrix**, but here’s a alternative, manual way to find which TensorRT versions are available for your specific **Ubuntu** and **CUDA** setup:
1. **Visit the CUDA repository index**: https://developer.download.nvidia.com/compute/cuda/repos
2. **Select your Ubuntu version** (e.g. ```ubuntu2204/```, ```ubuntu2404/```, etc)
3. **Choose your CPU architecture**
- ```x86_64/``` for AMD/Intel CPUs
- ```arm64/``` for ARM-based machines (e.g. Jetson, Apple Silicon)

Not sure? Run this in your terminal:
```bash
uname -m
```
4. **Search for available TensorRT packages**
Use ```CTRL+F``` (or ```Cmd+F``` on macOS) and search for:
```nginx
tensorrt_
```
You'll see available ```.deb``` packages SUCH AS:
- ```tensorrt_8.5.1.7-1+cuda11.8_amd64.deb```. Here **8.5.1.7** is the **TensorRT** version and **11.8** the **CUDA** version.
- ```tensorrt_10.7.0.23-1+cuda12.6_arm64.deb```. Here **10.7.0.23** is the **TensorRT** version and **12.6** the **CUDA** version.

Then choose a file and make sure the CUDA version in the filename matches the one you are using.

5. **Export the version as an environment variable**
(Use the part between ```tensorrt_``` and ```_amd64``` or ```_arm64```)
```bash
TENSORRT_VERSION=10.9.0.34-1+cuda12.8
```
If you don't want to use TensorRT, simply leave the variable empty.
```bash
TENSORRT_VERSION=
```

### Selection of OpenCV version

To pick an **OpenCV** version that fits your needs, go to the official [OpenCV release page](https://opencv.org/releases/). You There, you’ll find the full release history, patch notes for each version and important changes or known issues.

Create an **environment variable** with the selected **OpenCV version** in the format *x.x.x* :

```bash
OPENCV_VERSION=4.11.0
```
f you don't want to use OpenCV, simply leave the variable empty.
```bash
OPENCV_VERSION=
```

## Build and get into the development environment

First, **build the Docker image** using the following command:
```bash
docker build \
--build-arg CUDA_IMAGE_VERSION="$CUDA_IMAGE_VERSION" \
--build-arg TENSORRT_VERSION="$TENSORRT_VERSION" \
--build-arg OPENCV_VERSION="$OPENCV_VERSION" \
-t my-dev-image .                                                   
```

Please note that building the image can take a long time, especially when compiling OpenCV.

If you plan to test multiple combinations of **Ubuntu, CUDA, TensorRT, and OpenCV versions**, a good practice is to tag the image with a version name that suits your needs. For example, you can replace ```my-dev-image``` with ```my-dev-image:xxx```, where ```xxx``` represents a useful version tag for you, such as ```my-dev-image:ubuntu-24.04_cuda-12.8.1_tensorrt-10.9.0.34_opencv-4.11.0```.

To start working in the **development container**:
1. **Open the project folder in VS Code** if it is not already done

You can either select the folder when opening VS Code and go to ```File``` > ```Open Folder```, or on a terminal:
```bash
code devcontainer-cuda-tensorrt-opencv/
```

2. **Customize the workspace mount** (Optional but useful)

In the [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) file, there's a key called ```workspaceMount```. This controls how your local project folder is mounted into the container. This lets you choose the local repository you want to work on within the development environment.

Example setting:
```json
"workspaceMount": "source=/absolute/path/to/your/code,target=/workspace,type=bind"
```

3. **Reopen in Dev Container**

Once the folder is open, you should see a prompt in the bottom-right corner:
👉 *“Reopen in Container”* – click it.

If you don’t see the prompt:
- Press ```F1``` or ```Ctrl+Shift+P``` (Cmd+Shift+P on Mac)
- Run the command:
```yaml
Dev Containers: Reopen in Container
```

4. **Wait for the container to build and start**

VS Code will build the container based on the devcontainer.json config and launch a full-featured development environment inside it

**Feel free to customize** the [Dockerfile](Dockerfile) and [devcontainer setting file](.devcontainer/devcontainer.json) to tailor the development environment to your needs — for example, by adjusting APT packages, modifying OpenCV build arguments in the Dockerfile or adding more VS Code extensions in the devcontainer.json.

## License
This project is licensed under the **MIT License**.
See the [LICENSE](LICENSE) file for more details.

## Acknowledgements

- Thanks to [JulianAssmann/opencv-cuda-docker](https://github.com/JulianAssmann/opencv-cuda-docker/tree/master) on integrating OpenCV with CUDA in Docker. It gave me the initial idea for creating this repo.

## TO DO
- Add a lightweight runtime-only image for deployment
- Maybe add illustrations