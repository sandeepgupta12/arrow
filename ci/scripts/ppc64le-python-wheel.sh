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

n_jobs=$(nproc)

source_dir=${1}
build_dir=${2}/cpp

mkdir -p ${build_dir}
pushd ${build_dir}

echo "=== (${PYTHON_VERSION}) Building Arrow C++ libraries ==="
cmake \
    -Dabsl_SOURCE=${absl_SOURCE:-} \
    -DARROW_ACERO=${ARROW_ACERO:-OFF} \
    -DARROW_AZURE=${ARROW_AZURE:-OFF} \
    -DARROW_BOOST_USE_SHARED=${ARROW_BOOST_USE_SHARED:-ON} \
    -DARROW_BUILD_BENCHMARKS_REFERENCE=${ARROW_BUILD_BENCHMARKS:-OFF} \
    -DARROW_BUILD_BENCHMARKS=${ARROW_BUILD_BENCHMARKS:-OFF} \
    -DARROW_BUILD_EXAMPLES=${ARROW_BUILD_EXAMPLES:-OFF} \
    -DARROW_BUILD_INTEGRATION=${ARROW_BUILD_INTEGRATION:-OFF} \
    -DARROW_BUILD_OPENMP_BENCHMARKS=${ARROW_BUILD_OPENMP_BENCHMARKS:-OFF} \
    -DARROW_BUILD_SHARED=${ARROW_BUILD_SHARED:-ON} \
    -DARROW_BUILD_STATIC=${ARROW_BUILD_STATIC:-ON} \
    -DARROW_BUILD_TESTS=${ARROW_BUILD_TESTS:-OFF} \
    -DARROW_BUILD_UTILITIES=${ARROW_BUILD_UTILITIES:-ON} \
    -DARROW_COMPUTE=${ARROW_COMPUTE:-ON} \
    -DARROW_CSV=${ARROW_CSV:-ON} \
    -DARROW_CUDA=${ARROW_CUDA:-OFF} \
    -DARROW_CXXFLAGS=${ARROW_CXXFLAGS:-} \
    -DARROW_CXX_FLAGS_DEBUG="${ARROW_CXX_FLAGS_DEBUG:-}" \
    -DARROW_CXX_FLAGS_RELEASE="${ARROW_CXX_FLAGS_RELEASE:-}" \
    -DARROW_CXX_FLAGS_RELWITHDEBINFO="${ARROW_CXX_FLAGS_RELWITHDEBINFO:-}" \
    -DARROW_C_FLAGS_DEBUG="${ARROW_C_FLAGS_DEBUG:-}" \
    -DARROW_C_FLAGS_RELEASE="${ARROW_C_FLAGS_RELEASE:-}" \
    -DARROW_C_FLAGS_RELWITHDEBINFO="${ARROW_C_FLAGS_RELWITHDEBINFO:-}" \
    -DARROW_DATASET=${ARROW_DATASET:-OFF} \
    -DARROW_DEPENDENCY_SOURCE=${ARROW_DEPENDENCY_SOURCE:-AUTO} \
    -DARROW_DEPENDENCY_USE_SHARED=${ARROW_DEPENDENCY_USE_SHARED:-ON} \
    -DARROW_ENABLE_THREADING=${ARROW_ENABLE_THREADING:-ON} \
    -DARROW_ENABLE_TIMING_TESTS=${ARROW_ENABLE_TIMING_TESTS:-ON} \
    -DARROW_EXTRA_ERROR_CONTEXT=${ARROW_EXTRA_ERROR_CONTEXT:-OFF} \
    -DARROW_FILESYSTEM=${ARROW_FILESYSTEM:-ON} \
    -DARROW_FLIGHT=${ARROW_FLIGHT:-OFF} \
    -DARROW_FLIGHT_SQL=${ARROW_FLIGHT_SQL:-OFF} \
    -DARROW_FUZZING=${ARROW_FUZZING:-OFF} \
    -DARROW_GANDIVA_PC_CXX_FLAGS=${ARROW_GANDIVA_PC_CXX_FLAGS:-} \
    -DARROW_GANDIVA=${ARROW_GANDIVA:-OFF} \
    -DARROW_GCS=${ARROW_GCS:-OFF} \
    -DARROW_HDFS=${ARROW_HDFS:-ON} \
    -DARROW_INSTALL_NAME_RPATH=${ARROW_INSTALL_NAME_RPATH:-ON} \
    -DARROW_JEMALLOC=${ARROW_JEMALLOC:-ON} \
    -DARROW_JSON=${ARROW_JSON:-ON} \
    -DARROW_LARGE_MEMORY_TESTS=${ARROW_LARGE_MEMORY_TESTS:-OFF} \
    -DARROW_MIMALLOC=${ARROW_MIMALLOC:-OFF} \
    -DARROW_ORC=${ARROW_ORC:-OFF} \
    -DARROW_PARQUET=${ARROW_PARQUET:-OFF} \
    -DARROW_RUNTIME_SIMD_LEVEL=${ARROW_RUNTIME_SIMD_LEVEL:-MAX} \
    -DARROW_S3=${ARROW_S3:-OFF} \
    -DARROW_SIMD_LEVEL=${ARROW_SIMD_LEVEL:-DEFAULT} \
    -DARROW_SKYHOOK=${ARROW_SKYHOOK:-OFF} \
    -DARROW_SUBSTRAIT=${ARROW_SUBSTRAIT:-OFF} \
    -DARROW_TEST_LINKAGE=${ARROW_TEST_LINKAGE:-shared} \
    -DARROW_TEST_MEMCHECK=${ARROW_TEST_MEMCHECK:-OFF} \
    -DARROW_USE_ASAN=${ARROW_USE_ASAN:-OFF} \
    -DARROW_USE_CCACHE=${ARROW_USE_CCACHE:-ON} \
    -DARROW_USE_GLOG=${ARROW_USE_GLOG:-OFF} \
    -DARROW_USE_LD_GOLD=${ARROW_USE_LD_GOLD:-OFF} \
    -DARROW_USE_LLD=${ARROW_USE_LLD:-OFF} \
    -DARROW_USE_MOLD=${ARROW_USE_MOLD:-OFF} \
    -DARROW_USE_PRECOMPILED_HEADERS=${ARROW_USE_PRECOMPILED_HEADERS:-OFF} \
    -DARROW_USE_STATIC_CRT=${ARROW_USE_STATIC_CRT:-OFF} \
    -DARROW_USE_TSAN=${ARROW_USE_TSAN:-OFF} \
    -DARROW_USE_UBSAN=${ARROW_USE_UBSAN:-OFF} \
    -DARROW_VERBOSE_THIRDPARTY_BUILD=${ARROW_VERBOSE_THIRDPARTY_BUILD:-OFF} \
    -DARROW_WITH_BROTLI=${ARROW_WITH_BROTLI:-OFF} \
    -DARROW_WITH_BZ2=${ARROW_WITH_BZ2:-OFF} \
    -DARROW_WITH_LZ4=${ARROW_WITH_LZ4:-OFF} \
    -DARROW_WITH_OPENTELEMETRY=${ARROW_WITH_OPENTELEMETRY:-OFF} \
    -DARROW_WITH_MUSL=${ARROW_WITH_MUSL:-OFF} \
    -DARROW_WITH_SNAPPY=${ARROW_WITH_SNAPPY:-OFF} \
    -DARROW_WITH_UCX=${ARROW_WITH_UCX:-OFF} \
    -DARROW_WITH_UTF8PROC=${ARROW_WITH_UTF8PROC:-ON} \
    -DARROW_WITH_ZLIB=${ARROW_WITH_ZLIB:-OFF} \
    -DARROW_WITH_ZSTD=${ARROW_WITH_ZSTD:-OFF} \
    -DAWSSDK_SOURCE=${AWSSDK_SOURCE:-} \
    -DAzure_SOURCE=${Azure_SOURCE:-} \
    -Dbenchmark_SOURCE=${benchmark_SOURCE:-} \
    -DBOOST_SOURCE=${BOOST_SOURCE:-} \
    -DBrotli_SOURCE=${Brotli_SOURCE:-} \
    -DBUILD_WARNING_LEVEL=${BUILD_WARNING_LEVEL:-CHECKIN} \
    -Dc-ares_SOURCE=${cares_SOURCE:-} \
    -DCMAKE_BUILD_TYPE=${ARROW_BUILD_TYPE:-debug} \
    -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE:-OFF} \
    -DCMAKE_C_FLAGS="${CFLAGS:-}" \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS:-}" \
    -DCMAKE_CXX_STANDARD="${CMAKE_CXX_STANDARD:-17}" \
    -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR:-lib} \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-${ARROW_HOME}} \
    -DCMAKE_UNITY_BUILD=${CMAKE_UNITY_BUILD:-OFF} \
    -Dgflags_SOURCE=${gflags_SOURCE:-} \
    -Dgoogle_cloud_cpp_storage_SOURCE=${google_cloud_cpp_storage_SOURCE:-} \
    -DgRPC_SOURCE=${gRPC_SOURCE:-} \
    -DGTest_SOURCE=${GTest_SOURCE:-} \
    -Dlz4_SOURCE=${lz4_SOURCE:-} \
    -DORC_SOURCE=${ORC_SOURCE:-} \
    -DPARQUET_BUILD_EXAMPLES=${PARQUET_BUILD_EXAMPLES:-OFF} \
    -DPARQUET_BUILD_EXECUTABLES=${PARQUET_BUILD_EXECUTABLES:-OFF} \
    -DPARQUET_REQUIRE_ENCRYPTION=${PARQUET_REQUIRE_ENCRYPTION:-ON} \
    -DProtobuf_SOURCE=${Protobuf_SOURCE:-} \
    -DRapidJSON_SOURCE=${RapidJSON_SOURCE:-} \
    -Dre2_SOURCE=${re2_SOURCE:-} \
    -DSnappy_SOURCE=${Snappy_SOURCE:-} \
    -DThrift_SOURCE=${Thrift_SOURCE:-} \
    -Dutf8proc_SOURCE=${utf8proc_SOURCE:-} \
    -Dzstd_SOURCE=${zstd_SOURCE:-} \
    -Dxsimd_SOURCE=${xsimd_SOURCE:-} \
    -G "${CMAKE_GENERATOR:-Ninja}" \
    ${ARROW_CMAKE_ARGS} \
    ${source_dir}/cpp

cmake --build . --target install
popd


echo "=== (${PYTHON_VERSION}) Building wheel ==="

export PYARROW_CMAKE_GENERATOR=${CMAKE_GENERATOR:-Ninja}
export PYARROW_BUILD_TYPE=${CMAKE_BUILD_TYPE:-release}

export PYARROW_WITH_ACERO=${ARROW_ACERO:-OFF}
export PYARROW_WITH_AZURE=${ARROW_AZURE:-OFF}
export PYARROW_WITH_CUDA=${ARROW_CUDA:-OFF}
export PYARROW_WITH_DATASET=${ARROW_DATASET:-OFF}
export PYARROW_WITH_FLIGHT=${ARROW_FLIGHT:-OFF}
export PYARROW_WITH_GANDIVA=${ARROW_GANDIVA:-OFF}
export PYARROW_WITH_GCS=${ARROW_GCS:-OFF}
export PYARROW_WITH_HDFS=${ARROW_HDFS:-OFF}
export PYARROW_WITH_ORC=${ARROW_ORC:-OFF}
export PYARROW_WITH_PARQUET=${ARROW_PARQUET:-OFF}
export PYARROW_WITH_PARQUET_ENCRYPTION=${PARQUET_REQUIRE_ENCRYPTION:-OFF}
export PYARROW_WITH_S3=${ARROW_S3:-OFF}
export PYARROW_WITH_SUBSTRAIT=${ARROW_SUBSTRAIT:-OFF}
export PYARROW_BUNDLE_ARROW_CPP=1

export PYARROW_INSTALL_TESTS=1

export PYARROW_PARALLEL=${n_jobs}

: ${CMAKE_PREFIX_PATH:=${ARROW_HOME}}
export CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=${ARROW_HOME}/lib:${LD_LIBRARY_PATH}

pushd ${source_dir}/python
python setup.py bdist_wheel

echo "=== Strip symbols from wheel ==="
mkdir -p dist/temp-fix-wheel
mv dist/pyarrow-*.whl dist/temp-fix-wheel

pushd dist/temp-fix-wheel
wheel_name=$(ls pyarrow-*.whl)

unzip $wheel_name
rm $wheel_name
for filename in $(ls pyarrow/*.so pyarrow/*.so.*); do
    echo "Stripping debug symbols from: $filename";
    strip --strip-debug $filename
done

# Zip wheel again after stripping symbols
zip -r $wheel_name .
mv $wheel_name ..
popd

rm -rf dist/temp-fix-wheel

# Move the verified wheels
mkdir -p ${source_dir}/python/repaired_wheels
mv ${source_dir}/python/dist/*.whl ${2}
popd