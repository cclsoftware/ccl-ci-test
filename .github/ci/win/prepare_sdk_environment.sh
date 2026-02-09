#!/usr/bin/env bash
set -euo pipefail

echo "CMAKE_BUILD_OPTIONS=-DVENDOR_ENABLE_CODESIGNING=ON" >> "$GITHUB_ENV"
echo "CMAKE_PRESET=win64" >> "$GITHUB_ENV"
echo "CPACK_OPTIONS=-G NSIS64" >> "$GITHUB_ENV"
  