#!/usr/bin/env bash
# Pro: change where an existing link points, without changing the link.
# Usage: ./update-destination.sh <shortCode> <newUrl>
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }
# JSON-escape a value for the request body
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

code="${1:?Usage: ./update-destination.sh <shortCode> <newUrl>}"
new_url="${2:?Usage: ./update-destination.sh <shortCode> <newUrl>}"

curl -sS --fail-with-body -X PUT "$API/urls/$code" \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"originalUrl\": $(json "$new_url")}" | pretty
