#!/usr/bin/env bash
# List your links, newest first. Usage: ./list-links.sh [page] [limit]
# page starts at 1; limit is 1-1000 (default 100). The total is in the X-Total-Count header.
set -euo pipefail
: "${GAJO_API_KEY:?Set GAJO_API_KEY to your Gajo API key (free: https://gajo.io/account/signup)}"
API="${GAJO_API_URL:-https://gajo.io/api/v1}"
pretty() { if command -v jq >/dev/null; then jq .; else cat; echo; fi; }

page="${1:-1}"
limit="${2:-100}"
headers=$(mktemp)
trap 'rm -f "$headers"' EXIT

curl -sS --fail-with-body "$API/urls?page=$page&limit=$limit" \
  -H "x-api-key: $GAJO_API_KEY" \
  -D "$headers" | pretty

total=$(grep -i '^x-total-count:' "$headers" | tr -d '\r' | awk '{print $2}')
echo "Page $page, $limit per page, ${total:-?} links in total" >&2
