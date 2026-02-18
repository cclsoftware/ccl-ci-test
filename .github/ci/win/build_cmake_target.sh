#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

builddir=${BUILD_DIR-build}
buildconfig=${BUILD_CONFIG-Release}

echo "-- Prepare Build Environment"

source ${scriptdir}/prepare_build_environment.sh
source ${cidir}/shared/prepare_workingcopy.sh ${BUILD_REVISION}
            
echo "-- Configure CMake Project"

cd development/cmake
cmake -B "${builddir}" --fresh --preset ${CMAKE_PRESET} -DVENDOR_CACHE_DIRECTORY=/f/.cache/ccl ${CMAKE_BUILD_OPTIONS}

echo "-- Build"

cd "${builddir}" && cmake --build . --config ${buildconfig}

echo "-- Sign Binaries"

cmake --build . --config ${buildconfig} --target sign_ccl_binaries

if [ ! -z ${CPACK_TARGET+x} ]; then

	echo "-- Build Package"
	
	cmake --build . --config ${buildconfig} --target "${CPACK_TARGET}"

fi