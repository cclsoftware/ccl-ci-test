#!/bin/bash
set -e

scriptdir=$(dirname "$0")

declare -a apps=("CCL Demo" "CCL Localizer" "CCL Skin Editor")

tmpdir="build/deployment/mac/tmp"
artifactsdir="build/deployment/mac"

mkdir -p "${artifactsdir}"

for appname in "${apps[@]}";
do 
	rm -rf "${tmpdir}"
	mkdir -p "${tmpdir}"

    cp -R "build/cmake/mac/Release/${appname}.app" "${tmpdir}"
	ln -s /Applications "${tmpdir}/Applications"
	imagename="${artifactsdir}/${appname}.dmg"
	${scriptdir}/../../../framework/build/mac/codesign.sh "${tmpdir}/${appname}.app" "-o runtime" ${SIGNING_CERTIFICATE_MAC}
	hdiutil create -size 600m -fs HFS+ -volname "${appname}" -srcfolder "${tmpdir}" "${imagename}"
	${scriptdir}/../../../framework/build/mac/notarize.sh "${imagename}" ${APPLE_API_KEYPATH} ${APPLE_API_KEYID} ${APPLE_API_ISSUER}
	rm -rf "${tmpdir}"
done

