#**********************************************************************
#***                                                                ***
#*** Dockerfile:    SDL-Hercules-4.5                                ***
#***                                                                ***
#*** Updated:       24 March 2023                                   ***
#***                                                                ***
#**********************************************************************
#
# Use Ubuntu container as foundation
#
FROM ubuntu:lunar
#
# Set environment
#
ENV HERCULES /opt/hercules
#
# Install required packages
#
RUN apt-get -y update
RUN apt-get -y install apt-utils wget time htop nano
RUN apt-get -y install libcap2-bin
#
# Copy TK4- and Hercules 
#
COPY ./hercules $HERCULES
#
# Set working directory and define the default entrypoint into the
# container to luanch TK4- when starting the container
ENV PATH $HERCULES/bin:$HERCULES/bin/hercules:$PATH
ENV LD_LIBRARY_PATH $HERCULES/lib:$LD_LIBRARY_PATH
WORKDIR $HERCULES