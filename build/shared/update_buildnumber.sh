#!/bin/bash

scriptdir=$(dirname "$0")
outputfile=${scriptdir}/../../buildnumber.h
buildnumber="$1"

${scriptdir}/../../framework/build/shared/update_buildnumber.sh "${outputfile}" "${buildnumber}" "$@"
