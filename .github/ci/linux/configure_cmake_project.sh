#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

builddir=${BUILD_DIR-build}

echo "-- Configure CMake Project"

cd development/cmake
cmake -B "${builddir}" --fresh --preset ${CMAKE_PRESET} -DVENDOR_CACHE_DIRECTORY=${GITHUB_WORKSPACE}/.cache/ccl ${CMAKE_BUILD_OPTIONS}
