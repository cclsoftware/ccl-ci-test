#!/usr/bin/env bash
set -euo pipefail

buildnumber=$1

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

echo "-- Prepare Build Environment"

${scriptdir}/prepare_sdk_environment.sh
${cidir}/shared/prepare_workingcopy.sh ${buildnumber}
            
echo "-- Configure CMake Project"

cd development/cmake
cmake -B build/sdk --fresh --preset ${CMAKE_PRESET} -DBUILD_sdk=ON -DVENDOR_CACHE_DIRECTORY=/f/.cache/ccl ${CMAKE_BUILD_OPTIONS}

echo "-- Build Debug and Release"

cd build/sdk && cmake --build . --config Debug && cmake --build . --config Release

echo "-- Sign Binaries"

cmake --build . --config Debug --target sign_ccl_binaries && cmake --build . --config Release --target sign_ccl_binaries

echo "-- Build Installer"

cpack -C "Debug;Release" --config SdkPackageConfig.cmake ${CPACK_OPTIONS}

echo "-- Sign Installer"

cmake --build . --config Release --target signed_sdkpackage