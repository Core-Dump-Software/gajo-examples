#!/usr/bin/env bash
# Pro: one short link for a mobile app. iPhones and iPads go to the App Store, Android devices to
# Google Play, and every other device sees a page with a QR code of the link. <otherwise> picks it:
#   mobile_only   "This link must be opened in a mobile browser."
#   store_links   both store URLs, written out in full
#   store_badges  the official App Store and Google Play badges under "Click below to download <app name>"
#                 (only for apps published in both stores)
# Usage: ./app-link.sh <app-store-url> <play-store-url> <otherwise> [app name]
# Before release, pass the TestFlight link (https://testflight.apple.com/join/...) and Google Play test link
# (https://play.google.com/apps/internaltest/... or /apps/testing/...) with store_links or mobile_only.
# The app name is looked up from the App Store when omitted.
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }
# JSON-escape a value for the request body
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

usage="Usage: ./app-link.sh <app-store-url> <play-store-url> <mobile_only|store_links|store_badges> [app name]"
ios="${1:?$usage}"
android="${2:?$usage}"
otherwise="${3:?$usage}"
name="${4:-}"

body="{\"iosUrl\": $(json "$ios"), \"androidUrl\": $(json "$android"), \"otherwise\": $(json "$otherwise")"
[ -n "$name" ] && body="$body, \"appName\": $(json "$name")"

curl -sS --fail-with-body -X POST "$API/app-links" \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$body}" | pretty
