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

ARG base=ppc64le/python:3.9-slim-bullseye
FROM ${base}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo "debconf debconf/frontend select Noninteractive" | \
       debconf-set-selections

# Installs LLVM toolchain, for Gandiva and testing other compilers
#
# Note that this is installed before the base packages to improve iteration
# while debugging package list with docker build.
ARG clang_tools
ARG llvm
RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
        clang-${clang_tools} \
        clang-${llvm} \
        clang-format-${clang_tools} \
        clang-tidy-${clang_tools} \
        llvm-${llvm}-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*

# Installs C++ toolchain and dependencies
RUN apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends \
        autoconf \
        bzip2 \
        ca-certificates \
        ccache \
        cmake \
        curl \
        gdb \
        git \
        libbenchmark-dev \
        libboost-filesystem-dev \
        libboost-system-dev \
        libbrotli-dev \
        libbz2-dev \
        libc-ares-dev \
        libcurl4-openssl-dev \
        libgflags-dev \
        libgmock-dev \
        libgoogle-glog-dev \
        libgrpc++-dev \
        libidn2-dev \
        libkrb5-dev \
        libldap-dev \
        liblz4-dev \
        libnghttp2-dev \
        libprotobuf-dev \
        libprotoc-dev \
        libpsl-dev \
        libre2-dev \
        librtmp-dev \
        libsnappy-dev \
        libsqlite3-dev \
        libssh-dev \
        libssh2-1-dev \
        libssl-dev \
        libthrift-dev \
        libutf8proc-dev \
        libxml2-dev \
        libzstd-dev \
        make \
        ninja-build \
        nlohmann-json3-dev \
        npm \
        pkg-config \
        protobuf-compiler \
        protobuf-compiler-grpc \
        python3-dev \
        python3-pip \
        python3-venv \
        rapidjson-dev \
        rsync \
        tzdata \
        wget \
        xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists*

ARG gcc_version=""
RUN if [ "${gcc_version}" = "" ]; then \
      apt-get update -y -q && \
      apt-get install -y -q --no-install-recommends \
          g++ \
          gcc; \
    else \
      if [ "${gcc_version}" -gt "12" ]; then \
          apt-get update -y -q && \
          apt-get install -y -q --no-install-recommends software-properties-common && \
          add-apt-repository ppa:ubuntu-toolchain-r/volatile; \
      fi; \
      apt-get update -y -q && \
      apt-get install -y -q --no-install-recommends \
          g++-${gcc_version} \
          gcc-${gcc_version} && \
      update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-${gcc_version} 100 && \
      update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-${gcc_version} 100 && \
      update-alternatives --install \
        /usr/bin/$(uname --machine)-linux-gnu-gcc \
        $(uname --machine)-linux-gnu-gcc \
        /usr/bin/$(uname --machine)-linux-gnu-gcc-${gcc_version} 100 && \
      update-alternatives --install \
        /usr/bin/$(uname --machine)-linux-gnu-g++ \
        $(uname --machine)-linux-gnu-g++ \
        /usr/bin/$(uname --machine)-linux-gnu-g++-${gcc_version} 100 && \
      update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100 && \
      update-alternatives --set cc /usr/bin/gcc && \
      update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100 && \
      update-alternatives --set c++ /usr/bin/g++; \
    fi

ENV absl_SOURCE=BUNDLED \
    ARROW_PYTHON=ON \
    ARROW_BUILD_TESTS=ON \
    ARROW_EXTRA_ERROR_CONTEXT=OFF \
    ARROW_JEMALLOC=OFF \
    ARROW_FILESYSTEM=ON \
    ARROW_PARQUET=ON \
    ASAN_SYMBOLIZER_PATH=/usr/lib/llvm-${llvm}/bin/llvm-symbolizer \
    PATH=/usr/lib/ccache/:$PATH \
    PYTHON=python3