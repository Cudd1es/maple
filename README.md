# Maple

Route traffic through a remote server to access geo-restricted websites and services.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.


## How It Works

```
Client  ----Tailscale----->  Server  ----->  Internet
  |                            |
  |                            |
  |-- PAC split routing        |-- Squid proxy (:3128)
  |   (via local HTTP server)  |
  |-- Global mode              |-- Tailscale Exit Node
```

**Three modes:**
- **Global mode**: All traffic goes through the server (for Zoom/Teams/API calls)
- **Split mode** (default): Only configured domains go through the server (served via local PAC server)
- **Off**: All proxying disabled, direct connection restored

## Quick Start

### 1. Server (remote machine)

```bash
./server/install.sh        # Install Squid proxy
./server/start.sh          # Start the proxy
./server/setup_exit_node.sh  # Enable exit node (for global mode)
```

Approve the exit node in the [Tailscale admin console](https://login.tailscale.com/admin/machines).

### 2. Client (your local machine)

```bash
./client/setup.sh          # Interactive setup
```

## Usage

```bash
maple status              # Check status, connectivity, and latency
maple test                # Run full connectivity test
maple ping                # Measure latency to server
maple speed               # Measure download speed via proxy

maple global              # Enable global mode (all traffic via server)
maple split               # Enable split mode (domains.txt only)
maple off                 # Disable all proxying

maple list                # View proxied domains
maple add example.com     # Add a domain
maple remove example.com  # Remove a domain
```

## Pre-configured Domains

| Category | Domains |
|----------|---------|
| Search & Email | google.com, gmail.com, youtube.com |
| AI Services | openai.com, claude.ai, anthropic.com |
| Video Conferencing | zoom.us, teams.microsoft.com, meet.google.com |
| Coding Platforms | hackerrank.com, coderpad.io, leetcode.com |
| Social | twitter.com, instagram.com, reddit.com, discord.com |
| Gaming | steampowered.com, steamcommunity.com |
| Development | github.com, stackoverflow.com, npmjs.com |

Edit `client/domains.txt` to customize.

## Documentation

- [English User Guide](docs/USAGE_EN.md)
- [Chinese User Guide / 中文使用指南](docs/USAGE_CN.md)
