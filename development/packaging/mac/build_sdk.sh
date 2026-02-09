scriptdir=$(dirname "$0")

declare -a files=("cclbuilder" "cclcrypt" "cclmakebin" "cclmakeguid" "cclmodeller.app" "cclpackage" "cclreplacer" "cclscript.app" "ccltestrunner.app" "cclxstring" "cclgui.framework" "cclnet.framework" "cclsecurity.framework" "cclsystem.framework" "ccltext.framework")

tmpdir="tmp"

rm -rf "${tmpdir}"
mkdir -p "${tmpdir}"

IDENTITY=`xcrun codesign -dvv "build/cmake/mac/Release/cclbuilder" 2>&1 | sed -n -E 's/Authority=(.*)/\1/p' | head -1`

for f in "${files[@]}";
do
	path="build/cmake/mac/Release/${f}"
	${scriptdir}/codesign.sh "${path}" "-o runtime" "${IDENTITY}"
	/usr/bin/ditto "${path}/" "${tmpdir}/${f}"
done

/usr/bin/ditto -c -k --keepParent "${tmpdir}" archive.zip
rm -rf "${tmpdir}"
${scriptdir}/notarize.sh archive.zip
rm archive.zip
