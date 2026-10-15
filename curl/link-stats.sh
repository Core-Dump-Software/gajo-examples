#!/usr/bin/env bash
# Click stats for one link, bots excluded. Usage: ./link-stats.sh <shortCode>
# Free shows totals and the last 7 days; Basic and Pro add referrers, devices, countries, and regions.
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }

code="${1:?Usage: ./link-stats.sh <shortCode>}"

curl -sS --fail-with-body "$API/urls/$code/stats" \
  -H "x-api-key: $GAJO_API_KEY" | pretty
