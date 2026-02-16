#!/usr/bin/env bash
set -euo pipefail

echo "Starting Squid proxy..."
brew services start squid
echo "Squid proxy started on port 3128"

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "unknown")
echo "Accessible at: $TAILSCALE_IP:3128"
