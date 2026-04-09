#!/usr/bin/env bash
# Usage: scripts/submit_test.sh <path-to-png> [puzzle_id] [puzzle_version] [install_id]
# Submits a solution PNG to the local scoreserver and pretty-prints the response.
#
# Requires: curl, base64, python3 (for JSON pretty-print)
# The server must be running: go run ./cmd/server --config config.local.yaml
# The DB must have the target puzzle row seeded.

set -euo pipefail

PNG_FILE="${1:?Usage: $0 <path-to-png> [puzzle_id] [puzzle_version] [install_id]}"
PUZZLE_ID="${2:-1}"
PUZZLE_VERSION="${3:-v1}"
INSTALL_ID="${4:-test-install-local}"
HOST="${SCORESERVER_HOST:-http://localhost:8080}"

if [ ! -f "$PNG_FILE" ]; then
  echo "Error: file not found: $PNG_FILE" >&2
  exit 1
fi

ENCODED=$(base64 < "$PNG_FILE" | tr -d '\n')

PAYLOAD=$(printf '{"puzzle_id":%d,"puzzle_version":"%s","install_id":"%s","client_platform":"dev","solution_png_base64":"%s"}' \
  "$PUZZLE_ID" "$PUZZLE_VERSION" "$INSTALL_ID" "$ENCODED")

echo "Submitting $PNG_FILE to $HOST ..."
curl -s -X POST "$HOST/api/v1/submit-solution" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | python3 -m json.tool
