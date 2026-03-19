#!/usr/bin/env bash
# Runs a command inside the project's devcontainer.
# Prefers `devcontainer exec` when available, falls back to `docker exec`.
# Usage: exec.sh <command> [args...]

set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: exec.sh <command> [args...]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

# Verify a container is running (exits with a friendly message if not)
CONTAINER_ID="$("$SCRIPT_DIR/get-container-id.sh")"

if command -v devcontainer >/dev/null 2>&1; then
  exec devcontainer exec --workspace-folder "$PROJECT_ROOT" -- "$@"
fi

# Detect remote workspace folder from the container's bind mount (requires jq).
# Falls back to /workspaces/<project-basename> convention if jq is absent.
if command -v jq >/dev/null 2>&1; then
  WORKSPACE_DIR="$(docker inspect "$CONTAINER_ID" \
    | jq -r --arg src "$PROJECT_ROOT" \
      '.[0].Mounts[] | select(.Type == "bind" and .Source == $src) | .Destination')"
fi

if [ -z "${WORKSPACE_DIR:-}" ] || [ "$WORKSPACE_DIR" = "null" ]; then
  WORKSPACE_DIR="/workspaces/$(basename "$PROJECT_ROOT")"
fi

# Detect remote user from container metadata, default to the convention "node".
if command -v jq >/dev/null 2>&1; then
  REMOTE_USER="$(docker inspect "$CONTAINER_ID" \
    | jq -r '
      .[0].Config.Labels["devcontainer.metadata"] // empty
      | fromjson? // []
      | [.[] | select(.remoteUser)] | if length > 0 then last.remoteUser else empty end
    ')" || true
fi

if [ -z "${REMOTE_USER:-}" ] || [ "$REMOTE_USER" = "null" ]; then
  REMOTE_USER="node"
fi

exec docker exec -u "$REMOTE_USER" -w "$WORKSPACE_DIR" "$CONTAINER_ID" "$@"
