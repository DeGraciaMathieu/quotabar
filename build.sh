#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

APP=QuotaBar.app

swift build -c release

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/QuotaBar "$APP/Contents/MacOS/"
cp Resources/Info.plist "$APP/Contents/"
codesign --force -s - "$APP"

echo "$APP prêt : open $APP"
