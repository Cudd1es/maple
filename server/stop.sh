#!/usr/bin/env bash
set -euo pipefail

echo "Stopping Squid proxy..."
brew services stop squid
echo "Squid proxy stopped."
