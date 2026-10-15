#!/usr/bin/env bash
# Your plan, links created this month, and how many are left. Usage: ./usage.sh
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }

curl -sS --fail-with-body "$API/usage" \
  -H "x-api-key: $GAJO_API_KEY" | pretty
