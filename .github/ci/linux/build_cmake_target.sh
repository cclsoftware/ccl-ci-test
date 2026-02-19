#!/usr/bin/env bash
set -euo pipefail

echo $CCACHE_DIR
export CCACHE_DIR=${GITHUB_WORKSPACE}/.ccache
echo $CCACHE_DIR

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

buildconfig=${BUILD_CONFIG-Release}

echo "-- Build"

cmake --build . --config ${buildconfig}

if [ ! -z ${CPACK_TARGET+x} ]; then

	echo "-- Build Package"
	
	cmake --build . --config ${buildconfig} --target "${CPACK_TARGET}"

fi
