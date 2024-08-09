#!/usr/bin/env bash
#
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

set -ex

arrow_dir=${1}
build_dir=${2}

export PARQUET_TEST_DATA="${arrow_dir}/cpp/submodules/parquet-testing/data"
export ARROW_TEST_DATA="${arrow_dir}/testing/data"

cd ${arrow_dir}/cpp
mkdir build
cd build
export ARROW_HOME=/repos/dist
export LD_LIBRARY_PATH=$ARROW_HOME/lib:$LD_LIBRARY_PATH

cmake -DCMAKE_BUILD_TYPE=release \
      -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
      -Dutf8proc_LIB=/usr/lib/powerpc64le-linux-gnu/libutf8proc.so \
      -Dutf8proc_INCLUDE_DIR=/usr/include \
      -DARROW_PYTHON=on \
      -DARROW_BUILD_TESTS=ON \
      -DARROW_EXTRA_ERROR_CONTEXT=OFF \
      -DARROW_JEMALLOC=OFF \
      -DARROW_FILESYSTEM=ON \
      -DARROW_PARQUET=ON ..
make
make install

ctest

cd ../../python/
#PYTHONPATH=/usr/lib/python3.11/site-packages:$PYTHONPATH
CMAKE_PREFIX_PATH=$ARROW_HOME python setup.py build_ext --inplace

CMAKE_PREFIX_PATH=/repos/dist python setup.py install

##############----new changes


export PYARROW_TEST_ACERO=ON
export PYARROW_TEST_AZURE=OFF
export PYARROW_TEST_CUDA=OFF
export PYARROW_TEST_DATASET=OFF
export PYARROW_TEST_FLIGHT=OFF
export PYARROW_TEST_GANDIVA=OFF
export PYARROW_TEST_GCS=OFF
export PYARROW_TEST_HDFS=ON
export PYARROW_TEST_ORC=OFF
export PYARROW_TEST_PARQUET=OFF
export PYARROW_TEST_PARQUET_ENCRYPTION=OFF
export PYARROW_TEST_S3=OFF

pytest -k "not test_env_var and not test_specific_memory_pools and not test_supported_memory_backends"

