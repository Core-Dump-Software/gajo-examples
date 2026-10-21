#!/usr/bin/env bash
# Turn a deactivated link back on. Usage: ./reactivate.sh <shortCode>
# Expired links, links flagged as unsafe, and unassigned custom codes answer 409 with the reason.
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }

code="${1:?Usage: ./reactivate.sh <shortCode>}"

curl -sS --fail-with-body -X POST "$API/urls/$code/reactivate" \
  -H "x-api-key: $GAJO_API_KEY" | pretty
