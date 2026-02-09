#!/usr/bin/env bash
set -euo pipefail

echo "CMAKE_BUILD_OPTIONS=-DCPACK_STRIP_FILES=OFF" >> "$GITHUB_ENV"
echo "CMAKE_PRESET=linux" >> "$GITHUB_ENV"