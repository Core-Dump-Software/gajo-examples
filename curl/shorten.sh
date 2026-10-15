#!/usr/bin/env bash
# Shorten a link. Usage: ./shorten.sh <url> [lifetimeDays]
# lifetimeDays is optional and capped by your plan (Free 60, Basic 120, Pro unlimited).
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }
# JSON-escape a value for the request body
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

url="${1:?Usage: ./shorten.sh <url> [lifetimeDays]}"
body="{\"url\": $(json "$url")${2:+, \"lifetimeDays\": $2}}"

curl -sS --fail-with-body -X POST "$API/shorten" \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$body" | pretty
