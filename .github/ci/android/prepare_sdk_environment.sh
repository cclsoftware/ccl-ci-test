#!/usr/bin/env bash
set -euo pipefail

echo "CMAKE_BUILD_OPTIONS=-DCMAKE_ANDROID_NDK=/opt/android-sdk/ndk/29.0.14206865 -DCMAKE_TOOLCHAIN_FILE=/opt/android-sdk/ndk/29.0.14206865/build/cmake/android.toolchain.cmake" >> "$GITHUB_ENV"
