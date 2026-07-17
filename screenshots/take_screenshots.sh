#!/bin/bash
# Logicky App Store screenshot capture script
# Target: iPhone 17 Pro Max (6.7" / 1290x2796)
# Usage: ./screenshots/take_screenshots.sh

set -e

DEVICE_NAME="iPhone 17 Pro Max"
SCHEME="Logicky"
PROJECT="Logicky.xcodeproj"
OUTPUT_DIR="$(dirname "$0")/output"
APP_BUNDLE_ID="co.jp.oiroba.logicky"

mkdir -p "$OUTPUT_DIR"

# Get simulator UDID
UDID=$(xcrun simctl list devices available | grep "$DEVICE_NAME" | grep -E -o '[0-9A-F-]{36}' | head -1)
if [ -z "$UDID" ]; then
  echo "Error: Simulator '$DEVICE_NAME' not found."
  exit 1
fi
echo "Using simulator: $DEVICE_NAME ($UDID)"

# Build for simulator
echo "Building..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration Debug build \
  CONFIGURATION_BUILD_DIR=/tmp/logicky_build \
  > /tmp/logicky_build.log 2>&1 || { echo "Build failed. See /tmp/logicky_build.log"; exit 1; }

APP_PATH=$(find /tmp/logicky_build -name "Logicky.app" | head -1)
echo "App: $APP_PATH"

# Boot simulator and install app
xcrun simctl boot "$UDID" 2>/dev/null || true
open -a Simulator --args -CurrentDeviceUDID "$UDID"
sleep 3

xcrun simctl install "$UDID" "$APP_PATH"
echo "App installed."

take_screenshot() {
  local name="$1"
  local delay="$2"
  sleep "$delay"
  xcrun simctl io "$UDID" screenshot "$OUTPUT_DIR/${name}.png"
  echo "Captured: ${name}.png"
}

# Launch app and capture Home screen
xcrun simctl launch "$UDID" "$APP_BUNDLE_ID"
take_screenshot "01_home" 3

echo ""
echo "Manual steps required for remaining screenshots:"
echo "  02_diagnostic_quiz    — Start the Logicky diagnostic and show a question with feedback"
echo "  03_diagnostic_result  — Complete the diagnostic and show rank / 3-axis result"
echo "  04_dictionary_detail  — Open a thinking method (e.g., 三段論法) in the dictionary"
echo "  05_unit_quiz          — Start a unit quiz and show a 4-choice question"
echo ""
echo "After manually navigating to each screen, run:"
echo "  xcrun simctl io $UDID screenshot screenshots/output/<name>.png"
echo ""
echo "Screenshots saved to: $OUTPUT_DIR"
echo ""
echo "For automated capture, add UI test targets with XCTest screenshot APIs."
