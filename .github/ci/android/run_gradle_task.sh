#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
cidir="${scriptdir}/.."

echo "-- Build"

gradle "${GRADLE_TASK}"
