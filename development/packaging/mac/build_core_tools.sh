scriptdir=$(dirname "$0")

rm -rf build/deployment/mac; mkdir -p build/deployment/mac/core;
for f in bin2c jsonconverter skincrush; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/core/; done

/usr/bin/ditto -c -k --keepParent build/deployment/mac core.zip
${scriptdir}/../../../framework/build/mac/notarize.sh core.zip ${APPLE_API_KEYPATH} ${APPLE_API_KEYID} ${APPLE_API_ISSUER}
