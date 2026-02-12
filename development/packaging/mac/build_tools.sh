scriptdir=$(dirname "$0")

rm -rf build/deployment/mac; mkdir -p build/deployment/mac/ccl;
for f in cclbuilder cclcrypt cclmakebin cclmakeguid cclmodeller.app cclpackage cclscript.app cclxstring cclreplacer cclgenerator ccltestrunner.app; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/ccl/; done
mkdir -p build/deployment/mac/ccl/Frameworks
for f in cclgui.framework cclsecurity.framework cclsystem.framework ccltext.framework cclnet.framework; do cp -R "build/cmake/mac/Release/${f}" build/deployment/mac/ccl/Frameworks/; done
IDENTITY=`xcrun codesign -dvv "build/deployment/mac/ccl/cclbuilder" 2>&1 | sed -n -E 's/Authority=(.*)/\1/p' | head -1`
for f in build/deployment/mac/ccl/Frameworks/*; do ${scriptdir}/codesign.sh "$f" "-o runtime" "${IDENTITY}"; done

/usr/bin/ditto -c -k --keepParent build/deployment/mac ccl.zip
${scriptdir}/notarize.sh ccl.zip
