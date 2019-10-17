# escape=`

ARG version=1803
FROM mcr.microsoft.com/windows/servercore:$version

ENV chocolateyUseWindowsCompression false

SHELL ["cmd", "/S", "/C"]

RUN powershell -Command `
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')); `
    choco feature disable --name showDownloadProgress; `
    choco feature enable --name allowGlobalConfirmation

RUN choco install curl 7zip git cmake && `
    setx /M PATH "%PATH%;C:\Program Files\Git\bin;C:\Program Files\CMake\bin"

RUN (setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1 && `
     setx /M VSDEVCMD_ARGS "-vcvars_ver=14.11" && `
     curl -kL https://aka.ms/vs/15/release/vs_buildtools.exe --output %TEMP%\vs_buildtools.exe && `
     %TEMP%\vs_buildtools.exe --quiet --norestart --wait --nocache `
                               --installPath "C:\BuildTools"  `
                               --add Microsoft.VisualStudio.Workload.VCTools `
                               --add Microsoft.VisualStudio.Component.VC.Tools.14.11 `
                               --add Microsoft.Component.MSBuild `
                               --add Microsoft.VisualStudio.Component.Roslyn.Compiler `
                               --add Microsoft.VisualStudio.Component.TextTemplating `
                               --add Microsoft.VisualStudio.Component.VC.CoreIde `
                               --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest `
                               --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core `
                               --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
                               --add Microsoft.VisualStudio.Component.VC.Tools.14.11 `
                               --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Win81) || if "%errorlevel%" == "3010" exit 0

RUN curl -kL https://ossci-windows.s3.amazonaws.com/win2016/cuda_9.2.148_win10.exe --output "%TEMP%\cuda_9.2.148_win10.exe" && `
    curl -kL https://ossci-windows.s3.amazonaws.com/win2016/cudnn-9.2-windows10-x64-v7.2.1.38.zip --output "%TEMP%\cudnn-9.2-windows10-x64-v7.2.1.38.zip" && `
    7z x %TEMP%\cuda_9.2.148_win10.exe -o"%TEMP%\cuda92" && `
    del %TEMP%\cuda_9.2.148_win10.exe && `
    pushd %TEMP%\cuda92 && `
    start /wait setup.exe -s nvcc_9.2 cuobjdump_9.2 nvprune_9.2 cupti_9.2 cublas_9.2 cublas_dev_9.2 cudart_9.2 cufft_9.2 cufft_dev_9.2 curand_9.2 curand_dev_9.2 cusolver_9.2 cusolver_dev_9.2 cusparse_9.2 cusparse_dev_9.2 nvgraph_9.2 nvgraph_dev_9.2 npp_9.2 npp_dev_9.2 nvrtc_9.2 nvrtc_dev_9.2 nvml_dev_9.2 && `
    xcopy /Y "%TEMP%\cuda92\CUDAVisualStudioIntegration\extras\visual_studio_integration\MSBuildExtensions\*.*" "C:\BuildTools\Common7\IDE\VC\VCTargets\BuildCustomizations" && `
    popd && `
    rd /s /q %TEMP%\cuda92 && `
    7z x %TEMP%\cudnn-9.2-windows10-x64-v7.2.1.38.zip -o"%TEMP%\cudnn92" && `
    del %TEMP%\cudnn-9.2-windows10-x64-v7.2.1.38.zip && `
    xcopy /Y "%TEMP%\cudnn92\cuda\bin\*.*" "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2\bin" && `
    xcopy /Y "%TEMP%\cudnn92\cuda\lib\x64\*.*" "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2\lib\x64" && `
    xcopy /Y "%TEMP%\cudnn92\cuda\include\*.*" "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2\include" && `
    setx /M PATH "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2\bin;%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2\libnvvp;%PATH%" && `
    setx /M CUDA_PATH "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2" && `
    setx /M CUDA_PATH_V9_2 "%ProgramFiles%\NVIDIA GPU Computing Toolkit\CUDA\v9.2" && `
    rd /s /q %TEMP%\cudnn92 && `
    curl -kL https://ossci-windows.s3.amazonaws.com/cuda_10.1.243_426.00_win10.exe --output "%TEMP%\cuda_10.1.243_426.00_win10.exe" && `
    curl -kL https://ossci-windows.s3.amazonaws.com/cudnn-10.1-windows10-x64-v7.6.4.38.zip --output "%TEMP%\cudnn-10.1-windows10-x64-v7.6.4.38.zip" && `
    7z x %TEMP%\cuda_10.1.243_426.00_win10.exe -o"%TEMP%\cuda101" && `
    del %TEMP%\cuda_10.1.243_426.00_win10.exe && `
    pushd %TEMP%\cuda101 && `
    start /wait setup.exe -s nvcc_10.1 cuobjdump_10.1 nvprune_10.1 cupti_10.1 cublas_10.1 cublas_dev_10.1 cudart_10.1 cufft_10.1 cufft_dev_10.1 curand_10.1 curand_dev_10.1 cusolver_10.1 cusolver_dev_10.1 cusparse_10.1 cusparse_dev_10.1 nvgraph_10.1 nvgraph_dev_10.1 npp_10.1 npp_dev_10.1 nvrtc_10.1 nvrtc_dev_10.1 nvml_dev_10.1 && `
    xcopy /Y "%TEMP%\cuda101\CUDAVisualStudioIntegration\extras\visual_studio_integration\MSBuildExtensions\*.*" "C:\BuildTools\Common7\IDE\VC\VCTargets\BuildCustomizations" && `
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
    setx /M NVTOOLSEXT_PATH "%ProgramFiles%\NVIDIA Corporation\NvToolsExt\bin\x64"
