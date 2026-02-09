scriptdir=$(dirname "$0")

CCL_IDENTITIES_DIR=./framework/build/identities

rm -rf build/deployment/mac; mkdir -p build/deployment/mac/public;
for f in cclcrypt cclmakebin cclmakeguid cclpackage; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/public/; done
mkdir -p build/deployment/mac/public/Frameworks
for f in cclgui.framework cclsecurity.framework cclsystem.framework ccltext.framework; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/public/Frameworks/; done
IDENTITY=`xcrun codesign -dvv "build/deployment/mac/public/cclcrypt" 2>&1 | sed -n -E 's/Authority=(.*)/\1/p' | head -1`
for f in build/deployment/mac/public/Frameworks/*; do ${scriptdir}/codesign.sh "$f" "-o runtime" "${IDENTITY}"; done

cp ${CCL_IDENTITIES_DIR}/ccl/legal/CCL\ 3rd\ Party\ Licenses.txt build/deployment/mac
cp ${CCL_IDENTITIES_DIR}/ccl/eula/EULA.txt build/deployment/mac
/usr/bin/ditto -c -k --keepParent build/deployment/mac public.zip
${scriptdir}/notarize.sh public.zip
