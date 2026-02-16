#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.maple_config"

source "$CONFIG_FILE"

if [[ -z "${MAPLE_SERVER_IP:-}" ]]; then
    echo "ERROR: MAPLE_SERVER_IP not set."
    exit 1
fi

echo "Enabling global mode (all traffic via server)..."
sudo tailscale set --exit-node="$MAPLE_SERVER_IP"
echo "Global mode ON. All traffic now routes through server."
echo "Run 'maple off' to disable."
