#!/usr/bin/env bash
# Pro: shorten up to 100 links in one request. Usage: ./batch.sh <url> [url ...]
# Each item succeeds or fails on its own; every created link counts toward your monthly allowance.
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }
# JSON-escape a value for the request body
json() { local s=${1//\\/\\\\}; s=${s//\"/\\\"}; printf '"%s"' "$s"; }

[ $# -ge 1 ] || { echo "Usage: ./batch.sh <url> [url ...]" >&2; exit 1; }
items=""
for url in "$@"; do
  items="${items:+$items, }{\"url\": $(json "$url")}"
done

curl -sS --fail-with-body -X POST "$API/shorten/batch" \
  -H "x-api-key: $GAJO_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"urls\": [$items]}" | pretty
