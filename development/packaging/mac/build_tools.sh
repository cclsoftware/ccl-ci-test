scriptdir=$(dirname "$0")

rm -rf build/deployment/mac; mkdir -p build/deployment/mac/ccl;
for f in cclbuilder cclcrypt cclmakebin cclmakeguid cclmodeller.app cclpackage cclscript.app cclxstring cclreplacer cclgenerator ccltestrunner.app; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/ccl/; done
mkdir -p build/deployment/mac/ccl/Frameworks
for f in cclgui.framework cclsecurity.framework cclsystem.framework ccltext.framework cclnet.framework; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/ccl/Frameworks/; done
for f in build/deployment/mac/ccl/Frameworks/*; do ${scriptdir}/../../../framework/build/mac/codesign.sh "$f" "-o runtime" ${SIGNING_CERTIFICATE_MAC}; done

/usr/bin/ditto -c -k --keepParent build/deployment/mac ccl.zip
${scriptdir}/../../../framework/build/mac/notarize.sh ccl.zip ${APPLE_API_KEYPATH} ${APPLE_API_KEYID} ${APPLE_API_ISSUER}
