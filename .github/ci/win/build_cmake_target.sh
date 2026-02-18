#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

builddir=${BUILD_DIR-build}

echo "-- Prepare Build Environment"

source ${scriptdir}/prepare_build_environment.sh
source ${cidir}/shared/prepare_workingcopy.sh ${BUILD_REVISION}
            
echo "-- Configure CMake Project"

cd development/cmake
cmake -B "${builddir}" --fresh --preset ${CMAKE_PRESET} -DVENDOR_CACHE_DIRECTORY=/f/.cache/ccl ${CMAKE_BUILD_OPTIONS}

echo "-- Build Release Binaries"

cd "${builddir}" && cmake --build . --config Release

echo "-- Sign Release Binaries"

cmake --build . --config Release --target sign_ccl_binaries

if [ ! -z ${CPACK_TARGET+x} ]; then

	echo "-- Building Package"
	
	cmake --build . --config Release --target "${CPACK_TARGET}"

fi