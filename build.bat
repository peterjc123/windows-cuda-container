@echo off

if "%AWS_ACCESS_KEY_ID%" == "" goto build_section

choco install awscli
for /F "usebackq delims=" %%i in (`aws ecr get-login`) do (
    if errorlevel 1 exit /b 1
    set DOCKER_LOGIN_COMMAND=%%i
)
set DOCKER_LOGIN_COMMAND=%DOCKER_LOGIN_COMMAND:-e none =%
%DOCKER_LOGIN_COMMAND%
if errorlevel 1 exit /b 1

:build_section
docker build . --file Dockerfile -m 4GB --isolation="process" --tag 308535385114.dkr.ecr.us-east-1.amazonaws.com/pytorch/pytorch-windows-vs2017-win1803:v1.0.0
if errorlevel 1 exit /b 1

if "%AWS_ACCESS_KEY_ID%" == "" goto :eof

docker push 308535385114.dkr.ecr.us-east-1.amazonaws.com/pytorch/pytorch-windows-vs2017-win1803:v1.0.0
if errorlevel 1 exit /b 1
