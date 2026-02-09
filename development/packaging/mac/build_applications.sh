#!/bin/bash
set -e

scriptdir=$(dirname "$0")

declare -a apps=("CCL Demo" "CCL Localizer" "CCL Skin Editor")

tmpdir="build/deployment/mac/tmp"
artifactsdir="build/deployment/mac"

mkdir -p "${artifactsdir}"

IDENTITY=`xcrun codesign -dvv "build/deployment/mac/ccl/CCL Demo" 2>&1 | sed -n -E 's/Authority=(.*)/\1/p' | head -1`

for appname in "${apps[@]}";
do 
	rm -rf "${tmpdir}"
	mkdir -p "${tmpdir}"

    cp -R "build/cmake/mac/Release/${appname}.app" "${tmpdir}"
	ln -s /Applications "${tmpdir}/Applications"
	imagename="${artifactsdir}/${appname}.dmg"
	${scriptdir}/codesign.sh "${tmpdir}/${appname}.app" "-o runtime" "${IDENTITY}"
	hdiutil create -size 600m -fs HFS+ -volname "${appname}" -srcfolder "${tmpdir}" "${imagename}"
	${scriptdir}/notarize.sh "${imagename}"
	rm -rf "${tmpdir}"
done

