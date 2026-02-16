#!/usr/bin/env bash
set -euo pipefail

echo "=== Setting up Tailscale Exit Node ==="

# Enable IP forwarding (required for exit node)
echo "Enabling IP forwarding..."
sudo sysctl -w net.inet.ip.forwarding=1

# Make IP forwarding persistent across reboots
PLIST="/Library/LaunchDaemons/com.maple.ipforward.plist"
if [[ ! -f "$PLIST" ]]; then
    echo "Making IP forwarding persistent..."
    sudo tee "$PLIST" > /dev/null << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.maple.ipforward</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/sbin/sysctl</string>
        <string>-w</string>
        <string>net.inet.ip.forwarding=1</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
    sudo launchctl load "$PLIST"
fi

# Advertise as exit node
echo "Advertising as Tailscale exit node..."
sudo tailscale set --advertise-exit-node

echo ""
echo "=== Exit Node Setup Complete ==="
echo ""
echo "IMPORTANT: You must approve the exit node in the Tailscale admin console:"
echo "  https://login.tailscale.com/admin/machines"
echo ""
echo "Find this machine and enable 'Use as exit node' in the route settings."
