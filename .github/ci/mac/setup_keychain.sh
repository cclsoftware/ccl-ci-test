#!/usr/bin/env bash
set -euo pipefail

import_certificate ()
{
    local CERTIFICATE_BASE64="$1"
    local CERTIFICATE_PASSWORD="$2"
    local CERTIFICATE_FILE="${TMPDIR%/}/certificate.$RANDOM.p12"
    echo -n "$CERTIFICATE_BASE64" | base64 -D -o "$CERTIFICATE_FILE"
    security import "$CERTIFICATE_FILE" -P "$CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN_PATH"
}

# create temporary keychain and make default
KEYCHAIN_PATH=$TMPDIR/signing.keychain-db
security create-keychain -p "$APPLE_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security set-keychain-settings "$KEYCHAIN_PATH" # disable automatic lock
security list-keychains -d user -s "$KEYCHAIN_PATH" # add to search list
security default-keychain -d user -s "$KEYCHAIN_PATH"

# import Developer ID certificate to keychain
import_certificate "$APPLE_DEVELOPERID_CERTIFICATE_BASE64" "$APPLE_DEVELOPERID_CERTIFICATE_P12_PASSWORD"

# import Mac Developer certificate to keychain
import_certificate "$APPLE_DEVELOPMENT_CERTIFICATE_BASE64" "$APPLE_DEVELOPMENT_CERTIFICATE_P12_PASSWORD"

# import Mac Distribution certificate to keychain
import_certificate "$APPLE_DISTRIBUTION_CERTIFICATE_BASE64" "$APPLE_DISTRIBUTION_CERTIFICATE_P12_PASSWORD"

# allow private key access and unlock
security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$APPLE_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"
security unlock-keychain -p "$APPLE_KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH"

# write AppStore API Key 
echo -n "$APPLE_API_KEY_BASE64" | base64 -D -o "$HOME/$APPLE_API_KEY_FILENAME"

# github ssh key (optional)
if [[ -n "${CCLGITDEV_SSH_KEY:-}" ]]; then
    echo -n "$CCLGITDEV_SSH_KEY" | base64 -D -o "$HOME/.ssh/cclgitdev_github"
    chmod 600 "$HOME/.ssh/cclgitdev_github"
fi