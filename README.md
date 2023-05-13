# Dockerized SDL-Hercules-390
Build docker container with SDL Hercules 390 for ARM64

This builds SDL-Hercules-390 (Hyperion) using a docker image based on the development branch (version 4.6) of the project.

https://sdl-hercules-390.github.io/html/
https://github.com/SDL-Hercules-390/hyperion

## Building the Docker image 
Building the image is controlled through the Dockerfile found in the root directory of this repository. 
```
docker build -t sdl-hercules-390:4.6 .
```
## Running Hercules as a container
Running the container will not automatically start Hercules since it requires configuration files for the mainframe environment to be emulated which are not part of the library. When starting the container using the below command, the shell of the container is made accessible.
```
docker run -it --name sdl-hercules-390-dev --cap-add=sys_nice sdl-hercules-390:v4.6
```
