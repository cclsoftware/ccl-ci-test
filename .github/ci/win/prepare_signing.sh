#!/usr/bin/env bash
set -euo pipefail

scriptdir=$(dirname "$0")
signfile="${scriptdir}/../../../build/signing/ccl/signing.cmake"

echo "set (SIGNING_AZURE_KEYVAULT_WIN \"${{ secrets.SIGNING_AZURE_KEYVAULT_WIN }}\")" >> ${signfile}
set (SIGNING_AZURE_CLIENTID_WIN \"${{ secrets.SIGNING_AZURE_CLIENTID_WIN }}\")
set (SIGNING_AZURE_TENANTID_WIN \"${{ secrets.SIGNING_AZURE_TENANTID_WIN }}\")
set (SIGNING_CERTIFICATE_WIN \"${{ secrets.SIGNING_CERTIFICATE_WIN }}\")
set (SIGNING_TIMESTAMP_SERVER_WIN "${SIGNING_TIMESTAMP_SERVER_WIN}")
