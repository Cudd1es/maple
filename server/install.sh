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

# Determine the config file path Squid actually reads
# Squid via Homebrew uses: $(brew --prefix)/etc/squid.conf (file, NOT a subdirectory)
BREW_PREFIX="$(brew --prefix)"
SQUID_CONF="$BREW_PREFIX/etc/squid.conf"

# Backup original config
if [[ -f "$SQUID_CONF" ]]; then
    cp "$SQUID_CONF" "$SQUID_CONF.backup.$(date +%Y%m%d%H%M%S)"
    echo "Original config backed up."
fi

# Copy our config (replacing the default Squid config)
cp "$SCRIPT_DIR/squid.conf" "$SQUID_CONF"

# Update log paths for the current Homebrew prefix
LOG_DIR="$BREW_PREFIX/var/log/squid"
if [[ "$LOG_DIR" != "/usr/local/var/log/squid" ]]; then
    sed -i '' "s|/usr/local/var/log/squid|$LOG_DIR|g" "$SQUID_CONF"
fi
mkdir -p "$LOG_DIR"

echo "Config installed to $SQUID_CONF"

# Verify config is valid
echo "Validating config..."
if "$BREW_PREFIX/sbin/squid" -k parse 2>&1 | grep -qi 'error\|fatal'; then
    echo "WARNING: Config validation reported errors. Check above output."
else
    echo "Config validation passed."
fi

# Initialize cache
"$BREW_PREFIX/sbin/squid" -z 2>/dev/null || true

# Restart Squid to load new config (start if not running)
echo "Restarting Squid..."
brew services restart squid

echo ""
echo "=== Installation Complete ==="
echo "Tailscale IP: $TAILSCALE_IP"
echo ""
echo "Next steps:"
echo "  1. On your client Mac, run setup and enter: $TAILSCALE_IP"
echo ""
echo "To enable Exit Node (for global mode):"
echo "  $SCRIPT_DIR/setup_exit_node.sh"
