FROM rocker/r-ubuntu:18.04
LABEL Maintainer="w.furnass@sheffield.ac.uk"
LABEL Vendor="University of Sheffield"
LABEL Description="Valhalla, Routino and R: for OSM routing"

ARG NODE_VERS=10
ARG PRIME_SERVER_VERS=0.6.5
ARG ROUTINO_VERS=3.3.2
ARG VALHALLA_VERS=3.0.8

############################################################################
# PRIME-SERVER (dependency of Valhalla): install dependencies, build install
############################################################################
RUN apt-get update && \
    apt-get -y install \
        curl \
        dirmngr \
        apt-transport-https \
        lsb-release \
        ca-certificates && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERS}.x | bash && \
    apt-get update && \
    apt-get -y install nodejs
RUN apt-get -y install \
        nodejs \
        git \
        autoconf \
        automake \
        libtool \
        make \
        gcc \
        g++ \
        lcov \
        libcurl4-openssl-dev \
        libzmq3-dev \
        libczmq-dev
RUN cd /usr/src && \
    git clone --branch $PRIME_SERVER_VERS --depth 1 https://github.com/kevinkreiser/prime_server && \
    cd prime_server && \
    git submodule update --init --recursive && \
    ./autogen.sh && \
    ./configure && \
    make test -j8 && \
    make install

###################################################
# VALHALLA: install dependencies, build and install 
###################################################
RUN apt-get install -y \
        cmake \
        make \
        libtool \
        pkg-config \
        g++ \
        gcc \
        jq \
        lcov \
        protobuf-compiler \
        vim-common \
        libboost-all-dev \
        libboost-all-dev \
        libcurl4-openssl-dev \
        zlib1g-dev \
        liblz4-dev \
        libprotobuf-dev \
        libgeos++-dev \
        liblua5.2-dev \
        libspatialite-dev \
        libsqlite3-dev \
        lua5.2 \
        wget \
        libsqlite3-mod-spatialite
#if you plan to compile with python bindings, see below for more info
# RUN apt-get install -y python-all-dev
RUN cd /usr/src && \
    git clone --branch $VALHALLA_VERS --depth 1 https://github.com/valhalla/valhalla && \
    cd valhalla && \
    git submodule update --init --recursive && \
    npm install --ignore-scripts && \
    npm audit fix && \
    mkdir build && \
    cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make && \
    make install

##################################################
# ROUTINO: install dependencies, build and install 
##################################################
RUN apt-get install -y gcc make libc6-dev libz-dev libbz2-dev && \
    curl -sSL https://www.routino.org/download/routino-3.3.2.tgz | tar -xz -C /usr/src && \
    cd /usr/src/routino-${ROUTINO_VERS} && \
    make && \
    make install

USER docker
