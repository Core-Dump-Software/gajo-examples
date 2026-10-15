#!/usr/bin/env bash
# Pro: shorten with your own code, served at https://gajo.io/c/<code>.
# Usage: ./custom-code.sh <url> <code>
# A code another account holds answers 409 Conflict.
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }
# JSON-escape a value for the request body
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

url="${1:?Usage: ./custom-code.sh <url> <code>}"
code="${2:?Usage: ./custom-code.sh <url> <code>}"

curl -sS --fail-with-body -X POST "$API/shorten" \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"url\": $(json "$url"), \"customCode\": $(json "$code")}" | pretty
