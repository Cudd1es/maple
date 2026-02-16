#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAINS_FILE="$SCRIPT_DIR/domains.txt"
PAC_FILE="$SCRIPT_DIR/proxy.pac"
CONFIG_FILE="$SCRIPT_DIR/.maple_config"

# Load server IP from config
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Config file not found. Run 'maple setup' first."
    exit 1
fi
source "$CONFIG_FILE"

if [[ -z "${MAPLE_SERVER_IP:-}" ]]; then
    echo "ERROR: MAPLE_SERVER_IP not set in config."
    exit 1
fi

PROXY="PROXY ${MAPLE_SERVER_IP}:${MAPLE_PROXY_PORT:-3128}"

# Read domains (skip comments and blank lines)
DOMAINS=()
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/#.*//' | xargs)
    [[ -z "$line" ]] && continue
    DOMAINS+=("$line")
done < "$DOMAINS_FILE"

if [[ ${#DOMAINS[@]} -eq 0 ]]; then
    echo "WARNING: No domains found in $DOMAINS_FILE"
fi

# Generate PAC file
cat > "$PAC_FILE" << 'HEADER'
// Maple Proxy - Auto-generated PAC file
// Do not edit manually. Edit domains.txt and run generate_pac.sh

function FindProxyForURL(url, host) {
    // Strip www prefix for matching
    if (host.substring(0, 4) === "www.") {
        host = host.substring(4);
    }

    var proxyDomains = [
HEADER

# Add domains
for i in "${!DOMAINS[@]}"; do
    domain="${DOMAINS[$i]}"
    if [[ $i -lt $((${#DOMAINS[@]} - 1)) ]]; then
        echo "        \"$domain\"," >> "$PAC_FILE"
    else
        echo "        \"$domain\"" >> "$PAC_FILE"
    fi
done

cat >> "$PAC_FILE" << FOOTER
    ];

    for (var i = 0; i < proxyDomains.length; i++) {
        if (dnsDomainIs(host, proxyDomains[i]) ||
            dnsDomainIs(host, "." + proxyDomains[i])) {
            return "${PROXY}";
        }
    }

    return "DIRECT";
}
FOOTER

echo "PAC file generated: $PAC_FILE"
echo "Domains configured: ${#DOMAINS[@]}"
