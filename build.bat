@echo off

if "%DOCKER_PASSWORD%" == "" goto build_section

docker login -u peterjc123 -p %DOCKER_PASSWORD%
if errorlevel 1 exit /b 1

:build_section
docker build . --file Dockerfile -m 4GB --isolation="process" --compress --tag peterjc123/windows-cuda-container:v3.0.0
if errorlevel 1 exit /b 1

if "%DOCKER_PASSWORD%" == "" goto :eof

docker push peterjc123/windows-cuda-container:v3.0.0
if errorlevel 1 exit /b 1
