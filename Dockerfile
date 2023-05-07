# ---------------------------------------------------------------------
# 
# Description:      Build docker container to compile SDL-Hercules-390
#
#  Version:         1.1
#  Created:         17 April 2023
#  Updated:         07 May 2023
#  (c)2023:         Patrick Raths
#                   
# ---------------------------------------------------------------------
FROM ubuntu:lunar AS build
#
# Set source and target directory
#
ARG SRC=/usr/src
ARG TGT=/opt/hercules
#
# Add additional packages required to compile Hyperion
#
RUN apt-get -y update
RUN apt-get -y install apt-utils git wget time sudo nano
RUN apt-get -y install build-essential cmake flex gawk m4 autoconf automake libtool-bin 
RUN apt-get -y install libltdl-dev
RUN apt-get -y install libbz2-dev zlib1g-dev
RUN apt-get -y install libcap2-bin
RUN apt-get -y install libregina3-dev
#
# Create installation directories
#
RUN mkdir -p $SRC/extpkgs $SRC/hyperion
COPY ./extpkgs $SRC/extpkgs/
#
# Compile external packages
#
WORKDIR $SRC/extpkgs
RUN ./extpkgs.sh clone c d s t
#
# Download and compile Hyperion from Github
#
RUN git clone https://github.com/SDL-Hercules-390/hyperion.git $SRC/hyperion
WORKDIR $SRC/hyperion
RUN ./util/bldlvlck
RUN ./autogen.sh
# RUN ./configure --prefix=$TGT --enable-extpkgs=../extpkgs
RUN ./configure --prefix=$TGT --enable-extpkgs=../extpkgs
RUN make
RUN make install
#
# Stage 2: Deployment
#
FROM ubuntu:lunar AS deployment
ARG SRC=/opt/hercules
ARG TGT=/opt/hercules
RUN apt-get -y update
RUN apt-get -y install htop nano 
# RUN libcap2-bin
COPY --from=build $SRC $TGT
ENV PATH $TGT/bin:$TGT/bin/hercules:$PATH
ENV LD_LIBRARY_PATH $TGT/lib:$LD_LIBRARY_PATH
WORKDIR $TGT
# # RUN setcap 'cap_sys_nice=eip' $TGT/bin/hercules
# # RUN setcap 'cap_sys_nice=eip' $TGT/bin/herclin
# # RUN setcap 'cap_net_admin+ep' $TGT/bin/hercifc
ENTRYPOINT /bin/bash