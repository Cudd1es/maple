# Maple User Guide

Maple routes your internet traffic through a remote server using [Tailscale](https://tailscale.com) and [Squid](http://www.squid-cache.org/) proxy. It provides two routing modes and a simple CLI to manage everything.

## Architecture

```
Client  ----Tailscale----->  Server  ----->  Internet
  |                            |
  |-- PAC split routing        |-- Squid proxy (:3128)
  |-- Global mode              |-- Tailscale Exit Node
```

- **Split mode** (default): Only configured domains route through the server (browser only via PAC file)
- **Global mode**: All traffic from all apps routes through the server (uses Tailscale exit node)

## Prerequisites

Both machines need:
- macOS
- [Tailscale](https://tailscale.com/download) installed and connected
- [Homebrew](https://brew.sh) installed

## Setup

### Server

The server is the remote machine that will relay your traffic.

```bash
# Install Squid proxy
./server/install.sh

# Start the proxy
./server/start.sh

# Enable exit node (required for global mode)
./server/setup_exit_node.sh
```

After running `setup_exit_node.sh`, approve the exit node in the [Tailscale admin console](https://login.tailscale.com/admin/machines).

### Client

The client is your local machine.

```bash
# Run interactive setup
./client/setup.sh
```

This will:
1. Ask for your server's Tailscale IP
2. Generate the PAC proxy file
3. Configure macOS auto-proxy settings
4. Install the `maple` command

## CLI Commands

### Status & Diagnostics

| Command | Description |
|---------|-------------|
| `maple status` | Show current mode, connectivity, and latency |
| `maple test` | Run full connectivity test (Tailscale, Squid, HTTP/HTTPS) |
| `maple ping` | Measure latency to server (Tailscale + ICMP) |
| `maple speed` | Measure download speed via proxy vs direct |

### Mode Switching

| Command | Description |
|---------|-------------|
| `maple on` | Enable global mode (all traffic via server) |
| `maple off` | Disable global mode (back to split routing) |

### Domain Management

| Command | Description |
|---------|-------------|
| `maple list` | Show all proxied domains |
| `maple add <domain>` | Add a domain to the proxy list |
| `maple remove <domain>` | Remove a domain from the proxy list |

### Other

| Command | Description |
|---------|-------------|
| `maple setup` | Re-run initial setup |
| `maple help` | Show help |

## When to Use Each Mode

| Scenario | Mode | Action |
|----------|------|--------|
| Browsing proxied domains (Google, YouTube, etc.) | Split (default) | No action needed |
| Video call (Zoom/Teams/Meet) | Global | `maple on` before the call |
| Using external APIs (OpenAI, etc.) | Global | `maple on` |
| Coding test (HackerRank, CoderPad) | Split (default) | No action needed |
| Done with call/interview | Split | `maple off` |

## Domain Management

Domains are stored in `client/domains.txt`. Each line is a domain name, with comment sections marked by `# === Section Name ===`.

```bash
# Add a domain
maple add netflix.com

# Remove a domain
maple remove netflix.com

# View current list
maple list
```

You can also edit `client/domains.txt` directly, then regenerate the PAC file:

```bash
bash client/generate_pac.sh
```

## Network Diagnostics

### Latency Check

```bash
maple ping
```

Shows:
- **Tailscale ping**: Measures the Tailscale tunnel latency (DERP relay vs direct connection)
- **ICMP ping**: Traditional 5-packet ping with min/avg/max statistics

### Speed Test

```bash
maple speed
```

Downloads test files through the proxy and directly, showing:
- 1 MB and 10 MB download speeds via proxy (in Mbps)
- 1 MB direct download speed for comparison

### Quick Status

```bash
maple status
```

Shows mode, connectivity, latency, and domain count at a glance. The latency value is color-coded:
- **Green**: < 100 ms
- **Yellow**: 100-250 ms
- **Red**: > 250 ms

## Troubleshooting

**Proxy unreachable:**
1. Check Tailscale: `tailscale status`
2. Verify Squid is running on the server: `brew services list`
3. Run `maple test` for step-by-step diagnosis

**Slow speeds:**
- Use split mode for daily browsing (not global)
- Run `maple speed` to measure actual throughput
- Check `maple ping` for high latency

**Domain not proxied:**
- Add it: `maple add domain.com`
- Verify: `maple list`

**Global mode not working:**
- Ensure exit node is approved in [Tailscale admin console](https://login.tailscale.com/admin/machines)
- Run `maple test` to check connectivity
