#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/.maple_config"

echo "=== Maple Client Setup ==="
echo ""

# Check Tailscale
if ! command -v tailscale &>/dev/null; then
    echo "ERROR: Tailscale is not installed."
    echo "Install from: https://tailscale.com/download"
    exit 1
fi

TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || true)
if [[ -z "$TAILSCALE_IP" ]]; then
    echo "ERROR: Tailscale is not connected. Run 'tailscale up' first."
    exit 1
fi
echo "Your Tailscale IP: $TAILSCALE_IP"
echo ""

# Get server Tailscale IP
read -rp "Enter the Tailscale IP of your Canada Mac: " SERVER_IP

# Validate IP format
if ! echo "$SERVER_IP" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "ERROR: Invalid IP address format."
    exit 1
fi

# Test connectivity
echo ""
echo -n "Testing connection to $SERVER_IP... "
if ping -c 1 -W 3 "$SERVER_IP" > /dev/null 2>&1; then
    echo "OK"
else
    echo "FAILED"
    echo "WARNING: Cannot reach $SERVER_IP. Make sure both machines are on Tailscale."
    read -rp "Continue anyway? (y/N) " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        exit 1
    fi
fi

# Save config
cat > "$CONFIG_FILE" << EOF
MAPLE_SERVER_IP=$SERVER_IP
MAPLE_PROXY_PORT=3128
EOF
echo "Config saved."

# Generate PAC file
echo ""
bash "$SCRIPT_DIR/generate_pac.sh"

# Configure macOS proxy settings
echo ""
echo "Configuring macOS proxy settings..."

# Get active network service
ACTIVE_SERVICE=""
while IFS= read -r service; do
    [[ "$service" == "*"* ]] && continue
    [[ -z "$service" ]] && continue
    if networksetup -getinfo "$service" 2>/dev/null | grep -q "IP address: [0-9]"; then
        ACTIVE_SERVICE="$service"
        break
    fi
done < <(networksetup -listallnetworkservices)

if [[ -z "$ACTIVE_SERVICE" ]]; then
    echo "WARNING: Could not detect active network."
    echo "You may need to set proxy manually:"
    echo "  System Settings > Network > [Your Network] > Proxies"
    echo "  Set auto proxy config URL to: file://$SCRIPT_DIR/proxy.pac"
else
    echo "Active network: $ACTIVE_SERVICE"
    networksetup -setautoproxyurl "$ACTIVE_SERVICE" "file://$SCRIPT_DIR/proxy.pac"
    networksetup -setautoproxystate "$ACTIVE_SERVICE" on
    echo "Auto proxy configured for '$ACTIVE_SERVICE'"
fi

# Symlink maple to /usr/local/bin
echo ""
MAPLE_CMD="$SCRIPT_DIR/maple"
if [[ -d /usr/local/bin ]] && [[ -w /usr/local/bin ]]; then
    ln -sf "$MAPLE_CMD" /usr/local/bin/maple
    echo "'maple' command installed to /usr/local/bin/maple"
elif [[ -d /opt/homebrew/bin ]] && [[ -w /opt/homebrew/bin ]]; then
    ln -sf "$MAPLE_CMD" /opt/homebrew/bin/maple
    echo "'maple' command installed to /opt/homebrew/bin/maple"
else
    echo "To install 'maple' command globally, run:"
    echo "  sudo ln -sf $MAPLE_CMD /usr/local/bin/maple"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Quick start:"
echo "  maple status    - Check connectivity"
echo "  maple test      - Run full connectivity test"
echo "  maple on        - Enable global mode (for interviews/apps)"
echo "  maple off       - Back to split routing"
echo "  maple list      - View proxied domains"
echo "  maple add <domain> - Add a domain to proxy list"
