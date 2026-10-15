#!/usr/bin/env bash
# Pro: a link that opens your app, falling back to a web page (App Store, Google Play, or your site)
# when the app isn't installed.
# Usage: ./deep-link.sh <appUrl> <fallbackUrl>
# Example: ./deep-link.sh myapp://product/42 https://apps.apple.com/app/id123456789
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }
# JSON-escape a value for the request body
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

app_url="${1:?Usage: ./deep-link.sh <appUrl> <fallbackUrl>}"
fallback="${2:?Usage: ./deep-link.sh <appUrl> <fallbackUrl>}"

curl -sS --fail-with-body -X POST "$API/shorten" \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"url\": $(json "$app_url"), \"fallbackUrl\": $(json "$fallback")}" | pretty
