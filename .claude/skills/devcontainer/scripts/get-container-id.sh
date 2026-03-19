#!/usr/bin/env bash
# Prints the devcontainer container ID for the current project.
# Exit code 0 + container ID on stdout if found, non-zero otherwise.

set -euo pipefail

PROJECT_ROOT="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"

CONTAINER_ID="$(docker ps -q --filter "label=devcontainer.local_folder=${PROJECT_ROOT}")"

if [ -z "$CONTAINER_ID" ]; then
  echo "No running devcontainer found for ${PROJECT_ROOT}" >&2
  echo "Start the devcontainer first (VS Code → 'Reopen in Container' or 'devcontainer up --workspace-folder ${PROJECT_ROOT}')." >&2
  exit 1
fi

echo "$CONTAINER_ID"
