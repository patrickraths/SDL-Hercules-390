# #####################################################################
# Project:      SDL-Hercules-390
# Version:      1.1.1
# Created:      17 April 2023
# Updated:      13 May 2023
# (c)2023:      Patrick Raths
#
# Description:  Build docker container to compile SDL-Hercules-390
#
# ---------------------------------------------------------------------
# Changelog
# Version       Description
# ---------------------------------------------------------------------
# 1.1.1:        - ARG vales defined prior to build stage for global
#                 use
#               - Clone scripts for extpkgs from github
# ---------------------------------------------------------------------
# 1.1           Use Multistage build
# #####################################################################
#
# Set Source and target Directory
#
ARG SRC=/usr/src
ARG TGT=/opt/hercules
# ---------------------------------------------------------------------
# Stage 1: Build
# ---------------------------------------------------------------------
FROM ubuntu:latest AS build
ARG SRC
ARG TGT
#
# Add additional packages required to compile Hyperion
#
RUN apt-get -y update
RUN apt-get -y install apt-utils git wget time sudo nano
RUN apt-get -y install build-essential cmake flex gawk m4 autoconf automake libtool-bin libltdl-dev
RUN apt-get -y install libbz2-dev zlib1g-dev
RUN apt-get -y install libcap2-bin
RUN apt-get -y install libregina3-dev
#
# Download and Compile external packages
#
RUN git clone https://github.com/SDL-Hercules-390/gists.git $SRC/extpkgs
COPY ./extpkgs $SRC/extpkgs/
WORKDIR $SRC/extpkgs
RUN ./extpkgs.sh clone c d s t
#
# Download and compile Hyperion from Github
#
RUN git clone https://github.com/SDL-Hercules-390/hyperion.git $SRC/hyperion
WORKDIR $SRC/hyperion
RUN ./util/bldlvlck
RUN ./autogen.sh
RUN ./configure --prefix=$TGT --enable-extpkgs=../extpkgs
RUN make
RUN sudo make install
# ---------------------------------------------------------------------
# Stage 2: Deployment
# ---------------------------------------------------------------------
FROM ubuntu:latest AS deployment
ARG TGT
RUN apt-get -y update
RUN apt-get -y install htop time sudo nano
RUN apt-get -y install libcap2-bin
COPY --from=build $TGT $TGT
ENV PATH $TGT/bin:$TGT/bin/hercules:$PATH
ENV LD_LIBRARY_PATH $TGT/lib:$LD_LIBRARY_PATH
WORKDIR $TGT
RUN sudo setcap 'cap_sys_nice=eip' $TGT/bin/hercules
RUN sudo setcap 'cap_sys_nice=eip' $TGT/bin/herclin
RUN sudo setcap 'cap_net_admin+ep' $TGT/bin/hercifc
# CMD [ "/bin/bash" ]