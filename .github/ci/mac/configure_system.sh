#!/usr/bin/env bash
set -euo pipefail

# install software packages

# Sphinx dependencies
# python3 -m venv .venv
# source .venv/bin/activate
# python3 -m pip install pip
# pip install sphinx==6.2.1 sphinx_rtd_theme==2.0.0 breathe==4.35.0
# npm install typedoc@0.23.28 --global
# brew install doxygen

# configure Xcode version
xcodes select 16.0
# output system info 
echo "=== System ==="
uname -a
sw_vers

echo
echo "=== Hardware ==="
sysctl -n machdep.cpu.brand_string
sysctl -n hw.ncpu
sysctl -n hw.memsize | awk '{ printf "%.1f GB\n", $1 / 1024 / 1024 / 1024 }'
uname -m

echo
echo "=== Xcode ==="
xcodebuild -version
xcode-select -p

echo
echo "=== Toolchain ==="
cmake --version || true
python3 --version || true
clang --version || true

echo
echo "=== Disk ==="
df -h /
