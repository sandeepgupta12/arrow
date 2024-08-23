ARG base=ppc64le/python:3.9-slim-bullseye
FROM ${base}

# install python specific packages
ARG python=3.9

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    build-essential \
    curl \
    git \
    gcc \
    g++ \
    make \
    gfortran \
    wget \
    patch \
    pkg-config \
    zip \
    unzip \
    cmake \
    openjdk-11-jdk \
    zlib1g-dev \
    libboost-all-dev \
    libgflags-dev \
    rapidjson-dev \
    libre2-dev \
    google-mock \
    googletest \
    libutf8proc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*

RUN pip install Cython==3.0.8 numpy

COPY python/requirements-build.txt /arrow/python/
RUN pip install -r /arrow/python/requirements-build.txt

COPY python/requirements-test.txt /arrow/python/
RUN pip install -r /arrow/python/requirements-test.txt

RUN pip install ninja

