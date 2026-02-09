#!/bin/bash

scriptdir=$(dirname "$0")
outputfile=${scriptdir}/../../buildtime.h

${scriptdir}/../../framework/build/shared/update_buildtime.sh "${outputfile}" "$@"
