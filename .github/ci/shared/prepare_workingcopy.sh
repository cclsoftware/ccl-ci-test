#!/usr/bin/env bash
set -euo pipefail

# Accept revision from first input parameter, default to $BUILD_REVISION
buildrevision=${1-$BUILD_REVISION}

build/shared/update_buildnumber.sh "${buildrevision}"
build/shared/update_buildtime.sh