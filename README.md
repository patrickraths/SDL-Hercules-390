# Dockerized SDL-Hercules-390
Build docker container with SDL Hercules 390
## SDL-Hercules-390
...

## Building the Docker image 
Building the image is controlled through the Dockerfile found in the root directory of this repository. 

The following environment variables are configured:
| Environment Variable | Value |
| :--- | :--- |
| PATH | /opt/hercules/bin:/opt/hercules/bin/hercules |
| LD_LIBRARY_PATH | /opt/hercules/lib |
```
docker build -t sdl-hercules-390:v4.5 .
```

## Running Hercules as a container
Running the container will not automatically start Hercules since it requires configuration files for the mainframe environment to be emulated which are not part of the library. When starting the container using the below command, the shell of the container is made accessible.
```
docker run --name sdl-hercules-390 -it sdl-hercules-390:v4.5
```
jjj
