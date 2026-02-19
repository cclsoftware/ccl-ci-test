#!/usr/bin/env bash
set -euo pipefail

echo "CMAKE_PRESET=linux" >> "$GITHUB_ENV"
echo "CCACHE_DIR=${GITHUB_WORKSPACE}/.ccache" >> "$GITHUB_ENV"
