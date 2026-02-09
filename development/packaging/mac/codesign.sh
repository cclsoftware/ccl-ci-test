#!/bin/bash

scriptdir=$(dirname "$0")
${scriptdir}/../../../framework/build/mac/codesign.sh "$@"