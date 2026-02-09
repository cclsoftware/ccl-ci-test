#!/bin/bash
set -e

TEAMID=DAVK35GANN
APP_NAME="CCL Demo"
BUILD_PATH="build/cmake/ios/Release"

if [ $1 ]; then
	BUILD_PATH=$1
fi

# create .xcarchive
mkdir -p "${APP_NAME}.xcarchive/Products/Applications"
mkdir -p "${APP_NAME}.xcarchive/dSYMs"
mkdir -p "${APP_NAME}.xcarchive/SCMBlueprint"
cp -R -p "${BUILD_PATH}/${APP_NAME}.app" "${APP_NAME}.xcarchive/Products/Applications"
BUNDLEID=`/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" "${APP_NAME}.xcarchive/Products/Applications/${APP_NAME}.app/Info.plist"`
BUNDLEVERSION=`/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${APP_NAME}.xcarchive/Products/Applications/${APP_NAME}.app/Info.plist"`
BUNDLESHORTVERSIONSTRING=`/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${APP_NAME}.xcarchive/Products/Applications/${APP_NAME}.app/Info.plist"`

/usr/libexec/PlistBuddy -c "add ApplicationProperties:ApplicationPath string Applications/${APP_NAME}.app" "${APP_NAME}.xcarchive/Info.plist"
/usr/libexec/PlistBuddy -c "add ApplicationProperties:CFBundleIdentifier string ${BUNDLEID}" "${APP_NAME}.xcarchive/Info.plist"
/usr/libexec/PlistBuddy -c "add ApplicationProperties:CFBundleVersion string ${BUNDLEVERSION}" "${APP_NAME}.xcarchive/Info.plist"
/usr/libexec/PlistBuddy -c "add ApplicationProperties:CFBundleShortVersionString string ${BUNDLESHORTVERSIONSTRING}" "${APP_NAME}.xcarchive/Info.plist"

# export archive for .ipa (distribution certificate)
/usr/libexec/PlistBuddy -c "add destination string export" ExportOptions.plist
/usr/libexec/PlistBuddy -c "add method string app-store" ExportOptions.plist
/usr/libexec/PlistBuddy -c "add manageAppVersionAndBuildNumber bool YES" ExportOptions.plist
/usr/libexec/PlistBuddy -c "add signingStyle string automatic" ExportOptions.plist
/usr/libexec/PlistBuddy -c "add teamID string ${TEAMID}" ExportOptions.plist
/usr/libexec/PlistBuddy -c "add uploadSymbols bool YES" ExportOptions.plist
xcrun xcodebuild archive -exportArchive -allowProvisioningUpdates -authenticationKeyPath "$APPLE_API_KEYPATH" -authenticationKeyID "$APPLE_API_KEYID"  -authenticationKeyIssuerID "$APPLE_API_ISSUER" -archivePath "${APP_NAME}.xcarchive" -exportOptionsPlist ExportOptions.plist -exportPath "${APP_NAME}.archive"
rm ExportOptions.plist

artifactsdir="build/deployment/ios"
mkdir -p "${artifactsdir}"

mv "${APP_NAME}.archive/"*.ipa "${artifactsdir}"
rm -rf "${APP_NAME}.archive"

rm -rf "${APP_NAME}.xcarchive"
