#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Maple Proxy Server Setup ==="

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "ERROR: Homebrew is required. Install from https://brew.sh"
    exit 1
fi

# Check if Tailscale is running
if ! command -v tailscale &>/dev/null; then
    echo "ERROR: Tailscale is not installed."
    exit 1
fi

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || true)
if [[ -z "$TAILSCALE_IP" ]]; then
    echo "ERROR: Tailscale is not connected. Run 'tailscale up' first."
    exit 1
fi
echo "Tailscale IP: $TAILSCALE_IP"

# Install Squid
echo "Installing Squid..."
brew install squid

# Determine Squid config directory via Homebrew prefix
SQUID_CONF_DIR="$(brew --prefix)/etc/squid"
mkdir -p "$SQUID_CONF_DIR"

# Backup original config

if [[ -f "$SQUID_CONF_DIR/squid.conf" ]]; then
    cp "$SQUID_CONF_DIR/squid.conf" "$SQUID_CONF_DIR/squid.conf.backup.$(date +%Y%m%d%H%M%S)"
    echo "Original config backed up."
fi

# Copy our config
cp "$SCRIPT_DIR/squid.conf" "$SQUID_CONF_DIR/squid.conf"
echo "Config installed to $SQUID_CONF_DIR/squid.conf"

# Create log directory
LOG_DIR="$(brew --prefix)/var/log/squid"
if [[ "$LOG_DIR" != "/usr/local/var/log/squid" ]]; then
    # Update log paths in squid.conf for non-default prefix (e.g. Apple Silicon)
    sed -i '' "s|/usr/local/var/log/squid|$LOG_DIR|g" "$SQUID_CONF_DIR/squid.conf"
fi
mkdir -p "$LOG_DIR"

# Initialize cache
"$(brew --prefix)/sbin/squid" -z 2>/dev/null || true

echo ""
echo "=== Installation Complete ==="
echo "Tailscale IP: $TAILSCALE_IP"
echo ""
echo "Next steps:"
echo "  1. Start the proxy:  $SCRIPT_DIR/start.sh"
echo "  2. On your client Mac, run setup and enter: $TAILSCALE_IP"
echo ""
echo "To enable Exit Node (for global mode):"
echo "  $SCRIPT_DIR/setup_exit_node.sh"
