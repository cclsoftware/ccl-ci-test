#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

export BUILD_DIR=build/sdk
export CMAKE_BUILD_OPTIONS="${CMAKE_BUILD_OPTIONS:-} -DBUILD_sdk=ON -DBUILD_documentation=OFF -DCCL_PREBUILT_DOCUMENTATION=${DOCUMENTATION_DIR:-} -DCCL_ANDROID_SDK_DIR=${ANDROID_SDK_DIR:-}"
source ${scriptdir}/build_cmake_target.sh

echo "-- Build Debug Binaries"

cmake --build . --config Debug

echo "-- Sign Debug Binaries"

cmake --build . --config Debug --target sign_ccl_binaries

echo "-- Build Installer"

cpack -C "Debug;Release" --config SdkPackageConfig.cmake ${CPACK_OPTIONS}

echo "-- Sign Installer"

cmake --build . --config Release --target signed_sdkpackage
