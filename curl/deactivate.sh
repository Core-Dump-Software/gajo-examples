#!/usr/bin/env bash
# Deactivate a link so it stops redirecting. Usage: ./deactivate.sh <shortCode>
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }

code="${1:?Usage: ./deactivate.sh <shortCode>}"

curl -sS --fail-with-body -X DELETE "$API/urls/$code" \
  -H "x-api-key: $GAJO_API_KEY" | pretty
