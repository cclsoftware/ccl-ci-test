#!/usr/bin/env bash
set -euo pipefail

export MSYS_NO_PATHCONV=1

echo "CMAKE_PRESET=linux" >> "$GITHUB_ENV"
echo "CCACHE_DIR=${GITHUB_WORKSPACE}/.ccache" >> "$GITHUB_ENV"
