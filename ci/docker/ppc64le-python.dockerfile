# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

ARG base=docker.io/ppc64le/python:3.9-slim-bullseye
FROM ${base}

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

# Install Docker CLI
RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=ppc64el signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN pip install Cython==3.0.8 numpy

COPY arrow/python/requirements-build.txt /arrow-1/python/


COPY arrow/python/requirements-test.txt /arrow-1/python/


RUN pip install ninja


#RUN ls -lR
#COPY . /arrow


RUN pip install -r /arrow-1/python/requirements-build.txt

RUN pip install -r /arrow-1/python/requirements-test.txt

#RUN chmod +x /arrow/ci/scripts/ppc64le-python-wheel.sh

