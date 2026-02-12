#!/bin/bash
scriptdir=$(dirname "$0")

PRIVATEKEY=${scriptdir}/../../../build/signing/ccl/CCLAppStoreConnectDevAPIKey.p8
KEYID=8H6U6U863B
ISSUER=e5da5306-850d-45a9-b9aa-033495b9aa9d

${scriptdir}/../../../framework/build/mac/notarize.sh "$1" $PRIVATEKEY $KEYID $ISSUER