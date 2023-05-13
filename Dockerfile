# #####################################################################
# Project:      SDL-Hercules-390 (Development Branch)
# Version       1.0
# Created:      17 April 2023
# Updated:      08 May 2023
# (c)2023:      Patrick Raths  
#    
# Description:  Build docker container to compile SDL-Hercules-390
#               using the hercules-helper
#
#               This requires to have the actual build being performed
#               by a user other than root. To his end, user hercules
#               is created and granted sudo priviledges
#
# ---------------------------------------------------------------------
# Changelog
# Version       Description
# ---------------------------------------------------------------------
#
# #####################################################################
#
# Set Source and target Directory
#
ARG TGT=/opt/hercules
ARG USR=hercules
#
# Use Ubuntu container as foundation
#
FROM ubuntu:latest as build
ARG USR
#
# Add additional packages required to compile Hyperion
#
RUN apt-get -y update
RUN apt-get -y install apt-utils git wget time sudo nano
RUN apt-get -y install build-essential cmake flex gawk m4 autoconf automake libtool-bin libltdl-dev
#
# Create new user
# And assign priviledge to execute any command using sudo without password
#
RUN useradd -ms /bin/bash $USR
RUN echo "# Grant user hercules sudo permission on all commands with no password required" > /etc/sudoers.d/$USR
RUN echo "$USR ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USR
#
# Create source directory and copy source files
#
RUN mkdir -p /home/$USR/hercules-helper /home/$USR/herctest
RUN git clone https://github.com/wrljet/hercules-helper.git /home/$USR/hercules-helper
RUN chown -R hercules:hercules /home/$USR/hercules-helper /home/$USR/herctest
WORKDIR /home/$USR/hercules-helper
USER $USR:$USR
RUN ./hyperion-buildall.sh
#
# Stage 2: Deployment
#
FROM ubuntu:latest AS deployment
ARG TGT
ARG USR
ARG SRC=/home/$USR/hercules-helper/herc4x
# RUN useradd -ms /bin/bash hercules
COPY --from=build $SRC $TGT
# USER hercules:hercules
ENV PATH $TGT/bin:$TGT/bin/hercules:$PATH
ENV LD_LIBRARY_PATH $TGT/lib:$LD_LIBRARY_PATH
ENTRYPOINT /bin/bash