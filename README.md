# Windows CUDA container
Building docker image for building CUDA libraries on Windows

## Why do we need this?
Sometimes we need CUDA to be installed on the hosted machines provided by some CI services, like Appveyor, Azure Pipelines and so on. However, it takes very long time to do that before every build, especially when you have very low concurrency in these services.

## How to use this?
If you are familiar with Docker, it is really easy to start. Just type in the following commands to have a try.
```powershell
docker pull peterjc123/windows-cuda-container:v1.0.0
docker run -it peterjc123/windows-cuda-container cmd

:: Here you can do anything you want
echo Hello World!
```

## Software installed
They are listed below.
```
7-Zip
cURL
Git
CMake
Visual Studio 2017 (with 14.11 C++ toolchain)
CUDA 9.2 + cuDNN 7.2.1
CUDA 10.1 + cuDNN 7.6.4
```

## Limitations
1. The image is large. So it will take a long time to pull the image.
2. The generated CUDA executables cannot run in the container because it is not supported.
