#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

builddir=${BUILD_DIR-build}
buildconfig=${BUILD_CONFIG-Release}

echo "-- Build"

cd "${builddir}" && cmake --build . --config ${buildconfig}

if [ ! -z ${CPACK_TARGET+x} ]; then

	echo "-- Build Package"
	
	cmake --build . --config ${buildconfig} --target "${CPACK_TARGET}"

fi