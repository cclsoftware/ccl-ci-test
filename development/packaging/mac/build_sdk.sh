scriptdir=$(dirname "$0")

declare -a files=("cclbuilder" "cclcrypt" "cclmakebin" "cclmakeguid" "cclmodeller.app" "cclpackage" "cclreplacer" "cclscript.app" "ccltestrunner.app" "cclxstring" "cclgui.framework" "cclnet.framework" "cclsecurity.framework" "cclsystem.framework" "ccltext.framework")

tmpdir="tmp"

rm -rf "${tmpdir}"
mkdir -p "${tmpdir}"

for f in "${files[@]}";
do
	path="build/cmake/mac/Release/${f}"
	${scriptdir}/../../../framework/build/mac/codesign.sh "${path}" "-o runtime" ${SIGNING_CERTIFICATE_MAC}
	/usr/bin/ditto "${path}/" "${tmpdir}/${f}"
done

/usr/bin/ditto -c -k --keepParent "${tmpdir}" archive.zip
rm -rf "${tmpdir}"
${scriptdir}/../../../framework/build/mac/notarize.sh archive.zip ${APPLE_API_KEYPATH} ${APPLE_API_KEYID} ${APPLE_API_ISSUER}
rm archive.zip
