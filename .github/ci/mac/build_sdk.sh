#!/usr/bin/env bash
set -euo pipefail

: "${APPLE_API_KEY_FILENAME:?}"
export APPLE_API_KEYPATH="$HOME/$APPLE_API_KEY_FILENAME"
[[ -f "${APPLE_API_KEYPATH}" ]] ||
{
  echo "APPLE_API_KEYPATH does not exist: $APPLE_API_KEYPATH" >&2
  exit 2
}

: "${APPLE_API_KEYID:?}"
export APPLE_API_KEYID

: "${APPLE_API_ISSUER:?}"
export APPLE_API_ISSUER

# Python virtual environment
#source .venv/bin/activate

# build macOS SDK
pushd development/cmake
cmake --preset mac -DBUILD_sdk=ON ${CMAKE_BUILD_OPTIONS} -DBUILD_documentation=OFF -DCCL_PREBUILT_DOCUMENTATION=${GITHUB_WORKSPACE}/.docs -DCCL_ANDROID_SDK_DIR=${GITHUB_WORKSPACE}/.android
cmake --build build --config Debug -- -allowProvisioningUpdates -authenticationKeyPath "$APPLE_API_KEYPATH" -authenticationKeyID "$APPLE_API_KEYID"  -authenticationKeyIssuerID "$APPLE_API_ISSUER"
cmake --build build --config Release -- -allowProvisioningUpdates -authenticationKeyPath "$APPLE_API_KEYPATH" -authenticationKeyID "$APPLE_API_KEYID"  -authenticationKeyIssuerID "$APPLE_API_ISSUER"
popd

# codesigning and notarization
development/packaging/mac/build_sdk.sh 

pushd development/cmake/build
cpack -G TGZ -C "Debug;Release" --config SdkPackageConfig.cmake || true
popd

# development/packaging/mac/build_applications.sh

# build iOS SDK
pushd development/cmake
cmake --preset ios --fresh -DBUILD_sdk=ON ${CMAKE_BUILD_OPTIONS} -DBUILD_documentation=OFF -DCCL_PREBUILT_DOCUMENTATION=${GITHUB_WORKSPACE}/.docs
cmake --build build --config Debug -- -allowProvisioningUpdates -authenticationKeyPath "$APPLE_API_KEYPATH" -authenticationKeyID "$APPLE_API_KEYID"  -authenticationKeyIssuerID "$APPLE_API_ISSUER"
cmake --build build --config Release -- -allowProvisioningUpdates -authenticationKeyPath "$APPLE_API_KEYPATH" -authenticationKeyID "$APPLE_API_KEYID"  -authenticationKeyIssuerID "$APPLE_API_ISSUER"
pushd build
cpack -G TGZ -C "Debug;Release" --config SdkPackageConfig.cmake || true
popd
popd

# development/packaging/ios/build_applications.sh

# create archive packages
mkdir -p build/deployment/mac
MACARCHIVE=(build/cmake/archive/*macOS.tar.gz)
IOSARCHIVE=(build/cmake/archive/*iOS.tar.gz)
tar -xzf "$MACARCHIVE"
tar -xzf "$IOSARCHIVE"
MACDIR=`echo $MACARCHIVE | sed 's/.*\/\([^\/]*\)\.tar\.gz/\1/'`
IOSDIR=`echo $IOSARCHIVE | sed 's/.*\/\([^\/]*\)\.tar\.gz/\1/'`
mv "$IOSDIR/lib/iOS" "$MACDIR/lib"
mv "$IOSDIR/Frameworks/iOS" "$MACDIR/Frameworks"
mv "$IOSDIR"/Frameworks/cmake/ccl/ios-* "$MACDIR/Frameworks/cmake/ccl/"

rm -f "$MACDIR.tar.gz"
tar -czf "$MACDIR.tar.gz" "$MACDIR"
mv "$MACDIR.tar.gz" build/deployment/mac
