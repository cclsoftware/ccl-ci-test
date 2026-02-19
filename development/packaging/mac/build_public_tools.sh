scriptdir=$(dirname "$0")

CCL_IDENTITIES_DIR=./framework/build/identities

rm -rf build/deployment/mac; mkdir -p build/deployment/mac/public;
for f in cclcrypt cclmakebin cclmakeguid cclpackage; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/public/; done
mkdir -p build/deployment/mac/public/Frameworks
for f in cclgui.framework cclsecurity.framework cclsystem.framework ccltext.framework; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/public/Frameworks/; done
for f in build/deployment/mac/public/Frameworks/*; do ${scriptdir}/../../../framework/build/mac/codesign.sh "$f" "-o runtime" ${SIGNING_CERTIFICATE_MAC}; done

cp ${CCL_IDENTITIES_DIR}/ccl/legal/CCL\ 3rd\ Party\ Licenses.txt build/deployment/mac
cp ${CCL_IDENTITIES_DIR}/ccl/eula/EULA.txt build/deployment/mac
/usr/bin/ditto -c -k --keepParent build/deployment/mac public.zip
${scriptdir}/../../../framework/build/mac/notarize.sh public.zip ${APPLE_API_KEYPATH} ${APPLE_API_KEYID} ${APPLE_API_ISSUER}
