#!/usr/bin/env bash
# Permanently delete a link: its destination and click history are erased and it can't be undone.
# The code is never given to anyone else. To only switch a link off, use deactivate.sh. Usage: ./delete.sh <shortCode>
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }

code="${1:?Usage: ./delete.sh <shortCode>}"

curl -sS --fail-with-body -X DELETE "$API/urls/$code?permanent=true" \
  -H "x-api-key: $GAJO_API_KEY" | pretty
