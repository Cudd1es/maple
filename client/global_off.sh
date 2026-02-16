#!/usr/bin/env bash
set -euo pipefail

echo "Disabling global mode..."
sudo tailscale set --exit-node=
echo "Global mode OFF. Back to split routing only."
