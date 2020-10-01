# escape=`

ARG version=1809
FROM mcr.microsoft.com/windows:$version

ENV chocolateyUseWindowsCompression false

SHELL ["cmd", "/S", "/C"]

RUN powershell -Command `
    Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco feature disable --name showDownloadProgress; `
    choco feature enable --name allowGlobalConfirmation

RUN choco install curl 7zip git cmake awscli && `
    setx /M PATH "%PATH%;C:\Program Files\7-Zip;C:\Program Files\Git\bin;C:\Program Files\CMake\bin;C:\Program Files\Amazon\AWSCLIV2"

RUN (setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1 && `
     curl -kL https://aka.ms/vs/16/release/vs_buildtools.exe --output %TEMP%\vs_buildtools.exe && `
     %TEMP%\vs_buildtools.exe --quiet --norestart --wait --nocache `
                               --add Microsoft.VisualStudio.Workload.VCTools `
                               --add Microsoft.Component.MSBuild `
                               --add Microsoft.VisualStudio.Component.Roslyn.Compiler `
                               --add Microsoft.VisualStudio.Component.VC.CoreBuildTools `
                               --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest `
                               --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64) || if "%errorlevel%" == "3010" exit 0

RUN curl -kL https://ossci-windows.s3.amazonaws.com/cuda_10.1.243_426.00_win10.exe --output "%TEMP%\cuda_10.1.243_426.00_win10.exe" && `
    curl -kL https://ossci-windows.s3.amazonaws.com/cudnn-10.1-windows10-x64-v7.6.4.38.zip --output "%TEMP%\cudnn-10.1-windows10-x64-v7.6.4.38.zip" && `
    7z x %TEMP%\cuda_10.1.243_426.00_win10.exe -o"%TEMP%\cuda101" && `
    del %TEMP%\cuda_10.1.243_426.00_win10.exe && `
    pushd %TEMP%\cuda101 && `
    start /wait setup.exe -s nvcc_10.1 cuobjdump_10.1 nvprune_10.1 cupti_10.1 cublas_10.1 cublas_dev_10.1 cudart_10.1 cufft_10.1 cufft_dev_10.1 curand_10.1 curand_dev_10.1 cusolver_10.1 cusolver_dev_10.1 cusparse_10.1 cusparse_dev_10.1 nvgraph_10.1 nvgraph_dev_10.1 npp_10.1 npp_dev_10.1 nvrtc_10.1 nvrtc_dev_10.1 nvml_dev_10.1 && `
    xcopy /Y "%TEMP%\cuda101\CUDAVisualStudioIntegration\extras\visual_studio_integration\MSBuildExtensions\*.*" "%PROGRAMFILES(X86)%\Microsoft Visual Studio\2019\BuildTools\MSBuild\Microsoft\VC\v160\BuildCustomizations" && `
    popd && `
    rd /s /q %TEMP%\cuda101 && `
    7z x %TEMP%\cudnn-10.1-windows10-x64-v7.6.4.38.zip -o"%TEMP%\cudnn101" && `
    del %TEMP%\cudnn-10.1-windows10-x64-v7.6.4.38.zip && `
    xcopy /Y "%TEMP%\cudnn101\cuda\bin\*.*" "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1\bin" && `
    xcopy /Y "%TEMP%\cudnn101\cuda\lib\x64\*.*" "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1\lib\x64" && `
    xcopy /Y "%TEMP%\cudnn101\cuda\include\*.*" "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1\include" && `
    setx /M PATH "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1\bin;%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1\libnvvp;%PATH%" && `
    setx /M CUDA_PATH "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1" && `
    setx /M CUDA_PATH_V10_1 "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v10.1" && `
    rd /s /q %TEMP%\cudnn101 && `
    curl -kL https://www.dropbox.com/s/9mcolalfdj4n979/NvToolsExt.7z?dl=1 --output "%TEMP%\NvToolsExt.7z" && `
    7z x %TEMP%\NvToolsExt.7z -o"%TEMP%\NvToolsExt" && `
    del %TEMP%\NvToolsExt.7z && `
    mkdir "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\bin\x64" && `
    mkdir "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\include" && `
    mkdir "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\lib\x64" && `
    xcopy /Y "%TEMP%\NvToolsExt\bin\x64\*.*" "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\bin\x64" && `
    xcopy /Y "%TEMP%\NvToolsExt\include\*.*" "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\include" && `
    xcopy /Y "%TEMP%\NvToolsExt\lib\x64\*.*" "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\lib\x64" && `
    rd /s /q %TEMP%\NvToolsExt && `
    setx /M NVTOOLSEXT_PATH "%ProgramFiles%\NVIDIA Corporation\NvToolsExt"
